#!/bin/bash


## Remove old files
rm -rf /media/analyste/4b1e2b12-0d2d-48c5-812c-761c943b7f09/PACKER-cuckooVM/win10
## Generate machine
export PACKER_LOG=1; packer build win10.json




## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Remove cache directory
rm -rf ./packer_cache
