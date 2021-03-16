#!/bin/bash

/opt/bin/extract-mysql.sh /opt/data/Sat
cd /opt/data/restore
/opt/bin/prepare-mysql.sh
