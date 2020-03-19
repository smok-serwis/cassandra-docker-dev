FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates gnupg wget libjemalloc2 && apt-get clean

# https://wiki.apache.org/cassandra/DebianPackaging#Adding_Repository_Keys
RUN wget -q -O - https://www.apache.org/dist/cassandra/KEYS | apt-key add -
RUN echo "deb http://www.apache.org/dist/cassandra/debian 30x main\ndeb-src http://www.apache.org/dist/cassandra/debian 30x main" >> /etc/apt/sources.list.d/cassandra.list

ENV CASSANDRA_VERSION 3.0.20

RUN apt-get update \
	&& apt-get install -y \
		cassandra="$CASSANDRA_VERSION" \
		cassandra-tools="$CASSANDRA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*
# https://issues.apache.org/jira/browse/CASSANDRA-11661
RUN sed -ri 's/^(JVM_PATCH_VERSION)=.*/\1=25/' /etc/cassandra/cassandra-env.sh

ENV CASSANDRA_CONFIG /etc/cassandra
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod ugo+x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod -R 777 /tmp

ENV MAX_HEAP_SIZE=300M
ENV HEAP_NEWSIZE=80M

RUN sed -i '/UseParNewGC/d' /etc/cassandra/jvm.options  && \
    sed -i '/ThreadPriorityPolicy/d' /etc/cassandra/cassandra-env.sh && \
    sed -i '/PrintGCDateStamps/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintHeapAtGC/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintTenuringDistribution/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintGCApplicationStoppedTime/d' /etc/cassandra/jvm.options && \
    sed -i '/PrintPromotionFailure/d' /etc/cassandra/jvm.options && \
    sed -i '/UseGCLogFileRotation/d' /etc/cassandra/jvm.options && \
    sed -i '/NumberOfGCLogFiles/d' /etc/cassandra/jvm.options && \
    sed -i '/GCLogFileSize/d' /etc/cassandra/jvm.options

ADD load_schema.sh /tmp/load_schema.sh

ONBUILD ADD schema.cql /tmp/schema.cql
ONBUILD RUN bash /tmp/load_schema.sh

EXPOSE 9042
CMD ["cassandra", "-f"]

STOPSIGNAL SIGKILL
