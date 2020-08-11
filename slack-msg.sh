#!/bin/bash

# Description : envoie une chaine de caractères sur un channel slack.
# Usage : echo "message" | ./slack-msg.sh

MSG=`cat -` 
MSGchecked_quote=`echo $MSG | sed "s/'//g"`
MSGchecked_doublequote=`echo $MSGchecked_quote | sed 's/"//g'`
MSG=$MSGchecked_doublequote

curl -X POST -H 'Content-type: application/json' --data "{'text':'$MSG'}" https://hooks.slack.com/services/XXXXXXXXXXXXXXXX/YYYYYYYYYYYY/ZZZZZZZZZZZZZZZZ
