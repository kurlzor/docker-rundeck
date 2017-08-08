FROM debian:stretch-slim

MAINTAINER Régis Belson <regis@evaneos.com>

# little hack so openjdk-8-jre-headless installation doesn't fail...
RUN mkdir -p /usr/share/man/man1/

RUN apt-get -qq update \
    && apt-get install --no-install-recommends -qqy \
        curl \
        gosu \
        openjdk-8-jre-headless \
        openssh-client \
        uuid-runtime \
    && rm -rf /var/lib/apt/lists/*

ENV TINI_VERSION 0.15.0
ENV TINI_SHA 4007655082f573603c02bc1d2137443c8e153af047ffd088d02ccc01e6f06170

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

ENV RUNDECK_HOME /var/lib/rundeck

RUN addgroup \
        --system \
        --gid 1000 \
        rundeck \
    && adduser \
        --uid 1000 \
        --gid 1000 \
        --system \
        --home="$RUNDECK_HOME" \
        --disabled-password \
        rundeck

ENV RUNDECK_VERSION 2.9.1

RUN curl -L -o rundeck.deb "http://dl.bintray.com/rundeck/rundeck-deb/rundeck-$RUNDECK_VERSION-1-GA.deb" \
    && dpkg -i rundeck.deb \
    && rm rundeck.deb \
    && rm /etc/init.d/rundeckd \
    && mkdir -p $RUNDECK_HOME/projects \
    && chown -R rundeck:rundeck $RUNDECK_HOME

COPY rundeck.sh /usr/local/bin/rundeck
RUN chown rundeck:rundeck /usr/local/bin/rundeck \
    && chmod +x /usr/local/bin/rundeck

EXPOSE 4440

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/tini", "--", "/entrypoint.sh"]

CMD ["rundeck"]