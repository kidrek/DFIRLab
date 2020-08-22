#!/bin/bash

# Suppression du fichier de log
rm -f build.log

# Deploiement de la plateforme
yes yes | /usr/bin/terraform-0.12 apply | tee -a build.log; ( exit ${PIPESTATUS[0]})
ret=$?

# Test le code retour du deploiement 
if [ $ret -eq 1 ]; then
  ## S'il y a eu un probleme, les dernieres lignes du fichier de log sont envoyees sur le channel de slack pour debogage
  tail -n10 build.log | ../slack-msg.sh
else
  ## Si le deploiement s'est bien passe, la cle ssh est envoyee sur le channel slack pour que les analystes puissent se connecter aux differentes vm
  echo "[SUCCESS] Terraform deployement" | ../slack-msg.sh
  ../slack-uploadfile.sh ../packer/FILES/analyste.key "SSH Key for analyste User"
  rm -f build.log
fi
