#lang racket

(provide (contract-out
          [ean13-checksum (-> string? exact-nonnegative-integer?)]
          [char->barstring(-> char? symbol? string?)]
          [ean13->bar_group (-> string? (listof pair?))]
          [get-dimension (-> exact-nonnegative-integer? pair?)]
          [draw-ean13 (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          ))

(require racket/draw)

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

(define char_parity_map
  '#hash(
         (#\0 . (none odd  odd  odd  odd  odd  odd))
         (#\1 . (none odd  odd even  odd even  odd))
         (#\2 . (none odd  odd even even  odd even))
         (#\3 . (none odd  odd even even even  odd))
         (#\4 . (none odd  even odd  odd even even))
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

(define (ean13->bar_group ean13)
  (let* ([char_list (string->list ean13)]
         [parity_number (car char_list)])
    (list
     '("$" . "202")
     (cons (string (list-ref char_list 1)) (char->barstring (list-ref char_list 1) (if (eq? (char-parity parity_number 1) 'odd) 'left_odd 'left_even)))
     (cons (string (list-ref char_list 2)) (char->barstring (list-ref char_list 2) (if (eq? (char-parity parity_number 2) 'odd) 'left_odd 'left_even)))
     (cons (string (list-ref char_list 3)) (char->barstring (list-ref char_list 3) (if (eq? (char-parity parity_number 3) 'odd) 'left_odd 'left_even)))
     (cons (string (list-ref char_list 4)) (char->barstring (list-ref char_list 4) (if (eq? (char-parity parity_number 4) 'odd) 'left_odd 'left_even)))
     (cons (string (list-ref char_list 5)) (char->barstring (list-ref char_list 5) (if (eq? (char-parity parity_number 5) 'odd) 'left_odd 'left_even)))
     (cons (string (list-ref char_list 6)) (char->barstring (list-ref char_list 6) (if (eq? (char-parity parity_number 6) 'odd) 'left_odd 'left_even)))
     '("$" . "02020")
     (cons (string (list-ref char_list 7)) (char->barstring (list-ref char_list 7) 'right))
     (cons (string (list-ref char_list 8)) (char->barstring (list-ref char_list 8) 'right))
     (cons (string (list-ref char_list 9)) (char->barstring (list-ref char_list 9) 'right))
     (cons (string (list-ref char_list 10)) (char->barstring (list-ref char_list 10) 'right))
     (cons (string (list-ref char_list 11)) (char->barstring (list-ref char_list 11) 'right))
     (cons (string (list-ref char_list 12)) (char->barstring (list-ref char_list 12) 'right))
     '("$" . "202"))))

(define *quiet_zone_width* 10)
(define *bar_height* 60)
(define *foot_height* 7)
(define *font_size* 5)
(define *top_margin* 10)
(define *down_margin* 20)
(define *guard_width* 3)

(define (get-dimension brick_width)
  (cons
   (* (+ *quiet_zone_width* 3 3 (* 6 7) 5 (* 6 7) 3 *quiet_zone_width*) brick_width)
   (* (+ *top_margin* *bar_height* *down_margin*) brick_width)))

(define (set-color dc color)
  (when (not (string=? color "transparent"))
        (send dc set-pen color 1 'solid))

  (send dc set-brush color 'solid))

(define (draw-background dc color brick_width)
  (when (not (string=? color "transparent"))
        (set-color dc color)
        (let* ([dimension (get-dimension brick_width)]
               [width (car dimension)]
               [height (cdr dimension)])
          (send dc draw-rectangle 0 0 width height))))

(define (draw-ean13 ean13 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([front_color (car color_pair)]
         [back_color (cdr color_pair)]
         [dimension (get-dimension brick_width)]
         [width (car dimension)]
         [height (cdr dimension)]
         [x (* (add1 *quiet_zone_width*) brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [foot_height (* brick_width (+ *bar_height* *foot_height*))]
         [target (make-bitmap width height)]
         [dc (new bitmap-dc% [bitmap target])])

    (draw-background dc back_color brick_width)

    (set-color dc front_color)
    (send dc set-text-foreground front_color)
    (send dc set-font (make-font #:size-in-pixels? #t #:size (* *font_size* brick_width) #:face "Monospace" #:family 'modern))
    
    ;; first char
    (send dc draw-text (substring ean13 0 1) (- x (* 6 brick_width)) (* (+ *top_margin* *bar_height*) brick_width))

    (let loop-group ([group_list (ean13->bar_group ean13)]
                     [start_x x])
      (when (not (null? group_list))
            (let* ([group (car group_list)]
                   [hold_str (car group)]
                   [hold_bar (cdr group)])
              
              (when (not (string=? hold_str "$"))
                    (send dc draw-text hold_str (+ start_x (* 2 brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width)))

              (let loop-bar ([loop_list (string->list hold_bar)]
                             [loop_x start_x])
                (when (not (null? loop_list))
                      (cond
                       [(char=? (car loop_list) #\1)
                        (send dc draw-rectangle loop_x y brick_width bar_height)]
                       [(char=? (car loop_list) #\2)
                        (send dc draw-rectangle loop_x y brick_width foot_height)])

                      (loop-bar (cdr loop_list) (+ loop_x brick_width))))
              
              (loop-group (cdr group_list) (+ start_x (* (string-length hold_bar) brick_width))))))

    (send target save-file file_name 'png)))
