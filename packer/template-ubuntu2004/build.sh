#!/bin/bash


## Remove old files
### Remove old ova
NAME="`cat ubuntu-2004.json| egrep '"name":' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`.ova"
DIRECTORY=`cat ubuntu-2004.json| egrep 'output_directory' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g'`
rm -rf $DIRECTORY/$NAME
## Remove old log file
rm -f build.log

## Generate preseed with strong password
password_analyste=`../SCRIPTS/generate-password.sh`
password_analyste_tmp=`openssl passwd -6 -salt xyz $password_analyste`
password_analyste=$password_analyste_tmp
analyste_ssh_key=`cat ../FILES/analyste.key.pub`
sed "s|<password_analyste>|$password_analyste|; s|<analyste_ssh_key>|$analyste_ssh_key|" ./http/user-data.tpl > ./http/user-data

## Generate new ova
export PACKER_LOG=1; packer build ubuntu-2004.json | tee -a build.log

## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches
## Remove temp files
rm -rf ./packer_cache
