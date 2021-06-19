# Partie Web du ProjetIOT
Mot de passe rasp web :
login :     pi
mdp :       ProjetIOTCyber

Utilisation de RubyOnRails car Firmin a déjà travaillé dessus auparavant lors de projet personnel et lors de stage en entreprise.

À implémenter :
    - Admin par défaut lors de l'installation

Implémenté :
    - Action cable
    - utilisateur
    - gérer les utilisateurs
    - fonction de changement de mot de passe à la premiere connexion
    - Impossibilité de supprimer le dernier admin
    - Identifier le camion à l'aide d'un qrcode à scanner
    - carte intéractive
    - page tous les camions
    - Ajouter les camions sur la carte meme s'ils n'y étaient pas avant
    - supprimer les camions de la carte lors de suppression de la bdd
    - pas 2 meme utilisateur
    - Photo lors d'un vol
    - popup lors de l'ajout dynamique
    - Alerte visuelle si vol

Procédure d'installation :

Installation de RVM, pour gérer les version de Ruby :

    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash
    source ~/.rvm/scripts/rvm

Installation de Ruby version 2.7.2 pour le projet (peut etre assez long en fonction du matériel)

    rvm install -v 2.7.2

Installation de NodeJS

    sudo apt update
    sudo apt install nodejs