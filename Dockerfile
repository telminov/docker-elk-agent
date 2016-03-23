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
                                                filebeat \
                                                topbeat

RUN mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.default
RUN mv /etc/topbeat/topbeat.yml /etc/topbeat/topbeat.yml.default
ADD config/filebeat.yml /etc/filebeat/filebeat.yml
ADD config/topbeat.yml /etc/topbeat/topbeat.yml


CMD test "$(ls /conf/filebeat.yml)" || cp /etc/filebeat/filebeat.yml /conf/filebeat.yml; \
    test "$(ls /conf/topbeat.yml)" || cp /etc/topbeat/topbeat.yml /conf/topbeat.yml; \
    rm /etc/filebeat/filebeat.yml; ln -s /conf/filebeat.yml /etc/filebeat/filebeat.yml; \
    rm /etc/topbeat/topbeat.yml; ln -s /conf/topbeat.yml /etc/topbeat/topbeat.yml; \
    service filebeat start; \
    service topbeat start; \
    sleep 2;\
    tail -f /var/log/filebeat /var/log/topbeat
