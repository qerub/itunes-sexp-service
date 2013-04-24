# iTunes S-expression Service: Simple [Remote] Control

```
./main.sh
```

```
echo "(current-track)" | nc localhost 4137
# => (track (artist "Clint Heidorn") (album "Atwater") (name "3") (length "3:55"))
```
