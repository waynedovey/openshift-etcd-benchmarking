---
__Example command__  

```$ source /etc/etcd/etcd.conf```

```$ benchmark --target-leader --conns=1 --clients=1 put --key-size=8 --sequential-keys --total=10000 --val-size=25 --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt --endpoints=$ETCD_LISTEN_CLIENT_URLS```

---

__Working Command__  

```sh
export MASTER0=https://$(nslookup master0| grep Address| tail -1 | awk '{print $2}'):2379

export MASTER1=https://$(nslookup master1| grep Address| tail -1 | awk '{print $2}'):2379

export MASTER2=https://$(nslookup master2| grep Address| tail -1 | awk '{print $2}'):2379

source /etc/etcd/etcd.conf
```

__Check RSS Memory usage__

```sh
ansible -i openshift-inventory masters -m command -a "ps -C etcd -o rss="
```

```sh
# write to leader 1 Connection
benchmark --endpoints=${MASTER0} --target-leader --conns=1 --clients=1 \
    put --key-size=8 --sequential-keys --total=10000 --val-size=256 --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# write to leader 100 Connections
benchmark --endpoints=${MASTER0} --target-leader  --conns=100 --clients=1000 \
    put --key-size=8 --sequential-keys --total=100000 --val-size=256 --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# write to all members 100 Connections
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=100 --clients=1000 \
    put --key-size=8 --sequential-keys --total=100000 --val-size=256 --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt
```


| Number of keys | Key size in bytes | Value size in bytes | Number of connections | Number of clients | Target etcd server | Average write QPS | Average latency per request | Average server RSS |
|---------------:|------------------:|--------------------:|----------------------:|------------------:|--------------------|------------------:|----------------------------:|-------------------:|
| 10,000 | 8 | 256 | 1 | 1 | leader only | 161 | 0.0062s | 219MB |
| 100,000 | 8 | 256 | 100 | 1000 | leader only | 5112| 0.1942s |  387MB |
| 100,000 | 8 | 256 | 100 | 1000 | all members |  5692 | 0.1738s |  468MB |
