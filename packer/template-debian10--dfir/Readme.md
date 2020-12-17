# Template / Debian10 -- with DFIR tools



## Plaso

Plaso in a Docker container is on system.
references: https://plaso.readthedocs.io/en/latest/sources/user/Installing-with-docker.html


First of all, retrieve some requirements like Yara rules, and Filter to limit time to analyse. These files are implemented during packer generation.

```
cp /opt/malware_rules.yar . 
cp /usr/share/plaso/filter_windows.txt .
```


To use log2timeline, use this command. It's necessary to be in the same place of evidence files. Then add "/data/" in arguments to use binding.

```
docker run -v $(pwd):/data log2timeline/plaso log2timeline --no_dependencies_check -u -q --partitions all --volumes all -z UTC --yara_rules /data/malware_rules.yar -f /data/filter_windows.txt /data/evidence.plaso /data/<evidence>

docker run -v $(pwd):/data log2timeline/plaso psort -o l2tcsv -w /data/evidence-timeline.csv /data/evidence.plaso
```
