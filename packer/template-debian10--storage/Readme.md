
# Serveur dédié au stockage

Ce serveur a été pensé pour pouvoir partager facilement des prélévements entre plusieurs membres d'une équipe de réponse à incident.
Ils pourront ainsi récupérer les fichiers dont ils ont besoin afin de les analyser soit sur leurs machines soit sur les machines dfir (Linux/Windows).

Basé sur une distribution Linux/Debian10, ce serveur intègre un serveur SAMBA.
Il n'est donc pas recommandé d'effectuer les traitements sur les prélèvements directement sur le partage SAMBA.
Mieux vaut les copier sur les machines d'analyse puis lancer les traitements.
Les résultats seront ensuite poussés sur ce partage afin que les autres analystes puissent en bénéficier.
