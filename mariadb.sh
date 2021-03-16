docker run -d --rm \
    -e MYSQL_ROOT_PASSWORD=nfh0rfy \
    -e MYSQL_DATABASE=zabbix \
    -v /var/run/mysqld:/var/run/mysqld \
    --name mariadb \
    -p 3306:3306 \
    mariadb
