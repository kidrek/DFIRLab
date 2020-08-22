#!/bin/bash

# USAGE : send file to slack channel
## ./slack-uploadfile.sh <file> <comment>

SLACKToken="<slack_token>"
SLACKChannel="#<slack_channel>"
UPLOADFile=$1
UPLOADComment=$2

curl -F file=@$UPLOADFile -F "initial_comment=$UPLOADComment" -F channels=$SLACKChannel -H "Authorization: Bearer $SLACKToken" https://slack.com/api/files.upload
