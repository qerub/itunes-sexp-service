#!/bin/sh

PORT=4137

echo "Listening on port $PORT!"

exec tcpserver -v -H 0.0.0.0 $PORT racket main.rkt
