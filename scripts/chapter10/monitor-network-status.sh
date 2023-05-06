#!/bin/sh
# getstats - Every 'n' minutes, grabs netstats values (via crontab).
logfile="/var/log/netstat.log"
temp="/tmp/getstats.tmp"
trap "/bin/rm -f $temp" 0
(
  echo -n "time=$(date +%s);"
  netstat -s -p tcp >$temp
  sent="$(grep 'packets sent' $temp | cut -d\ -f1 | sed 's/[^[:digit:]]//g')"
  resent="$(grep 'retransmitted' $temp | cut -d\ -f1 | sed 's/[^[:digit:]]//g')"
  received="$(grep 'packets received$' $temp | cut -d\ -f1 |
    sed 's/[^[:digit:]]//g')"
  dupacks="$(grep 'duplicate acks' $temp | cut -d\ -f1 |
    sed 's/[^[:digit:]]//g')"
  outoforder="$(grep 'out-of-order packets' $temp | cut -d\ -f1 |
    sed 's/[^[:digit:]]//g')"
  connectreq="$(grep 'connection requests' $temp | cut -d\ -f1 |
    sed 's/[^[:digit:]]//g')"
  connectacc="$(grep 'connection accepts' $temp | cut -d\ -f1 |
    sed 's/[^[:digit:]]//g')"
  retmout="$(grep 'retransmit timeouts' $temp | cut -d\ -f1 |
    sed 's/[^[:digit:]]//g')"
  echo -n "snt=$sent;re=$resent;rec=$received;dup=$dupacks;"
  echo -n "oo=$outoforder;creq=$connectreq;cacc=$connectacc;"
  echo "reto=$retmout"
) >>$logfile
exit 0
The second script analyzes the netstat historical log file:
#!/bin/sh
# netperf - Analyzea the netstat running performance log, identifying
# important results and trends.
log="/var/log/netstat.log"
scriptbc="$HOME/bin/scriptbc" # Script #9
stats="/tmp/netperf.stats.$$"
awktmp="/tmp/netperf.awk.$$"
trap "/bin/rm -f $awktmp $stats" 0
if [ ! -r $log ]; then
  echo "Error: can't read netstat log file $log" >&2
  exit 1
fi
# First, report the basic statistics of the latest entry in the log file...
eval $(tail -1 $log) # all values turn into shell variables
rep="$($scriptbc -p 3 $re/$snt\*100)"
repn="$($scriptbc -p 4 $re/$snt\*10000 | cut -d. -f1)"
repn="$(($repn / 100))"
retop="$($scriptbc -p 3 $reto/$snt\*100)"
retopn="$($scriptbc -p 4 $reto/$snt\*10000 | cut -d. -f1)"
retopn="$(($retopn / 100))"
dupp="$($scriptbc -p 3 $dup/$rec\*100)"
duppn="$($scriptbc -p 4 $dup/$rec\*10000 | cut -d. -f1)"
duppn="$(($duppn / 100))"
oop="$($scriptbc -p 3 $oo/$rec\*100)"
oopn="$($scriptbc -p 4 $oo/$rec\*10000 | cut -d. -f1)"
oopn="$(($oopn / 100))"
echo "Netstat is currently reporting the following:"
echo -n " $snt packets sent, with $re retransmits ($rep%) "
echo "and $reto retransmit timeouts ($retop%)"
echo -n " $rec packets received, with $dup dupes ($dupp%)"
echo " and $oo out of order ($oop%)"
echo " $creq total connection requests, of which $cacc were accepted"
echo ""
## Now let's see if there are any important problems to flag
if [ $repn -ge 5 ]; then
  echo "*** Warning: Retransmits of >= 5% indicates a problem "
  echo "(gateway or router flooded?)"
fi
if [ $retopn -ge 5 ]; then
  echo "*** Warning: Transmit timeouts of >= 5% indicates a problem "
  echo "(gateway or router flooded?)"
fi
if [ $duppn -ge 5 ]; then
  echo "*** Warning: Duplicate receives of >= 5% indicates a problem "
  echo "(probably on the other end)"
fi
if [ $oopn -ge 5 ]; then
  echo "*** Warning: Out of orders of >= 5% indicates a problem "
  echo "(busy network or router/gateway flood)"
fi
# Now let's look at some historical trends...
echo "analyzing trends...."
while read logline; do
  eval "$logline"
  rep2="$($scriptbc -p 4 $re / $snt \* 10000 | cut -d. -f1)"
  retop2="$($scriptbc -p 4 $reto / $snt \* 10000 | cut -d. -f1)"
  dupp2="$($scriptbc -p 4 $dup / $rec \* 10000 | cut -d. -f1)"
  oop2="$($scriptbc -p 4 $oo / $rec \* 10000 | cut -d. -f1)"
  echo "$rep2 $retop2 $dupp2 $oop2" >>$stats
done <$log
echo ""
# Now calculate some statistics, and compare them to the current values
cat <<"EOF" >$awktmp
 { rep += $1; retop += $2; dupp += $3; oop += $4 }
END { rep /= 100; retop /= 100; dupp /= 100; oop /= 100;
 print "reps="int(rep/NR) ";retops=" int(retop/NR) \
 ";dupps=" int(dupp/NR) ";oops="int(oop/NR) }
EOF
eval $(awk -f $awktmp <$stats)
if [ $repn -gt $reps ]; then
  echo "*** Warning: Retransmit rate is currently higher than average."
  echo " (average is $reps% and current is $repn%)"
fi
if [ $retopn -gt $retops ]; then
  echo "*** Warning: Transmit timeouts are currently higher than average."
  echo " (average is $retops% and current is $retopn%)"
fi
if [ $duppn -gt $dupps ]; then
  echo "*** Warning: Duplicate receives are currently higher than average."
  echo " (average is $dupps% and current is $duppn%)"
fi
if [ $oopn -gt $oops ]; then
  echo "*** Warning: Out of orders are currently higher than average."
  echo " (average is $oops% and current is $oopn%)"
fi
echo \(analyzed $(wc -l <$stats) netstat log entries for calculations\)
exit 0
