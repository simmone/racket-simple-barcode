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
      (check-equal? (hash-ref code_a_bar_char_map "11011001100") #\u0020)
      ))
   
   (test-case
    "test-encode-c128"
    
    (check-equal? (encode-c128 "chenxiao") '("StartB" #\c #\h #\e #\n #\x #\i #\a #\o "Stop"))
    
    )
   
   ))

(run-tests test-lib)
