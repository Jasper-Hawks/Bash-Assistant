#!/bin/bash

if [[ "$1" == "-c" ]]; then
    # Make a variable for the equation the user submitted
    exp=$2

    # Split each item into an array to format it for expr

    sol=$(expr $2)
    echo $sol
    #Use expr in order to find the value and return it

elif [[ $1 == -d ]]; then

    # Turn the users input into a variable
    word=$2

    # Use cURL with a dictionary API in order to find the definition
    def=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$2")

    if [[ $def =~ title ]]; then
        # Since only undefineable words have title headers
        # we can use this for error handling
        echo Error invalid word
    fi
    # Sort and format the data to be human readable
    case "\"phonetic\"(?!.*\]).*"" in $def
        
    esac

    IFS='{' read -ra parsed <<< "$def"

   for i in ${parsed[@]}
   do
       echo $i
#      if [[ $i =~ \{ ]]; then

#          echo -e $i "\n\n===SPACE==="
#      fi
   done

    # If there is no definition then echo not found
    echo Define

elif [[ "$1" == "-s" ]]; then
    # Increment a timer and take into account converting seconds to minutes
    # minutes to hours etc.
    echo Stopwatch

elif [[ $1 == "-t" ]]; then
    echo timer

fi

