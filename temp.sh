#!/bin/bash

file='/home/garglemonster/Documents/bash_scripts/signal/100_quotes'
i=1

while read line
do
	echo "$i $line"
	((i+=1))
done < $file

exit 0
