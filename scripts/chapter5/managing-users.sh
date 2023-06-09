#! /bin/sh
# $Aumix: aumix/src/mute,v 1.1 2002/03/19 01:09:18 trevor Exp $
# Copyright (c) 2001, Ben Ford and Trevor Johnson
#
# Run this script to mute, then again to un-mute.
# Note: it will clobber your saved settings.
#
volumes=$(aumix -vq | tr -d ,)
if [ $(echo $volumes | awk '{print $2}') -ne 0 -o \
  $(echo $volumes | awk '{print $3}') -ne 0 ]; then
  aumix -S -v 0
else
  aumix -L >/dev/null
fi
