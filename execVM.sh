#!/bin/bash
#This script should not exit until the application and VM are finished.
#Designed and tested with VirtualBox version 4.1.4. Likely to break with other versions.

#Import ubiquitous_bash.
. ubiquitous_bash.sh

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDirUUID=$1

InstanceDir=/tmp/IQemu/$InstanceDirUUID

#Launch clone VM with hostToGuest.iso image.
"$scriptLocation"/VM/startTempVBoxVM_withISO.sh "$InstanceDir"/hostToGuest/hostToGuest.iso

# Set window title. - Probably infeasible, may have to compromise.