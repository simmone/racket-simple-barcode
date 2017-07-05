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
      (check-equal? (search-barcode-on-row points_row_false) #f)
      (let ([res (search-barcode-on-row points_row_true)])
        (check-equal? (car res) 'ean13)
        (check-equal? (cdr res) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
    ))

   (test-case
    "test-search-barcode"
    
    (let* (
           [real_row '(
                       1 0 1 0 0 1 0
                         1 0 1
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
                         1 0 1
                         0 0 1 0 1 1 1)]
           [real_row2 '(
                       1 0 1 0 0 1
                         1 0 1
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
                         1 0 1
                         0 0 1 0 1 1 1 0)]
           [noise_row '(
                        1 0 1 0 0 1 0
                          1 0 0
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
                          1 0 1
                          0 0 1 0 1 1 1)]
           [points_list_true1 (list noise_row noise_row real_row real_row real_row real_row real_row noise_row)]
           [points_list_true2 (list real_row real_row real_row real_row real_row noise_row)]
           [points_list_true3 (list real_row real_row real_row real_row real_row)]
           )
      (check-equal? (search-barcode points_list_true1) '(ean13 . "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
      (check-equal? (search-barcode points_list_true2) '(ean13 . "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
      (check-equal? (search-barcode points_list_true3) '(ean13 . "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
   ))

   ))

(run-tests test-lib)