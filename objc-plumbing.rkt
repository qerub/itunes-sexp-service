#lang racket

(provide @)

(require (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         ffi/unsafe/nsstring)

(require "qutils.rkt")

(import-class NSString)

(define (objc->rkt-bridge object)
  (if (and (cpointer? object)
           (tell #:type _BOOL object isKindOfClass: NSString))
      (tell #:type _NSString object self) ; TODO: Is there another way?
      object))

; TODO: Refactor this
(define-syntax-case tell-with-check ()
  ((_ #:type type target method-name rest ...)
   #`(if (tell #:type _BOOL target respondsToSelector: #:type _SEL (selector method-name))
         (objc->rkt-bridge (tell #:type type target method-name rest ...))
         (error '@ "No method ~a on ~a" 'method-name (objc->rkt-bridge (tell target description)))))
  ((_ rest ...)
   #`(tell-with-check #:type _id rest ...)))

(define-syntax-case @ ()
  ((_ rest ...)
   #`(tell-with-check rest ...)))
