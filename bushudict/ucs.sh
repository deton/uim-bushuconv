#!/bin/sh
grep '^;;' bushu34h.rev.utf-8 | sed -e 's/;;{\([+UA-F0-9]*\)}/\1/' | \
grep -v '^;;' | LANG=C sed -e 's/	\([^    ]*\)	*;.*$/\1/' | \
$PWD/../tools/uimsh-ucs.scm >part2

grep -v '^;;' bushu34h.rev.utf-8 >part1

cat part1 part2 >bushu34h+.rev.nosort
