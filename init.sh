#!/bin/bash

if [ -x $(dirname $0)/_terraform.sh ]; then
    exec $(dirname $0)/_terraform.sh
else
    TMPDIR="`mktemp -d`"
    git clone https://github.com/spigwitmer/home-cfg.git $TMPDIR
    exec $TMPDIR/_terraform.sh $@
fi
