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
    if curledDef=$(echo -e $curledDef | jq '.') && [ -n "$curledDef" ]; then

        echo $curledDef | jq '.[0].word'
        meanings=$(echo $curledDef | jq '.[0].meanings')

        echo $meanings | jq '.[0].partOfSpeech'

        def=$(echo $meanings | jq '.[].definitions')

        echo $def | jq '.[].definition'
        echo -n Synonyms: ;echo $meanings | jq '.[].synonyms'
        echo -n Antonyms: ; echo $meanings | jq '.[].antonyms'

    elif [ -z "$curledDef" ]; then

        echo No definition found

    else
        echo Please install jq
        exit 0
    fi

elif [[ "$1" == "-t" ]]; then
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

elif [[ $1 == "-s" ]]; then

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

elif [[ $1 == "-w" ]]; then
    NUMOFLINES=$(wc -l < $TODOFILE)
    if [[ -n $TODOFILE ]]; then
        NUM=$( echo "$NUMOFLINES + 1" | bc )
        echo $NUM. $2 >> "$TODOFILE"
    else
        echo Please setup your TODO file with the -su flag
    fi
elif [[ $1 == "-r" ]]; then
    if [[ -n $TODOFILE ]]; then
        cat $TODOFILE
    else
        echo Please setup your TODO file with the -su flag
    fi

elif [[ $1 == "-rm" ]]; then
    NUMOFLINES=$(wc -l < $TODOFILE)
    if [[ $2 -le $NUMOFLINES ]]; then
        sed -i $2d $TODOFILE
        for (( i = 1; i<=$NUMOFLINES ; i++ ));
        do
            sed -i ""$i"s/^[0-9]*/$i/" $TODOFILE
        done

    elif [[ $2 -gt $NUMOFLINES ]] || [[ $2 -le 0 ]]; then
        echo Please enter a valid line
    else
        echo Please setup your TODO file with the -su flag
    fi

elif [[ $1 == "-su" ]]; then
    if [[ -n $2 ]]; then
        mkdir -p $2
        if  echo "$2" | grep -q "/$"
        then
            echo Please insert this into your .bashrc \"export TODOFILE="$2"TODO.md\"
            echo Please insert this into your .bashrc \"export NUMOFLINES=\$\(\w\c \-\l \< \$TODOFILE\)\"
            touch $2TODO.md
        else
            echo Please insert this into your .bashrc "export TODOFILE="$2"/TODO.md"
            echo Please insert this into your .bashrc \"export NUMOFLINES=\$\(\w\c \-\l \< \$TODOFILE\)\"
            touch $2/TODO.md
        fi
    else
        echo Please specify a directory
    fi


elif [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    nm=$(basename $0)
    printf "%s\n\n" "usage: $nm [-h] [-r] [-s] [-su FILEPATH] [-t MINUTES]  [-c EQUATION] [-d WORD] [-rm LINENUMBER] [-w GOAL]"
    printf "%s\n\n" "Use a plethora of tools to help you on the command line with Bash Assistant."
    printf "%s\n" "options:"
    printf "%-10s\t%s\n"  "-c EQUATION" "Solves equation"
    printf "%-10s\t%s\n" "-d WORD" "Finds the first definition of the given word"
    printf "%-10s\t%s\n" "-h, --help" "This help message"
    printf "%-10s\t%s\n" "-r" "Read your TODO list"
    printf "%-10s\t%s\n" "-rm LINENUMBER" "Remove selected line from the TODO list"
    printf "%-10s\t%s\n" "-s" "Starts a stopwatch"
    printf "%-10s\t%s\n" "-su FILEPATH" "Setup the TODO list"
    printf "%-10s\t%s\n" "-t MINUTES" "Start a time with a number of minutes"
    printf "%-10s\t%s\n" "-w GOAL" "Write a goal to your TODO list"

else
    echo Please enter a valid argument.
fi
