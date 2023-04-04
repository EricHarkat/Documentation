# Bridge Linux

* Creer un bridge linux, creer des netwrok namespaces, mettre en place les interfaces réseauu dans les namespaces
* Creer des network namespaces
* Mettre en place les interfaces réseau dans les namespaces

/!\ Important il ne doit pas avoir Docker d'installer pour faire cette manipulation par risque de conflit.

![Schema](https://github.com/EricHarkat/Documentation/blob/main/Reseau.png?raw=true "Title")

## Déclaration des variables

### Variables Namespace
```bash
NS1="x1"
NS2="x2"
```

### Variables vethernet
```bash
VETH1="xeth1"
VETH2="xeth2"
```

### Variables interface des conteneurs
```bash
VPEER1="xpeer1"
VPEER2="xpeer2"
```

### Variables ip des conteneurs
```bash
VPEER_ADDR1="10.11.0.10"
VPEER_ADDR2="10.11.0.20"
```

### Variables du bridge
```bash
BR_ADDR="10.11.0.1"
BR_DEV="eric0"
```

## Création des namespaces
```bash
ip netns add $NS1
ip netns add $NS2
```


##Création des vethernet (cables) & interfaces
```bash
ip link add ${VETH1} type veth peer name ${VPEER1}
ip link add ${VETH2} type veth peer name ${VPEER2}
```

## Ajout des interfaces au namespace
```bash
ip link set ${VPEER1} netns ${NS1}
ip link set ${VPEER2} netns ${NS2}
```

## Activation des vethernet
```bash
ip link set ${VETH1} up
ip link set ${VETH2} up
```

```bash
ip --netns ${NS1} a
ip --netns ${NS2} a
```


## Activation des interfaces dans les namespaces
(lo pour monter les loopback) (ip netns exec ${NS1} veut dire j'execute la commande dans le namspace1)
```bash
ip netns exec ${NS1} ip link set lo up
ip netns exec ${NS2} ip link set lo up
ip netns exec ${NS1} ip link set ${VPEER1} up
ip netns exec ${NS2} ip link set ${VPEER2} up
```

## Ajout des ip pour chaque interface
```bash
ip netns exec ${NS1} ip addr add ${VPEER_ADDR1}/16 dev ${VPEER1}
ip netns exec ${NS2} ip addr add ${VPEER_ADDR2}/16 dev ${VPEER2}
```

## Création et activation du bridge
```bash
ip link add ${BR_DEV} type bridge
ip link set ${BR_DEV} up
```

## Ajout des vethernet au bridge
```bash
ip link set ${VETH1} master ${BR_DEV}
ip link set ${VETH2} master ${BR_DEV}
```

## Ajout de l'ip du bridge
```bash
ip addr add ${BR_ADDR}/16 dev ${BR_DEV}
```

## Ajout des routes pour chaque namespace pour passer par le bridge
```bash
ip netns exec ${NS1} ip route add default via ${BR_ADDR}
ip netns exec ${NS2} ip route add default via ${BR_ADDR}
```

## Accès externe 
Ip forwarding pour faire du NAT (rendre les adresses privées invisibles depuis internet ou traduit une adresse IP source interne en adresse IP globale).
Encapsulage de tout ce qui va sortir des containers et de tous ce qui va rentrer dans les container. On applique le MASQUERADE -j pour tout ce qui n'est pas bridge,
car quand on a quelques chose qui ressort du bridge on va le faire passer par le bridge et tous qui n'est pas bridge on va passer par là.

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s ${BR_ADDR}/16 ! -o ${BR_DEV} -j MASQUERADE
```

