#lang racket

(provide (contract-out
          [set-color (-> (is-a?/c bitmap-dc%) (or/c (is-a?/c color%) string?) void?)]
          [draw-background (-> (is-a?/c bitmap-dc%) (or/c (is-a?/c color%) string?) exact-nonnegative-integer? void?)]
          [pic->points (-> path-string? (listof list?))]
          [points->pic (-> (listof list?) path-string? hash? any)]
          [find-threshold (-> list? exact-nonnegative-integer?)]
          [points->bw (-> list? exact-nonnegative-integer? list?)]
          [squash-points (-> list? exact-nonnegative-integer? pair?)]
          [guess-first-dark-width (-> list? exact-nonnegative-integer?)]
          [draw-bars (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          ))

(require racket/draw)

(define *quiet_zone_width* 10)
(define *bar_height* 60)
(define *top_margin* 10)
(define *down_margin* 20)

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

(define (draw-bars bars file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
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

    ;; last char
    (send dc draw-text ">" (+ x (* (+ 95 3) brick_width)) (* (+ *top_margin* *bar_height*) brick_width))

    (send target save-file file_name 'png)))
