#!/usr/bin/awk -f
{
	FS = "\t";
}
/^#/ {
	next;
}
$2 == "kDefinition" {
	code[$1] = $1;
	def[$1] = $3;
	next;
}
$2 == "kJapaneseKun" {
	code[$1] = $1;
	kun[$1] = tolower($3);
	next;
}
$2 == "kJapaneseOn" {
	code[$1] = $1;
	on[$1] = tolower($3);
	next;
}
END {
	for (c in code) {
		printf("%s\t%s\t%s\t%s\n", tolower(c), kun[c], on[c], def[c]);
	}
}
