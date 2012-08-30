#!/bin/sh
testsame () {
	if [ "$1" = "$2" ]; then
		echo OK
	else
		echo "NG (expected: $1, actual: $2)"
	fi
}

kanjiset=`uim-sh -e '(begin (require "bushuconv.scm") bushuconv-kanjiset)'`
case $kanjiset in
bushu34)
	bushu34=1
	;;
bushu34h+)
	bushu34=0
	;;
*)
	echo "Unknown bushuconv-kanjiset: $kanjiset"
	exit 1
	;;
esac

actual=`echo '木刀' | $PWD/../tools/uimsh-bushuconv.scm`
case $kanjiset in
bushu34)
	testsame "朷枌枴梛棻棼楔檞梁棃𥱋樑簗蔾" "$actual"
	;;
bushu34h+)
	testsame "朷枌枴梛栔棻棼楔檞梁棃𥱋樑簗蔾" "$actual"
	;;
*)
	echo "NG Unknown bushuconv-kanjiset: $kanjiset"
	;;
esac

actual=`echo '口木イ' | $PWD/../tools/uimsh-bushuconv.scm`
case $kanjiset in
bushu34)
	testsame "保堡葆褒褓" "$actual"
	;;
bushu34h+)
	testsame "咻保堡媬緥葆褒褓賲僺" "$actual"
	;;
*)
	echo "NG Unknown bushuconv-kanjiset: $kanjiset"
	;;
esac

$PWD/../tools/uimsh-kanjiset.scm <kanjiset.in >kanjiset.out
cmp kanjiset.out kanjiset.expect && echo OK && rm kanjiset.out

actual=`echo '例えば、U+8a3bU+91c8とか' | $PWD/../tools/uimsh-ucs.scm`
testsame "例えば、註釈とか" "$actual"

actual=`$PWD/../tools/uimsh-rk.scm ittyoume | iconv -f euc-jp -t utf-8`
testsame "いっちょうめ" "$actual"

actual=`$PWD/../tools/uimsh-rk.scm -k shoppingu | iconv -f euc-jp -t utf-8`
testsame "ショッピング" "$actual"

actual=`$PWD/../tools/uimsh-rk.scm shinnyuu | iconv -f euc-jp -t utf-8`
testsame "しんゆう" "$actual"

actual=`$PWD/../tools/uimsh-rk.scm -n shinnyuu | iconv -f euc-jp -t utf-8`
testsame "しんにゅう" "$actual"
