#lang racket

(require rackunit/text-ui)

(require rackunit "../lib/share.rkt")

(require racket/runtime-path)
(define-runtime-path ean13_file "../example/barcode_ean13.png")

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

   (test-case
    "test-search-barcode-on-row"
    
    (let ([points_row_false '(1 0)]
          [points_row_true '(1 0 1
                              0 1 1 0 0 0 1 
                              0 1 0 0 1 1 1 
                              0 0 1 1 0 0 1
                              0 1 0 0 1 1 1
                              0 1 1 1 1 0 1
                              0 1 1 0 0 1 1
                              0 1 0 1 0
                              1 0 0 0 0 1 0
                              1 1 0 0 1 1 0
                              1 1 0 0 1 1 0
                              1 0 0 0 0 1 0
                              1 1 1 0 0 1 0
                              1 1 1 0 1 0 0 
                              1 0 1)]
          )
      (check-equal? (search-barcode-on-row points_row_false 'ean13) #f)
      (let ([res (search-barcode-on-row points_row_true 'ean13)])
        (check-equal? res "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
    ))

   ))

(run-tests test-lib)
