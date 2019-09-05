#!/bin/bash

export MASTER0=https://$(nslookup master0| grep Address| tail -1 | awk '{print $2}'):2379
export MASTER1=https://$(nslookup master1| grep Address| tail -1 | awk '{print $2}'):2379
export MASTER2=https://$(nslookup master2| grep Address| tail -1 | awk '{print $2}'):2379
source /etc/etcd/etcd.conf
clientconnection=1000
grpc=100

while true;
do  
  let grpc="$clientconnection+100";
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=$grpc --clients=$clientconnection put --key-size=8 --sequential-keys --total=1 --val-size=256  --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt 2>/dev/null;

echo "GRPC Connection $grpc"
done
