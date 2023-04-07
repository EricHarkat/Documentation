# Docker

Ensemble des informations relative à docker et à son environnement.

Lorsque vous installez Docker sur une machine. Deux programmes différents entrent en jeu :

- Client Docker
- Serveur Docker
- 
Docker Server reçoit des commandes via un socket (soit via un réseau, soit via un "fichier")

Le client Docker communique sur un réseau et envoie un message au serveur Docker pour dire créer un conteneur, démarrer un conteneur, arrêter un conteneur, etc.

Lorsque le client et le serveur s'exécutent sur le même ordinateur, ils peuvent se connecter via un fichier spécial appelé socket. Et comme ils peuvent communiquer via un fichier et que Docker peut partager efficacement des fichiers entre des hôtes et des conteneurs, cela signifie que vous pouvez exécuter le client dans Docker lui-même.

## Installation

### Desintallation des vieilles versions de docker 
```bash
sudo apt update
sudo apt remove docker docker-engine docker.io 2>/dev/null
```
### Mettre à jour les paquets
```bash
sudo apt update
```
### Installer les paquets
```bash
sudo apt -y install lsb-release gnupg apt-transport-https ca-certificates curl software-properties-common
```
### Ajouetr les GPG key officiel de docker
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
```
### Ajouter le repository stable
```bash
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
### Installation de docker ce
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
### Si vous souhaitez utiliser docker avec un utilisateur non root, ajoutez un utilisateur au group docker
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Commande linux

### Creer un utilisateur
Le -u sert à spécifier un id sinon il sera choisi automatiquement
```bash
useradd -u 0000 nameUser 
```

### Voir les processsus, utiliser grep pour filter
```bash
ps aux | grep sleep
```

### Remplacer le propriétaire du fichier ou du répertoire
```bash
chown eric /myfile/
```
### Liste des fichiers ainsi que les fichiers cachés (ceux qui commence par un .) avec les details du style qui a créé le fichié etc
```bash
ls -la /myfile/
```

### Voir si un utilisateur existe
```bash
id username
```

### Creer un fichier
```bash
touch filename
```

### Afficher les adresse IP du reseau (cela peut inclure les adresses d'autres Pheripherique)
```bash
ip addr ou ip a
```

### Quitter vim en sauvegardant
échap pour passer un mode commande
```bash
:wq
```

### Quitter vim sans sauvegarder
```bash
:wq!
```

### Librairie pour controler le trafic reseau
```bash
apt install iproute2
```

### lister les ports ouverts
```bash
nmap -PM ipadress
```

## Commandes docker

### lancer un container docker
L'argument -d implique l'utilsation du d'étache mode, l'arguement -ti implique le terminal interactif suivie de l'attribution du nom, de l'image et de la version
```bash
docker run -d -ti --name c1 nginx:latest
```
### Demarrer un container 
```bash
docker start name/id
```
### Liste des container actif
```bash
docker ps
```
### Liste des container actif/non actif
```bash
docker ps -a
```
### Liste des container actif/non actif (list uniquement les id)
```bash
docker ps -aq
```
### Kill un containeur à la fin du processus
l'argument --rm kil le docker à la fin du processus
```bash
docker run -ti --rm -name Eric debian:lastest
```
### supprimer un container
```bash
docker rm name/id
```

### Inspecter un container
```bash
docker inspect name/id
```

### Voir toutes mes images
```bash
docker images
```

## Docker volume
Pour faire persister de la donnée ou l'echanger entre container, le volume est un espace partagé entre le container et l'host pour y stocker de la data.
Trois type de volume
1 - Bind Mount = monter un path personnalisé ex: /srv/data dans un repertoire target /data mais cette fois-ci a l'interieur du container
2 - Volumes Docker = on creer un volume comme ci-dessus et on va monter un repertoire dans ce volume data persistante dans /var/lib/docker/volume/nameduvolume
3 - TMPFS = espace de travail en memoire temporaire

### Liste des volumes
```bash
docker volume ls
```

### Creation d'un volume 
```bash
docker volume create volumename
```

### Attribution d'un volume version 1
L'argument -v permet d'associer un volume existant suivie du path où on souhaite le monter
```bash
docker run -d --name c1 -v name:/usr/share/nginx/html nginx:latest
```

### Attribution d'un volume version 2
Methode avec le mount bind, la source est l'emplacement sur le host que l'on va binder à la destination 
```bash
docker run -d --name c1 --mount type=bind,source=/data/,destination=/usr/share/nginx/html nginx:latest
```
meme chose mais avec un volume, mais ici la source fait reference au volume creer
```bash
docker run -d --name c1 --mount type=volume,source=volumename,destination=/usr/share/nginx/html nginx:latest 
```

avec tmpfs et donc sans persistance à la cloture du container
```bash
docker run -d --name c1 --mount type=tmpfs,destination=/usr/share/nginx/html nginx:latest
```

## Rentrer à l'interieur du container docker
Le dernier argument est la commande que l'on souhaite activer dans notre docker exec
```bash
exec -ti c1 bash
```

### Voir les metadatas d'un element
A l'interieur de ce volume on pourra retrouver le Mountpoint var/lib/docker/volumes/volumename/_data equivalent de /usr/share/name/html mais sur le host en dehors du container
```bash
docker volume inspect volumename 
```

## Dockerfile

C'est quoi un dockerfile :
* Un fichier plat de configuration
* Sont objectif : creer une image
* On y retrouve une sequence d'instruction

C'est quoi un dockerfile :
* Un fichier plat de configuration
* Sont objectif : creer une image
* On y retrouve une sequence d'instruction

```bash
FROM : de où on part
RUN : lancements de commandes (apt...)
ENV : definir les variables d'environement
EXPOSE : exposer le port du container
VOLUME : définir des volumes
COPY : copier des elements entre le host docker et le container
ENTRYPOINT : definir le processus maitre du container (l'idée dans un container c'est d'avoir un seul processus qui tourne)
```

L'interet du dockerfile:
* relance la creation d'image à tout moment
* meilleur visibilité sur ce qui est fait (toutes les etapes de la création detaillés)
* partage facile et possibilité de gitter
* script d'edition de docker file (variable...)
* ne pas se poser de question lors du docker run du container
* création images pod // dev - CI // CD

### Exemple DockerFile
```bash
FROM ubuntu:latest
MAINTAINER eric
RUN apt-get update\
&& apt-get install -y vim git \
## nettoyer le cash 
&& apt-get clean \
## supprimer les residus suite à l'apt-get
&& rm -rf /var/lib/apt/listes/* /tmp/* /var/tmp/*
```


```bash
FROM debian:9
RUN apt-get update -yq \
&& apt-get install curl gnupg -yq \ apache2
&& curl -sL https://deb.nodesource.com/setup_10.x | bash \
&& apt-get install nodejs -yq \
&& apt-get clean -y
&& rm -rf /var/lib/apt/listes/* /tmp/* /var/tmp/*

ADD . /app/
WORKDIR /app
RUN npm install

EXPOSE 2368
VOLUME /app/logs

CMD npm run start
```

### Build une image à partir du dockerfile
L'argument -t pour attribuer un nom à l'image suivie de la version attribué (ex:1.0) le point est pour la symboliser le dockerfile
```bash
docker build -t imagename:versionnumber .
```

### Lancer une image (dockerfile)
Le derniere argument est le nom est la version de l'image creer à partir du dockerfile
```bash
docker run -d --name c1 -v /myvolume/:/data/ imagename:versionnumber
```


### Lancer une image dockerfile persistante
L'arguement sleep infinity pour faire persister le container pour des tests ou autre
```bash
docker run -d --name c1 -v /myvolume/:/data/ myimage:v1.0 sleep infinity
```

### Lancer une image dockerfile persistance avec un user
L'argument -u pour lancer un container avec un utilsateur ce qui permet de ne pas creer un container en root, 
mais attention à déclarer dans le dockerfile le nom de l'utlisateur avec lequel le container pourra etre lancé. 
Afin qu'il y ai un lien entre le user de l'host et celui du container. Il s'agit d'une question de permission de l'ecture ecriture à l'interieur du container
```bash
docker run -d --name c1 -v /myvolume/:/data/ -u name/id myimage:v1.0
```

### Supprimer une image
```bash
docker rmi imagename/id
```


## Reseaux docker (communication vers l'exterieur)
Par defaut quand on install docker on benficie d'un bridge qui s'appel docker 0, celui-ci fourni des IP aux containers et Le reseaux par defaut repose par default sur le 172.17.0.1/16
consultable par
```bash
ipconfig
```
```bash
ip a
```

172.17.0.1 est la gateway/le bridge/le host, le premier conteneur aura l'adresse 172.17.0.2, le second 172.17.0.3, etc..

### Une autre maniere de retrouver le bridge directement depuis la commande docker
```bash
docker network ls
```

Une fois un container créé rentrer dans le conteneur et
faire un update et installer deux outils
```bash
apt update
```
```bash
apt install iputils-ping net-tools
```
### Controle de l'ip du container
On pourra voir que l'ip du container commence par 172.17.0.x
```bash
ifconfig
```

### Teste du bridge
On peut pinguer le host et google pour l'acces exterieur
```bash
ping 172.17.0.1
```
ou
```bash
ping 8.8.8.8
```


## Notion entre l'exposition et le publish

Quand on parle d'Exposition de port en realité on expose qu'une metatdata ce qui ne veut pas dire que l'applicatif dans le containeur ecoute sur ce port. 
Il s'agit d'une simple declaration que l'on peut faire à la creation d'une image docker soit dans la ligne de commande docker run avec l'option --expose.
La publication de port elle est la capacité de mapper un port de notre machine host avec un port du container il peut se faire de deux maniere:
1 - Manuellement avec -p
2 - De maniere dynamique et aleatoire avec le -P
Avec le -P On parle publish all et c'est dans le cas de cette allocation dynamqiue et aleatoire que le metadata de expose va etre utilisé.
Avec le -p on va pouvoir par exemple mapper le port 80 de notre container nginx par exemeple sur le port 8080 de l'host il s'agit la de publication,
on peut immaginer aussi un contenaire avec un postgres qui fonctionne sur le port 5432 à le publier sur le port 5432 de notre host.
On peut publier plusieur mapping dans le docker run voir meme un rang de port.
Pour le publish all cest à dire le mode aleatoire il va se baser sur le Expose du dockerfile ou lors du docker run avec l'option --expose et le numero du port à l'interieur du container et les port sur l'host seront superieur à 32000

### publish manuel
Mapping entre le port 8080 du host et le 80 du container
```bash
docker run -d --name c1 -p 8080:80 nginx
```

### Voir si on ecoute bien sur le port 8080
```bash
curl ip:80
```
docker run -d --name c1 -p 8080:80(mappingentre8080du host et le 80 du contziner) nginx
pour voir si on ecoute bien sur le port 8080 ouvrir un nouveau terminal et faire une requete curl sur l ip de l'host au port 80

### publish dynamique
```bash
docker run -d --name c2 -P nginx 
```

### Voir le port exposé
On peut voir que le port qui est exposé est au dessus de 32000
```bash
docker ps
```

## Network cli
Les containers n'ont pas d'adresse ip static, donc si on stop ou detruit un container on est pas certain de récuperer la meme ip. 

### Voir les reseaux 
```bash
docker network ls
```

### Creer un reseau
```bash
docker network create --driver=bridge --subnet=192.168.0.0/24 networkname
```

### Inspecter le reseau créé
```bash
docker network inspect networkname
```

### Inspecter le bridge
```bash
docker network inspect bridge docker
```

### Creer un docker connecté a un reseau 
```bash
docker run -d --name c1 --network networkname nginx:latest
```

on créer un deuxieme docker sur le meme reseau pour tester le reseau
```bash
docker run -d --name c2 --network networkname nginx:latest
```

on rentre à l'interieur du container, on le met à jour, on install l'utilitaire de ping, et on ping
```bash
exec -ti c2 bash
apt update
apt install iputils-ping
ping c2
```

Ce qui n'est pas possible de faire avec le docker0 car il ne dispose pas de cette resolution, qui est uniquement disponible sur les reseaux custome.

### Rattacher un container à un reseau si il n'a pas été declaré au debut
```bash
docker network connect networkname containername
```

il est possible reconfirgurer le bridge docker0, par exemple si le reseau dans l'entreprise utilise deja le range ip du bridge docker0

# Changer le range ip du docker0
```bash
vim /etc/docker/daemon.json
```

à l'interieur du fichier ecrire
{
	"bip": "10.10.0.1/16" par exemple
}

## Redemarrer docker et vérifier si le bridge à changé
```bash
systemctl restart docker
ifconfig docker0
```

### Modifier le bridge par default ("com.docker.network.bridge.name": "docker0")

### Notion de vethernet
Le vethernet est un cable virtuel pour relier deux port.

## Network namespace reseau (isolation reseau au seing du host)
```bash
create network namespace
```

### Lister les nameSpace
```bash
ip netns ls
```

### Ajouter le namespace
```bash
ip netns add namenameSpace
```

### Commande ls mais dans le contexte de mon namespace reseau
```bash
ip netns exec namenamespace ls
```

### Monter un serveur web
-m signifie module http.server est une module qui lance un serverweb à l'endroit ou on lance la commande en question.
```bash
ip netns exec namenamespace python3 -m http.server 8000
```

### Tester le port 8080 du namespace
```bash
ip netns exec mynet curl 127.0.0.1:8080
```

### Reseau du namespace
```bash
ip netns exec mynet ip a
```

### Mettre la backloop up
```bash
ip netns exec namenamespace ip link set lo up
```

## Variable d'environement 
passer une variable en ligne de commande 
```bash
docker run -tid --name dockername --env VARIABLENAME ="xxxx" ubuntu:latest
```

### Passer un fichier de variable 
on peut creer un fichier vim vars_env.lst ou on rentre des mot de passe ou autre
```bash
docker run -tid --name dockername --env-file vars_env.lst ubuntu:latest
```

### Voir les variables
```bash
docker exec -ti testenv sh
env
```

## Comprendre les layers 
Il existe deux type de couches sur docker:
* lecture seule
* lecture - ecriture (mode container qui permet d'avoir un systeme pour travailler à l'interieur du container)
La plupart des couches sont en lecture seule. autre subtilité les image puevent se partager des couches exemple un container avec un image debian et un container ubuntu peuevent avoir une couche commune pour demarrer plus rapidement par exemple.
Sur l'ensemble des couches empilées la derniere est la couche de travail celle ou on passe en mode container et donc c'est des couches en lecture et ecriture.

### Dockerfile multi-couche
```bash
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y --no-install-recommends vim
RUN apt-get install -y --no-install-recommends git
```
Dans ce dockerfile le nombre de RUN fait référence au nombre de couches.

### Voir les couches
```bash
docker history nameimage:version
```
cette comment permet de visualiser le contenu d'une image et par definiton les couches.

## Consulter la couche en mode écriture
```bash
docker diff test
```
docker enregistre les differences l'image standart et tout ce qu'on va y faire dessus puisse qu'on y est en mode container.

## Pour creer une image à partir d'un container 
```bash
docker commit -m "création d'une image" imagename -t imagename:version
```
Ca ressemble beaucoup à un commit de git et en fait ce qui va se passer c'est que ca va juste commmiter les modifications qu'on a realiser sur notre image precedente.
