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
    "test-ean13->bar"
    (check-equal? (ean13->bar "7501031311309") "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101")
    )

   (test-case
    "test-draw-bar"
    
    (let* ([canvas_width 100]
           [target (make-bitmap canvas_width canvas_width)]
           [dc (new bitmap-dc% [bitmap target])])

      (draw-bar dc '(10 . 10) "black" 10 50)

      (send target save-file "test.png" 'png)))

   (test-case
    "test-get-dimension"
    
    (let* ([bar_width 1]
           [dimension (get-dimension bar_width)])
      (check-equal? (car dimension) 118)
      (check-equal? (cdr dimension) 32))
    )

   ))

(run-tests test-lib)
