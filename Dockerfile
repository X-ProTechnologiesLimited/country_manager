FROM python:3.7-alpine
WORKDIR /app

ARG JMETER_VERSION="5.1.1"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV     JMETER_BIN      ${JMETER_HOME}/bin
ENV MIRROR_HOST http://mirrors.ocf.berkeley.edu/apache/jmeter
ENV JMETER_PLUGINS_DOWNLOAD_URL http://repo1.maven.org/maven2/kg/apc
ENV JMETER_PLUGINS_FOLDER ${JMETER_HOME}/lib/ext/
ENV     JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

RUN    apk --update --upgrade add --no-cache \
        && apk upgrade \
        && apk add ca-certificates \
        && update-ca-certificates \
        && apk add --update openjdk8-jre tzdata curl unzip bash \
        && apk add --no-cache nss \
        && apk add --no-cache tzdata \
        && rm -rf /var/cache/apk/* \
        && mkdir -p /tmp/dependencies  \
        && curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
        && mkdir -p /opt  \
        && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
        && rm -rf /tmp/dependencies


RUN curl -L --silent ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-casutg/2.9/jmeter-plugins-casutg-2.9.jar -o ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-casutg-2.9.jar

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN
ENV TZ Europe/London

COPY tests/ /app/tests
COPY lib/ /app/lib
COPY requirements.txt /app/
COPY utils /app/utils/
COPY initialise_db.py /app/

ENV CONTAINERISED true

USER root
RUN apk add --update python3
RUN apk add --no-cache bash
RUN apk add sqlite
RUN apk update && apk add g++ gcc
RUN pip3 install --upgrade pip setuptools
RUN pip3 install -r requirements.txt
RUN if [ -d "lib/__pycache__/" ] ; then rm -rf lib/__pycache__ ; fi
RUN if [ -d "tests/__pycache__/" ] ; then rm -rf tests/__pycache__ ; fi
RUN if [ -d "tests/test_output" ] ; then rm -f tests/test_output/* ; fi
USER root
RUN /bin/sh

ENTRYPOINT ["utils/start_app.sh", "Jenkins"]
