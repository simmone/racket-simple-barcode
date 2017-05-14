#lang racket

(require rackunit/text-ui)
(require racket/date)

(require rackunit "lib.rkt")

(define test-lib
  (test-suite
   "test-ean13"

   (test-case 
    "test-ean13-checksum"
    (check-equal? (ean13-checksum "001234567890") 5)
    (check-equal? (ean13-checksum "001234067890") 0)
   )
    
   ))

(run-tests test-lib)
