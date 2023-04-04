#!/usr/bin/bash

## Variables Namespace
NS1="x1"
NS2="x2"

## Variables vethernet
VETH1="xeth1"
VETH2="xeth2"

## Variables interface des conteneurs
VPEER1="xpeer1"
VPEER2="xpeer2"

# Variables ip des conteneurs
VPEER_ADDR1="10.11.0.10"
VPEER_ADDR2="10.11.0.20"

## Variables du bridge
BR_ADDR="10.11.0.1"
BR_DEV="eric0"

## Création des namespaces
ip netns add $NS1
ip netns add $NS2


##Création des vethernet (cables) & interfaces
ip link add ${VETH1} type veth peer name ${VPEER1}
ip link add ${VETH2} type veth peer name ${VPEER2}

## Ajout des interfaces au namespace
ip link set ${VPEER1} netns ${NS1}
ip link set ${VPEER2} netns ${NS2}

## Activation des vethernet
ip link set ${VETH1} up
ip link set ${VETH2} up


ip --netns ${NS1} a
ip --netns ${NS2} a


## Activation des interfaces dans les namespaces
ip netns exec ${NS1} ip link set lo up
ip netns exec ${NS2} ip link set lo up
ip netns exec ${NS1} ip link set ${VPEER1} up
ip netns exec ${NS2} ip link set ${VPEER2} up

## Ajout des ip pour chaque interface
ip netns exec ${NS1} ip addr add ${VPEER_ADDR1}/16 dev ${VPEER1}
ip netns exec ${NS2} ip addr add ${VPEER_ADDR2}/16 dev ${VPEER2}

## Création et activation du bridge
ip link add ${BR_DEV} type bridge
ip link set ${BR_DEV} up

## Ajout des vethernet au bridge
ip link set ${VETH1} master ${BR_DEV}
ip link set ${VETH2} master ${BR_DEV}

## Ajout de l'ip du bridge
ip addr add ${BR_ADDR}/16 dev ${BR_DEV}

## Ajout des routes pour chaque namespace pour passer par le bridge
ip netns exec ${NS1} ip route add default via ${BR_ADDR}
ip netns exec ${NS2} ip route add default via ${BR_ADDR}

## Accès externe
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s ${BR_ADDR}/16 ! -o ${BR_DEV} -j MASQUERADE
