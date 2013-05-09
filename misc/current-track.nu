#!/usr/bin/env nush -f ScriptingBridge
#
# (goto http://programming.nu/)

(macro -> (first second *rest)
  (if (== *rest (list))
    (then (if (list? second)
            (then `(,first ,@second))
            (else `(,first  ,second))))
    (else `(-> (-> ,first ,second) ,@*rest))))

(set iTunes (SBApplication applicationWithBundleIdentifier: "com.apple.iTunes"))

(function error (x) (list 'error x))

(function is-playing? () (-> iTunes currentTrack name))

(function current-track ()
  (if (is-playing?)
    (then (let ((t (iTunes currentTrack)))
               `(track (artist ,(t artist))
                       (album  ,(t album))
                       (number ,(t trackNumber))
                       (name   ,(t name)))))
    (else (error "iTunes is not playing"))))

(function read-command () (-> Nu parser (parse: (gets)) cdr car))

(function handle-command (command)
  (if (and (list? command) (symbol? (car command)))
    (then (cond ((and (== (command car) 'current-track)
                      (== (-> command cdr length) ((send current-track parameters) length)))
                 ; =>
                 (current-track))
                (else (error "Unknown command"))))
    (else (error "Command must be a list beginning with a symbol"))))

(puts (handle-command (read-command)))
