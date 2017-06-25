#lang racket

(provide (contract-out
          [ean13-checksum (-> string? exact-nonnegative-integer?)]
          [char->barstring (-> char? symbol? string?)]
          [bar->string (-> string? string?)]
          [ean13->bar_group (-> string? (listof pair?))]
          [get-dimension (-> exact-nonnegative-integer? pair?)]
          [draw-ean13 (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [draw-ean13-raw (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [search-barcode-on-row (-> list? (or/c exact-nonnegative-integer? #f) (or/c list? #f))]
          [search-barcode (-> (listof list?) (or/c string? #f))]
          [read-ean13 (-> path-string? string?)]
          [get-bar-char-map (-> hash?)]
          ))

(require racket/draw)

(require "share.rkt")

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

(define (bar->string bar_string)
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

(define *foot_height* 7)

(define (get-dimension brick_width)
  (cons
   (* (+ *quiet_zone_width* 3 3 (* 6 7) 5 (* 6 7) 3 *quiet_zone_width*) brick_width)
   (* (+ *top_margin* *bar_height* *down_margin*) brick_width)))

(define (draw-ean13 ean13 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (if (regexp-match #px"^[0-9]{12}$" ean13)
      (draw-ean13-raw 
       (string-append
        ean13
        (number->string (ean13-checksum ean13)))
       file_name
       #:color_pair color_pair
       #:brick_width brick_width)
      (error
       "invalid ean13 string: length is 12, only digit")))

(define (draw-ean13-raw ean13 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([dimension (get-dimension brick_width)]
         [width (car dimension)]
         [height (cdr dimension)]
         [x (* (add1 *quiet_zone_width*) brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [foot_height (* brick_width (+ *bar_height* *foot_height*))]
         [dc #f])

    (set! dc (draw-init width height #:color_pair color_pair #:brick_width brick_width))
    
    (draw-bars dc "110011100011" #:x x #:y y #:bar_width brick_width #:bar_height bar_height)
    
    (save-bars dc file_name)))

;(define (draw-bak-raw ean13 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
;  (let* ([front_color (car color_pair)]
;         [back_color (cdr color_pair)]
;         [dimension (get-dimension brick_width)]
;         [width (car dimension)]
;         [height (cdr dimension)]
;         [x (* (add1 *quiet_zone_width*) brick_width)]
;         [y (* (add1 *top_margin*) brick_width)]
;         [bar_height (* brick_width *bar_height*)]
;         [foot_height (* brick_width (+ *bar_height* *foot_height*))]
;         [target (make-bitmap width height)]
;         [dc (new bitmap-dc% [bitmap target])])
;
;    (draw-background dc back_color brick_width)
;
;    (set-color dc front_color)
;    (send dc set-text-foreground front_color)
;    (send dc set-font (make-font #:size-in-pixels? #t #:size (* *font_size* brick_width) #:face "Monospace" #:family 'modern))
;    
;    ;; first char
;    (send dc draw-text (substring ean13 0 1) (- x (* 6 brick_width)) (* (+ *top_margin* *bar_height*) brick_width))
;
;    (let loop-group ([group_list (ean13->bar_group ean13)]
;                     [start_x x])
;      (when (not (null? group_list))
;            (let* ([group (car group_list)]
;                   [hold_str (car group)]
;                   [hold_bar (cdr group)])
;              
;              (when (not (string=? hold_str "$"))
;                    (send dc draw-text hold_str (+ start_x (* 2 brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width)))
;
;              (let loop-bar ([loop_list (string->list hold_bar)]
;                             [loop_x start_x])
;                (when (not (null? loop_list))
;                      (cond
;                       [(char=? (car loop_list) #\1)
;                        (send dc draw-rectangle loop_x y brick_width bar_height)]
;                       [(char=? (car loop_list) #\2)
;                        (send dc draw-rectangle loop_x y brick_width foot_height)])
;
;                      (loop-bar (cdr loop_list) (+ loop_x brick_width))))
;              
;              (loop-group (cdr group_list) (+ start_x (* (string-length hold_bar) brick_width))))))
;
;    ;; last char
;    (send dc draw-text ">" (+ x (* (+ 95 3) brick_width)) (* (+ *top_margin* *bar_height*) brick_width))
;
;    (send target save-file file_name 'png)))

(define (search-barcode-on-row points_row guess_module_width)
  (let ([max_module_width (floor (/ (length points_row) 95))]
        [loop_module_width guess_module_width])
    (let loop ([points points_row])
      (if (not (null? points))
          (if (= (car points) 1)
              (begin
                (when (not loop_module_width)
                      (set! loop_module_width (guess-first-dark-width points)))
                
                (let* ([squashed_line (squash-points points_row loop_module_width)]
                       [squashed_cols (car squashed_line)]
                       [squashed_positions (cdr squashed_line)]
                       [original_str 
                        (foldr (lambda (a b) (string-append a b)) "" (map (lambda (b) (number->string b)) points_row))]
                       [squashed_str 
                        (foldr (lambda (a b) (string-append a b)) "" (map (lambda (b) (number->string b)) squashed_cols))])

                  (if (regexp-match #px"101[0-1]{42}01010[0-1]{42}101" squashed_str)
                      (let ([barcode_pos (car (regexp-match-positions #px"101[0-1]{42}01010[0-1]{42}101" squashed_str))])
                        (list
                         loop_module_width
                         (car barcode_pos)
                         (substring squashed_str (car barcode_pos) (cdr barcode_pos))))
                      (if (> (length points) loop_module_width)
                          (loop (list-tail points loop_module_width))
                          #f))))
              (loop (cdr points)))
          #f))))

(define (search-barcode rows)
  (let loop ([loop_rows rows]
             [loop_start_pos -1]
             [loop_barcode ""]
             [loop_count 0]
             [loop_module_width #f])
    (if (= loop_count 5)
        loop_barcode
        (if (not (null? loop_rows))
            (let ([result (search-barcode-on-row (car loop_rows) loop_module_width)])
              (if result
                  (let ([module_width (list-ref result 0)]
                        [start_pos (list-ref result 1)]
                        [barcode (list-ref result 2)])
                    (if (and
                         (= start_pos loop_start_pos)
                         (string=? barcode loop_barcode))
                        (loop
                         (cdr loop_rows)
                         start_pos
                         barcode
                         (add1 loop_count)
                         module_width)
                        (loop
                         (cdr loop_rows)
                         start_pos
                         barcode
                         1
                         module_width)))
                  (loop
                   (cdr loop_rows)
                   -1
                   ""
                   0
                   #f)))
            #f))))

(define (read-ean13 pic_path)
   (let (
         [step1_points_list #f]
         [step2_threshold #f]
         [step3_bw_points #f]
         )
     (set! step1_points_list (pic->points pic_path))
     (set! step2_threshold (find-threshold step1_points_list))
     (set! step3_bw_points (points->bw step1_points_list step2_threshold))
     (let ([search_result (search-barcode step3_bw_points)])
       (if search_result
           (bar->string search_result)
           ""))))
