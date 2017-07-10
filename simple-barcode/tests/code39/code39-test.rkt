#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../../lib/code39-lib.rkt")

(require racket/runtime-path)
(define-runtime-path code39_write_test1 "code39_write_test1.png")
(define-runtime-path code39_write_test2 "code39_write_test2.png")

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
      (check-equal? (hash-ref bar_char_map "1001001001010101101001011") #\u0002)

      (check-equal? (hash-ref bar_char_map "1010010010010101011011001") #\u007f)
      (check-equal? (hash-ref bar_char_map "1010010010010100101101011") #\u007f)
      (check-equal? (hash-ref bar_char_map "1010010010010110010110101") #\u007f)
      (check-equal? (hash-ref bar_char_map "1010010010010100110110101") #\u007f)
      ))

   (test-case
    "test-code39->bars"

    (check-equal? (code39->bars "CHEN")
                  (string-append
                   "100101101101" "0"
                   "110110100101" "0"
                   "110101001101" "0"
                   "110101100101" "0"
                   "101011010011" "0"
                   "100101101101"))

    (check-equal? (code39->bars "chen")
                  (string-append
                   "100101101101" "0"
                   "100101001001" "0" "110110100101" "0"
                   "100101001001" "0" "110101001101" "0"
                   "100101001001" "0" "110101100101" "0"
                   "100101001001" "0" "101011010011" "0"
                   "100101101101"))
    )
   
   (test-case
    "test-get-code39-dimension"
    
    (check-equal? (get-code39-dimension 77 1) '(97 . 85))

    (check-equal? (get-code39-dimension 77 2) '(194 . 170))
    )

   (test-case
    "test-write"
    
    (dynamic-wind
        (lambda ()
          (void)
          )
        (lambda ()
          (draw-code39 "CHEN" code39_write_test1)
          (draw-code39 "chenxiao" code39_write_test2)
          )
        (lambda ()
          (void)
;          (delete-file code39_write_test1)
;          (delete-file code39_write_test2)
          )))

   ))

(run-tests test-lib)
