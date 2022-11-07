.intel_syntax noprefix
.globl _start

# constants
.set SYS_READ, 0
.set SYS_WRITE, 1
.set SYS_OPEN, 2
.set SYS_CLOSE, 3
.set SYS_SOCKET, 41
.set SYS_ACCEPT, 43
.set SYS_BIND, 49
.set SYS_LISTEN, 50
.set SYS_EXIT, 60

# constant args
.set AF_INET, 2
.set SOCK_STREAM, 1
.set IPPROTO_IP, 0

# for file usage
.set O_RDONLY, 0
.set BUFFERSIZE, 1024   



# the program is expecting a socket
# socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
_start:
    endbr64
    push rbp
    mov rbp, rsp
    # create the socket!
    mov rdi, AF_INET # ARG0, AF_INET
    mov rsi, SOCK_STREAM # ARG1, SOCK_STREAM
    mov rdx, IPPROTO_IP # ARG2, IPPROTO_IP                                                         
    call socket

    mov r15, rax # this will save the socket's FD to r15

    #    - Bind to port 80                                                                                         
    #    - Bind to address 0.0.0.0 
        # size of the struct, reserve some space
    sub rsp, 16 # clear some space on the stack

    mov word ptr [rbp-16], 2      # sa_family AF _INET
    mov word ptr [rbp-14], 0x5000 # sin_port Port 80
    mov dword ptr [rbp-12], 0      # sin_addr IP 0.0.0.0
    mov qword ptr [rbp-8], 0      # padding, 0
    
    mov rsi, rsp    # THE addr struct
    mov rdx, 16     # addrlen
    mov rdi, rax    # FD

    call bind
    add rsp, 16 

    # listen on the socket
    mov rdi, r15 # Socket FD
    mov rsi, 0   # backlog
    call listen

    # accept a connection
    mov rdi, r15 # Socket fd
    mov rsi, 0
    mov rdx, 0 
    call accept

    # save the FD of the connection accepted!
    mov r14, rax

    # call read - Get the request
    sub rsp, BUFFERSIZE # clear up some space on the stack for the request
    mov rdi, r14    # FD of the connection accepted previously
    mov rsi, rsp    # buffer address to read the request
    mov rdx, BUFFERSIZE   # size of the buffer
    call read

    mov r10, rsp
    add r10, 4 # skip the "GET " part of the request
    mov qword ptr [r10+10], 0 # get only the filename
    mov rdi, r10      # set the filename
    mov rsi, O_RDONLY              # set to read only
    call open


    # read the contents of the file
    mov r8, rax     # save the file's fd for close
    mov rdi, r8
    mov rsi, r10
    mov rdx, 1024
    call read

    push rax # push the size of the actual contents in the file

    mov rdi, r8
    call close


    mov rdi, r14        # FD of the connection
    # respond to a connection with a header
    lea rsi, response   # the response ascii
    mov rdx, 19         # size of the response
    call write


    # response body
    mov rdi, r14        # FD of the connection
    mov rsi, r10        # contents of the file saved on the stack (mov r10, rsp)
    pop rdx             # size of the file, get the actual size saved on the stack
    call write


    mov rdi, r14
    call close


    call exit

# socket(int domain, int type, int protocol)
socket:
    endbr64
    push rbp
    mov rbp, rsp

    # create a socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
    mov rax, SYS_SOCKET # sys_socket
    syscall

    leave
    ret

# bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
bind:
    endbr64
    # save rbp
    push rbp
    mov rbp, rsp

    # bind socket
    mov rax, SYS_BIND #sys_bind
    syscall


    leave
    ret 

# listen(int sockfd, int backlog)
listen:
    endbr64
    push rbp
    mov rbp, rsp

    # start listening
    mov rax, SYS_LISTEN
    syscall 

    leave
    ret

# accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict addrlen)
accept:
    endbr64
    push rbp
    mov rbp, rsp

    mov rax, SYS_ACCEPT
    syscall


    leave
    ret



# open(const char *pathname, int flags, mode_t mode)
open:
    endbr64
    push rbp
    mov rbp, rsp

    mov rax, SYS_OPEN
    syscall

    leave
    ret

# read(int fd, void *buf, size_t count)
read:
    endbr64
    push rbp
    mov rbp, rsp
     
    mov rax, SYS_READ
    syscall

    leave
    ret

# write(int fd, const void *buf, size_t count)
write:
    endbr64
    push rbp
    mov rbp, rsp

    mov rax, SYS_WRITE
    syscall

    leave
    ret


# close(int fd)
close:
    endbr64
    push rbp
    mov rbp, rsp

    mov rax, SYS_CLOSE
    syscall

    leave
    ret

# exit(int code)
exit:
    endbr64
    push rbp
    mov rsp, rbp

    mov rdi, 0
    mov rax, SYS_EXIT
    syscall

    leave
    ret

response:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"

test_file:
    .ascii "index.html"

.section .data
    .lcomm buffer, 1024
    .lcomm file_buff, 1024

