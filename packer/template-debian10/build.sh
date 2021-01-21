#!/bin/bash


## Remove old files
### Remove old ova
NAME="`cat debian10.json| egrep '"name":' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`.ova"
DIRECTORY=`cat debian10.json| egrep 'output_directory' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g'`
rm -rf $DIRECTORY/$NAME
## Remove old log file
rm -f build.log

## Generate SSH Keys
if [ ! -f ../FILES/analyste.key ]; then
  echo "Generate SSH keys"; yes yes | ssh-keygen -q -t rsa -N "" -f ../FILES/analyste.key -b 4096 -C "analyste@dfirlab.local"
fi

## Generate preseed with strong password
password_root=`../SCRIPTS/generate-password.sh`
password_analyste=`../SCRIPTS/generate-password.sh`
analyste_ssh_key=`cat ../FILES/analyste.key.pub`
sed "s/<password_root>/$password_root/; s/<password_analyste>/$password_analyste/; s|<analyste_ssh_key>|$analyste_ssh_key|" ./http/preseed.cfg.tpl > ./http/preseed.cfg

## Generate new ova
export PACKER_LOG=1; packer build -var-file=../variables.json debian10.json | tee -a build.log

## Remove temp files
rm -rf ./packer_cache
rm -rf ./http/preseed.cfg
