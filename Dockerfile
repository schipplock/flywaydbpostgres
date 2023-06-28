FROM ubuntu:22.04 as build
SHELL ["/bin/bash", "-c"]

ARG FLYWAYDB_VERSION=9.20.0
ARG POSTGRES_JDBC_DRIVER_VERSION=42.6.0

ENV DEBIAN_FRONTEND=noninteractive

# Falls der Ubuntu-Server mal wieder rumspackt (tut er manchmal),
# kann man hier einen Mirror eintragen
#COPY ubuntu/sources.list /etc/apt/sources.list

COPY entrypoint.sh /opt/flywaydb/entrypoint.sh

RUN apt-get update && apt-get install -y \
  wget

RUN mkdir -p /opt/flywaydb \
 && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAYDB_VERSION}/flyway-commandline-${FLYWAYDB_VERSION}-linux-x64.tar.gz \
 && tar xf flyway-commandline-${FLYWAYDB_VERSION}-linux-x64.tar.gz -C /opt/flywaydb --strip-components=1 \
 && cd /opt/flywaydb \
 && rm -rf jre \
 && rm -rf drivers && mkdir drivers && cd drivers && wget https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar && cd .. \
 && cd /

RUN mkdir -p /opt/java \
 && wget "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.6%2B10/OpenJDK17U-jre_x64_linux_hotspot_17.0.6_10.tar.gz" \
 && tar xf OpenJDK17U-jre_x64_linux_hotspot_17.0.6_10.tar.gz -C /opt/java --strip-components=1 \
 && rm -rf /opt/java/{man,legal}

FROM ubuntu:22.04
SHELL ["/bin/bash", "-c"]

ENV LANG de_DE.utf8
ENV TZ Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/java
ENV PATH=/opt/java/bin:/opt/flywaydb:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=build /opt/java /opt/java
COPY --from=build /opt/flywaydb /opt/flywaydb

RUN apt-get update && apt-get install -y \
  locales tzdata nano \
 && locale-gen ${LANG} \
 && update-locale LANG=${LANG} \
 && cp -vf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo ${TZ} | tee /etc/timezone \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && addgroup --gid 1000 flywaydb \
 && adduser --system --uid 1000 --no-create-home --shell /bin/bash --home "/opt/flywaydb" --gecos "" --ingroup flywaydb flywaydb \
 && echo flywaydb:flywaydb | chpasswd \
 && chmod +x /opt/flywaydb/entrypoint.sh \
 && chown -R flywaydb:flywaydb /opt/flywaydb \
 && rm -rf /var/lib/apt/lists/* \
 && true

USER flywaydb
WORKDIR /opt/flywaydb
ENTRYPOINT ["/opt/flywaydb/entrypoint.sh"]