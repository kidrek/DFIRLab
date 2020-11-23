#!/bin/bash

# Variables
CONCURRENCY=3
# BINARY
VOLATILITY="python /opt/volatility/vol.py"
LOKI=`find /opt/ -name loki.py -type f`
## Elasticsearch
ES_export=False
ES_host="10.1.1.11"
ES_port="9200"
ES_index="volatility"
## Dump memory to analyse
DMP_dir=/media/evidences/

## Function to launch volatility plugin
task(){
  CACHE_dir="/dev/shm/volatility"
  $VOLATILITY -f $1 --profile=$2 --kdbg=$3 --dtb=$4 --tz=UTC $5
  #$VOLATILITY -f $1 --profile=$2 --kdbg=$3 --dtb=$4 --tz=UTC --cache-directory=$CACHE_dir --cache $5
}

## Function to generate timeline
task_timeline(){
  CACHE_dir="/dev/shm/volatility"
  #$VOLATILITY -f $1 --profile=$2 --kdbg=$3 --dtb=$4 --tz=UTC --output=body --cache-directory=$CACHE_dir --cache $5 > $1.output/$5.body
  $VOLATILITY -f $1 --profile=$2 --kdbg=$3 --dtb=$4 --tz=UTC --output=body $5 > $1.output/$5.body
}

cd $DMP_dir 1>/dev/null

## Yarascan
wget https://gist.githubusercontent.com/andreafortuna/29c6ea48adf3d45a979a78763cdc7ce9/raw/4ec711d37f1b428b63bed1f786b26a0654aa2f31/malware_yara_rules.py -O ./malware_yara_rules.py 
mkdir rules 2>/dev/null
python malware_yara_rules.py 

## Update Loki
cd /opt/Loki/; yes | python ./loki.py --update; cd -


for dumpmem in `find $DMP_dir -type f | egrep '*\.mem$|*\.dmp$|*\.vmem$' | grep -v '.output' 2>/dev/null`; 
do 
  DMP_filename=`basename $dumpmem | tr '[:upper:]' '[:lower:]'`
  # exit if dump has been already analysed
  if [ -d $dumpmem.output ]; then 
    echo "$DMP_filename already analyzed";  
    exit 0
  else
    echo "[$DMP_filename] Start imageinfo processing" | tee $dumpmem.log
    if [ -f $dumpmem.imageinfo ]; then 
      echo "[$DMP_filename] Status imageinfo already done";  
    else
      ## Identify profile from dump memory
      $VOLATILITY -f $dumpmem imageinfo > $dumpmem.imageinfo
      echo "[$DMP_filename] Status imageinfo done";  
    fi

    if [ ! -f $dumpmem.profile ]; then 
      VOLATILITY_profile_suggestion=`cat $dumpmem.imageinfo | grep 'No suggestion' | wc -l`
      if [ $VOLATILITY_profile_suggestion -eq 0 ]; then
        ## Extract profiles from imageinfo plugin
        profile_list=`cat $dumpmem.imageinfo | grep 'Suggested Profile(s)' | awk -F " : " '{print $2}' | awk -F "(" '{print $1}'`
        kdbg_tmp=`cat $dumpmem.imageinfo | grep 'KDBG :' | awk -F ': ' '{print $2}'` 
        kdbg="${kdbg_tmp:0:-1}"
        dtb_tmp=`cat $dumpmem.imageinfo| grep 'DTB :' | awk -F ': ' '{print $2}'`
        dtb="${dtb_tmp:0:-1}"
        set -f
        profile_array=(${profile_list//,/ })
        ### Try to extract files from memorydump for each profile to determine the GOOD profile
        for index in "${!profile_array[@]}"; 
        do 
          profile=${profile_array[$index]}
          echo "TEST Profile: $profile on $dumpmem"
          #result=`timeout 60s $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb --output=greptext filescan | wc -l`
          result=`timeout 60s $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb --output=greptext hivelist | wc -l`
          ### Execute plugins once the right profile is found
          if [ $result -gt 5 ]; then
            echo "[$DMP_filename] Profile: $profile"  | tee -a $dumpmem.log
            echo $profile > $dumpmem.profile
            echo $kdbg > $dumpmem.kdbg
            echo $dtb > $dumpmem.dtb
            break
          fi
        done
      fi
    fi


    ###############    
    if [ -f $dumpmem.profile ]; then 
      profile=`cat $dumpmem.profile` 
      kdbg=`cat $dumpmem.kdbg` 
      dtb=`cat $dumpmem.dtb` 
      mkdir $dumpmem.output 2>/dev/null

      ##########################################################################
      ### Generate timeline
      for plugin in timeliner mftparser shellbags ; do
        echo "[$dumpmem] Launch: $plugin"  | tee -a $dumpmem.log
        task_timeline $dumpmem $profile $kdbg $dtb $plugin & 
      done
      while [ `ps aux | grep -v grep | grep -i 'vol.py -f' | wc -l` -gt 0 ]
      do
        sleep 1
      done
      cat $dumpmem.output/timeliner.body > $dumpmem.output/memory-timeline.tmp.body
      cat $dumpmem.output/mftparser.body >> $dumpmem.output/memory-timeline.tmp.body
      cat $dumpmem.output/shellbags.body >> $dumpmem.output/memory-timeline.tmp.body
      sort -u $dumpmem.output/memory-timeline.tmp.body > $dumpmem.output/memory-timeline.body
      mactime -z UTC -y -d -b $dumpmem.output/memory-timeline.body > $dumpmem.output/memory-timeline-mactime.csv
      log2timeline.py --artifact_definitions /usr/local/share/artifacts/ --parsers "mactime" --no_dependencies_check  -z UTC /dev/shm/memory-timeline.plaso $dumpmem.output/memory-timeline.body 
      mv /dev/shm/memory-timeline.plaso $dumpmem.output/
      psort.py -z UTC -o l2tcsv -w $dumpmem.output/memory-timeline-psort.csv $dumpmem.output/memory-timeline.plaso
      # Send psort result in Elasticsearch
      if [ $ES_export = True ]
      then
        psort.py -z UTC -o elastic --server $ES_host --port $ES_port --flush_interval 50 --raw_fields --index_name $ES_index.$DMP_filename.timeline $dumpmem.output/memory-timeline.plaso
      fi

      #### SCAN Malfind output
      # Hardening analyse
      #####################
      mkdir -p $dumpmem.output/malfind-output
      mkdir -p $dumpmem.output/malfind-dump-process
      mkdir -p $dumpmem.output/malfinddeep-output
      mkdir -p $dumpmem.output/malfinddeep-dump-process

      ## Malfind
      $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb malfind -D $dumpmem.output/malfind-output | tee $dumpmem.output/malfind
      for i in `cat $dumpmem.output/malfind | grep 'Pid:' | awk -F " " '{print $4}' | sort -u`
      do 
        $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb procdump -p $i -u -m -D $dumpmem.output/malfind-dump-process &
        while [ `ps aux | grep -v grep | grep -i 'vol.py -f' | wc -l` -gt $CONCURRENCY ]
        do
          sleep 1
        done
      done
      #####################
      ## Malfinddeep
      $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb malfinddeep -W -D $dumpmem.output/malfinddeep-output | tee $dumpmem.output/malfinddeep_-W
      for i in `cat $dumpmem.output/malfinddeep_-W | grep 'Pid:' | awk -F " " '{print $4}' | sort -u`
      do 
        $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb procdump -p $i -u -m -D $dumpmem.output/malfinddeep-dump-process &
        while [ `ps aux | grep -v grep | grep -i 'vol.py -f' | wc -l` -gt $CONCURRENCY ]
        do
          sleep 1
        done
      done
      
      ## Extract all registry
      mkdir $dumpmem.output/dumpregistry-output
      $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb dumpregistry -D $dumpmem.output/dumpregistry-output | tee $dumpmem.output/dumpregistry
      #############
      ## Loki scan
      cd `dirname $LOKI`
      python2 loki.py --dontwait --intense --pesieveshellc -p $dumpmem.output/ -l $dumpmem.output/analyse.loki.log
      cd -
      #############
      ## Clamscan
      clamscan --quiet -i -l $dumpmem.output/analyse.clamav.log -r $dumpmem.output 
      ##############
      ## Yarascan
      cp malware_rules.yar $dumpmem.output/
      $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb yarascan -y $dumpmem.output/malware_rules.yar | grep "Rule:" | grep -v "Str_Win32" | sort | uniq | tee $dumpmem.output/yarascan

      ## Extract all PCAP from dump
      bulk_extractor -x all -e net -o $dumpmem.output/packet/ $dumpmem
      cat $dumpmem.output/packet/ip.txt  | grep -v "#" | awk -F" " '{print $2}' | sort -u | tee $dumpmem.output/packet/ip--uniq.txt
      suricata -c /etc/suricata/suricata.yaml -l $dumpmem.output/packet/ -r $dumpmem.output/packet/packets.pcap
      cp fast.log $dumpmem.output/analyse.suricata.log


      ## List all running processes and full path of binaries
      for plugin in amcache auditpol autoruns cachedump clipboard cmdline cmdscan connections connscan consoles chromecookies chromedownloadchains chromedownloads chromehistory devicetree dlllist envars filescan firefoxcookies firefoxdownloads firefoxhistory getservicesids getsids hashdump hivelist iehistory ldrmodules lsadump "malprocfind -a -x" malsysproc mbrparser mftparser mimikatz modscan modules mutantscan ndispktscan netscan openvpn privs pslist "pstree -v" "psxview --apply-rules" rsakey schtasks servicediff shellbags shimcache sockets sockscan svcscan symlinkscan timeliner timers truecryptmaster truecryptpassphrase truecryptsummary trustrecords userassist "usnparser -S -C" vadinfo; do
        while [ `ps aux | grep -v grep | grep -i 'vol.py -f' | wc -l` -gt $CONCURRENCY ]
        do
          sleep 1
        done
        echo "[$dumpmem] Launch: $plugin"  | tee -a $dumpmem.log
        task $dumpmem $profile $kdbg $dtb "$plugin" | tee $dumpmem.output/${plugin// /_} & 
      done

      ## Export some plugins results in ElasticSearch
      if [ $ES_export = True ]
      then
        for plugin in amcache auditpol autoruns cachedump clipboard cmdline cmdscan connections connscan consoles chromecookies chromedownloadchains chromedownloads chromehistory devicetree dlllist envars filescan firefoxcookies firefoxdownloads firefoxhistory getservicesids getsids hashdump hivelist iehistory ldrmodules lsadump "malprocfind -a -x" malsysproc mbrparser mftparser mimikatz modscan modules mutantscan ndispktscan netscan openvpn privs pslist "pstree -v" "psxview --apply-rules" rsakey schtasks servicediff shellbags shimcache sockets sockscan svcscan symlinkscan timeliner timers truecryptmaster truecryptpassphrase truecryptsummary trustrecords userassist "usnparser -S -C" vadinfo; do
          while [ `ps aux | grep -v grep | grep -i 'vol.py -f' | wc -l` -gt $CONCURRENCY ]
          do
            sleep 1
          done
          echo "[$dumpmem] Launch: $plugin"  | tee -a $dumpmem.log
          $VOLATILITY -f $dumpmem --profile=$profile --kdbg=$kdbg --dtb=$dtb --output=elastic --elastic-url="http://$ES_host:$ES_port" --index=$ES_index.$DMP_filename "$plugin" & 
        done
      fi

      ## Look for interesting privileges
      cat $dumpmem.output/privs | grep Enabled | grep "SeImpersonatePrivilege\|SeAssignPrimaryPrivilege\|SeTcbPrivilege\|SeBackupPrivilege\|SeRestorePrivilege\|SeCreateTokenPrivilege\|SeLoadDriverPrivilege\|SeTakeOwnershipPrivilege\|SeDebugPrivilege" | tee $dumpmem.output/privs.interesting_privileges & 
      ## Look for process with admin privileges
      cat $dumpmem.output/getsids | grep -i admin | tee $dumpmem.output/getsids.process_with_admin_privileges


      ## Remove temporary file
      #rm $dumpmem.imageinfo
      break
    fi
  fi
done

cd - 1>/dev/null 
exit 0
