# DFIRLab


Ce projet a pour but d'offrir une plateforme d'investigation facilement déployable.

Elle est constituée :
* d'un serveur de fichier SAMBA
* d'un serveur d'analyse, contenant une instance ELK
* d'un serveur d'analyse en sandbox Cuckoo
* de deux machines contenant des outils d'analyse Forensic, en environnement Debian et Microsoft Windows.

Les preuves sont à transférer vers le serveur de stockage (Samba). 
Une fois le transfert effectué, elles seront accessibles des autres serveurs.

!! Ce projet est toujours en cours d'élaboration !! 

## Mise en oeuvre

Il est impératif de dédier un serveur virtuel pour faciliter la génération des templates et de leur déploiement.
Les templates de machine virtuelle sont générés grâce à l'outil Packer.
Le déploiement de la plateforme est quant à lui assuré par l'outil Terraform.

### Packer


### Terraform

### Tips

Packer et Terraform utilise une connexion SSH sur les machines virtuelles nouvelles créées pour y installer des paquets ou y appliquer certaines configurations. Afin d'éviter l'attente d'une validation 'Fingerprint' durant le déploiement, j'ai du appliquer la configuration suivante :

```
# vi $HOME/.ssh/config 
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ControlMaster auto
  ControlPath /tmp/socket-%r@%h:%p
  ControlPersist 3600
```
