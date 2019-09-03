---
__Example command__  

```$ source /etc/etcd/etcd.conf```

```$ benchmark --target-leader --conns=1 --clients=1 put --key-size=8 --sequential-keys --total=10000 --val-size=25 --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt --endpoints=$ETCD_LISTEN_CLIENT_URLS```

---

__Environment Variables__  

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

__All ETCD Write Tests__

```sh
# Write to leader 1 Connection
benchmark --endpoints=${MASTER0} --target-leader --conns=1 --clients=1 \
    put --key-size=8 --sequential-keys --total=10000 --val-size=256 \
    --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# Write to leader 100 Connections
benchmark --endpoints=${MASTER0} --target-leader  --conns=100 --clients=1000 \
    put --key-size=8 --sequential-keys --total=100000 --val-size=256 \
    --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# Write to all members 100 Connections
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=100 --clients=1000 \
    put --key-size=8 --sequential-keys --total=100000 --val-size=256 \
    --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt
```

__ETCD Write Results__

| Number of keys | Key size in bytes | Value size in bytes | Number of connections | Number of clients | Target etcd server | Average write QPS | Average latency per request | Average server RSS |
|---------------:|------------------:|--------------------:|----------------------:|------------------:|--------------------|------------------:|----------------------------:|-------------------:|
| 10,000 | 8 | 256 | 1 | 1 | leader only | 161 | 0.0062s | 219MB |
| 100,000 | 8 | 256 | 100 | 1000 | leader only | 5112| 0.1942s |  387MB |
| 100,000 | 8 | 256 | 100 | 1000 | all members |  5692 | 0.1738s |  468MB |

__All ETCD Read Tests__

```sh
# Single connection read requests Linearizable
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=1 --clients=1 \
    range YOUR_KEY --consistency=l --total=10000 --cert=$ETCD_PEER_CERT_FILE \
    --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# Single connection read requests Serializable
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=1 --clients=1 \
    range YOUR_KEY --consistency=s --total=10000 --cert=$ETCD_PEER_CERT_FILE \
    --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# Many concurrent read requests Linearizable
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=100 --clients=1000 \
    range YOUR_KEY --consistency=l --total=100000 --cert=$ETCD_PEER_CERT_FILE \
    --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt

# Many concurrent read requests Serializable
benchmark --endpoints=${MASTER0},${MASTER1},${MASTER2} --conns=100 --clients=1000 \
    range YOUR_KEY --consistency=s --total=100000 --cert=$ETCD_PEER_CERT_FILE \
    --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt
```

__ETCD Read Results__

| Number of requests | Key size in bytes | Value size in bytes | Number of connections | Number of clients | Consistency | Average read QPS | Average latency per request |
|-------------------:|------------------:|--------------------:|----------------------:|------------------:|-------------|-----------------:|----------------------------:|
| 10,000 | 8 | 256 | 1 | 1 | Linearizable | 640 | 0.0016s |
| 10,000 | 8 | 256 | 1 | 1 | Serializable | 1900 | 0.0005s |
| 100,000 | 8 | 256 | 100 | 1000 | Linearizable | 14349 | 0.0663s |
| 100,000 | 8 | 256 | 100 | 1000 | Serializable | 18394 | 0.0495s |

__Install flexible I/O tester Tool__

```yum install fio  -y```

```cd /var/lib/etcd/member/wal```

__Disk Tests__

__Random read/write performance__

```fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=./testfile --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75```

(Target Average read min IOPS > avg=2000) (ideal >= avg=6000)

(Target Average write min IOPS > avg=500) (ideal >= avg=2000)

__Random read performance__

```fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=./testfile --bs=4k --iodepth=64 --size=4G --readwrite=randread```

(Target Average read min IOPS > avg=4000) (ideal >= avg=10000)

__Random write performance__

```fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=./testfile --bs=4k --iodepth=64 --size=4G --readwrite=randwrite```

(Target Average write min IOPS > avg=3000) (ideal >= avg=10000)"
