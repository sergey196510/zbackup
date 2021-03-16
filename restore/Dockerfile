FROM mariadb
MAINTAINER Sergey Lang <lsi@lserg.ru>
ENV TZ=Europe/Samara
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt -y install tzdata mariadb-backup
COPY bin /opt
COPY backup.cnf /etc/mysql
COPY schema.sql /docker-entrypoint-initdb.d

RUN echo innodb_buffer_pool_size = 6G                    >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo innodb_buffer_pool_instances = 6                >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo innodb_log_file_size = 1536M                    >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo #innodb_data_file_path = ibdata1:10M:autoextend >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo innodb_flush_log_at_trx_commit = 2              >> /etc/mysql/mariadb.conf.d/50-server.conf

RUN echo query_cache_size = 0    >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo query_cache_type = 0    >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo query_cache_limit = 1M  >> /etc/mysql/mariadb.conf.d/50-server.conf
RUN echo table_open_cache = 2500 >> /etc/mysql/mariadb.conf.d/50-server.conf

WORKDIR /opt/data
