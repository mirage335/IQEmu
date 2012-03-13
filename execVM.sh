#!/bin/bash
#This script should not exit until the application and VM are finished.
#Designed and tested with VirtualBox version 4.1.4. Likely to break with other versions.

#Import ubiquitous_bash.
. ubiquitous_bash.sh

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDirUUID=$1
shift

InstanceDir=/tmp/IQemu/$InstanceDirUUID

if (($#))
then
	if [[ ! -d "$1" ]]
	then
		absoluteAppFileParam=$(getAbsoluteLocation "$1")
		appFolder=$(dirname "$absoluteAppFileParam")
	else
		appFolder=$(getAbsoluteLocation "$1")
	fi
	shift
else
	appFolder="/"
fi

#Launch clone VM with hostToGuest.iso image and app shared folder.
"$scriptLocation"/VM/startTempVBoxVM_withISO_andSharedFolder.sh "$InstanceDir"/hostToGuest/hostToGuest.iso "$appFolder"

# Set window title. - Probably infeasible, may have to compromise.