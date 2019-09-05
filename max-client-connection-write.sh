#!/bin/bash

export MASTER0=https://$(nslookup master0| grep Address| tail -1 | awk '{print $2}'):2379
export MASTER1=https://$(nslookup master1| grep Address| tail -1 | awk '{print $2}'):2379
export MASTER2=https://$(nslookup master2| grep Address| tail -1 | awk '{print $2}'):2379
source /etc/etcd/etcd.conf
clientconnection=1000000

while true;
do  
  let clientconnection="$clientconnection+10000";
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=1 --clients=$clientconnection put --key-size=8 --sequential-keys --total=1 --val-size=256  --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt;

echo "Client Connection $clientconnection"
done
