#!/bin/bash
#
cat expressions.txt | (
i=1
read A
variables=$(cat variables.txt)
file=samples.txt
while test -n "$A"; do
	echo "$A" >> $file
	~/platform-base/bin/saolacli --dump-assembly $variables "$A" >>$file 2>/dev/null
	read A
	i=$[$i+1]
	echo >> $file
done
)

