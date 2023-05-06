#!/bin/sh
# diskhogs - Disk quota analysis tool for Unix; assumes all user
# accounts are >= UID 100. Emails message to each violating user
# and reports a summary to the screen.
MAXDISKUSAGE=20
violators="/tmp/diskhogs0.$$"
trap "/bin/rm -f $violators" 0
for name in $(cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 { print $1 }'); do
  echo -n "$name "
  # You might need to modify the following list of directories to match
  # the layout of your disk. Most likely change: /Users to /home
  find / /usr /var /Users -user $name -xdev -type f -ls |
    awk '{ sum += $7 } END { print sum / (1024*1024) }'
done | awk "\$2 > $MAXDISKUSAGE { print \$0 }" >$violators
if [ ! -s $violators ]; then
  echo "No users exceed the disk quota of ${MAXDISKUSAGE}MB"
  cat $violators
  exit 0
fi
