FROM ubuntu
MAINTAINER Sergey Lang <lsi@lserg.ru>
ENV TZ=Europe/Samara
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt -y install tzdata mariadb-backup
COPY bin /opt/bin

CMD /opt/bin/restore.sh
