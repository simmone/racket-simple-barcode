#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../lib/lib.rkt")

(require racket/runtime-path)
(define-runtime-path ean13_file "../example/barcode_ean13.png")
(define-runtime-path ean13_w5_file "../example/barcode_ean13_w5.png")
(define-runtime-path ean13_color_file "../example/barcode_ean13_color.png")
(define-runtime-path ean13_trans_file "../example/barcode_ean13_trans.png")

(define-runtime-path ean13_test1 "ean13_test1.png")

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
    "test-find-threshold"
    
    (let ([points_list (pic->points ean13_file)])
      (check-equal? (length points_list) 180)
      (check-equal? (length (car points_list)) 236)

      (check-equal? (find-threshold points_list) 382)
    ))

   (test-case
    "test-search-barcode-on-row"
    
    (let ([points_row_false1 '(1 0)]
          [points_row_true1 '(1 0 1
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
          [points_row_true2 '(1 0 1 0 0 1 0
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
          )
      (check-equal? (search-barcode-on-row points_row_false1 #f) #f)
      (let ([res (search-barcode-on-row points_row_true1 #f)])
        (check-equal? (list-ref res 0) 1)
        (check-equal? (list-ref res 1) 0)
        (check-equal? (list-ref res 2) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
      (let ([res (search-barcode-on-row points_row_true2 #f)])
        (check-equal? (list-ref res 0) 1)
        (check-equal? (list-ref res 1) 7)
        (check-equal? (list-ref res 2) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
      (let ([res (search-barcode-on-row points_row_true1 1)])
        (check-equal? (list-ref res 0) 1)
        (check-equal? (list-ref res 1) 0)
        (check-equal? (list-ref res 2) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101"))
      (check-equal? (search-barcode-on-row points_row_true1 3) #f)
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
           [points_list_false1 (list noise_row noise_row real_row real_row real_row real_row noise_row)]
           [points_list_false2 (list noise_row noise_row real_row real_row real_row real_row noise_row real_row)]
           [points_list_false3 (list real_row real_row real_row real_row real_row2)]
           )
      (check-equal? (search-barcode points_list_true1) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101")
      (check-equal? (search-barcode points_list_true2) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101")
      (check-equal? (search-barcode points_list_true3) "10101100010100111001100101001110111101011001101010100001011001101100110100001011100101110100101")
      (check-equal? (search-barcode points_list_false1) #f)
      (check-equal? (search-barcode points_list_false2) #f)
      (check-equal? (search-barcode points_list_false3) #f)
    ))

   (test-case
    "test-get-bar-char-map"
    
    (check-equal? (hash-count (get-bar-char-map)) 30)
    )
   
   (test-case
    "test-read-ean13"

    (check-equal? (read-ean13 ean13_file) "7501031311309")
    (check-equal? (read-ean13 ean13_w5_file) "7501031311309")
    (check-equal? (read-ean13 ean13_color_file) "7501031311309")
    (check-equal? (read-ean13 ean13_trans_file) "7501031311309")

    (check-equal? (read-ean13 ean13_test1) "5901234123457")
    )

   ))

(run-tests test-lib)
