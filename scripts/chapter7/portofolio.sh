#!/bin/sh
# portfolio - Calculates the value of each stock in your holdings,
# then calculates the value of your overall portfolio, based on
# the latest stock market position.
scriptbc="$HOME/bin/scriptbc" # tweak this as needed
portfolio="$HOME/.portfolio"
if [ ! -f $portfolio ] ; then
 echo "$(basename $0): No portfolio to check? ($portfolio)" >&2
 exit 1
fi
while read holding
 do
 eval $(echo $holding | \
 awk -F\| '{print "name=\""$1"\"; ticker=\""$2"\"; hold=\""$3"\""}')
 if [ ! -z "$ticker" ] ; then
   value="$(getstock $ticker)"
    totval="$($scriptbc ${value:-0} \* $hold)"
    echo "$name is trading at $value (your $hold shares = $totval)"
    sumvalue="$($scriptbc ${sumvalue:-0} + $totval)"
    fi
    done < $ portfolio
   echo "Total portfolio value: $sumvalue"
   exit 0