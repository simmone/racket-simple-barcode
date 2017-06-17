#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../../lib/ean13-lib.rkt")

(require racket/runtime-path)
(define-runtime-path ean13_write_test1 "ean13_write_test1.png")

(define test-lib
  (test-suite
   "test-ean13"

   (test-case 
    "test-ean13-checksum"
    (check-equal? (ean13-checksum "001234567890") 5)
    (check-equal? (ean13-checksum "509876543210") 0)

    (check-equal? (ean13-checksum "001234067890") 0)
    (check-equal? (ean13-checksum "009876043210") 0)

    (check-equal? (ean13-checksum "750103131130") 9)
    (check-equal? (ean13-checksum "903113130105") 7)
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
    "test-ean13->bars"
    (check-equal? (ean13->bars "7501031311309")
                  (string-append
                   "000"
                   "0110001"
                   "0100111"
                   "0011001"
                   "0100111"
                   "0111101"
                   "0110011"
                   "00000"
                   "1000010"
                   "1100110"
                   "1100110"
                   "1000010"
                   "1110010"
                   "1110100"
                   "000"))
    )

   (test-case
    "test-get-ean13-dimension"
    
    (let* ([brick_width 1]
           [dimension (get-ean13-dimension brick_width)])
      (check-equal? (car dimension) 118)
      (check-equal? (cdr dimension) 90)
      )
    )

   (test-case
    "test-get-bar-char-map"
    
    (check-equal? (hash-count (get-bar-char-map)) 30)
    )
   
   (test-case
    "test-write-read"
    
    (dynamic-wind
        (lambda ()
          (void))
        (lambda ()
          (check-exn exn:fail? (lambda () (draw-ean13 "1234567890123" ean13_write_test1)))
          (check-exn exn:fail? (lambda () (draw-ean13 "12345678901a2" ean13_write_test1)))
          (draw-ean13 "750103131130" ean13_write_test1)
          )
        (lambda ()
          (delete-file ean13_write_test1)
          )))
   ))

(run-tests test-lib)
