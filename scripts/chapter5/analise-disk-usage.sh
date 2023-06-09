#!/bin/sh
# fquota - Disk quota analysis tool for Unix.
# Assumes that all user accounts are >= UID 100.
MAXDISKUSAGE=20
for name in $(cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 {print $1}'); do
  echo -n "User $name exceeds disk quota. Disk usage is: "
  # You might need to modify the following list of directories to match
  # the layout of your disk. Most likely change: /Users to /home
  find / /usr /var /Users -user $name -xdev -type f -ls |
    awk '{ sum += $7 } END { print sum / (1024*1024) " Mbytes" }'
done | awk "\$9 > $MAXDISKUSAGE { print \$0 }"
exit 0
