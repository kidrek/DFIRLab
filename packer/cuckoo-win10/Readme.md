# Template de machine Microsoft Windows 10 (QEMU/KVM)

Cette machine virtuelle va être utilisée dans le cadre d'analyse dynamique d'exécutable.
Celles-ci permettront d'identifier des charges malveillantes.

Pour obtenir un maximum d'information, l'outil sysmon a été integré à la machine virtuelle. 
Les événements produits par Sysmon seront transférés par Winlogbeat à l'instance ElasticSearch du lab pour une analyse ultérieure.

L'authentification s'effectue automatiquement avec les informations de l'utilisateur analyste.
Cet utilisateur fait partie du groupe administrateur pour permette une exécution optimale des exécutables qui seront soumis à la Sandbox.
* nom d'utilisateur : analyste
* mot de passe : analyste

## Génération via PACKER

## Test de bon fonctionnement

Il est important de vérifier que toutes les modifications souhaitées soient appliquées.
Pour ce faire, la machine virtuelle peut être démarrée via l'outil qemu.

```
# qemu-system-x86_64 -machine type=pc accel=kvm -m 1024 -smp 2 -boot disk -name Win10.qcow2 -usbdevice tablet -display gtk -drive file=../ova/PACKER-cuckooVM/win10/Win10.qcow2 if=virtio cache=writeback discard=ignore format=qcow2
```
