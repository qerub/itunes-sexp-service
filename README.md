# iTunes S-expression Service: Simple [Remote] Control

I like music, my office colleague, Scheme, and OS X (in that particular order).
My colleague oftens asks me what music I'm playing at the office and would
sometimes like to control the music volume (when he has a phone call to make).
What a great occasion to combine all the things I like!

This repository contains a service implemented in Racket that reads S-expression
commands/queries and forwards them to iTunes through Scripting Bridge.

```
$ ./main.sh
Listening on port 4137!
```

```
$ echo "(help)" | nc localhost 4137
(help
 "Available commands:"
 (help)
 (current-track)
 (pause)
 (volume)
 (volume 0-100))
```

```
$ echo "(current-track)" | nc localhost 4137
(track (artist "Clint Heidorn") (album "Atwater") (name "3") (length "3:55"))
```
