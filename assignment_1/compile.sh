#!/bin/bash

RUBY=`/usr/bin/which ruby`
NASM=`/usr/bin/which nasm`
LD=`/usr/bin/which ld`
MKTEMP=`/usr/bin/which mktemp`
RM=`/usr/bin/which rm`
OBJDUMP=`/usr/bin/which objdump`
TR=`/usr/bin/which tr`
FMT=`/usr/bin/which fmt`
EGREP=`/usr/bin/which egrep`
TMP=$($MKTEMP)
declare -a arr

if [ ! -n "$1"  ] || [ ! -n "$2" ]
then
  echo "\\"
  echo " Usage: `basename $0` file.asm port_number"
  echo "/"
  exit $E_BADARGS
fi

echo "* Setting PORT: $2"
$RUBY -pe "gsub /PORT/, '0x'+['$2'.to_i].pack('v*').unpack('H*')[0]" $1 > $TMP

echo "* Assembling"
$NASM -f elf32 -o ${TMP%.*}.o $TMP

echo "* Linking"
$LD -o ${1%.*} ${TMP%.*}.o
$RM $TMP ${TMP%.*}.o

echo "* Executable: ${1%.*}"

# http://www.commandlinefu.com/commands/using/objdump
for i in `$OBJDUMP -d ${1%.*} | $TR '\t' ' ' | $TR ' ' '\n' | $EGREP '^[0-9a-f]{2}$' ` ; do arr[${#arr[@]}]="\x$i" ; done
echo -e "* Shellcode dump (len = ${#arr[@]}):\n"
echo ${arr[@]} | $FMT | $TR -d ' '
echo -e "\n"
