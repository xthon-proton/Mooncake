
在服务场景，普通CNAI场景，可在集群内，通过coredns，解析mss、etcd的稳定pod域名；
但在三方云场景，节点的/etc/resolv.conf, /etc/hosts，不会带coredns的地址，所以不支持容器外解析集群域名。届时，测试方法应另想方法。

```shell
# 必要的环境变量
# MC_DISABLE_SSL=false 为开启安全加固
# 【拉起新的master进程，或者使用clientctl之前，都要执行】
export MC_DISABLE_SSL=false
export MC_ENABLE_SSL=true
export XMS_WORKSPACE_DIR=/home/paas/llc/test/xms-default-secret/
export MC_STORE_CLUSTER_ID=test

export MC_CA_FILE=/home/paas/llc/test/ca.crt
export MC_CERT_FILE=/home/paas/llc/test/server.crt
export MC_KEY_FILE=/home/paas/llc/test/server.key
export MC_PWD_FILE=/home/paas/llc/test/server.key.pwd

export LD_LIBRARY_PATH=/home/paas/llc/tools/client-tools/lib:$LD_LIBRARY_PATH


# 开一个master做http_metadata_server
mooncake_master --enable-ha=true --rpc-address=127.0.0.1 --rpc_port=50051 --etcd-endpoints=https://mooncake-etcd-svc.fst-manage.svc.cluster.local:2379 --enable_http_metadata_server=true --http_metadata_server_host=127.0.0.1 --http_metadata_server_port=20208 --metrics_port=9001 --cluster_id=test --logtostderr=true --client-ttl=3 1>>/tmp/mooncake-test.log 2>&1 &

# 确定端口已监听
netstat -anp | grep mooncake
tcp        0      0 0.0.0.0:9001            0.0.0.0:*               LISTEN      28378/mooncake_mast 
tcp        0      0 0.0.0.0:20208           0.0.0.0:*               LISTEN      28378/mooncake_mast 
tcp        0      0 127.0.0.1:50051         0.0.0.0:*               LISTEN      28378/mooncake_mast 
tcp        0      0 7.246.78.44:62502       10.247.72.175:2379      ESTABLISHED 28378/mooncake_mast 

# 启动client
# 由于证书dnsName问题，master先连pod服务，meta连上面启动的实例
/home/paas/llc/test/clientctl --master_server_entry=etcd://mooncake-etcd-svc.fst-manage.svc.cluster.local:2379 --engine_meta_url=http://127.0.0.1:20208/metadata

/home/paas/llc/tools/client-tools/bin/clientctl --master_server_entry=etcd://mooncake-etcd-svc.fst-manage.svc.cluster.local:2379 --engine_meta_url=http://127.0.0.1:20208/metadata


# 通过metrics接口，查询segments, key等信息
curl http://127.0.0.1:9001/metrics
curl http://127.0.0.1:9001/get_all_keys
curl http://127.0.0.1:9001/get_all_segments
curl http://127.0.0.1:9001/query_key?key=key1
```


# 资料

metrics接口（metrics_port, 如：9001）
参考：
Mooncake/docs/source/http-api-reference/http-service.md

```shell
curl http://127.0.0.1:9001/get_all_keys
key1

curl http://127.0.0.1:9001/get_all_segments
localhost:30000

curl http://127.0.0.1:9001/query_key?key=key1
{"size_":4,"buffer_address_":281467041087488,"protocol_":"tcp","transport_endpoint_":"localhost:30000"}

curl http://127.0.0.1:9001/metrics/summary
Mem Storage: 4 B / 1.00 GB (0.0%) | SSD Storage: 0 B / 0 B | Keys: 1 (soft-pinned: 0) | Clients: 1 | Requests (Success/Total): PutStart=1/1, PutEnd=1/1, PutRevoke=0/0, Get=1/1, Exist=0/0, Del=0/0, DelAll=0/0, Ping=560/560, CopyStart=0/0, CopyEnd=0/0, CopyRevoke=0/0, MoveStart=0/0, MoveEnd=0/0, MoveRevoke=0/0, EvictDiskReplica=0/0 | Batch Requests (Req=Success/PartialSuccess/Total, Item=Success/Total): PutStart:(Req=0/0/0, Item=0/0), PutEnd:(Req=0/0/0, Item=0/0), PutRevoke:(Req=0/0/0, Item=0/0), Get:(Req=0/0/0, Item=0/0), ExistKey:(Req=0/0/0, Item=0/0), QueryIp:(Req=0/0/0, Item=0/0), Clear:(Req=0/0/0, Item=0/0), CreateMoveTask:(Req=0/0), CreateCopyTask:(Req=0/0), QueryTask=(Req=0/0), FetchTasks=(Req=560/560), MarkTaskToComplete= (Req=0/0),  | Eviction: Success/Attempts=0/0, keys=0, size=0 B | Discard: Released/Total=0/0, StagingSize=0 B | Snapshots: Success=0, Fail=0[root@paas-core test]


```

http_metadata_server接口（如：8888）
参考：
Mooncake/docs/source/design/transfer-engine/index.md
如：
1. `GET /metadata?key=$KEY`: Get the metadata corresponding to `$KEY`.
2. `PUT /metadata?key=$KEY`: Update the metadata corresponding to `$KEY` to the value of the request body.
3. `DELETE /metadata?key=$KEY`: Delete the metadata corresponding to `$KEY`.


python编码测试资料
参考：
Mooncake/docs/source/python-api-reference
Mooncake/docs/source/design/mooncake-store.md
/home/paas/llc/test/mooncake_transfer_engine-0.3.10-cp311-cp311-manylinux_2_38_aarch64.whl
pip install mooncake_transfer_engine-0.3.10-cp311-cp311-manylinux_2_38_aarch64.whl


e2e 工具 clientctl, chaosctl 使用
参考：
Mooncake/mooncake-store/tests/e2e/readme.md
用例：
mooncake-store/tests/e2e/client_ctl_cases


clientctl

```shell
**Commands**:
- `create [name] [port]`: Create a new client instance.
- `put [client_name] [key] [value]`: Store a key-value pair via the specified client.
- `get [client_name] [key]`: Retrieve a value by key via the specified client.
- `mount [client_name] [segment_name] [size]`: Mount a memory segment from the specified client.
- `remove [client_name]`: Remove a client instance.
- `sleep [seconds]`: Pause execution for the specified duration.
- `terminate`: Exit the program.
```

mount [client_name] [segment_name] [size]：
size的单位是bytes，测试时可以使用1073741824，即1个G

