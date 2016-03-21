# docker build -t telminov/elk-agent .

FROM ubuntu:14.04
MAINTAINER telminov@soft-way.biz


VOLUME /conf/
VOLUME /tls/            # cerstificate paths

RUN apt-get -qqy update && apt-get install -qqy \
                                                unzip \
                                                wget \
                                                curl \
                                                apt-transport-https


RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://packages.elastic.co/beats/apt stable main" |  tee -a /etc/apt/sources.list.d/beats.list

RUN apt-get -qqy update && apt-get install -qqy \
                                                filebeat

RUN mv /etc/filebeat/filebeat.yml  /etc/filebeat/filebeat.yml.default
ADD config/filebeat.yml /etc/filebeat/filebeat.yml


CMD test "$(ls /conf/filebeat.yml)" || cp /etc/filebeat/filebeat.yml /conf/filebeat.yml; \
    rm /etc/filebeat/filebeat.yml; ln -s /conf/filebeat.yml /etc/filebeat/filebeat.yml; \
    service filebeat start; sleep 2;\
    tail -f /var/log/filebeat
