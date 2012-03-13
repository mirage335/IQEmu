#!/bin/bash 

#Import ubiquitous_bash.
. ubiquitous_bash.sh

InstanceDirUUID=$1

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDir=/tmp/IQemu/$InstanceDirUUID

mkdir -p "$InstanceDir"/hostToGuest

mkdir -p "$InstanceDir"/VM_Clone

cp -a "$scriptLocation"/hostToGuest/files $InstanceDir/hostToGuest/files