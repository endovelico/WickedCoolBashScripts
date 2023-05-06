#!/bin/sh
# unrm - Searches the deleted files archive for the specified file or directory.
# If there is more than one matching result, shows a list of the results,
# ordered by timestamp, and lets the user specify which one to restore.
mydir="$HOME/.deleted-files"
realrm="/bin/rm"
move="/bin/mv"
dest=$(pwd)
if [ ! -d $mydir ]; then
  echo "$0: No deleted files directory: nothing to unrm" >&2
  exit 1
fi
cd $mydir
if [ $# -eq 0 ]; then # no args, just show listing
  echo "Contents of your deleted files archive (sorted by date):"
  ls -FC | sed -e 's/\([[:digit:]][[:digit:]]\.\)\{5\}//g' \
    -e 's/^/ /'
  exit 0
fi
# Otherwise we must have a user-specified pattern to work with. Let's see if the
# pattern matches more than one file or directory in the archive.
matches="$(ls *"$1" 2>/dev/null | wc -l)"
if [ $matches -eq 0 ]; then
  echo "No match for \"$1\" in the deleted file archive." >&2
  exit 1
fi
if [ $matches -gt 1 ]; then
  echo "More than one file or directory match in the archive:"
  index=1
  for name in $(ls -td *"$1"); do
    datetime="$(echo $name | cut -c1-14 |
      awk -F. '{ print $5"/"$4" at "$3":"$2":"$1 }')"
    if [ -d $name ]; then
      size="$(ls $name | wc -l | sed 's/[^[:digit:]]//g')"
      echo " $index) $1 (contents = ${size} items, deleted = $datetime)"
    else
      size="$(ls -sdk1 $name | awk '{print $1}')"
      echo " $index) $1 (size = ${size}Kb, deleted = $datetime)"
    fi
    index=$(($index + 1))
  done
  echo ""
  echo -n "Which version of $1 do you want to restore ('0' to quit)? [1] : "
  read desired
  if [ ${desired:=1} -ge $index ]; then
    echo "$0: Restore canceled by user: index value too big." >&2
    exit 1
  fi
  if [ $desired -lt 1 ]; then
    echo "$0: restore canceled by user." >&2
    exit 1
  fi
  restore="$(ls -td1 *"$1" | sed -n "${desired}p")"
  if [ -e "$dest/$1" ]; then
    echo "\"$1\" already exists in this directory. Cannot overwrite." >&2
    exit 1
  fi
  echo -n "Restoring file \"$1\" ..."
  $move "$restore" "$dest/$1"
  echo "done."
  echo -n "Delete the additional copies of this file? [y] "
  read answer
  if [ ${answer:=y} = "y" ]; then
    $realrm -rf *"$1"
    echo "deleted."
  else
    echo "additional copies retained."
  fi
else
  if [ -e "$dest/$1" ]; then
    echo "\"$1\" already exists in this directory. Cannot overwrite." >&2
    exit 1
  fi
  restore="$(ls -d *"$1")"
  echo -n "Restoring file \"$1\" ... "
  $move "$restore" "$dest/$1"
  echo "done."
fi
exit 0
