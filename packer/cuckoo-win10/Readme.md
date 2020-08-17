# Template de machine Microsoft Windows 10 (QEMU/KVM)

Cette machine virtuelle va être utilisé dans le cadre d'analyse dynamique d'exécutable, afin d'identifier des charges malveillantes.

## Génération via PACKER

## Test de bon fonctionnement

Il est important de vérifier que toutes les modifications souhaitées soient appliquées.
Pour ce faire, la machine virtuelle peut être démarrée via l'outil qemu.

```
# qemu-system-x86_64 -machine type=pc accel=kvm -m 1024 -smp 2 -boot disk -name Win10.qcow2 -usbdevice tablet -display gtk -drive file=../ova/PACKER-cuckooVM/win10/Win10.qcow2 if=virtio cache=writeback discard=ignore format=qcow2
```
