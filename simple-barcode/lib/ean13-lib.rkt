#lang racket

(provide (contract-out
          [ean13-checksum (-> string? natural?)]
          [char->barstring (-> char? symbol? string?)]
          [ean13-bar->string (-> string? string?)]
          [ean13->bars (-> string? string?)]
          [get-ean13-dimension (-> (cons/c natural? natural?))]
          [draw-ean13 (-> (or/c 'png 'svg) string? path-string? void?)]
          [get-bar-char-map (-> hash?)]
          ))

(require "share.rkt")
(require "draw/draw.rkt")

(define (ean13-checksum barcode)
  (let-values ([
                (even_sum odd_sum)
                (let loop ([number_list
                            (map
                             (lambda (ch)
                               (string->number (string ch)))
                             (string->list barcode))]
                           [index 0]
                           [even_sum 0]
                           [odd_sum 0])
                  (if (not (null? number_list))
                      (if (even? index)
                          (loop
                           (cdr number_list)
                           (add1 index)
                           (+ even_sum (car number_list))
                           odd_sum)
                          (loop
                           (cdr number_list)
                           (add1 index)
                           even_sum
                           (+ odd_sum (car number_list))))
                      (values even_sum odd_sum)))])
    (let ([step4 (+ (* odd_sum 3) even_sum)])
      (if (= (remainder step4 10) 0)
          0
          (- 10 (remainder step4 10))))))

(define char_bar_map
  '#hash(
         (#\0 . ("0001101" "0100111" "1110010"))
         (#\1 . ("0011001" "0110011" "1100110"))
         (#\2 . ("0010011" "0011011" "1101100"))
         (#\3 . ("0111101" "0100001" "1000010"))
         (#\4 . ("0100011" "0011101" "1011100"))
         (#\5 . ("0110001" "0111001" "1001110"))
         (#\6 . ("0101111" "0000101" "1010000"))
         (#\7 . ("0111011" "0010001" "1000100"))
         (#\8 . ("0110111" "0001001" "1001000"))
         (#\9 . ("0001011" "0010111" "1110100"))))

(define (get-bar-char-map)
  (let ([bar_char_map (make-hash)])
    (hash-for-each
     char_bar_map
     (lambda (char bar_list)
       (for-each
        (lambda (rec)
          (hash-set! bar_char_map rec (string char)))
        bar_list)))
    bar_char_map))

(define (ean13-bar->string bar_string)
  (let* ([bar_char_map (get-bar-char-map)]
         [string_list
          (list
           (hash-ref bar_char_map (substring bar_string 3 10))
           (hash-ref bar_char_map (substring bar_string 10 17))
           (hash-ref bar_char_map (substring bar_string 17 24))
           (hash-ref bar_char_map (substring bar_string 24 31))
           (hash-ref bar_char_map (substring bar_string 31 38))
           (hash-ref bar_char_map (substring bar_string 38 45))

           (hash-ref bar_char_map (substring bar_string 50 57))
           (hash-ref bar_char_map (substring bar_string 57 64))
           (hash-ref bar_char_map (substring bar_string 64 71))
           (hash-ref bar_char_map (substring bar_string 71 78))
           (hash-ref bar_char_map (substring bar_string 78 85))
           (hash-ref bar_char_map (substring bar_string 85 92))
           )]
         [first_char (ean13-checksum (foldl (lambda (a b) (string-append a b)) "" string_list))])
    (string-append
     (number->string first_char)
     (foldr (lambda (a b) (string-append a b)) "" string_list))))

(define char_parity_map
  '#hash(
         (#\0 . (none odd  odd  odd  odd  odd  odd))
         (#\1 . (none odd  odd even  odd even  odd))
         (#\2 . (none odd  odd even even  odd even))
         (#\3 . (none odd  odd even even even  odd))
         (#\4 . (none odd even  odd  odd even even))
         (#\5 . (none odd even even  odd  odd even))
         (#\6 . (none odd even even even  odd  odd))
         (#\7 . (none odd even  odd even  odd even))
         (#\8 . (none odd even  odd even even  odd))
         (#\9 . (none odd even even  odd even  odd))
         ))

(define (char-parity ch place)
  (list-ref (hash-ref char_parity_map ch) place))

(define (char->barstring ch type)
  (let ([place
         (cond
          [(eq? type 'left_odd)
           0]
          [(eq? type 'left_even)
           1]
          [(eq? type 'right)
           2])])
    (list-ref (hash-ref char_bar_map ch) place)))

(define (ean13->bars ean13)
  (let* ([char_list (string->list ean13)]
         [parity_number (car char_list)])
    (string-append
     "000"
     (char->barstring (list-ref char_list 1) (if (eq? (char-parity parity_number 1) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 2) (if (eq? (char-parity parity_number 2) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 3) (if (eq? (char-parity parity_number 3) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 4) (if (eq? (char-parity parity_number 4) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 5) (if (eq? (char-parity parity_number 5) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 6) (if (eq? (char-parity parity_number 6) 'odd) 'left_odd 'left_even))
     "00000"
     (char->barstring (list-ref char_list 7) 'right)
     (char->barstring (list-ref char_list 8) 'right)
     (char->barstring (list-ref char_list 9) 'right)
     (char->barstring (list-ref char_list 10) 'right)
     (char->barstring (list-ref char_list 11) 'right)
     (char->barstring (list-ref char_list 12) 'right)
     "000")))

(define *foot_height* 7)
(define *ean13_bars_length* 7)
(define *ean13_down_margin* 20)

(define (get-ean13-dimension)
  (cons
   (* (+ (*quiet_zone_width*) 3 3 (* 6 *ean13_bars_length*) 5 (* 6 *ean13_bars_length*) 3 (*quiet_zone_width*)) (*brick_width*))
   (* (+ (*top_margin*) (*bar_height*) *ean13_down_margin*) (*brick_width*))))

(define (draw-ean13 type ean13 file_name)
  (if (regexp-match #px"^[0-9]{12}$" ean13)
      (let* ([dimension (get-ean13-dimension)]
             [bars (ean13->bars 
                    (string-append
                     ean13
                     (number->string (ean13-checksum ean13))))]
             [x (* (add1 (*quiet_zone_width*)) (*brick_width*))]
             [y (* (add1 (*top_margin*)) (*brick_width*))]
             [bar_height (* (*bar_height*) (*brick_width*))]
             [foot_height (* (+ (*bar_height*) *foot_height*) (*brick_width*))])

        (drawing
         type
         (car dimension)
         (cdr dimension)
         file_name
         (lambda ()
           (draw-bars type bars #:x x #:y y #:bar_height bar_height)

           ;; left split
           (draw-bars type "101" #:x x #:y y #:bar_height foot_height)

           ;; middle split
           (draw-bars type "01010" #:x (+ x (* 45 (*brick_width*))) #:y y #:bar_height foot_height)

           ;; right split
           (draw-bars type "101" #:x (+ x (* 92 (*brick_width*))) #:y y #:bar_height foot_height)

           ;; first char
           (draw-text type (substring ean13 0 1) #:x (- x (* 6 (*brick_width*))) #:y (* (+ (*top_margin*) (*bar_height*)) (*brick_width*)))

           (let loop ([loop_list (cdr (string->list ean13))]
                      [start_x (+ x (* 10 (*brick_width*)))])
             (when (not (null? loop_list))
                   (draw-text type (string (car loop_list)) #:x (+ start_x (* 2 (*brick_width*))) #:y (* (+ (*top_margin*) (*bar_height*) 2) (*brick_width*)))
                   (if (= (length loop_list) *ean13_bars_length*)
                       (loop (cdr loop_list) (+ start_x (* 12 (*brick_width*))))
                       (loop (cdr loop_list) (+ start_x (* *ean13_bars_length* (*brick_width*)))))))

           ;; last char
           (draw-text type ">" #:x (+ x (* (+ 95 3) (*brick_width*))) #:y (* (+ (*top_margin*) (*bar_height*)) (*brick_width*))))))
       (error
        "invalid ean13 string: length is 12, only digit")))
