#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../../lib/code39-lib.rkt")

(define test-lib
  (test-suite
   "test-code39"

   (test-case 
    "test-get-code39-map"
    
    (let (
          [char_bar_map (get-code39-map #:type 'char->bar)]
          [bar_char_map (get-code39-map #:type 'bar->char)]
          )

      (check-equal? (hash-count char_bar_map) 128)
      (check-equal? (hash-ref char_bar_map #\7) "101001011011")
      (check-equal? (hash-ref char_bar_map #\.)  "110010101101")
      (check-equal? (hash-ref char_bar_map #\u0002) "100100100101101101001011")

      (check-equal? (hash-count bar_char_map) 128)
      (check-equal? (hash-ref bar_char_map "101001011011") #\7)
      (check-equal? (hash-ref bar_char_map "110010101101") #\.)
      (check-equal? (hash-ref bar_char_map "100100100101101101001011") #\u0002)
      ))
   
   ))

(run-tests test-lib)
