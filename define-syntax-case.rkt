#lang racket

(provide define-syntax-case)

(define-syntax-rule (define-syntax-case name literals cases ...)
  (define-syntax (name stx)
    (syntax-case stx literals cases ...)))
