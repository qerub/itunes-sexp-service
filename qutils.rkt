#lang racket

(provide define-syntax-case -> ->> if-let)

(define-syntax-rule (define-syntax-case name literals cases ...)
  (define-syntax (name stx)
    (syntax-case stx literals cases ...)))

(define-syntax-case -> ()
  ((_ x)                 #'x)
  ((_ x (form more ...)) #'(form x more ...))
  ((_ x form)            #'(form x))
  ((_ x form more ...)   #'(-> (-> x form) more ...)))

(define-syntax-case ->> ()
  ((_ x (form more ...)) #'(form more ... x))
  ((_ x form)            #'(form x))
  ((_ x form more ...)   #'(->> (->> x form) more ...)))

(define-syntax-case if-let ()
  [(_ [binding value] then-expr else-expr)
   #'(let ([binding value])
       (if binding then-expr else-expr))])
