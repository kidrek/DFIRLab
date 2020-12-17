#!/bin/bash


## Remove old files
rm -rf ../ova/PACKER-cuckooVM/win10

## Download CAPEv2 Agent
curl https://raw.githubusercontent.com/kevoreilly/CAPEv2/master/agent/agent.py -o ../FILES/capev2_agent.py

## Build machine
export PACKER_LOG=1; packer build win10.json | tee build.log

## Flush memory cache
echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Remove cache directory
rm -rf ./packer_cache
