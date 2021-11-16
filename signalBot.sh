#!/bin/bash

signal='/opt/Signal/signal-desktop'
file='/home/garglemonster/Documents/bash_scripts/signal/100_quotes'
signalGroup='JOCCP3'
isRunning=false
gotsInternets=false

# FIRST LETS CHECK IF WE GOTS SOME INTERWEBS
#
while [ "$gotsInternets" = false ]
do
	wget -q --spider https://www.google.com
	
	if [ $? -eq 0 ]
	then
		echo "We have interWEBS! May your signaling prove fruitful ..."
		gotsInternets=true
	else
		echo "Currently, there is no internet! You're precious signal bot must await a connection ..."
		sleep 15s
	fi
done

# BEFORE WE OPEN SIGNAL LETS CLEAN UP THOSE NASTY LOG FILES IN CASE A PID WAS RECYCLED
#
truncate -s 0 ~/.config/Signal/logs/main.log

# SIGNAL SHOULD NEVER ALREADY BE STARTED; SO WE'LL START IT
#
/bin/bash /home/garglemonster/Documents/bash_scripts/signal/startSignal.sh & signalPid=$(($! + 2))
echo "$signal has been started with a pidof: $signalPid"
sleep 11s

# IS SIGNAL READY TO SEND MESSAGES? A VERY IMPORTANT QUESTION
#
while [ "$isRunning" = false ] 
do 
	grep -q "\"pid\":$signalPid.*\"App" ~/.config/Signal/logs/main.log
	
	if [ $? -eq 0 ]
	then
		echo "Signal is ready now ..."
		isRunning=true
		sleep 3s
	else
		echo "Still not ready yet ..."
		sleep 17s
	fi
done

# SIGNAL IS UP AND RUNNING NOW SO DO THE OTHER THINGS
# COUNT THE LINES THEN PULL THE RANDO NUMBER
#
lines=$(awk '/^0/{n++}; END {print n+1}' $file)

# IF YOU'VE USED UP ALL THE QUOTES WE MUST BEGIN AGAIN, SET EVERYTHING TO 0
#
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
#
line=$(sed -n "$randomNumber"p $file)
quote=$(echo $line | awk '{print substr($0, 19, length($0))}')
echo "This is the quote ... "
echo "$quote"
sed -i "/$line/d" $file
echo $line | sed "s/0\s[A-Za-z][A-Za-z][A-Za-z]-[0-9]*\s[0-9]*\s[0-9]*:[0-9]*/1 `date +"%b-%d %y %H:%M"`/" >> $file


# FINAL STEP IS TO INTERACT WITH THE SIGNAL APP ON THE DESKTOP
#
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

#grep -q "\"pid\":$signalPid.*createOrUpdateItem" ~/.config/Signal/logs/main.log

#if [ $? -eq 0 ]
#then
#	echo "Message was successfully sent!"
#else
#	echo "Message failed to send, not sure why ..."
#fi

echo "Press any key to close the signal bot ..."
while [ true ]
do
	read -t 11 -n 1
	if [ $? = 0 ]
	then
		break
	else
		echo "Still waiting ..."
	fi
done

# KILL AND CLOSE
#
killall -15 $signal > /dev/null

exit 0
