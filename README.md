---
**Example command**

source /etc/etcd/etcd.conf

benchmark --target-leader --conns=1 --clients=1 put --key-size=8 --sequential-keys --total=10000 --val-size=25 --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=/etc/etcd/ca.crt --endpoints=$ETCD_LISTEN_CLIENT_URLS

---
