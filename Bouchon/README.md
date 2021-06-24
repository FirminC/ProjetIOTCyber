# Bouchon connecté avec Raspberry Pi

Pour installer le programme, suivez les étapes suivantes:


Télécharger les fichiers disponibles sur GitHub.


Mettre à jour le Raspberry Pi:

    sudo apt update 
    sudo apt upgrade 

Installer les packages nécessaires pour le Bluetooth:

    sudo apt install bluetooth libbluetooth-dev
    sudo python3 -m pip install pybluez

Lancer l'application en tapant executant la commande:

    make run
    
    
   # Bouchon connecté avec Raspberry Pi
Une petite description du projet

## Pour commencer

Télécharger les fichiers du projet

### Pré-requis

Ce qu'il est requis pour commencer avec votre projet...

- Raspberry Pi 3 ou plus
- LED
- Buzzer
- 1 x 220 ohm
- 3 x 1000 ohm 

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
 Lancer l'application en tapant executant la commande:

    make run
