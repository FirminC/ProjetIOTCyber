   # Bouchon connecté avec Raspberry Pi
## Pour commencer

Télécharger les fichiers du projet

### Pré-requis

Ce qu'il est requis pour commencer avec votre projet...

- 1 x Raspberry Pi 3 ou plus
- 1 x Carte SD 4Go ou plus
- 1 x LED
- 1 x Buzzer
- 1 x 220 ohm
- 3 x 1000 ohm 
- 1 x BreadBoard
- 1 x Pi Camera
- 2 x Moteur 28BYJ-48
- 2 x Driver pour moteur
- 1 x Capteur à ultrason HC-SR04

### Installation automatique

        make install
        
### Installation manuelle

Mettre à jour le Raspberry Pi:

    sudo apt update 
    sudo apt upgrade 

Installer les packages nécessaires pour le Bluetooth:

    sudo apt install bluetooth libbluetooth-dev
    sudo python3 -m pip install pybluez
    
## Démarrage
 Lancer l'application en executant la commande:

    make run
