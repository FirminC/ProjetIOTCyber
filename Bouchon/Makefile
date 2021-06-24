CC = python3

default: help

run:
	clear
	sudo $(CC) main.py

install:
	sudo apt update 
	sudo apt upgrade -Y
	sudo apt install bluetooth libbluetooth-dev -Y
	sudo python3 -m pip install pybluez	-Y

help:
	@echo ""
	@echo "Use 'make' with one argument:"
	@echo ""
	@echo "  make run"
	@echo "  make install"
	@echo ""
