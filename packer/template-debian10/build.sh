#!/bin/bash


## Remove old files
rm -rf ./ova/template-debian10.ova 2>/dev/null

## Generate machine
rm build.log
export PACKER_LOG=1; packer build debian10.json | tee -a build.log
ret=${?}

## Send logs and result in my slack channel
if [ `tail -n 50 build.log | egrep "Failed to prepare build|Builds finished but no artifacts were created" | grep -v "grep" | wc -l` -eq 0 ]; then
  echo "Packer [template-debian10] : Success" | ../../slack-msg.sh
else
  echo "Packer [template-debian10] : Failure" | ../../slack-msg.sh
  tail -n20 build.log | ../../slack-msg.sh
fi

## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches

## Remove cache directory
rm -rf ./packer_cache
