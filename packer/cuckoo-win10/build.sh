#!/bin/bash


## Remove old files
rm -rf ../ova/PACKER-cuckooVM/win10
## Build machine
export PACKER_LOG=1; packer build win10.json | tee build.log

if [ $? -ne 0 ]; then
  echo "Packer [template-cuckoo_win10] : Failure" | ../../slack-msg.sh
  tail -n20 build.log | ../../slack-msg.sh
else
  echo "Packer [template-cuckoo_win10] : Success" | ../../slack-msg.sh
  #rm -f build.log
fi


## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Remove cache directory
rm -rf ./packer_cache
