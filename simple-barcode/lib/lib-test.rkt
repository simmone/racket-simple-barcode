#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "lib.rkt")

(define test-lib
  (test-suite
   "test-ean13"

   (test-case 
    "test-ean13-checksum"
    (check-equal? (ean13-checksum "001234567890") 5)
    (check-equal? (ean13-checksum "001234067890") 0)
    (check-equal? (ean13-checksum "750103131130") 9)
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

   (test-case
    "test-ean13->bar_group"
    (check-equal? (ean13->bar_group "7501031311309")
                  '(
                   ("$" . "202")
                   ("5" . "0110001")
                   ("0" . "0100111")
                   ("1" . "0011001")
                   ("0" . "0100111")
                   ("3" . "0111101")
                   ("1" . "0110011")
                   ("$" . "02020")
                   ("3" . "1000010")
                   ("1" . "1100110")
                   ("1" . "1100110")
                   ("3" . "1000010")
                   ("0" . "1110010")
                   ("9" . "1110100")
                   ("$" . "202")))
    )

   (test-case
    "test-get-dimension"
    
    (let* ([brick_width 1]
           [dimension (get-dimension brick_width)])
      (check-equal? (car dimension) 118)
      (check-equal? (cdr dimension) 90)
      )
    )

   (test-case
    "test-draw-ean13"
    
    (draw-ean13 "7501031311309" "test.png")

    (draw-ean13 "7501031311309" "test5.png" #:brick_width 5)

    (draw-ean13 "7501031311309" "test_color.png" #:color_pair '("red" . "blue"))

    (draw-ean13 "7501031311309" "test_trans.png" #:color_pair '("red" . "transparent"))
    )

   ))

(run-tests test-lib)
