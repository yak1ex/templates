#!/bin/sh

function process() {
  from=$1
  to=$2
  if [ ! -e $to ]; then
    echo linking $from to $to
    ln $from $to
  elif [ `stat -c %h $to` -gt 1 ]; then
    : # already linked, do nothing
  elif diff -q $from $to; then
    echo same content but not link, linking $from to $to
    rm $to
    ln $from $to
  else
    diff -u $from $to
  fi
}

for from in dzcl dzin ga ghclone.pl ghissues.pl ghupstream.pl gidup gist.pl glst; do
  process $from ~/bin/$from
done
if [ ! -e ~/bin/glpl ]; then
  process glst ~/bin/glpl
fi
