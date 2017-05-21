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

   (test-case
    "test-char->barstring"
    (check-equal? (char->barstring #\1 'left_odd) "0011001")
    (check-equal? (char->barstring #\1 'left_even) "0110011")
    (check-equal? (char->barstring #\1 'right) "1100110")

    (check-equal? (char->barstring #\9 'left_odd) "0001011")
    (check-equal? (char->barstring #\9 'left_even) "0010111")
    (check-equal? (char->barstring #\9 'right) "1110100")
   )
   ))

(run-tests test-lib)
