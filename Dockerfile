FROM debian:buster

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates gnupg wget libjemalloc2 && \
    apt-get clean && \
    wget -q -O - https://www.apache.org/dist/cassandra/KEYS | apt-key add - && \
    echo "deb http://www.apache.org/dist/cassandra/debian 311x main" >> /etc/apt/sources.list.d/cassandra.list
# https://wiki.apache.org/cassandra/DebianPackaging#Adding_Repository_Keys

ENV MAX_HEAP_SIZE=300M \
    HEAP_NEWSIZE=80M \
    CASSANDRA_CONFIG=/etc/cassandra \
    CASSANDRA_VERSION=3.11.8

RUN apt-get update \
	&& apt-get install -y \
		cassandra="$CASSANDRA_VERSION" \
		cassandra-tools="$CASSANDRA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*
# https://issues.apache.org/jira/browse/CASSANDRA-11661
RUN sed -ri 's/^(JVM_PATCH_VERSION)=.*/\1=25/' /etc/cassandra/cassandra-env.sh

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod ugo+x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod -R 777 /tmp

RUN sed -i '/UseParNewGC/d' /etc/cassandra/jvm.options  && \
    sed -i '/ThreadPriorityPolicy/d' /etc/cassandra/cassandra-env.sh && \
    sed -i '/PrintGCDateStamps/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintHeapAtGC/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintTenuringDistribution/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintGCApplicationStoppedTime/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintPromotionFailure/d' /etc/cassandra/jvm.options && \
    sed -i '/UseGCLogFileRotation/d' /etc/cassandra/jvm.options && \
    sed -i '/NumberOfGCLogFiles/d' /etc/cassandra/jvm.options && \
    sed -i '/GCLogFileSize/d' /etc/cassandra/jvm.options && \
    sed -i "s/batch_size_fail_threshold_in_kb.*/batch_size_fail_threshold_in_kb: 2048/g" /etc/cassandra/cassandra.yaml

ADD load_schema.sh /tmp/load_schema.sh

ONBUILD ADD schema*.cql /tmp/
ONBUILD RUN bash /tmp/load_schema.sh

EXPOSE 9042
CMD ["cassandra", "-f"]

STOPSIGNAL SIGKILL
