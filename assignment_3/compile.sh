#!/bin/bash

NASM=`/usr/bin/which nasm`
LD=`/usr/bin/which ld`
RM=`/usr/bin/which rm`
OBJDUMP=`/usr/bin/which objdump`
TR=`/usr/bin/which tr`
FMT=`/usr/bin/which fmt`
EGREP=`/usr/bin/which egrep`
declare -a arr

if [ ! -n "$1"  ]
then
  echo "\\"
  echo " Usage: `basename $0` file.asm"
  echo "/"
  exit $E_BADARGS
fi

echo "* Assembling"
$NASM -f elf32 -o ${1%.*}.o $1

echo "* Linking"
$LD -m elf_i386 -z execstack -o ${1%.*} ${1%.*}.o
$RM ${1%.*}.o

echo "* Executable: ${1%.*}"

# http://www.commandlinefu.com/commands/using/objdump
for i in `$OBJDUMP -d ${1%.*} | $TR '\t' ' ' | $TR ' ' '\n' | $EGREP '^[0-9a-f]{2}$' ` ; do arr[${#arr[@]}]="\x$i" ; done
echo -e "* Shellcode dump (length = ${#arr[@]}):\n"
echo ${arr[@]} | $FMT | $TR -d ' '
echo -e "\n"
