#!/bin/sh
/usr/bin/awk -f kunondef.awk Unihan_Readings.txt | \
$PWD/kunonrk.scm | sed -e 's/^u+//' | LANG=C sort >annotation