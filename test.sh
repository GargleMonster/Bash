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

while [ "$isRunning" = false ] 
do 
	if ps ax | grep -v grep | grep $signal > /dev/null
	then
		killall -15 $signal
		# DECIDED TO KILL ANY INSTANCE BECAUSE IF IT IS ALREADY OPEN IT CREATES PROBLEMS
		# I DON'T WANT TO DEAL WITH RIGHT NOW
		# isRunning=true
		# list=$(pidof $signal)
		# echo $list > list.txt
		# sed -i 's/ /\n/g' list.txt
		# sort -n -o list.txt list.txt
		# signalPid=$(head -n 1 list.txt)
		# rm -f list.txt
		# echo "$signal was already running with a pidof: $signalPid"
	else
		/bin/bash /home/garglemonster/Documents/bash_scripts/signal/startSignal.sh & signalPid=$(($! + 2))
		echo "$signal was not running, but we started it with pidof: $signalPid"
		isRunning=true
	fi

	sleep 15s
done
