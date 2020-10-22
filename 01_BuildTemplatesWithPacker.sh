#!/bin/bash

## Generate new analyste SSH keys
cd packer 1>/dev/null 2>&1
rm -f ./FILES/analyste.key ./FILES/analyste.key.pub
yes yes | ssh-keygen -q -t rsa -N "" -f ./FILES/analyste.key -b 4096 -C "analyste@dfirlab.local"
cd - 1>/dev/null 2>&1


for template in `find packer -name 'build.sh' `; 
do 
  template_dir=`dirname $template`
  cd $template_dir 1>/dev/null 2>&1
  template_conf=`find . -iname *.json`
  echo "Generation du template : `cat $template_conf | grep 'vm_name' | awk -F '"' '{print $4}'`"
  ./build.sh
  cd - 1>/dev/null 2>&1
done
