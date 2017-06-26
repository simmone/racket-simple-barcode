#lang racket

(provide (contract-out
          [set-color (-> (is-a?/c bitmap-dc%) (or/c (is-a?/c color%) string?) void?)]
          [pic->points (-> path-string? (listof list?))]
          [points->pic (-> (listof list?) path-string? hash? any)]
          [find-threshold (-> list? exact-nonnegative-integer?)]
          [points->bw (-> list? exact-nonnegative-integer? list?)]
          [squash-points (-> list? exact-nonnegative-integer? pair?)]
          [guess-first-dark-width (-> list? exact-nonnegative-integer?)]
          [*quiet_zone_width* exact-nonnegative-integer?]
          [*top_margin* exact-nonnegative-integer?]
          [*down_margin* exact-nonnegative-integer?]
          [*bar_height* exact-nonnegative-integer?]
          [draw-init (->* (exact-nonnegative-integer? exact-nonnegative-integer?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) (is-a?/c bitmap-dc%))]
          [draw-bars (-> (is-a?/c bitmap-dc%) string? #:x exact-nonnegative-integer? #:y exact-nonnegative-integer? #:bar_width exact-nonnegative-integer? #:bar_height exact-nonnegative-integer? void?)]
          [save-bars (-> (is-a?/c bitmap-dc%) path-string? boolean?)]
          [search-barcode-on-row (-> list? (or/c exact-nonnegative-integer? #f) (or/c list? #f))]
          [search-barcode (-> (listof list?) (or/c string? #f))]
          ))

(require racket/draw)

(define *quiet_zone_width* 10)
(define *bar_height* 60)
(define *top_margin* 10)
(define *down_margin* 20)
(define *font_size* 5)

(define (draw-init width height #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([front_color (car color_pair)]
         [back_color (cdr color_pair)]
         [x (* (add1 *quiet_zone_width*) brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [target (make-bitmap width height)]
         [dc (new bitmap-dc% [bitmap target])])

    (when (not (string=? back_color "transparent"))
          (set-color dc back_color)
          (send dc draw-rectangle 0 0 width height))

    (set-color dc front_color)
    (send dc set-text-foreground front_color)
    (send dc set-font (make-font #:size-in-pixels? #t #:size (* *font_size* brick_width) #:face "Monospace" #:family 'modern))
    dc))

(define (save-bars dc file_name)
    (send (send dc get-bitmap) save-file file_name 'png))

(define (draw-bars dc bars #:x x #:y y #:bar_width bar_width #:bar_height bar_height)
  (let loop ([loop_list (string->list bars)]
             [loop_x x])
    (when (not (null? loop_list))
          (when (char=? (car loop_list) #\1)
                (send dc draw-rectangle loop_x y bar_width bar_height))
          (loop (cdr loop_list) (+ loop_x bar_width)))))

(define (set-color dc color)
  (when (not (string=? color "transparent"))
        (send dc set-pen color 1 'solid))

  (send dc set-brush color 'solid))

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

(define *mode_hash* hash(
                         'ean13 (list 
                                 (pregexp "101[0-1]{42}01010[0-1]{42}101"))
                         'code128 (list 
                                   (pregexp "11010000100.+1100011101011")
                                   (pregexp "11010010000.+1100011101011")
                                   (pregexp "11010011100.+1100011101011"))
                         ))

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

                  (if (ormap (lambda (regx) (regexp-match regx squashed_str)) (hash-values
                      (let ([barcode_pos (car (regexp-match-positions regx squashed_str))])
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

