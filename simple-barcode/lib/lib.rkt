#lang racket

(provide (contract-out
          [ean13-checksum (-> string? exact-nonnegative-integer?)]
          [char->barstring (-> char? symbol? string?)]
          [bar->string (-> string? string?)]
          [ean13->bar_group (-> string? (listof pair?))]
          [get-dimension (-> exact-nonnegative-integer? pair?)]
          [draw-ean13 (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [pic->points (-> path-string? (listof list?))]
          [find-threshold (-> list? exact-nonnegative-integer?)]
          [search-barcode-on-row (-> list? (or/c exact-nonnegative-integer? #f) (or/c list? #f))]
          [search-barcode (-> (listof list?) (or/c string? #f))]
          [read-ean13 (-> path-string? string?)]
          [get-bar-char-map (-> hash?)]
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

(define (bitmap->points img)
  (let* ([width (send img get-width)]
         [height (send img get-height)]
         [bits_count (* width height 4)])

    (let ([bits_bytes (make-bytes bits_count)])
      (send img get-argb-pixels 0 0 width height bits_bytes)
      
      (let loop ([loop_list (bytes->list bits_bytes)]
                 [rows '()]
                 [cols '()])
        (if (= (length rows) height)
            (reverse rows)
            (if (= (length cols) width)
                (loop loop_list (cons (reverse cols) rows) '())
                (loop (cdr (cdr (cdr (cdr loop_list)))) 
                      rows
                      (cons (+ (list-ref loop_list 1) (list-ref loop_list 2) (list-ref loop_list 3)) cols))))))))

(define (pic->points pic_path)
  (bitmap->points (make-object bitmap% pic_path)))

(define (points->pixels points_list pixel_map)
  (let loop ([rows points_list]
             [row_index 0]
             [bytes_list '()])
    (if (not (null? rows))
        (loop
         (cdr rows)
         (add1 row_index)
         (cons
          (let col-loop ([cols (car rows)]
                         [col_index 0]
                         [col_bytes_list '()])
            (if (not (null? cols))
                (if (hash-has-key? pixel_map (cons row_index col_index))
                    (col-loop (cdr cols) (add1 col_index) `(,@(hash-ref pixel_map (cons row_index col_index)) ,@col_bytes_list))
                    (if (= (car cols) 0)
                        (col-loop (cdr cols) (add1 col_index) (cons 255 (cons 255 (cons 255 (cons 255 col_bytes_list)))))
                        (col-loop (cdr cols) (add1 col_index) (cons 0 (cons 0 (cons 0 (cons 255 col_bytes_list)))))))
                (reverse col_bytes_list)))
          bytes_list))
        (list->bytes (foldr (lambda (a b) (append a b)) '() (reverse bytes_list))))))

(define (points->pic points_list pic_path pixel_map)
  (let* ([width (length (car points_list))]
         [height (length points_list)]
         [points_pic (make-object bitmap% width height)])
    (send points_pic set-argb-pixels 0 0 width height (points->pixels points_list pixel_map))
    (send points_pic save-file pic_path 'png)))

(define (find-threshold point_rows)
  (let row-loop ([loop_row_list point_rows]
                 [max_value 0]
                 [min_value 765])
    (if (not (null? loop_row_list))
        (let col-loop ([loop_col_list (car loop_row_list)]
                       [col_max_value max_value]
                       [col_min_value min_value])
          (if (not (null? loop_col_list))
              (cond
               [(>= (car loop_col_list) col_max_value)
                (col-loop (cdr loop_col_list) (car loop_col_list) col_min_value)]
               [(< (car loop_col_list) col_min_value)
                (col-loop (cdr loop_col_list) col_max_value (car loop_col_list))]
               [else
                (col-loop (cdr loop_col_list) col_max_value col_min_value)]
               )
              (row-loop (cdr loop_row_list) col_max_value col_min_value)))
        (floor (/ (+ max_value min_value) 2)))))

(define (points->bw points_list threshold)
  (map
   (lambda (row)
     (map
      (lambda (col)
        (if (> col threshold) 0 1))
      row))
   points_list))

(define (squash-points points width)
  (let ([min_width (ceiling (* width 0.5))])
    (let loop ([loop_points points]
               [last_index 0]
               [last_value -1]
               [same_count 0]
               [result_list '()]
               [index_list '()])

      (if (not (null? loop_points))
          (if (= same_count width)
              (loop (cdr loop_points) (+ width last_index) (car loop_points) 1 (cons last_value result_list) (cons last_index index_list))
              (if (= (car loop_points) last_value)
                  (loop (cdr loop_points) last_index last_value (add1 same_count) result_list index_list)
                  (if (= last_value -1)
                      (loop (cdr loop_points) last_index (car loop_points) (add1 same_count) result_list index_list)
                      (if (>= same_count min_width)
                          (loop (cdr loop_points) (+ last_index same_count) (car loop_points) 1 (cons last_value result_list) (cons last_index index_list))
                          (loop (cdr loop_points) (+ last_index same_count) (car loop_points) 1 result_list index_list)))))
          (if (and (> same_count 0) (>= same_count min_width))
              (cons (reverse (cons last_value result_list)) (reverse (cons last_index index_list)))
              (cons (reverse result_list) (reverse index_list)))))))

(define (guess-first-dark-width points)
  (let loop ([points_loop points]
             [dark_length 0])
    (if (not (null? points_loop))
        (if (= (car points_loop) 0)
            (if (> dark_length 0)
                dark_length
                (loop (cdr points_loop) dark_length))
            (loop (cdr points_loop) (add1 dark_length)))
        dark_length)))

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
