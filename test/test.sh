#!/bin/sh
testsame () {
	if [ "$1" = "$2" ]; then
		echo OK
	else
		echo "NG (expected: $1, actual: $2)"
	fi
}

actual=`echo '木刀' | $PWD/../tools/uimsh-bushuconv.scm`
testsame "朷枌枴梛棻棼楔檞梁棃𥱋樑簗蔾" "$actual"

actual=`echo '口木イ' | $PWD/../tools/uimsh-bushuconv.scm`
testsame "保堡葆褒褓" "$actual"

$PWD/../tools/uimsh-kanjiset.scm <detect.in >detect.out
cmp detect.out detect.ok && echo OK && rm detect.out
