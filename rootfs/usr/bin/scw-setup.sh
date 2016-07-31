#!/bin/bash

if [ ! -f /etc/scw-int-done-setup ]; then
    HOST=$(hostname)
    SCWIP=$(hostname  -I | awk '{print $1}')
    SCWPUBLIC=$(curl http://v4.myip.ninja)
    METADATA=`curl http://169.254.42.42/conf`
    MODEL=$(echo "$METADATA" | egrep COMMERCIAL_TYPE= | sed 's/COMMERCIAL_TYPE=//g')
    DISCOVER=$(echo "$METADATA" | egrep TAGS_0= | sed 's/TAGS_0=discover://g')
    APIKEY=$(echo "$METADATA"  | egrep TAGS_1= | sed 's/TAGS_1=api://g')
    PROXY=$(echo "$METADATA"  | egrep TAGS_2= | sed 's/TAGS_2=proxy://g')

    if [[ $PROXY == "true" ]]
    then
        echo "ETCD_PROXY=on" >>/etc/scw-env
    else
        echo "ETCD_PROXY=off" >>/etc/scw-env
    fi
    echo "ETCD_NAME=$HOST" >>/etc/scw-env
    echo "ETCD_DISCOVERY=$DISCOVER" >>/etc/scw-env
    echo "ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380" >>/etc/scw-env
    echo "ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379,http://0.0.0.0:4001" >>/etc/scw-env
    echo "ETCD_ADVERTISE_CLIENT_URLS=http://$SCWIP:2379,http://$SCWIP:4001" >>/etc/scw-env
    echo "ETCD_INITIAL_ADVERTISE_PEER_URLS=http://$SCWIP:2380" >>/etc/scw-env
    echo "FWUPD_LOGIN="$APIKEY >>/etc/scw-env
    echo "FWUPD_TAG=discover:"$DISCOVER >>/etc/scw-env
    echo "PRIVATE_IPV4="$SCWIP >>/etc/scw-env
    echo "PUBLIC_IPV4="$SCWPUBLIC >>/etc/scw-env
    chmod +x /etc/scw-env
    touch /etc/scw-int-done-setup
fi

exit 0
