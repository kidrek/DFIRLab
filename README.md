# DFIRLab


Ce projet a pour but d'offrir à toutes équipes de réponse à incident une plateforme prête à mener une investigation.

Elle est constituée :
* d'un serveur de fichier SAMBA
* d'un serveur d'analyse, contenant une instance ELK
* d'un serveur d'analyse en sandbox Cuckoo
* de deux machines contenant des outils d'analyse Forensic, en environnement Debian et Microsoft Windows.

Les preuves sont transférées vers le serveur de stockage (Samba). 
Elles seront ensuite accessibles des autres serveurs.

!! Ce projet est toujours en cours d'élaboration !! 

## Mise en oeuvre

Pour faciliter la génération des templates et de leur déploiement, il est impératif d'appliquer quelques ajustements sur le système hôte.
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
