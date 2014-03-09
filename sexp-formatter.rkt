#lang racket

;; pretty-print's pretty-print-extend-style-table is a bit cumbersome...

(require rackjure/threading)

(require (prefix-in text: scribble/text))

(provide write-formatted-sexp)

(define (write-formatted-sexp form)
  (define gen-text
    (match-lambda
      [(list x xs ..1)
       (list "(" (~s x) " " (text:add-newlines (map gen-text xs)) ")")]
      [other
       (~s other)]))
  
  (~>> form gen-text text:output))

(module+ test
  (require rackunit)
  
  (define (f form)
    (with-output-to-string
     (lambda () (write-formatted-sexp form))))
  
  (check-equal? (f 1)                        "1")
  (check-equal? (f "foo")                    "\"foo\"")
  (check-equal? (f '(foo))                   "(foo)")
  (check-equal? (f '(foo bar))               "(foo bar)")
  (check-equal? (f '(foo bar baz))           "(foo bar\n     baz)")
  (check-equal? (f '(foo bar (foo bar baz))) "(foo bar\n     (foo bar\n          baz))"))
