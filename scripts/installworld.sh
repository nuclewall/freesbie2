#!/bin/sh
#
# Copyright (c) 2005 Dario Freni
#
# See COPYING for licence terms.
#
# $FreeBSD$
# $Id: installworld.sh,v 1.11 2008/11/08 21:15:15 sullrich Exp $

set -e -u

if [ -z "${LOGFILE:-}" ]; then
    echo "This script can't run standalone."
    echo "Please use launch.sh to execute it."
    sleep 999
    exit 1
fi

if [ -n "${NO_INSTALLWORLD:-}" ]; then
    echo "+++ NO_INSTALLWORLD set, skipping install" | tee -a ${LOGFILE}
    return
fi

echo ">>> Installing world for ${ARCH} architecture..."

# Set SRC_CONF variable if it's not already set.
if [ -z "${SRC_CONF:-}" ]; then
    if [ -n "${MINIMAL:-}" ]; then
		SRC_CONF=${LOCALDIR}/conf/src.conf.minimal
    else
		SRC_CONF=${LOCALDIR}/conf/src.conf
    fi
fi

mkdir -p ${BASEDIR}

cd ${SRCDIR}

makeargs="${MAKEOPT:-} ${MAKEJ_WORLD:-} SRCCONF=${SRC_CONF} TARGET_ARCH=${ARCH} DESTDIR=${BASEDIR} LOADER_ZFS_SUPPORT=YES"

echo ">>> FreeSBIe2 is running the command: env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} installworld" > /tmp/freesbie_installworld_cmd.txt

# make installworld
(env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} installworld || print_error;) | egrep '^>>>'

makeargs="${MAKEOPT:-} SRCCONF=${SRC_CONF} TARGET_ARCH=${ARCH} DESTDIR=${BASEDIR}"

set +e

echo ">>> FreeSBIe2 is running the command: env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} distribution"  > /tmp/freesbie_installworld_distribution_cmd.txt

# make distribution
(env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} distribution || print_error;) | egrep '^>>>'

set -e

cd $LOCALDIR
