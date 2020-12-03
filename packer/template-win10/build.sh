#!/bin/bash


## Remove old files
rm -rf ./template-Win10.ova 2>/dev/null

## Generate machine
export PACKER_LOG=1; packer build -var-file=../variables.json win10.json | tee build.log

## Remove cache directory
rm -rf ./packer_cache
