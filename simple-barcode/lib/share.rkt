#lang racket

(provide (contract-out
          [pic->points (-> path-string? (listof list?))]
          [find-threshold (-> list? exact-nonnegative-integer?)]
          [points->bw (-> list? exact-nonnegative-integer? list?)]
          [points->strict-bw (-> list? list?)]
          [squash-points (-> list? exact-nonnegative-integer? pair?)]
          [search-barcode-on-row (-> list? symbol? (or/c string? #f))]
          [search-barcode (-> (listof list?) symbol? (or/c string? #f))]
          ))

(require racket/draw)

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

(define (points->strict-bw points_list)
  (map
   (lambda (row)
     (filter
      (lambda (rec)
        rec)
      (map
       (lambda (col)
         (cond
          [(> col 565)
           0]
          [(< col 200)
           1]
          [else
           #f]))
       row)))
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

(define *pattern_map* 
  (hash
   'code39 (list (pregexp "1001011011010(1[0-1]{11}0)+100101101101"))
   'code39_checksum (list (pregexp "1001011011010(1[0-1]{11}0)+100101101101"))
   'ean13  (list (pregexp "101[0-1]{42}01010[0-1]{42}101"))
   'code128 (list (pregexp "11010000100(1[0-1]{9}0)+1100011101011")
                  (pregexp "11010010000(1[0-1]{9}0)+1100011101011")
                  (pregexp "11010011100(1[0-1]{9}0)+1100011101011"))))

(define (search-barcode-on-row points_row code_type)
  (let ([regex_list (hash-ref *pattern_map* code_type)])
    (let loop ([loop_width 1])
      (if (> (* loop_width 30) (length points_row))
          #f
          (let ([result
                 (let* ([squashed_line (squash-points points_row loop_width)]
                        [squashed_cols (car squashed_line)]
                        [squashed_positions (cdr squashed_line)]
                        [original_str 
                         (foldr (lambda (a b) (string-append a b)) "" (map (lambda (b) (number->string b)) points_row))]
                        [squashed_str 
                         (foldr (lambda (a b) (string-append a b)) "" (map (lambda (b) (number->string b)) squashed_cols))])
                   
                   (let regex-loop ([loop_regex_list regex_list])
                     (if (not (null? loop_regex_list))
                         (let ([search_result (regexp-match-positions (car loop_regex_list) squashed_str)])
                           (if search_result
                               (substring squashed_str (caar search_result) (cdar search_result))
                               (regex-loop (cdr loop_regex_list))))
                         #f)))])
          (if result
              result
              (loop (add1 loop_width))))))))

(define (search-barcode rows code_type)
  (let loop ([loop_rows rows]
             [loop_count 1])
    (if (not (null? loop_rows))
        (let ([result (search-barcode-on-row (car loop_rows) code_type)])
          (if result
              result
              (if (>= (length loop_rows) 6)
                  (loop (list-tail loop_rows 5) (+ loop_count 5))
                  #f)))
        #f)))

