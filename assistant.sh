#!/bin/bash

if [[ "$1" == "-c" ]]; then
    # Make a variable for the equation the user submitted
    exp=$2

    # We can't pipe the variable into bc without echoing it first
    sol=$(echo 'scale=2;' $2 | bc)
    echo $sol

elif [[ $1 == -d ]]; then

    # Turn the users input into a variable
    word=$2

    # Use cURL with a dictionary API in order to find the definition
    curledDef=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$2")

    if [[ $curledDef =~ title ]]; then
        # Since only undefineable words have title headers
        # we can use this for error handling
        echo Error invalid word
        exit 0
    fi
    echo -e $curledDef

    # If there is no definition then echo not found
    #echo Define

elif [[ "$1" == "-s" ]]; then
    # Increment a timer and take into account converting seconds to minutes
    # minutes to hours etc.
    if [[ $2 =~ ^-?[0-9]+$  ]]; then
        MINUTES=$2 # Set the variable MINUTES to the first argument provided
        SEC=0 # Set the seconds to 0 since we'll never modify them

        printf "Starting timer for $MINUTES minutes\n"

        while [ $MINUTES -ge 0 ]; do # Nested while loops so that once the seconds loop is over the minute is decremented
            while [ $SEC -ge 0 ]; do # Second while loop that will echo the current seconds on the same line replacing the previous text
                echo -ne "[$MINUTES:$SEC]\033[0K\r"
                SEC=`expr $SEC - 1`
                sleep 1
            done
            SEC=59 # Then reset the seconds and start the loop again
            MINUTES=`expr $MINUTES - 1` # Subtract a minute
        done
    else
        echo Invalid amount of minutes
        exit 0

    fi

elif [[ $1 == "-t" ]]; then

    SEC=0
    MIN=0
    HR=0
    while [ $MIN -lt 59 ]; do
        while [ $SEC -le 59 ]; do
            if [[ $SEC =~ ^[0-9]$ ]]; then
                echo -ne "[$HR:$MIN:0$SEC]\033[0K\r"
            else
                echo -ne "[$HR:$MIN:$SEC]\033[0K\r"
            fi
            sleep 1
            SEC=` expr $SEC + 1`
        done
    SEC=0
    MIN=`expr $MIN + 1`
    done
    MIN=0
    HR=` expr $HR + 1`

    echo timer

fi
