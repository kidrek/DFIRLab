#!/bin/bash


## Remove old files
rm -rf ./template-Win10.ova 2>/dev/null

## Generate machine
export PACKER_LOG=1; packer build win10.json

## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Remove cache directory
rm -rf ./packer_cache
