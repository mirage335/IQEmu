#!/bin/bash
#Send parameters to this script, conversion will be attempted on all before building application.bat. First parameter will be a UUID however, and will not be passed to VM.

#Import ubiquitous_bash.
. ubiquitous_bash.sh

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDirUUID=$1
shift

InstanceDir=/tmp/IQemu/$InstanceDirUUID

preCommand=$(cat "$scriptLocation"/preCommand)

echo -n "start $preCommand" > "$InstanceDir"/hostToGuest/files/application.bat
while (($#))
do
	echo -n \"$("$scriptLocation/VMWareParamConverter.sh" "$1")\" >> "$InstanceDir"/hostToGuest/files/application.bat
shift
if (($#))
then
	echo -n " " >> "$InstanceDir"/hostToGuest/files/application.bat
fi
done
