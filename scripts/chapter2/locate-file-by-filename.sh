#!/bin/sh
# mklocatedb - Builds the locate database using find. Must be root
# to run this script.
locatedb="/var/locate.db"
if [ "$(whoami)" != "root" ]; then
  echo "Must be root to run this command." >&2
  exit 1
fi
find / -print >$locatedb
exit 0
The second script is even shorter:
#!/bin/sh
# locate - Searches the locate database for the specified pattern.
locatedb="/var/locate.db"
exec grep -i "$@" $locatedb
