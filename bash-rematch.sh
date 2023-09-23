#!/bin/bash

# A bit of fun with bash regex and capture groups. No speed demon, but so long as you know regex and capture groups,
# the syntax is quite straight forward.

help-func(){
cat << EOF

    Useage:

    args
    ----
    -h / --help                                                             # This Helps
    -i / --insensitive                                                      # A bit of a lie... it will match insensitively, but all the
                                                                              output will be lowercase. You can still do case insensitivity
                                                                              in your regex if this matters.


    Capture Groups
    --------------
    ./bash-rematch.sh 'crontab' /var/log/syslog                             # Print entire line
    ./bash-rematch.sh 'crontab' 0 /var/log/syslog                           # print the match inside single quotes
    ./bash-rematch.sh '(cron)(tab)' 1 2 /var/log/syslog                     # match crontab and print cron and tab (1 2)
    ./bash-rematch.sh '(cron)(tab)' 2 /var/log/syslog                       # match crontab, but print only tab.
    ./bash-rematch.sh '(cron)(tab)' 1 /var/log/syslog                       # match crontab, but print only cron



    Regex
    -----
    ./bash-rematch.sh '.*crontab.*' /var/log/syslog                         # Prints entire line, but will slow you down!
    ./bash-rematch.sh "([Cc][Rr][Oo][Nn])\[([0-9]*)\]" 2 /var/log/syslog    # Matched upper and lower CRON followed by PID inside square brackets
                                                                              but prints only the second capture group (the PID).
    ./bash-rematch.sh -i "(cron).([0-9]*)\]" 0 /var/log/syslog              # with a -i or --insensitive, will convert to lowercase and match, but
                                                                              the output will also be lowercase. Might work depending on output required.

    Warning (Experimental):

    Previous using pure bash, but i've included a common regex tool to help speed it up... grep. So far i've not seen a syntax issue using this.
    I might make it optional if i find issues.


    Pure bash
    ---------

    When using pure bash (in it's present form grep helps speed up times)
    Quite slow when not using files, when piping, or using redirection with process substitution. However, command substitution seems to work better.
    i.e. this works better than piping or process substitution..

    ./bash-rematch.sh "([Cc][Rr][Oo][Nn]).([0-9]*)\]" 0 <<< \$(cat /var/log/syslog)

    It is much slower than the greps, awks, seds and ripgreps of this world, and was only for a bit of a fun. If input is small, time not such an issue,
    it'll work ok.



EOF
    exit

}

if [[ $1 == '-h' || $1 == '--help' ]]; then
    help-func
fi


# Takes in piped stdin 
from-stdin(){
    grep -E "$1" /dev/stdin |
    while IFS= read -r line; do
        if [[ $line =~ $1 ]]; then
            if [[ $# == 1 ]]; then printf '%s\n' "$line"; continue ; fi
            for ((i=2; i<=$#; i++)); do
                printf '%s\n' "${BASH_REMATCH[${!i}]}"
            done
        fi	
    done
}

# Takes in a file as an arg.
from-file(){
    grep -E "$1" "${BASH_ARGV[0]}" |
    while IFS= read -r line; do
        if [[ $line =~ $1 ]]; then
            if [[ $# == 2 ]]; then printf '%s\n' "$line"; continue ; fi
            for ((i=2; i<=$#-1; i++)); do
                printf '%s\n' "${BASH_REMATCH[${!i}]}"
            done
        fi
    done
    #done < "${BASH_ARGV[0]}"
}

# from file input, case insensitive
from-file-insensitive(){
    grep -iE "$1" "${BASH_ARGV[0]}" |
    while IFS= read -r line; do
        if [[ ${line@L} =~ ${1@L} ]]; then
            if [[ $# == 2 ]]; then printf '%s\n' "$line"; continue ; fi
            for ((i=2; i<=$#-1; i++)); do
                printf '%s\n' "${BASH_REMATCH[${!i}]}"
            done
        fi
    done
    #done < "${BASH_ARGV[0]}"
}

# from piped stdin case insensitive
from-stdin-insensitive(){
    grep -iE "$1" /dev/stdin |
    while IFS= read -r line; do
        if [[ ${line@L} =~ ${1@L} ]]; then
            if [[ $# == 1 ]]; then printf '%s\n' "$line"; continue ; fi
            for ((i=2; i<=$#; i++)); do
                printf '%s\n' "${BASH_REMATCH[${!i}]}"
            done
        fi	
    done
}


# Match the desired function, case sensitivity, piped stdin, or file input.
if [[ $1 == '-i' || $1 == '--insensitive' ]]; then
    if [[ -f ${BASH_ARGV[0]} ]]; then
        from-file-insensitive "${@:2}"
    else
        from-stdin-insensitive "${@:2}"
    fi
else
    if [[ -f ${BASH_ARGV[0]} ]]; then
        from-file "${@:1}"
    else
        from-stdin "${@:1}"
    fi
fi
