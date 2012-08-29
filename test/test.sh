#!/bin/sh
testsame () {
	if [ "$1" = "$2" ]; then
		echo OK
	else
		echo "NG (expected: $1, actual: $2)"
	fi
}

# TODO: set bushuconv-kanjiset for this test.
# (define bushuconv-kanjiset 'bushu34)

actual=`echo '木刀' | $PWD/../tools/uimsh-bushuconv.scm`
testsame "朷枌枴梛棻棼楔檞梁棃𥱋樑簗蔾" "$actual"

actual=`echo '口木イ' | $PWD/../tools/uimsh-bushuconv.scm`
testsame "保堡葆褒褓" "$actual"

$PWD/../tools/uimsh-kanjiset.scm <kanjiset.in >kanjiset.out
cmp kanjiset.out kanjiset.expect && echo OK && rm kanjiset.out
