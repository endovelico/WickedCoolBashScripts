#!/bin/sh
# log-yahoo-search - Given a search request, logs the pattern, then
# feeds the entire sequence to the real Yahoo! search system.
# Make sure the directory path and file listed as 'logfile' are writable by
# user nobody, or whatever user you have as your web server uid.
logfile="/var/www/wicked/scripts/searchlog.txt"
if [ ! -f $logfile ]; then
  touch $logfile
  chmod a+rw $logfile
fi
if [ -w $logfile ]; then
  echo "$(date): $QUERY_STRING" | sed 's/p=//g;s/+/ /g' >>$logfile
fi
echo "Location: http://search.yahoo.com/bin/search?$QUERY_STRING"
echo ""
exit 0
