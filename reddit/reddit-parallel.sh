#!/bin/bash

# Quick example of parallel processing
# ./script 5
# for 5 threads.

# Inspired by a post on reddit, my example was not as good as marauderingman
# but I had to make an effort, and show my illusion of parallel
# processing in a terminal.
# Link to marauderingman example
# https://www.reddit.com/r/bash/comments/za3ym1/comment/iylo1o6/?utm_source=share&utm_medium=web2x&context=3
  
for (( i=1; i<=$1; i++ )); do
  touch /tmp/follow"$i"
done
touch /tmp/final
echo 1 > /tmp/end

function for-trap {

for files in /tmp/end /tmp/follow* /tmp/final
do
	rm "$files" 2>/dev/null
done
exit
}

trap 'for-trap' EXIT SIGINT

function job {
  max="$1"
  counts="$2"
  threads="$3"

  printf '\n%s\n' "Job number $counts" >> /tmp/follow"$counts"
  for (( i=1; i<=max; i++ )); do
    if (( i < max )) ; then
      printf '%s' "$i " >> /tmp/follow"$counts"
      sleep 0.5
    else
      printf '%s\n%s\n' "$i" "Job number $counts completed!!" >> /tmp/follow"$counts"
    fi
    cat /tmp/follow* > /tmp/final
  done
  # for some reason i need the sleep 1 below or i lose a little output.
  if [[ $counts -eq $threads ]]; then sleep 1 ; echo 2 > /tmp/end ; fi
  }

export -f job
counter=1
calc=$(( $1 * 5 ))
for (( i=5; i<=calc; i=i+5 )); do
  job "$i" "$counter" "$1" &
  (( counter++ ))
done

while [[ $(< /tmp/end) -eq 1 ]] ; do
  clear
  echo "$(< /tmp/final)"
  sleep 0.5
done
echo
