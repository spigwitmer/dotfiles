#!/bin/bash

if [ -x _terraform.sh ]; then
    ./_terraform.sh
else
    TMPDIR="`mktemp -d`"
    git clone https://github.com/spigwitmer/home-cfg.git $TMPDIR
    $TMPDIR/_terraform.sh $@
fi
