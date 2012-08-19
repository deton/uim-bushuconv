#!/bin/sh
# wget -N http://unicode.org/Public/UNIDATA/Unihan.zip
# unzip Unihan.zip
/usr/bin/awk -f kunondef.awk Unihan_Readings.txt | \
$PWD/kunonrk.scm | sed -e 's/^u+//' -e 's/	/ /g' | LANG=C sort >annotation
