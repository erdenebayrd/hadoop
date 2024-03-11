# Use Ubuntu as the base image
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND noninteractive

# Install Java, SSH, and other necessary utilities
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    ssh \
    rsync \
    vim \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Hadoop
ENV HADOOP_VERSION 3.3.6
ENV HADOOP_URL https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN wget $HADOOP_URL && \
    tar -xvzf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/local/hadoop && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# Set Hadoop environment variables
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install Spark
ENV SPARK_VERSION 3.5.1
ENV HADOOP_SPARK_VERSION 3
ENV SPARK_URL https://downloads.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_SPARK_VERSION.tgz
RUN wget $SPARK_URL && \
    tar -xvzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_SPARK_VERSION.tgz && \
    mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_SPARK_VERSION /usr/local/spark && \
    rm spark-$SPARK_VERSION-bin-hadoop$HADOOP_SPARK_VERSION.tgz

# Set Spark environment variables
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# Set JAVA_HOME environment variable
RUN MACHINE_TYPE=`uname -m` && \
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then \
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64; \
        # echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /root/.bashrc; \
    elif [ ${MACHINE_TYPE} == 'arm64' ]; then \
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64; \
        # echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64" >> /root/.bashrc; \
    fi

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-arm64
# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin


# Copy configuration files (if any) and scripts to the container
# You would need to create these based on your requirements
COPY hadoop-config/* $HADOOP_CONF_DIR/
COPY spark-config/* $SPARK_HOME/conf/
# COPY scripts /usr/local/bin/

RUN mkdir -p /hadoop/hdfs/namenode
RUN mkdir -p /hadoop/hdfs/datanode

# Format HDFS namenode (This is generally not recommended to do at build time for a production image)
# RUN $HADOOP_HOME/bin/hdfs namenode -format

# Expose ports for Hadoop services (Namenode, Datanode, ResourceManager, NodeManager, etc.)
# and Spark services (Master, Worker, HistoryServer, etc.)
EXPOSE 8088 9870 9864 8042 8080 18080

RUN mkdir -p /tmp/spark-events

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]


#   spark-submit \
#        --class org.apache.spark.examples.SparkPi \
#        --master yarn \
#        --deploy-mode cluster \
#        --driver-memory 1g \
#        --executor-memory 1g \
#        --executor-cores 1 \
#        /usr/local/spark/jars/spark-examples_2.13-3.5.1.jar \
#        1000

# netstat -tuln | grep 8032

# spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster /usr/local/spark/jars/spark-examples_2.13-3.5.1.jar 1000
# spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster /usr/local/spark/examples/jars/spark-examples_2.12-3.5.1.jar 1000
