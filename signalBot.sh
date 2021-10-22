#!/bin/bash

isRunning=false
signal='/opt/Signal/signal-desktop'
signalPid=0

while [ $isRunning == "false" ]
do
	# CHECK IF SIGNAL IS RUNNING
	if ps ax | grep -v grep | grep $signal > /dev/null
	then
		echo "$signal service is running!"
		isRunning=true
		list=$(pidof $signal)
		echo $list > list.txt
		sed -i 's/ /\n/g' list.txt
		sort -n -o list.txt list.txt
		signalPid=$(head -n 1 list.txt)
		rm -f list.txt
	else
		echo "$signal is not running!"
		echo "Attempting to open ..."
		/bin/bash /home/garglemonster/Documents/bash_scripts/signal/startSignal.sh & signalPid=$(($! + 2))
		sleep 3s
		break
	fi

	sleep 7s	
done

# WAIT A BIT TO ENSURE ALL MESSAGES ARE LOADED
# MAYHAPS LATER WE'LL DO A HOOK INTO SIGNAL TO SEE THE MESSAGE LOADING STATUS

sleep 29s

# CHOOSE A RANDOM NUMBER BETWEEN 1-115

echo "Create random number between 1 and 115 ..."
number=`python3 -c "import random; print(random.SystemRandom().randint(1, 115))"`
echo "The number is $number"

# OPEN FILE AND SELECT LINE CORRESPONDING TO RANDOM NUMBER

file='/home/garglemonster/Documents/bash_scripts/signal/100_quotes'

# CHECK IF FILE EXISTS

if test -f "$file"
then
	echo "$file exists."
	i=1
	while read line
	do
		if [ "$i" -eq "$number" ]
		then
			echo "Below will be published ... \n"
			echo "$line"
			break
		fi

		((i+=1))
	done < "$file"
else
	echo "Error: $file was not found!"
fi

# QUOTE HAS BEEN SELECTED NOW POST TO GROUP

signalGroup="JOCCP3"
signalWindowID=`xdotool search --onlyvisible --pid "$signalPid"`
sleep 1

xdotool windowfocus --sync $signalWindowID key Control+n type "$signalGroup"
sleep 1

xdotool windowfocus --sync $signalWindowID key Tab 
sleep 1

xdotool windowfocus --sync $signalWindowID key Return Return
sleep 1

xdotool windowfocus --sync $signalWindowID type "$line"
sleep 1

xdotool windowfocus --sync $signalWindowID key Return Return

echo "Message was successfully sent!"

sleep 3

killall -15 signal-desktop

exit 0

