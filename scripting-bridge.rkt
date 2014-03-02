#lang racket

(provide get-scripting-bridge-app)

; http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ScriptingBridgeConcepts/Introduction/Introduction.html

(require ffi/unsafe/objc
         ffi/unsafe/nsstring)

(require "objc-plumbing.rkt")

(import-class NSBundle)

(define sb-bundle
  [@ NSBundle bundleWithPath: #:type _NSString "/System/Library/Frameworks/ScriptingBridge.framework"])

(unless [@ #:type _BOOL sb-bundle load]
  (error "Failed to load scripting bridge"))

(import-class SBApplication)

(define (get-scripting-bridge-app identifier)
  [@ SBApplication applicationWithBundleIdentifier: #:type _NSString identifier])
