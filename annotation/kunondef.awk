#!/usr/bin/awk -f
{
	FS = "\t";
}
/^#/ {
	next;
}
$2 == "kDefinition" {
	def[$1] = $3;
	next;
}
$2 == "kJapaneseKun" {
	kun[$1] = tolower($3);
	next;
}
$2 == "kJapaneseOn" {
	on[$1] = tolower($3);
	next;
}
END {
	for (code in def) {
		printf("%s\t%s\t%s\t%s\n", tolower(code), kun[code], on[code], def[code]);
	}
}
