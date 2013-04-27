#lang racket

(require "qutils.rkt")
(require "objc-plumbing.rkt")
(require "scripting-bridge.rkt")

(require (only-in ffi/unsafe _float _uint8))
(require (only-in ffi/unsafe/objc _BOOL))

(define iTunes (get-scripting-bridge-app "com.apple.iTunes"))

(define (handle command)
  (match command
    ['(help)
     '(help "Available commands:" (help) (current-track) (pause) (volume) (volume 0-100))]
    
    ['(current-track)
     (if (is-playing?)
         (let* ([t [@ iTunes currentTrack]]
                [d [@ #:type _float t duration]])
           `(track (artist ,[@ t artist])
                   (album  ,[@ t album])
                   (number ,[@ #:type _uint8 t trackNumber])
                   (name   ,[@ t name])
                   (length ,(seconds->m:s d))))
         '(error "iTunes is not playing"))]
    
    ['(pause)
     [@ iTunes pause]
     'ok]
    
    ['(volume)
     (current-volume)]
    
    [`(volume ,(? acceptable-volume? end))
     (for ([v (volume-steps (current-volume) end)])
       [@ iTunes setSoundVolume: #:type _uint8 v]
       (sleep 0.050))
     'ok]
    
    [(list _ ...)
     '(error "No such command (try the help command)")]
    
    [_
     '(error "Command must be a list")]))

; NOTE: This is the best way I've found without having to make an enum for "player state".
(define (is-playing?) [@ [@ iTunes currentTrack] name])

(define (seconds->m:s x)
  (let-values ([(m s) (-> x round inexact->exact (quotient/remainder 60))])
    (~a m ":" (~a #:width 2 #:pad-string "0" #:align 'right s))))

(define (current-volume) [@ #:type _uint8 iTunes soundVolume])

(define (acceptable-volume? v) (<= 0 v 100))

(define (volume-steps start end)
  (reverse (range end start (if (< end start) +5 -5))))

(module+ main
  (match (current-command-line-arguments)
    [(vector) (->> (read) handle pretty-write)]
    [_        (error "Run this program without arguments!")]))
