#!/bin/bash

file='100_quotes'
count=0

main () {
	# Call file check function
	checkFile $file
	go $file
}

checkFile() {
	if test -f $1
	then
		echo "$1 file exists."
	else
		echo "$1 does not exist."
	fi
}

go () {
	while read line
	do
		if [ "${line:0:1}" -eq 0 ]
		then
			echo "${line:0:1}"
			((count+=1))
		fi
	done < $1

	echo "$count"
}

main

exit 0
