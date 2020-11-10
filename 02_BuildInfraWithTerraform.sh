#!/bin/bash

###############################################################
#  Deploy Infra auto with Terraform on remote ESXi            #
#  Date: 2020/11/10                                           #
#  Description : The Configuration is based on the .tf files  #
###############################################################

for template in `find terraform -name 'build.sh' `; 
do 
  template_dir=`dirname $template`
  cd $template_dir 1>/dev/null 2>&1
  template_conf=`find . -iname '*.tf'`
  echo "Deploiement de l'infrastructure : `echo $template_conf `"
  ./build.sh
  cd - 1>/dev/null 2>&1
done
