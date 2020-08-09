# Template / Microsoft Windows 10

Ce template est généré à partir de l'iso Microsoft Windows 10, provenant du programme d'évaluation disponible ici : 
https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise.

J'ai choisi pour mon projet les caractéristiques suivantes : 
* Architecture : 64Bits
* Version : Enterprise
* Licence : La licence est valide pour une durée de 90jours. Cette durée limitée n'est pas problématique. Les plateformes étant ephémères, les templates seront générés tous les 2mois afin de pallier tout problème à l'usage. 

L'iso correspondant à ces caractéristiques peut être téléchargé via l'url : 
https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso


J'y ai appliqué les scripts suivants : 
* Installation des dernières mises à jour
* Installation de logiciels grâce à Chocolatey : Firefox(ESR), 7zip, Git
* Installation des VmwareTools
* Désactivation de l'hibernation et de l'écran de veille
* Création d'un utilisateur **analyste** associé au mot de passe **analyste**. Cet utilisateur est d'ailleurs celui utilisé par défaut, et se connecte automatiquement "Autologon".
