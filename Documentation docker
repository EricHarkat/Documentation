##Docker

Ensemble des informations relative à docker et à son environnement

##Commande linux

#Creer un utilisateur
Le -u sert à spécifier un id 

```bash
useradd -u 0000 nameUser 
```

#Voir les processsus, utiliser grep pour filter

```bash
ps aux | grep sleep
```

#Remplacer le propriétaire du fichier ou du répertoire

```bash
chown eric /myfile/
```
#Liste des fichiers ainsi que les fichiers cachés (ceux qui commence par un .) avec les details du style qui a créé le fichié etc

```bash
ls -la /myfile/
```

#Voir un utilisateur existe

```bash
id username
```

#Creer un fichier

```bash
touch filename
```

#Afficher les adresse IP du reseau (cela peut inclure les adresses d'autres Pheripherique)

```bash
ip addr ou ip a
```

#Quitter vim en sauvegardant
échap pour passer un mode commande

```bash
:wq
```

#Quitter vim sans sauvegarder

```bash
:wq!
```

##Commandes docker

#lancer un container docker
L'argument -d implique l'utilsation du d'étache mode, l'arguement -ti implique le terminal interactif suivie de l'attribution du nom, de l'image et de la version

```bash
docker run -d -ti --name c1 nginx:latest
```
#Demarrer un container 

```bash
docker start name/id
```
#Liste des container actif

```bash
docker ps
```
#Liste des container actif/non actif

```bash
docker ps -a
```

#Kill un containeur à la fin du processus
l'argument --rm kil le docker à la fin du processus

```bash
docker run -ti --rm -name Eric debian:lastest
```
#supprimer un container

```bash
docker rm name/id
```

#Inspecter un container

```bash
docker inspect name/id
```

#voir toutes mes images

```bash
docker images
```

##Docker volume
Pour faire persister de la donnée ou l'echanger entre container, le volume est un espace partagé entre le container et l'host pour y stocker de la data.
Trois type de volume
1 - Bind Mount = monter un path personnalisé ex: /srv/data dans un repertoire target /data mais cette fois-ci a l'interieur du container
2 - Volumes Docker = on creer un volume comme ci-dessus et on va monter un repertoire dans ce volume data persistante dans /var/lib/docker/volume/nameduvolume
3 - TMPFS = espace de travail en memoire temporaire

#Liste des volumes

```bash
docker volume ls
```

#Creation d'un volume 

```bash
docker volume create volumename
```

#Attribution d'un volume version 1
L'argument -v permet d'associer un volume existant suivie du path où on souhaite le monter

```bash
docker run -d --name c1 -v name:/usr/share/nginx/html nginx:latest
```

#Attribution d'un volume version 2
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

#Rentrer à l'interieur du container docker
Le dernier argument est la commande que l'on souhaite activer dans notre docker exec

```bash
exec -ti c1 bash
```

#Voir les metadatas d'un element
A l'interieur de ce volume on pourra retrouver le Mountpoint var/lib/docker/volumes/volumename/_data equivalent de /usr/share/name/html mais sur le host en dehors du container

```bash
docker volume inspect volumename 
```

##Docker file

#Image source que l'on souhaite utiliser
FROM debian:9

#lance des commande shell au moment du le creation de l'image
RUN apt-get update -yq \
&& apt-get install curl gnupg -yq \ apache2
&& curl -sL https://deb.nodesource.com/setup_10.x | bash \
&& apt-get install nodejs -yq \
&& apt-get clean -y

ADD . /app/
WORKDIR /app
RUN npm install

EXPOSE 2368
VOLUME /app/logs

CMD npm run start

#Build une image à partir du dockerfile
L'argument -t pour attribuer un nom à l'image suivie de la version attribué (ex:1.0) le point est pour la symboliser le dockerfile

```bash
docker build -t imagename:versionnumner .
```

#Lancer une image (dockerfile)
Le derniere argument est le nom est la version de l'image creer à partir du dockerfile

```bash
docker run -d --name c1 -v /myvolume/:/data/ imagename:versionnumber
```


#Lancer une image dockerfile persistante
L'arguement sleep infinity pour faire persister le container pour des tests ou autre

```bash
docker run -d --name c1 -v /myvolume/:/data/ myimage:v1.0 sleep infinity
```

#Lancer une image dockerfile persistance avec un user
L'argument -u pour lancer un container avec un utilsateur ce qui permet de ne pas creer un container en root, 
mais attention à déclarer dans le dockerfile le nom de l'utlisateur avec lequel le container pourra etre lancé. 
Afin qu'il y ai un lien entre le user de l'host et celui du container. Il s'agit d'une question de permission de l'ecture ecriture à l'interieur du container

```bash
docker run -d --name c1 -v /myvolume/:/data/ -u name/id myimage:v1.0
```

#Reseaux docker (communication vers l'exterieur)
Par defaut quand on install docker on benficie d'un bridge qui s'appel docker 0, celui-ci fourni des IP aux containers et Le reseaux par defaut repose par default sur le 172.17.0.1/16
consultable par

```bash
ipconfig
```
```bash
ip a
```

172.17.0.1 est la gateway/le bridge/le host, le premier conteneur aura l'adresse 172.17.0.2, le second 172.17.0.3, etc..

#Une autre maniere de retrouver le bridge directement depuis la commande docker

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
#Controle de l'p du container
On pourra voir que l'ip du container commence par 172.17.0.x

```bash
ifconfig
```

#Teste du bridge
On peut pinguer le host et google pour l'acces exterieur

```bash
ping 172.17.0.1
```
ou
```bash
ping 8.8.8.8
```


#Notion entre l'exposition et le publish

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

#publish manuel
Mapping entre le port 8080 du host et le 80 du container

```bash
docker run -d --name c1 -p 8080:80 nginx
```

#Voir si on ecoute bien sur le port 8080

```bash
curl ip:80
```
docker run -d --name c1 -p 8080:80(mappingentre8080du host et le 80 du contziner) nginx
pour voir si on ecoute bien sur le port 8080 ouvrir un nouveau terminal et faire une requete curl sur l ip de l'host au port 80

#publish dynamique

```bash
docker run -d --name c2 -P nginx 
```

#Voir le port exposé
On peut voir que le port qui est exposé est au dessus de 32000

```bash
docker ps
```