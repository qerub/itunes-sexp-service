# iTunes S-expression Service: Simple [Remote] Control

I like music, my office colleague, Scheme, and OS X (in that particular order).
My colleague oftens asks me what music I'm playing at the office and would
sometimes like to control the music volume (when he has a phone call to make).
What a great occasion to combine all the things I like!

This repository contains a service implemented in Racket that reads S-expression
commands/queries and forwards them to iTunes through Scripting Bridge.

## Usage Instructions

### Privately

```
$ echo "(help)" | racket main.rkt
(help
 "Available commands:"
 (help)
 (current-track)
 (pause)
 (volume)
 (volume 0-100))
```

### Shared (Temporarily)

```
$ tcpserver -v -H 0.0.0.0 4137 racket main.rkt
tcpserver: status: 0/40
```

```
$ echo "(current-track)" | nc localhost 4137
(track (artist "Clint Heidorn") (album "Atwater") (name "3") (length "3:55"))
```

### Shared (Permanently)

```
$ mkdir -p compiled ~/Library/LaunchDaemons
$ raco exe -o compiled/itunes-sexp-service main.rkt
$ sudo cp compiled/itunes-sexp-service /usr/local/bin
$ cp misc/se.defsoftware.itunes-sexp-service.plist ~/Library/LaunchDaemons
$ launchctl load ~/Library/LaunchDaemons/se.defsoftware.itunes-sexp-service.plist
$ echo "(volume 75)" | nc localhost 4137
```
