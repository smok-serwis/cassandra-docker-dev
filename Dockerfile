FROM debian:bullseye


ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-11-jre-headless gnupg2 python3 libjemalloc2 && \
    apt-get clean

RUN mkdir -p /etc/ssl/certs/java/ && \
    apt install --reinstall -o Dpkg::Options::="--force-confask,confnew,confmiss" --reinstall ca-certificates-java ssl-cert openssl ca-certificates && \
    apt-get clean


ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

LABEL apache.cassandra.version="4.1.7"

# Cassandra apt-get
ADD cassandra.sources.list /etc/apt/sources.list.d/cassandra.sources.list
ADD https://www.apache.org/dist/cassandra/KEYS /tmp/repo_key
RUN  apt-key add /tmp/repo_key && \
     apt-get update --fix-missing && \
     apt-get install -y --no-install-recommends cassandra cassandra-tools && \
     apt-get clean

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod ugo+x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra \
	&& chown -R cassandra:cassandra /var/lib/cassandra  \
	&& chmod 777 /var/lib/cassandra \
	&& chmod -R 777 /tmp


ADD load_schema.sh /tmp/load_schema.sh

ENV NEW_HEAP_SIZE=300M

EXPOSE 9042

STOPSIGNAL SIGKILL

ONBUILD ADD schema*.cql /tmp/
ONBUILD RUN bash /tmp/load_schema.sh

CMD ["cassandra", "-R", "-f"]
