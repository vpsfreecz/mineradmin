Minerd
======
Minerd is a simple process manager. Its purpose is to spawn processes within
a pty and allow user interaction with these processes.

Minerd is controlled via TCP socket with a line based protocol. Clients send
messages, where the first word is the command name and the rest are arguments.
Minerd replies to every message.

There are four commands:

 - `STATUS` - returns OK, will return more information in the future
 - `START <id> <cmd> [args...]` - start a process identified by `id`
 - `STOP <id>` - stop process identified by `id`
 - `LIST` - list active processes
