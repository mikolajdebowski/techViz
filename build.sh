#!/bin/sh

if [ -n "$1" ]; then
    VTEXT="version=$1"
    perl -i -pe "s/version=.*/\\$VTEXT/g" /ios/Runner/Info.plist
    cat example.txt
else
  echo "First parameter not supplied."
fi

