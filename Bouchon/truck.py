import time
import RPi.GPIO as GPIO
import threading
from picamera import PiCamera



class Truck:
    def __init__(self):

        self.TRUCK_IS_MOVING = False

        self.ALARM_ACTIVATED = False

        self.ALARM_DEACTIVATED = False

        self.camera = PiCamera()

        self.GAS_LEVEL = 0

        self.SEND_NOTIFICATION = False

        self.PIN = {
            'FLASH': 21,
            'ALARM': 17,
            'ULTRA_SONIC': [19,26],
            'LOCKER_MOTOR': [11,9,10,22],
            'TRAP_MOTOR': [0,5,6,13]
        }
        
        self.INI_TAB = {
            self.PIN['FLASH'],
            self.PIN['ALARM'],
            self.PIN['ULTRA_SONIC'][0],
            self.PIN['LOCKER_MOTOR'][0],
            self.PIN['LOCKER_MOTOR'][1],
            self.PIN['LOCKER_MOTOR'][2],
            self.PIN['LOCKER_MOTOR'][3],
            self.PIN['TRAP_MOTOR'][0],
            self.PIN['TRAP_MOTOR'][1],
            self.PIN['TRAP_MOTOR'][2],
            self.PIN['TRAP_MOTOR'][3]
        }

        self.MOTOR_SEQ = [
            [1,0,0,0],
            [1,1,0,0],
            [0,1,0,0],
            [0,1,1,0],
            [0,0,1,0],
            [0,0,1,1],
            [0,0,0,1],
            [1,0,0,1]
        ]

    '''-------------------------------------------'''
    '''  ---------- Primary functions ----------  '''
    '''-------------------------------------------'''

    def initialization(self):
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)

        for i in self.INI_TAB:
            GPIO.setup(i, GPIO.OUT)
            GPIO.output(i, 0)

        GPIO.setup(self.PIN['ULTRA_SONIC'][1], GPIO.IN)

        print("Truck initialized")

    def activateMotor(self, angle, motor):
            
        final_angle = angle  # * int(64 / 45)
        if final_angle < 0:
            angle_range = -final_angle
        else:
            angle_range = final_angle

        for i in range(angle_range):
            for halfstep in range(8):
                for pin in range(4):
                    if final_angle > 0:
                        GPIO.output(motor[pin], self.MOTOR_SEQ[halfstep][pin])
                    elif final_angle < 0:
                        GPIO.output(motor[pin], self.MOTOR_SEQ[7 - halfstep][pin])
                    time.sleep(0.00025)

        for i in motor:
            GPIO.setup(i, GPIO.OUT)
            GPIO.output(i, 0)

    '''---------------------------------------------'''
    '''  ---------- Secondary functions ----------  '''
    '''---------------------------------------------'''

    '''  ----- Trap functions -----  '''
    def trapState(self):
        f = open('trap-state.txt', 'r')
        state = f.read()
        f.close()
        return state

    def checkTrap(self, action):
        
        state = self.trapState()

        if state != 'moving':
            if action == 'open' and state == 'open':
                return 0
            elif action == 'close' and state == 'close':
                return 0
            else:
                return 1
        else:
            return 0
        
    def setTrapState(self, state):
        f = open('trap-state.txt', 'w')
        f.write(state)
        f.close()

    # TODO setup de la trappe
    # TODO calibration de la trappe en cas de problème

    def openTrap(self):
        if self.checkTrap('open'):
            self.setTrapState('moving')
            self.activateMotor(145, self.PIN['LOCKER_MOTOR'])
            self.activateMotor(124, self.PIN['TRAP_MOTOR'])
            self.setTrapState('open')

    def closeTrap(self):
        if self.checkTrap('close'):
            self.setTrapState('moving')
            self.activateMotor(-124, self.PIN['TRAP_MOTOR'])
            self.activateMotor(-145, self.PIN['LOCKER_MOTOR'])
            self.setTrapState('close')

    '''  ----- Gas tank functions -----  '''
    def gasLevel(self, sleep):  # min = 0.06

        startImpulsion = 0
        endImpulsion = 1627110587

        GPIO.output(self.PIN['ULTRA_SONIC'][0], 1)
        time.sleep(0.00001)
        GPIO.output(self.PIN['ULTRA_SONIC'][0], 0)

        while GPIO.input(self.PIN['ULTRA_SONIC'][1]) == 0:
            startImpulsion = time.time()

        while GPIO.input(self.PIN['ULTRA_SONIC'][1]) == 1:
            endImpulsion = time.time()

        distance = round((endImpulsion - startImpulsion) * 340 * 100 / 2, 1)
        time.sleep(sleep)

        self.GAS_LEVEL = distance

        return distance

    def getInitialGasLevel(self):
        counter = 0
        for i in range(100):
            counter += self.gasLevel(0.06)
        return (counter / 100)


    '''  ----- Alarm functions -----  '''
    def startBuzzer(self):
        while self.ALARM_ACTIVATED == True:
            GPIO.output(self.PIN['ALARM'], 1)
            time.sleep(0.05)
            GPIO.output(self.PIN['ALARM'], 0)
            time.sleep(0.05)

    def startFlash(self):
        while self.ALARM_ACTIVATED == True:
            GPIO.output(self.PIN['FLASH'], 1)
            time.sleep(1)
            GPIO.output(self.PIN['FLASH'], 0)
            time.sleep(1)

    def takePicture(self):
        self.camera.start_preview()

        for i in range(5):
            self.camera.capture('/home/pi/Safe-Truck_v3/image/image%s.jpg' % i)
            print("Photo:", i)
            time.sleep(1.45)

        self.camera.stop_preview()

        

    def alarm(self):
        
        while True:
            
            while  self.trapState() == 'open' or self.ALARM_ACTIVATED == True:
                self.GAS_LEVEL = self.gasLevel(1)
                print("Stand-by Current level : ", self.GAS_LEVEL, " cm")


            initial_gas_level = self.getInitialGasLevel()
            print("Initial gas level: " , initial_gas_level, " cm")

            self.ALARM_DEACTIVATED = False

            while self.TRUCK_IS_MOVING == False and self.trapState() == 'close' and self.ALARM_DEACTIVATED == False:
                
                distance = self.gasLevel(1)
                print("Current level : ", distance, " cm")

                if distance > 1 + initial_gas_level:
                    print("Level decreasing detected, verifing...")

                    verif = 0
                    for i in range(50):
                        verif += self.gasLevel(0.075)
                    
                    verif /= 50 

                    if verif > 1 + initial_gas_level:
                        print("Level decreasing detected, comfirmed... Difference of ", initial_gas_level - verif)

                        self.ALARM_ACTIVATED = True
                        self.SEND_NOTIFICATION = True

                        t_take_picture = threading.Thread(target=self.takePicture)
                        t_start_buzzer = threading.Thread(target=self.startBuzzer)
                        t_start_flash = threading.Thread(target=self.startFlash)
        
                        t_start_flash.start()
                        t_start_buzzer.start()
                        t_take_picture .start()

                        t_start_flash.join()
                        t_start_buzzer.join()
                        t_take_picture .join()

                        self.ALARM_ACTIVATED = False

                        
    def testAlarm(self):
        print('testAlarm')

        t_start_flash = threading.Thread(target=self.startFlash)
        t_start_buzzer = threading.Thread(target=self.startBuzzer)

        self.ALARM_ACTIVATED = True

        t_start_flash .start()
        t_start_buzzer.start()

        time.sleep(2.5)

        self.ALARM_ACTIVATED = False

        t_start_flash .join()
        t_start_buzzer.join()

    '''  ----- Other functions -----  '''
    def setTruckIsMoving(self, status):
        if status == 0:
            self.TRUCK_IS_MOVING = False
        elif status == 0:
            self.TRUCK_IS_MOVING = True
# TODO envoie
# returnGasLevel, alerte vol, envoie d'image, state de la trappe

# recois
# ouverture trappe, fermeture trappe, arret de l'alarme, testalarme