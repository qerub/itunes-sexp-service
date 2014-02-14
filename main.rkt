#lang racket

(require "objc-plumbing.rkt")
(require "scripting-bridge.rkt")

(require rackjure/conditionals)
(require rackjure/threading)

(require (only-in ffi/unsafe _float _uint8))
(require (only-in ffi/unsafe/objc _BOOL))

(define iTunes (get-scripting-bridge-app "com.apple.iTunes"))

(define (help)
  '(help "Available commands:" (help) (current-track) (pause) (volume) (set-volume 0-100)))

(define (current-track)
  (if (is-playing?)
      (let* ([t [@ iTunes currentTrack]]
             [d [@ #:type _float t duration]])
        `(track (artist ,[@ t artist])
                (album  ,[@ t album])
                (number ,[@ #:type _uint8 t trackNumber])
                (name   ,[@ t name])
                (length ,(seconds->m:s d))))
      (error "iTunes is not playing")))

(define (pause)
  (define starting-volume (volume))
  (set-volume 0)
  [@ iTunes pause]
  [@ iTunes setSoundVolume: #:type _uint8 starting-volume]
  'ok)

(define (volume) [@ #:type _uint8 iTunes soundVolume])

(define (set-volume v)
  (unless (<= 0 v 100) (error "Invalid volume"))
  
  (for ([v-step (volume-steps (volume) v)])
    [@ iTunes setSoundVolume: #:type _uint8 v-step]
    (sleep 0.1))
  'ok)

;; Command handling

; NOTE: This is very general because I plan to reuse it :)

(define (abstract-command-handler command-map command)
  (with-handlers ([exn? (λ (e) (list 'error (exn-message e)))])
    (match command
      [(list (? symbol? name) args ...)
       (if-let [proc (hash-ref command-map name #f)]
               (apply proc args)
               (error "No such command [try (help)]"))]
      
      [_ (error "Command must be a list beginning with a symbol")])))

(define (make-command-handler . commands)
  (curry abstract-command-handler
         (for/hasheq ([x commands]) (values (object-name x) x))))

(define command-handler (make-command-handler help current-track pause volume set-volume))

;; Helpers

; NOTE: This is the best way I've found without having to make an enum for "player state".
(define (is-playing?) [@ [@ iTunes currentTrack] name])

(define (seconds->m:s x)
  (let-values ([(m s) (~> x round inexact->exact (quotient/remainder 60))])
    (~a m ":" (~a #:width 2 #:pad-string "0" #:align 'right s))))

(define (volume-steps start end)
  (reverse (range end start (if (< end start) +5 -5))))

;; main

(module+ main
  (match (current-command-line-arguments)
    [(vector) (~>> (read) command-handler pretty-write)]
    [_        (error "Run this program without arguments!")]))
