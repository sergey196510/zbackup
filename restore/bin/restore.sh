#!/bin/bash

cd /var/tmp
/opt/bin/extract-mysql.sh /opt/data/*.bz2
cd restore
/opt/bin/prepare-mysql.sh
