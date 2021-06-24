from socketBluetooth import SocketBluetooth
# from socketBluetooth import SocketBluetooth
from truck import GPIO, threading

# import signal
# def handler(sig, frame):
#     server_socket.stopServer()
# signal.signal(signal.SIGINT, handler)

server_socket = SocketBluetooth()


t_server_socket = threading.Thread(target=server_socket.startServer)
t_alarm = threading.Thread(target=server_socket.truck.alarm)

t_server_socket.start()
t_alarm.start()


t_server_socket.join()
t_alarm.join()

GPIO.cleanup()

