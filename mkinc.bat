echo off
'
'	usage: mkinc [xfile] [labelfile] [rcfile] [incfile]
'

if "%4" == "" goto retn
dis --overwrite -m68000 -b 2 -j -g%2 %1 _sala1.s
if errorlevel 1 goto retn
cp _sala1.s _sala2.s
em @%3
has -n _sala1
hlk _sala1
has -n _sala2
hlk _sala2
fc -b _sala1.x _sala2.x|cut -0|tr -d ':'|gres '^' '\t\tPATTBL\t$'>%4
rm --no-no-match _sala1.s _sala1.o _sala1.x _sala2.s _sala2.o _sala2.x
:retn
