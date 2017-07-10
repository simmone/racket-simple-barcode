#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../../lib/code128-lib.rkt")

(require racket/runtime-path)
(define-runtime-path code128_write_test1 "code128_write_test1.png")
(define-runtime-path code128_write_test2 "code128_write_test2.png")

(define test-lib
  (test-suite
   "test-code128"

   (test-case 
    "test-get-code128-map"
    
    (let (
          [code_a_char_bar_map (get-code128-map #:code 'A #:type 'char->bar)]
          [code_a_char_weight_map (get-code128-map #:code 'A #:type 'char->weight)]
          [code_a_bar_char_map (get-code128-map #:code 'A #:type 'bar->char)]
          )

      (check-equal? (hash-count code_a_char_bar_map) 106)

      (check-equal? (hash-ref code_a_char_bar_map #\u0020) "11011001100")
      (check-equal? (hash-ref code_a_char_weight_map #\u0020) 0)
      (check-equal? (hash-ref code_a_char_weight_map #\u0011) 81)
      (check-equal? (hash-ref code_a_bar_char_map "11011001100") #\u0020)
      ))

   (test-case
    "test-shift-compress"
    
    (check-equal? (shift-compress 
                   '("StartA" #\u0011 "CodeB" #\a "CodeA" #\u0011)) 
                   '("StartA" #\u0011 "Shift" #\a #\u0011))

    (check-equal? (shift-compress 
                   '("StartB" #\a "CodeA" #\u0011 "CodeB" #\a "CodeA" #\u0011 "CodeB" #\a))
                   '("StartB" #\a "Shift" #\u0011 #\a "Shift" #\u0011 #\a))

    (check-equal? (shift-compress 
                   '("StartB" #\a "CodeA" #\u0011 "CodeB" #\a "CodeA" #\u0011 "CodeB" #\a "CodeA" #\u0011 "CodeB" #\a))
                   '("StartB" #\a "Shift" #\u0011 #\a "Shift" #\u0011 #\a "Shift" #\u0011 #\a))

    (check-equal? (shift-compress 
                   '("StartB" #\a "CodeA" #\u0011 "CodeC" "01" "CodeA" #\u0011 "CodeC" "02" "04" "CodeB" #\a))
                   '("StartB" #\a "CodeA" #\u0011 "CodeC" "01" "CodeA" #\u0011 "CodeC" "02" "04" "CodeB" #\a))

    (check-equal? (shift-compress 
                   '("StartB" #\a "CodeA" #\u0011 "CodeC" "01" "CodeA" #\u0011 "CodeB" #\a "CodeA" #\u0011 "CodeC" "02" "04"    "CodeB" #\a))
                   '("StartB" #\a "CodeA" #\u0011 "CodeC" "01" "CodeA" #\u0011 "Shift" #\a #\u0011 "CodeC"  "02"   "04" "CodeB" #\a))

    (check-equal? (shift-compress 
                   '("StartB" #\a "CodeA"  #\u0011 "CodeB" #\a #\b      "CodeA" #\u0011 "CodeB" #\a))
                   '("StartB" #\a "Shift" #\u0011 #\a     #\b "Shift" #\u0011 #\a))

    (check-equal? (shift-compress 
                   '("StartB" #\a "CodeA"  #\u0011 #\u0011 "CodeB" #\a #\b))
                   '("StartB" #\a "CodeA"  #\u0011 #\u0011 "CodeB" #\a #\b))
    )
   
   (test-case
    "test-encode-c128"
    
    (check-equal? (encode-c128 "chenxiao") '("StartB" #\c #\h #\e #\n #\x #\i #\a #\o))
    (check-equal? (encode-c128 "\u0011CHENXIAO") '("StartA" #\u0011 #\C #\H #\E #\N #\X #\I #\A #\O))
    (check-equal? (encode-c128 "\u0011CHEnxIAO") '("StartA" #\u0011 #\C #\H #\E "CodeB" #\n #\x #\I #\A #\O))
    (check-equal? (encode-c128 "chen\u0011xiao") '("StartB" #\c #\h #\e #\n "CodeA" #\u0011 "CodeB" #\x #\i #\a #\o))

    (check-equal? (encode-c128 "chen123x") '("StartB" #\c #\h #\e #\n #\1 #\2 #\3 #\x))
    (check-equal? (encode-c128 "chen1234x") '("StartB" #\c #\h #\e #\n "CodeC" "12" "34" "CodeB" #\x))
    (check-equal? (encode-c128 "chen12345x") '("StartB" #\c #\h #\e #\n "CodeC" "12" "34" "CodeB" #\5 #\x))
    (check-equal? (encode-c128 "chen123456x") '("StartB" #\c #\h #\e #\n "CodeC" "12" "34" "56" "CodeB" #\x))
    (check-equal? (encode-c128 "chen1234567x") '("StartB" #\c #\h #\e #\n "CodeC" "12" "34" "56" "CodeB" #\7 #\x))
    (check-equal? (encode-c128 "chen12345678x") '("StartB" #\c #\h #\e #\n "CodeC" "12" "34" "56" "78" "CodeB" #\x))
    (check-equal? (encode-c128 "chen123456789x") '("StartB" #\c #\h #\e #\n "CodeC" "12" "34" "56" "78" "CodeB" #\9 #\x))

    (check-equal? (encode-c128 "\u00111234abc") '("StartA" #\u0011 "CodeC" "12" "34" "CodeB" #\a #\b #\c))

    (check-equal? (encode-c128 "PJJ123C") '("StartA" #\P #\J #\J #\1 #\2 #\3 #\C))
    )
   
   (test-case
    "test-code->value"
    
    (check-equal? (code->value '("StartA" #\P #\J #\J #\1 #\2 #\3 #\C)) '(103 48 42 42 17 18 19 35))
    (check-equal? (code->value '("StartA" #\u0011 "CodeC" "12" "34" "CodeB" #\a #\b #\c)) '(103 81 99 12 34 100 65 66 67))

    )
   
   (test-case
    "test-get-code128-dimension"
    
    (check-equal? (get-code128-dimension 11 1) '(143 . 85))
    )
   
   (test-case
    "test-code128-checksum"
    
    (check-equal? (code128-checksum '(103 48 42 42 17 18 19 35)) 54)
    (check-equal? (code128-checksum (code->value (encode-c128 "\u00111234abc"))) 73)

    )

   (test-case
    "test-code128-bars-checksum"
    
    (check-equal? (code128-bars-checksum 
                  (string-append
                   "11010000100" "10010111100"
                   "10111011110" "10110011100" "10001011000"
                   "10111101110" "10010110000" "10010000110" "10000101100"
                   "10000110100"
                   "1100011101011"))
                  73)
    )
   
   (test-case
    "test-code128-verify"

    (check-equal? (code128-verify 
                  (string-append
                   "11010000100" "10010111100"
                   "10111011110" "10110011100" "10001011000"
                   "10111101110" "10010110000" "10010000110" "10000101100"
                   "10000110100"
                   "1100011101011"))
                  #t)

    (check-equal? (code128-verify 
                  (string-append
                   "11010000100" "10010111100"
                   "10111011110" "10110011100" "10001011000"
                   "10111101110" "10010110000" "10010000110" "10000101100"
                   "11001000010"
                   "1100011101011"))
                  #f)
    )
   
   (test-case
    "test-code128->bars"
    
    (check-equal? (code128->bars '("StartA" #\u0011 "CodeC" "12" "34" "CodeB" #\a #\b #\c "73" "Stop"))
                  (string-append
                   "11010000100" "10010111100"
                   "10111011110" "10110011100" "10001011000"
                   "10111101110" "10010110000" "10010000110" "10000101100"
                   "10000110100"
                   "1100011101011"))
    )

   (test-case
    "test-write"
    
    (dynamic-wind
        (lambda ()
          (void)
          )
        (lambda ()
          (draw-code128 "750103131130" code128_write_test1 #:brick_width 5)
          (draw-code128 "chenxiao770117" code128_write_test2 #:brick_width 5)
          )
        (lambda ()
          (delete-file code128_write_test1)
          (delete-file code128_write_test2)
          )))
   
   ))

(run-tests test-lib)
