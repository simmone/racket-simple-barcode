#lang info

(define version "1.1")

(define license
  '(Apache-2.0 OR MIT))

(define collection 'multi)

(define deps '("base"
               "rackunit-lib"
               "draw-lib"
               "simple-svg"
               ))

(define build-deps '("racket-doc"
                     "scribble-lib"))

(define test-omit-paths '("info.rkt"))

