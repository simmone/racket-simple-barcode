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
      (check-equal? (hash-ref char_bar_map #\u0002) "1001001001010101101001011")
      (check-equal? (hash-ref char_bar_map #\u007f) "1010010010010101011011001")

      (check-equal? (hash-count bar_char_map) 131)
      (check-equal? (hash-ref bar_char_map "101001011011") #\7)
      (check-equal? (hash-ref bar_char_map "110010101101") #\.)
      (check-equal? (hash-ref bar_char_map "1001001001010101011011001") #\u0002)

      (check-equal? (hash-ref bar_char_map "1001001001010101011011001") #\u007f)
      (check-equal? (hash-ref bar_char_map "1001001001010100101101011") #\u007f)
      (check-equal? (hash-ref bar_char_map "1001001001010110010110101") #\u007f)
      (check-equal? (hash-ref bar_char_map "1001001001010100110110101") #\u007f)
      ))
   
   ))

(run-tests test-lib)
