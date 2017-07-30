Minerd
======
Minerd is a simple process manager. Its purpose is to spawn processes within
a pty and allow user interaction with these processes.

Minerd is controlled via TCP socket with a line based protocol. Clients send
messages encoded in JSON. The top-level object has keys `cmd` and `opts`,
where `cmd` is a command name string and `opts` an object or array with
command-specific options.

Minerd replies to every message with JSON object containing `status` flag
and optionally `response` or `message`. `status` indicates whether the operation
was successful or not. `response` may contain data when the command was
successful. `message` can contain an error message.

Available commands are described below.

## STATUS
Return status of either minerd itself, or a specific process, identified by
option `id`.

## START
Start a new process identified by option `id`, with executable in `cmd`
and arguments in option `args`.

## STOP
Stop a running process identified by `id`.

## LIST
List all running processes.

## ATTACH
Switches into interactive mode, providing access stdin/out/err of a running
process identified by `id`. When in interactive mode, the client can send
the following line-based commands:

 - `W <data in base64>` to send data to the program
 - `S <width> <height>` to set the program's pty dimensions (cols and rows)
 - `Q` to leave the interactive mode

Minerd sends the raw process's output directly.
