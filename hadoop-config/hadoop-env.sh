#!/usr/bin/env bash

# export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root 
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop
export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native
# export HADOOP_OPTS="-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR"
export HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib"
