#!/bin/bash

signal='/opt/Signal/signal-desktop'
file='/home/garglemonster/Documents/bash_scripts/signal/100_quotes'
signalGroup='JOCCP3'
isRunning=false


# IS SIGNAL OPEN? VERY IMPORTANT QUESTION
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
		sleep 188s
	fi

	sleep 7s
done


# SIGNAL IS UP AND RUNNING NOW SO DO THE OTHER THINGS
# COUNT THE LINES THEN PULL THE RANDO NUMBER
lines=$(awk '/^0/{n++}; END {print n+0}' $file)
# IF YOU'VE USED UP ALL THE QUOTES WE MUST BEGIN AGAIN, SET EVERYTHING TO 0
if [ "$lines" -eq 0 ] 
then
	sed -i 's/^1/0/' $file
	lines=$(wc -l < $file)	
fi	
echo "Generate a true random number between 1 and $lines ..."
randomNumber=`python3 -c "import random; print(random.SystemRandom().randint(1, $lines))"`
echo "The selected line is $randomNumber!"


# NOW THAT WE HAVE THE LINE NUMBER LETS GRAB IT FROM THE FILE
# THEN LETS DO A LITTLE HOUSEKEEPING
line=$(sed -n "$randomNumber"p $file)
quote=$(echo $line | awk '{print substr($0, 19, length($0))}')
echo "This is the quote ... "
echo "$quote"
sed -i "/$line/d" $file
echo $line | sed "s/0\s[A-Za-z][A-Za-z][A-Za-z]-[0-9]*\s[0-9]*\s[0-9]*:[0-9]*/1 `date +"%b-%d %y %H:%M"`/" >> $file


# FINAL STEP IS TO INTERACT WITH THE SIGNAL APP ON THE DESKTOP
signalWindowId=`xdotool search --onlyvisible --pid "$signalPid"`
sleep 1

xdotool windowfocus --sync $signalWindowId key Control+n type "$signalGroup"
sleep 1

xdotool windowfocus --sync $signalWindowId key Tab 
sleep 1

xdotool windowfocus --sync $signalWindowId key Return Return
sleep 2

xdotool windowfocus --sync $signalWindowId type "$quote"
sleep 1

xdotool windowfocus --sync $signalWindowId key Return Return

echo "Message was successfully sent!"

sleep 17s

echo "Press any key to exit."
while [ true ]
do
	read -t 15 -n 1
	if [ $? = 0 ]
	then
		break
	else
		echo "Still waiting ..."
	fi
done

# KILL AND CLOSE
killall -15 $signal > /dev/null

exit 0
