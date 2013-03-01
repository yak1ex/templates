#!/bin/sh
#
#   verbump.sh: Version bump script
#
#       Copyright (C) 2013 Yak! / Yasutaka ATARASHI
#
#       This software is distributed under the terms of a zlib/libpng License
#
#       $Id$
#

version=`echo $1 | sed 's,_,.,g'`
major=`echo $1 | sed 's@_0*@,@g'`
date=`date +%Y/%m/%d`
version2=`date +$major,%Y,%-m%d`
echo $version $date $version2
shift
for i in $@; do
    case $i in
    *.bak)
        continue
        ;;
    esac
    sed -i.bak "s,[0-9]\.[0-9][0-9] (..../../..),$version ($date),;s,[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9] Yak!,$date Yak!,;s@\(FILE\|PRODUCT\)VERSION [0-9]*,[0-9]*,[0-9]*,[0-9]*@\1VERSION $version2@g" $i
    case $i in
    *.txt)
        u2d $i
        ;;
    esac
    diff -u $i.bak $i
done
