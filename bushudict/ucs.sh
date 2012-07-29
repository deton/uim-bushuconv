
sed '1,13147d' bushu34h.rev.utf-8>a
sed -e 's/;;{\([+UA-F0-9]*\)}/\1/' a>b
LANG=C sed -e 's/       \([^    ]*\)    *;.*$/\1/' b>c
./ucs2utf8 <c>d

sed '13147,$d' bushu34h.rev.utf-8>z

cat z d>bushu34h+.rev.nosort
