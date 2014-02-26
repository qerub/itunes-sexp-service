#lang racket

(provide @)

(require (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         ffi/unsafe/nsstring)

(import-class NSString)

(define (objc->rkt-bridge object)
  (if (and (cpointer? object)
           (tell #:type _BOOL object isKindOfClass: NSString))
      (tell #:type _NSString object self) ; TODO: Is there another way?
      object))

; TODO: Refactor this
(define-syntax (@ stx)
  (syntax-case stx ()
    ([_ #:type type target method-name rest ...]
     #'(if (tell #:type _BOOL target respondsToSelector: #:type _SEL (selector method-name))
           (objc->rkt-bridge (tell #:type type target method-name rest ...))
           (error '@ "No method ~a on ~a" 'method-name (objc->rkt-bridge (tell target description)))))
    ((_ rest ...)
     #'[@ #:type _id rest ...])))
