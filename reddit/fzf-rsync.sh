#!/bin/bash

# For reddit member looking to backup over ssh
# Author: jonny peace
# Simple fzf rsync backup script

remote_host='ENTER REMOTE HOST HERE'

function exit_yes_no {
  ans=$(printf '%s\n' "exit" "yes" "no" | \
    fzf --header="Please Select if you want to continue" --preview='cat /tmp/select') 
  [[ $ans == 'exit' ]] && exit
}

# Change directories to suit your needs
function choose_dir {
  cat << EOF | fzf -m --reverse > /tmp/file1
exit
$HOME/Music
$HOME/git
$HOME/Documents
EOF
  check=$(< /tmp/file1)
  [[ $check == 'exit' ]] && exit
}

while true; do
  choose_dir
  ssh "$remote_host" "find $(tr '\n' ' ' < /tmp/file1) -maxdepth 1" | \
    sort -f | fzf -m --reverse > /tmp/select
  exit_yes_no
  [[ $ans == 'yes' ]] && break
done

rsync -arvhz --progress --files-from=/tmp/select "$remote_host":/ ./backup
