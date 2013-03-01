#!/bin/sh
#
#   rcfix.sh: Resource file regulation script
#
#       Copyright (C) 2013 Yak! / Yasutaka ATARASHI
#
#       This software is distributed under the terms of a zlib/libpng License
#
#       $Id$
#

RESOURCE=axffmpeg.rc

if ! grep -q DEBUG $RESOURCE; then
    sed -i.bak -e '/#include <windows.h>/i/***********************************************************************/\
/*                                                                     */\
/* axffmpeg.rc: Resource file for axffmpeg                             */\
/*                                                                     */\
/*     Copyright (C) 2012,2013 Yak! / Yasutaka ATARASHI                */\
/*                                                                     */\
/*     This software is distributed under the terms of a zlib/libpng   */\
/*     License.                                                        */\
/*                                                                     */\
/*     $Id$                  */\
/*                                                                     */\
/***********************************************************************/' -e 's/FILEFLAGSMASK   0x0000003F/FILEFLAGSMASK   VS_FFI_FILEFLAGSMASK/;/FILEFLAGS       0x00000000/c#ifdef DEBUG\
    FILEFLAGS       VS_FF_DEBUG | VS_FF_PRIVATEBUILD | VS_FF_PRERELEASE\
#else\
    FILEFLAGS       0x00000000\
#endif' -e '/ProductVersion/a#ifdef DEBUG\
            VALUE "PrivateBuild", "Debug build"\
#endif' $RESOURCE
    d2u ${RESOURCE}.bak
    diff ${RESOURCE}.bak ${RESOURCE}
fi

if ! grep -q resource\\.h resource.h; then
    sed -i.bak -e '1i/***********************************************************************/\
/*                                                                     */\
/* resource.h: Header file for windows resource constants              */\
/*                                                                     */\
/*     Copyright (C) 2012 Yak! / Yasutaka ATARASHI                     */\
/*                                                                     */\
/*     This software is distributed under the terms of a zlib/libpng   */\
/*     License.                                                        */\
/*                                                                     */\
/*     $Id$                  */\
/*                                                                     */\
/***********************************************************************/\
#ifndef RESOURCE_H\
#define RESOURCE_H\
' -e '$a\
\
#endif' resource.h
    d2u resource.h.bak
    diff resource.h.bak resource.h
fi
