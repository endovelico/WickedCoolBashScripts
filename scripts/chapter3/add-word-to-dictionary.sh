#!/bin/sh
# spelldict - Uses the 'aspell' feature and some filtering to allow easy
# command-line spell-checking of a given input file.
# Inevitably you'll find that there are words it flags as wrong but
# you think are fine. Simply save them in a file, one per line, and
# ensure that the variable 'okaywords' points to that file.
okaywords="$HOME/okaywords"
tempout="/tmp/spell.tmp.$$"
spell="aspell" # tweak as needed
trap "/bin/rm -f $tempout" EXIT
if [ -z "$1" ]; then
  echo "Usage: spell file|URL" >&2
  exit 1
elif [ ! -f $okaywords ]; then
  echo "No personal dictionary found. Create one and rerun this command" >&2
  echo "Your dictionary file: $okaywords" >&2
  exit 1
fi
for filename; do
  $spell -a <$filename |
    grep -v '@(#)' | sed "s/\'//g" |
    awk '{ if (length($0) > 15 && length($2) > 2) print $2 }' |
    grep -vif $okaywords |
    grep '[[:lower:]]' | grep -v '[[:digit:]]' | sort -u |
    sed 's/^/ /' >$tempout
  if [ -s $tempout ]; then
    sed "s/^/${filename}: /" $tempout
  fi
done
exit 0
