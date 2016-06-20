#!/bin/bash

. ~/.profile

MASTER_IP=$1
NUM_WORKERS=$2

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
TASKMANAGER_HEAP=$(printf "%.0f" $(echo "0.90 * ($TOTMEM - 1000)" | bc -l))
TASK_SLOTS=$(nproc)
PARALLELISM=$(echo "$TASK_SLOTS * $NUM_WORKERS" | bc -l)
TMP_DIRS=/var/flink/tmp

sudo mkdir -p $TMP_DIRS
sudo chown -R ubuntu $TMP_DIRS

cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-*.jar ${FLINK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar ${FLINK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/httpclient-*.jar ${FLINK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/httpcore-*.jar ${FLINK_HOME}/lib

sed -i "s@jobmanager.rpc.address: localhost@jobmanager.rpc.address: $MASTER_IP@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@jobmanager.heap.mb: 256@jobmanager.heap.mb: 1024@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@taskmanager.heap.mb: 512@taskmanager.heap.mb: $TASKMANAGER_HEAP@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@taskmanager.numberOfTaskSlots: 1@taskmanager.numberOfTaskSlots: $TASK_SLOTS@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@parallelism.default: 1@parallelism.default: $PARALLELISM@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@# taskmanager.tmp.dirs: /tmp@taskmanager.tmp.dirs: $TMP_DIRS@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@# fs.hdfs.hadoopconf: /path/to/hadoop/conf/@fs.hdfs.hadoopconf: $HADOOP_HOME/etc/hadoop@g" $FLINK_HOME/conf/flink-conf.yaml
