#!/bin/bash

file='/home/garglemonster/Documents/bash_scripts/signal/100_quotes_test'

# CHECK IF FILE EXISTS

number=119

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

