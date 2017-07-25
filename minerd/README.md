Minerd
======
Minerd is a simple process manager. Its purpose is to spawn processes within
a pty and allow user interaction with these processes.

Minerd is controlled via TCP socket with a line based protocol. Clients send
messages, where the first word is the command name and the rest are arguments.
Minerd replies to every message.

There are four commands:

 - `STATUS [id]` - returns OK without `id`, process info when `id` is set
 - `START <id> <cmd> [args...]` - start a process identified by `id`
 - `STOP <id>` - stop process identified by `id`
 - `LIST` - list active processes, JSON encoded
 - `ATTACH <id>` - switch into interactive mode, where the client can send
   data to running program's stdin and receives data from stdout/stderr. When
   in this mode, the following commands are available:
   - `W <data in base64>` to send data to the program
   - `S <width> <height>` to set the program's pty dimensions (cols and rows)
   - `Q` to leave the interactive mode
