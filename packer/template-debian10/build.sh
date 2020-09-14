#!/bin/bash


## Remove old files
### Remove old ova
NAME="`cat debian10.json| egrep '"name":' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`.ova"
DIRECTORY=`cat debian10.json| egrep 'output_directory' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g'`
rm -rf $DIRECTORY/$NAME
## Remove old log file
rm -f build.log

## Generate new analyste SSH keys
rm -f ../FILES/analyste.key ../FILES/analyste.key.pub
yes yes | ssh-keygen -q -t rsa -N "" -f ../FILES/analyste.key -b 4096 -C "analyste@dfirlab.local"


## Generate preseed with strong password
password_root=`../SCRIPTS/generate-password.sh`
password_analyste=`../SCRIPTS/generate-password.sh`
analyste_ssh_key=`cat ../FILES/analyste.key.pub`
sed "s/<password_root>/$password_root/; s/<password_analyste>/$password_analyste/; s|<analyste_ssh_key>|$analyste_ssh_key|" ./http/preseed.cfg.tpl > ./http/preseed.cfg

## Generate new ova
export PACKER_LOG=1; packer build debian10.json | tee -a build.log
if [ `tail -n 50 build.log | egrep "Failed to prepare build|Builds finished but no artifacts were created" | grep -v "grep" | wc -l` -eq 0 ]; then
  echo "Packer [template-debian10] : Success" | ../../slack-msg.sh
else
  echo "Packer [template-debian10] : Failure" | ../../slack-msg.sh
  tail -n20 build.log | ../../slack-msg.sh
fi

## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches
## Remove temp files
rm -rf ./packer_cache
rm -rf ./http/preseed.cfg
