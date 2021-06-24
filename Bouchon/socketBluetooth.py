from time import sleep
from truck import Truck, threading
import bluetooth
import base64

import os
import sys

class SocketBluetooth:
    
    def __init__(self):
        
        self.truck = Truck()

        self.ALARM_NOTIFICATION = False

        self.execution_code = {
            '1': self.openTrap,
            '2': self.closeTrap,
            '3': self.stopAlarm,
            '4': self.testAlarm,
            '5': self.confirmationNotification,
            '6': self.returnGasLevel,
            '7': self.returnPicture
        }

        self.uuid = "7be1fcb3-5776-42fb-91fd-2ee7b5bbb86d"

        self.client_socket = None

    def openTrap(self):
        self.truck.openTrap()

    def closeTrap(self):
        self.truck.closeTrap()

    def stopAlarm(self):
        self.truck.ALARM_ACTIVATED = False
        self.truck.ALARM_DEACTIVATED = True

    def testAlarm(self):
        self.truck.testAlarm()

    def confirmationNotification(self):
        self.ALARM_NOTIFICATION = False

    def returnGasLevel(self):
        while True:
            gas_level = str(self.truck.GAS_LEVEL)
            self.send(gas_level)
            sleep(5)

    def returnPicture(self):
        tab_picture = []
        for i in range(5):
            tab_picture.append(self.getBlob())

    def send(self, message):
        try:
            self.client_socket.send((message+'/').encode('utf-8'))
        except:
            pass

    def sendNotification(self):
        while self.ALARM_NOTIFICATION == True:
            self.send('1')
            sleep(1)

    def checkNotification(self):

        while True:
            sleep(0.1)
            if self.truck.SEND_NOTIFICATION == True:
                self.truck.SEND_NOTIFICATION = False
                self.ALARM_NOTIFICATION = True
                self.sendNotification()

    

    def startServer(self):

        self.truck.initialization()

        t_notification = threading.Thread(target=self.checkNotification)
        t_notification.start()
        t_gas = threading.Thread(target=self.returnGasLevel)

        os.system("hciconfig hci0 piscan")

        server_socket=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        server_socket.bind(("", bluetooth.PORT_ANY))
        server_socket.listen(1)
        port = server_socket.getsockname()[1]
        bluetooth.advertise_service(server_socket, 'RaspiBtSrv',
                                    service_id=self.uuid,
                                    service_classes=[self.uuid, bluetooth.SERIAL_PORT_CLASS],
                                    profiles=[bluetooth.SERIAL_PORT_PROFILE])
        self.client_socket, client_info = server_socket.accept()
        print("Accepted connection from ",client_info)
        t_gas.start()

        while True:
            try:
                data = self.client_socket.recv(1024)
                data = str(data.decode('utf8'))
            
                print('Instruction: ',data)
                self.execution_code[data]()
            except IOError:
                pass

            except KeyboardInterrupt:
                
                print('keyboard interrupt')
                if self.client_socket is not None:
                    self.client_socket.close()
                    print('client socket killed')
                server_socket.close()
                break

            except:
                print("Unexpected error:", sys.exc_info()[0])


        t_notification.join()
        t_gas.join()
        self.client_socket.close()
        server_socket.close()
    
    
