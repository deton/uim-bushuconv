#!/bin/sh
module=bushuconv
srcdir=$(dirname $0)
scmdir=$(pkg-config --variable=uim_scmdir uim)
pixmapsdir=$(pkg-config --variable=uim_datadir uim)/pixmaps
cp "$srcdir/$module.scm" "$srcdir/$module-custom.scm" $srcdir/$module-rule.scm" "$scmdir"
cp "$srcdir/pixmaps/$module.png" "$srcdir/pixmaps/${module}_dark_background.png" "$pixmapsdir"
cp "$srcdir/pixmaps/$module.svg" "$srcdir/pixmaps/${module}_dark_background.svg" "$pixmapsdir"
uim-module-manager --register "$module"
