# Microservices et docker

## Introduction
Les microservices sont l'inverse de ce que propose les architectudes monolitique. Le but du microservice et du segmenter une application en plusieur parties independantes.
L'interet du microservice est de fractionner pour mieux maitriser l'environnement.
* Mieux maitriser le reseau ce qui permet de meiux le securiser.
* Mieux maitriser les versions des services (php, apache, ngnix,etc...).
* ...
Fractionner ca permet de mieux s'adapter aux ressources
* On va pouvoir dupliquer certains services pour "scalabiliser".Plus de workers pour produire plus.
* On va pouvoir s'adapter au mieux en terme d'installation de paquet adapté à ces services.
* Le fait de segmenté finement les éléments permets d'augmenter la vitesse de deploiement, du fait que les services vont etres plus petits, on va pouvoir plus facilement dessus.
* En terme d'architecture d'hebergement on va pouvoir acceuillir plus de service avec moins de contraintes. Pratique pour les serveurs web.
* Limiter les single point of failure (SPOF).

## Exemple de microservice minimalite

### Dockerfile container web
```bash
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y nginx
VOLUME /var/www/html/
ENTRYPOINT ["nginx, "-g", "deamon off;"]
```
L'objectif du ENTRYPOINT c'est de dire de passer de premier processus qui est lancer au seing du container et dans ce cas precis que le ngnix,
ce soit le container qui soit capable de le gerer tout seul sans que ce soit un demon ngninx qui le gere. On a desactiver le daemon nginx

### Dockerfile worker
```bash
FROM php:7.2-cli
COPY rollon.sh /
COPY affichage.php /
RUN chmod 755 /rollon.sh
ENTRYPOINT ["./rollon.sh"]
```
Deux scripts tournent sur les workers rollon.sh pour la variable calculé et un script php affichage.php pour mettre à jour la page index.html.
On les COPy à la creation de l'image, et a chaque creation d'image on dira que le process à lancer c'est rollon.sh.

### Script rollon.sh worker 1
```bash
#!/bin/bash
x=1
while true
do
echo $x > /var/www/html/worker1.txt
((x=x+100))
php /affichage.php
sleep 10
done
```
### Script rollon.sh worker 2
```bash#!/bin/bash
x=1
while true
do
echo $x > /var/www/html/worker2.txt
((x=x+1))
sleep 5
php /affichage.php
done
```
Sur le volume partagé on va avoir un index html mais ca c'est dédié au serveur web. Pour les workers vont modifier une variable qui va etre modifié et placé dans placé dans un
fichié worker1, worker2.txt.

### Script affichage.php
```php
<?php
$file1='/var/www/html/worker1.txt';
$file2='/var/www/html/worker2.txt';
$Data1="";
$Data2="";

# worker1 data
if (file_exists($file1)) {
$fh = fopen($file1,'r');
while ($line = fgets($fh)) {
  $worker1 = $line;
}
fclose($fh);
}


# worker2 data
if (file_exists($file2)) {
$fh = fopen($file2,'r');
while ($line = fgets($fh)) {
  $worker2 = $line;
}
fclose($fh);
}

# affichage
$File = "/var/www/html/index.html";
$Handle = fopen($File, 'w');
$Data1 = "worker 1 vaut ".$worker1."\n";
fwrite($Handle, $Data1);
$Data2 = "worker 2 vaut ".$worker2."\n";
fwrite($Handle, $Data2);
fclose($Handle);
?>
```

### Arborescence
myapp
* serveurweb
- - Dockerfile
* worker1
- - affichage.php
- - Dockerfile
- rollon.sh
* worker2
- - affichage.php
- - Dockerfile
- - rollon.sh
