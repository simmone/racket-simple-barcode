#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../../lib/code128-lib.rkt")

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
    "test-encode-c128"
    
    (check-equal? (encode-c128 "chenxiao") '("StartB" #\c #\h #\e #\n #\x #\i #\a #\o "Stop"))
    (check-equal? (encode-c128 "\u0011CHENXIAO") '("StartA" #\u0011 #\C #\H #\E #\N #\X #\I #\A #\O "Stop"))
    (check-equal? (encode-c128 "\u0011CHEnxIAO") '("StartA" #\u0011 #\C #\H #\E "StartB" #\n #\x #\I #\A #\O "Stop"))
    (check-equal? (encode-c128 "chen\u0011xiao") '("StartB" #\c #\h #\e #\n "StartA" #\u0011 "StartB" #\x #\i #\a #\o "Stop"))

    (check-equal? (encode-c128 "chen123x") '("StartB" #\c #\h #\e #\n #\1 #\2 #\3 #\x "Stop"))
    (check-equal? (encode-c128 "chen1234x") '("StartB" #\c #\h #\e #\n "StartC" "12" "34" "StartB" #\x "Stop"))
    (check-equal? (encode-c128 "chen12345x") '("StartB" #\c #\h #\e #\n "StartC" "12" "34" "StartB" #\5 #\x "Stop"))
    (check-equal? (encode-c128 "chen123456x") '("StartB" #\c #\h #\e #\n "StartC" "12" "34" "56" "StartB" #\x "Stop"))
    (check-equal? (encode-c128 "chen1234567x") '("StartB" #\c #\h #\e #\n "StartC" "12" "34" "56" "StartB" #\7 #\x "Stop"))
    (check-equal? (encode-c128 "chen12345678x") '("StartB" #\c #\h #\e #\n "StartC" "12" "34" "56" "78" "StartB" #\x "Stop"))
    (check-equal? (encode-c128 "chen123456789x") '("StartB" #\c #\h #\e #\n "StartC" "12" "34" "56" "78" "StartB" #\9 #\x "Stop"))
    )
   
   ))

(run-tests test-lib)
