#!/bin/bash
#Import ubiquitous_bash.
. ubiquitous_bash.sh

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDirUUID=$1

InstanceDir=/tmp/IQemu/$InstanceDirUUID

if [[ "$InstanceDirUUID" = "" ]]
then
	echo "Cleanup: FATAL ERROR. Bad instance UUID!"
	exit
fi

#Pirhana infested waters ahead. Swim at own risk. (don't tamper with this unless all implications are understood)
rm --preserve-root --one-file-system --recursive $InstanceDir