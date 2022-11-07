# Assembly-Basic-Server
A very basic server in written Assembly, for learning purposes


## Basics
Everything is done with syscalls (see https://x64.syscall.sh/)
The small program:
 - Creates a socket
 - Binds it to a port and address (AF_INET)
 - Starts listening
 - Accepts a connection
 - Reads the content of the connection
 - Opens a file (i.e GET index.html HTTP/1.1 will retrieve index.html)
 - Reads the content of the file
 - Closes the file
 - Writes a response header with status (simple HTTP/1.0 200 OK)
 - Writes the content of the file to the user
 - Closes the connection
 - Exits


Socket, bind, listen, accept, read, open, read, close, write, write, close, exit

It can also be improved by adding a loop to keep listening to other connections or handling the connection in a child process (FORK) 

If you're looking to replicate this, I recommend writing a simple server in C and disassembling it