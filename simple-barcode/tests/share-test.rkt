#lang racket

(require rackunit/text-ui)

(require rackunit "../lib/share.rkt")

(define test-lib
  (test-suite
   "test-ean13"

   (test-case
    "test-find-threshold"
    
    (let ([points_list (pic->points ean13_file)])
      (check-equal? (length points_list) 180)
      (check-equal? (length (car points_list)) 236)

      (check-equal? (find-threshold points_list) 382)
    ))

   ))

(run-tests test-lib)
