#!/bin/bash

HELP="usage:\ncont2ns.sh add container_name\ncont2ns.sh del container_name" 

if [ "$2" = "" ];then
	echo -e $HELP
	exit 1
fi


if [ "$1" = "add" ]; then 

	CONTAIN=k8s_POD_$2
	CONTAIN_ID=`docker ps |grep $CONTAIN |awk -F " " '{printf $1}'`
	PID=`docker top $CONTAIN_ID|awk -F " " '{if(NR==2)printf $2}'`
	ln -sf /proc/$PID/ns/net "/var/run/netns/$2"

	exit 0
fi

if [ "$1" = "del" ]; then 
	rm -rf /var/run/netns/$2
	exit 0
fi

echo $HELP

exit 1
