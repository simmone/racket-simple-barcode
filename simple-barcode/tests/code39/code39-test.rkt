#lang racket

(require rackunit/text-ui)
(require racket/date)
(require racket/draw)

(require rackunit "../../lib/code39-lib.rkt")

(require racket/runtime-path)
(define-runtime-path code39_write_test1 "code39_write_test1.png")
(define-runtime-path code39_write_test2 "code39_write_test2.png")
(define-runtime-path code39_write_test3 "code39_write_test3.png")

(define test-lib
  (test-suite
   "test-code39"

   (test-case
    "test-get-code39-map"

    (let (
          [basic_char_bar_map (get-code39-map #:type 'basic_char->bar)]
          [basic_bar_char_map (get-code39-map #:type 'basic_bar->char)]
          [basic_char_value_map (get-code39-map #:type 'basic_char->value)]
          [basic_value_char_map (get-code39-map #:type 'basic_value->char)]
          [extend_char_chars_map (get-code39-map #:type 'extend_char->chars)]
          [extend_chars_char_map (get-code39-map #:type 'extend_chars->char)]
          )

      (check-equal? (hash-count basic_char_value_map) 44)
      (check-equal? (hash-ref basic_char_value_map #\0) 0)
      (check-equal? (hash-ref basic_char_value_map #\F) 15)
      (check-equal? (hash-ref basic_char_value_map #\%) 42)

      (check-equal? (hash-count basic_value_char_map) 44)
      (check-equal? (hash-ref basic_value_char_map 0) #\0)
      (check-equal? (hash-ref basic_value_char_map 15) #\F)
      (check-equal? (hash-ref basic_value_char_map 42) #\%)

      (check-equal? (hash-count basic_char_bar_map) 44)
      (check-equal? (hash-ref basic_char_bar_map #\7) "101001011011")
      (check-equal? (hash-ref basic_char_bar_map #\.)  "110010101101")

      (check-equal? (hash-count basic_bar_char_map) 44)
      (check-equal? (hash-ref basic_bar_char_map "101001011011") #\7)
      (check-equal? (hash-ref basic_bar_char_map "110010101101") #\.)

      (check-equal? (hash-count extend_char_chars_map) 128)
      (check-equal? (hash-ref extend_char_chars_map #\u0007) "$G")
      (check-equal? (hash-ref extend_char_chars_map #\u007f) "%T")

      (check-equal? (hash-count extend_chars_char_map) 131)
      (check-equal? (hash-ref extend_chars_char_map "$G") #\u0007)
      (check-equal? (hash-ref extend_chars_char_map "%T") #\u007f)
      (check-equal? (hash-ref extend_chars_char_map "%X") #\u007f)
      (check-equal? (hash-ref extend_chars_char_map "%Y") #\u007f)
      (check-equal? (hash-ref extend_chars_char_map "%Z") #\u007f)
      ))
   
   (test-case
    "test-code39->groups"
    
    (check-equal? (code39->groups "CHEN") '("C" "H" "E" "N"))
    (check-equal? (code39->groups "chen") '("+C" "+H" "+E" "+N"))

    )

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

    (check-equal? (code39->bars "+C+H+E+N")
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
          (draw-code39-checksum "CHEN" code39_write_test3)
          )
        (lambda ()
          (delete-file code39_write_test1)
          (delete-file code39_write_test2)
          (delete-file code39_write_test3)
          )))
   
   (test-case
    "test-code39-checksum"
    
    (check-equal? (code39-checksum "CHEN") 23)
    )
   
   (test-case
    "test-code39-verify"
    
    (check-equal? (code39-verify "CHENN") #t)
    (check-equal? (code39-verify "CHENM") #f)
    )
   
   (test-case
    "test-code39-bar->string"
    
    (check-equal? (code39-bar->string 
                   (string-append
                    "100101101101" "0"
                    "110110100101" "0"
                    "110101001101" "0"
                    "110101100101" "0"
                    "101011010011" "0"
                    "100101101101")
                   #f)
                  "CHEN")

    (check-equal? (code39-bar->string 
                   (string-append
                    "100101101101" "0"
                    "110110100101" "0"
                    "110101001101" "0"
                    "110101100101" "0"
                    "101011010011" "0"
                    "101011010011" "0"
                    "100101101101")
                   #t)
                  "CHEN")

    (check-equal? (code39-bar->string 
                   (string-append
                    "100101101101" "0"
                    "110110100101" "0"
                    "110101001101" "0"
                    "110101100101" "0"
                    "101011010011" "0"
                    "110101001101" "0"
                    "100101101101")
                   #t)
                  "")

    (check-equal? (code39-bar->string 
                   (string-append
                    "100101101101" "0"
                    "100101001001" "0" "110110100101" "0"
                    "100101001001" "0" "110101001101" "0"
                    "100101001001" "0" "110101100101" "0"
                    "100101001001" "0" "101011010011" "0"
                    "100101101101")
                   #f)
                  "chen")
    )

   ))

(run-tests test-lib)
