#lang racket

(provide (contract-out
          [get-code39-map (-> #:type symbol? hash?)]
          [code39->groups (-> string? list?)]
          [code39->bars (-> string? string?)]
          [code39-checksum (-> string? exact-nonnegative-integer?)]
          [get-code39-dimension (-> exact-nonnegative-integer? exact-nonnegative-integer? pair?)]
          [draw-code39 (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [draw-code39-checksum (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [code39-bar->string (-> string? boolean? string?)]
          [code39-verify (-> string? boolean?)]
          [code39-check-bars (-> string? boolean?)]
          [code39-checksum-check-bars (-> string? boolean?)]
          ))

(require "share.rkt")

(define *code_list*
  '(
    (0  #\0  "101001101101")
    (1  #\1  "110100101011")
    (2  #\2  "101100101011")
    (3  #\3  "110110010101")
    (4  #\4  "101001101011")
    (5  #\5  "110100110101")
    (6  #\6  "101100110101")
    (7  #\7  "101001011011")
    (8  #\8  "110100101101")
    (9  #\9  "101100101101")
    (10 #\A  "110101001011")
    (11 #\B  "101101001011")
    (12 #\C  "110110100101")
    (13 #\D  "101011001011")
    (14 #\E  "110101100101")
    (15 #\F  "101101100101")
    (16 #\G  "101010011011")
    (17 #\H  "110101001101")
    (18 #\I  "101101001101")
    (19 #\J  "101011001101")
    (20 #\K  "110101010011")
    (21 #\L  "101101010011")
    (22 #\M  "110110101001")
    (23 #\N  "101011010011")
    (24 #\O  "110101101001")
    (25 #\P  "101101101001")
    (26 #\Q  "101010110011")
    (27 #\R  "110101011001")
    (28 #\S  "101101011001")
    (29 #\T  "101011011001")
    (30 #\U  "110010101011")
    (31 #\V  "100110101011")
    (32 #\W  "110011010101")
    (33 #\X  "100101101011")
    (34 #\Y  "110010110101")
    (35 #\Z  "100110110101")
    (36 #\-  "100101011011")
    (37 #\.  "110010101101")
    (38 #\   "100110101101")
    (39 #\$  "100100100101")
    (40 #\/  "100100101001")
    (41 #\+  "100101001001")
    (42 #\%  "101001001001")
    (43 #\*  "100101101101")
    ))

(define *ascii_table*
  '(
    (#\u0000 "%U")
    (#\u0001 "$A")
    (#\u0002 "$B")
    (#\u0003 "$C")
    (#\u0004 "$D")
    (#\u0005 "$E")
    (#\u0006 "$F")
    (#\u0007 "$G")
    (#\u0008 "$H")
    (#\u0009 "$I")
    (#\u000a "$J")
    (#\u000b "$K")
    (#\u000c "$L")
    (#\u000d "$M")
    (#\u000e "$N")
    (#\u000f "$O")
    (#\u0010 "$P")
    (#\u0011 "$Q")
    (#\u0012 "$R")
    (#\u0013 "$S")
    (#\u0014 "$T")
    (#\u0015 "$U")
    (#\u0016 "$V")
    (#\u0017 "$W")
    (#\u0018 "$X")
    (#\u0019 "$Y")
    (#\u001a "$Z")
    (#\u001b "%A")
    (#\u001c "%B")
    (#\u001d "%C")
    (#\u001e "%D")
    (#\u001f "%E")
    (#\u0020 " ")
    (#\u0021 "/A")
    (#\u0022 "/B")
    (#\u0023 "/C")
    (#\u0024 "/D")
    (#\u0025 "/E")
    (#\u0026 "/F")
    (#\u0027 "/G")
    (#\u0028 "/H")
    (#\u0029 "/I")
    (#\u002a "/J")
    (#\u002b "/K")
    (#\u002c "/L")
    (#\u002d "-")
    (#\u002e ".")
    (#\u002f "/O")
    (#\u0030 "0")
    (#\u0031 "1")
    (#\u0032 "2")
    (#\u0033 "3")
    (#\u0034 "4")
    (#\u0035 "5")
    (#\u0036 "6")
    (#\u0037 "7")
    (#\u0038 "8")
    (#\u0039 "9")
    (#\u003a "/Z")
    (#\u003b "%F")
    (#\u003c "%G")
    (#\u003d "%H")
    (#\u003e "%I")
    (#\u003f "%J")
    (#\u0040 "%V")
    (#\u0041 "A")
    (#\u0042 "B")
    (#\u0043 "C")
    (#\u0044 "D")
    (#\u0045 "E")
    (#\u0046 "F")
    (#\u0047 "G")
    (#\u0048 "H")
    (#\u0049 "I")
    (#\u004a "J")
    (#\u004b "K")
    (#\u004c "L")
    (#\u004d "M")
    (#\u004e "N")
    (#\u004f "O")
    (#\u0050 "P")
    (#\u0051 "Q")
    (#\u0052 "R")
    (#\u0053 "S")
    (#\u0054 "T")
    (#\u0055 "U")
    (#\u0056 "V")
    (#\u0057 "W")
    (#\u0058 "X")
    (#\u0059 "Y")
    (#\u005a "Z")
    (#\u005b "%K")
    (#\u005c "%L")
    (#\u005d "%M")
    (#\u005e "%N")
    (#\u005f "%O")
    (#\u0060 "%W")
    (#\u0061 "+A")
    (#\u0062 "+B")
    (#\u0063 "+C")
    (#\u0064 "+D")
    (#\u0065 "+E")
    (#\u0066 "+F")
    (#\u0067 "+G")
    (#\u0068 "+H")
    (#\u0069 "+I")
    (#\u006a "+J")
    (#\u006b "+K")
    (#\u006c "+L")
    (#\u006d "+M")
    (#\u006e "+N")
    (#\u006f "+O")
    (#\u0070 "+P")
    (#\u0071 "+Q")
    (#\u0072 "+R")
    (#\u0073 "+S")
    (#\u0074 "+T")
    (#\u0075 "+U")
    (#\u0076 "+V")
    (#\u0077 "+W")
    (#\u0078 "+X")
    (#\u0079 "+Y")
    (#\u007a "+Z")
    (#\u007b "%P")
    (#\u007c "%Q")
    (#\u007d "%R")
    (#\u007e "%S")
    (#\u007f "%T,%X,%Y,%Z")
    ))

(define (get-code39-map #:type type)
  (let ([result_map (make-hash)])
    (cond
     [(eq? type 'basic_char->value)
      (for-each
       (lambda (rec)
         (hash-set! result_map (list-ref rec 1) (list-ref rec 0)))
       *code_list*)]
     [(eq? type 'basic_value->char)
      (for-each
       (lambda (rec)
         (hash-set! result_map (list-ref rec 0) (list-ref rec 1)))
       *code_list*)]
     [(eq? type 'basic_char->bar)
      (for-each
       (lambda (rec)
         (hash-set! result_map (list-ref rec 1) (list-ref rec 2)))
       *code_list*)]
     [(eq? type 'basic_bar->char)
      (for-each
       (lambda (rec)
         (hash-set! result_map (list-ref rec 2) (list-ref rec 1)))
       *code_list*)]
     [(eq? type 'extend_char->chars)
      (for-each
       (lambda (rec)
         (hash-set! result_map (first rec) (car (regexp-split #rx"," (second rec)))))
       *ascii_table*)]
     [(eq? type 'extend_chars->char)
      (for-each
       (lambda (rec)
         (for-each
          (lambda (chars)
            (hash-set! result_map chars (first rec)))
          (regexp-split #rx"," (second rec))))
       *ascii_table*)])
    result_map))

(define (chars->bars ch chars char_bar_map result_map) 
  (let* ([first_chars (car (regexp-split #rx"," chars))]
         [bar_list
          (map
           (lambda (ch)
             (hash-ref char_bar_map ch))
           (string->list first_chars))])
    (hash-set! result_map ch
               (if (= (length bar_list) 2)
                   (string-append (first bar_list) "0" (second bar_list))
                   (first bar_list)))))

(define (bars->chars ch chars char_bar_map result_map)
  (for-each
   (lambda (char_list)
     (let ([bars
            (if (= (length char_list) 2)
                (string-append (hash-ref char_bar_map (first char_list) "") "0" (hash-ref char_bar_map (second char_list) ""))
                (hash-ref char_bar_map (first char_list)))])
       (hash-set! result_map bars ch)))
  (map
   (lambda (rec)
     (string->list rec))
   (regexp-split #rx"," chars))))

(define (code39->groups code39)
  (let ([ref_map (get-code39-map #:type 'extend_char->chars)])
    (map
     (lambda (ch)
       (hash-ref ref_map ch))
     (string->list code39))))

(define (code39-group->chars code39_groups)
  (foldr
   (lambda (a b)
     (string-append a b))
   ""
   code39_groups))

(define (code39->bars chars)
  (let ([char_bar_map (get-code39-map #:type 'basic_char->bar)])
    (string-append
     "1001011011010"
     (foldr
      (lambda (fc fd)
        (string-append fc "0" fd))
      ""
      (map
       (lambda (code)
         (hash-ref char_bar_map code))
       (string->list chars)))
    "100101101101")))

(define (get-code-length bars_length)
  (/ (add1 bars_length) 13))

(define *code39_bars_length* 12)

(define (get-code39-dimension bars_length brick_width)
  (cons
   (* (+ *quiet_zone_width* bars_length *quiet_zone_width*) brick_width)
   (* (+ *top_margin* *bar_height* *code_down_margin*) brick_width)))

(define (draw-code39-checksum code39 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([basic_value_char_map (get-code39-map #:type 'basic_value->char)]
         [groups (code39->groups code39)]
         [checksum (code39-checksum (foldr (lambda (a b) (string-append a b)) "" groups))])

    (draw-code39-groups `(,@groups ,(string (hash-ref basic_value_char_map checksum))) groups file_name #:color_pair color_pair #:brick_width brick_width)))

(define (draw-code39 code39 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let ([groups (code39->groups code39)])
    (draw-code39-groups groups groups file_name #:color_pair color_pair #:brick_width brick_width)))
  
(define (draw-code39-groups groups display_groups file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([chars (code39-group->chars groups)]
         [bars (code39->bars chars)]
         [dimension (get-code39-dimension (string-length bars) brick_width)]
         [width (car dimension)]
         [height (cdr dimension)]
         [x (* *quiet_zone_width* brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [foot_height (* brick_width *bar_height*)]
         [extend_chars_char_map (get-code39-map #:type 'extend_chars->char)]
         [dc #f])
    
    (set! dc (draw-init width height #:color_pair color_pair #:brick_width brick_width))
    
    (draw-bars dc bars #:x x #:y y #:bar_width brick_width #:bar_height bar_height)

    (send dc draw-text "*" (+ x (* 4 brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width))
    (send dc draw-text "*" (+ x (* (- (string-length bars) 8) brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width))
    (let loop ([loop_list display_groups]
               [start_x (+ x (* (+ *code39_bars_length* 1) brick_width))])
      (when (not (null? loop_list))
            (if (= (string-length (car loop_list)) 1)
                (begin
                  (send dc draw-text (string (hash-ref extend_chars_char_map (car loop_list))) (+ start_x (* 3 brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width))
                  (loop (cdr loop_list) (+ start_x (* (add1 *code39_bars_length*) brick_width))))
                (begin
                  (send dc draw-text (string (hash-ref extend_chars_char_map (car loop_list))) (+ start_x (* 8 brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width))
                  (loop (cdr loop_list) (+ start_x (* (add1 (* *code39_bars_length* 2)) brick_width)))))))
    
    (save-bars dc file_name)))

(define (code39-checksum chars)
  (let ([basic_char_value_map (get-code39-map #:type 'basic_char->value)])
    (modulo
     (let loop ([loop_list (string->list chars)]
                [sum 0])
      (if (not (null? loop_list))
          (loop
           (cdr loop_list)
           (+ sum (hash-ref basic_char_value_map (car loop_list))))
          sum))
     43)))

(define (code39-verify chars)
  (let* ([basic_value_char_map (get-code39-map #:type 'basic_value->char)]
         [data (substring chars 0 (sub1 (string-length chars)))]
         [check_char (substring chars (sub1 (string-length chars)) (string-length chars))]
         [checksum (code39-checksum data)])
    (string=? (string (hash-ref basic_value_char_map checksum)) check_char)))

(define (code39-bar->string bars is_checksum?)
  (printf "~a\n" bars)
  (let* ([basic_bar_char_map (get-code39-map #:type 'basic_bar->char)]
         [data (substring bars (+ *code39_bars_length* 1) (- (string-length bars) *code39_bars_length*))]
         [decoded_data
          (let loop ([loop_str data]
                     [result_list '()])
            (if (>= (string-length loop_str) (add1 *code39_bars_length*))
                (loop (substring loop_str (add1 *code39_bars_length*)) (cons (hash-ref basic_bar_char_map (substring loop_str 0 *code39_bars_length*)) result_list))
                (foldr
                 (lambda (a b)
                   (string-append a b))
                 ""
                 (map
                  (lambda (ch)
                    (string ch))
                  (reverse result_list)))))])
    (if is_checksum? 
        (if (code39-verify decoded_data)
            (code39-reencode (substring decoded_data 0 (sub1 (string-length decoded_data))))
            "")
        (code39-reencode decoded_data))))

(define (code39-reencode data)
  (let ([extend_chars_char_map (get-code39-map #:type 'extend_chars->char)])
    (let loop ([loop_str data]
               [result_list '()])
      (if (not (string=? loop_str ""))
          (if (or 
               (string=? (substring loop_str 0 1) "$")
               (string=? (substring loop_str 0 1) "%")
               (string=? (substring loop_str 0 1) "/")
               (string=? (substring loop_str 0 1) "+"))
              (loop (substring loop_str 2) (cons (string (hash-ref extend_chars_char_map (substring loop_str 0 2))) result_list))
              (loop (substring loop_str 1) (cons (substring loop_str 0 1) result_list)))
          (foldr
           (lambda (a b)
             (string-append a b))
           ""
           (reverse result_list))))))

(define (code39-check-bars bars)
  #t)

(define (code39-checksum-check-bars bars)
  (and
   (= (remainder (add1 string-length bars) 13) 0)
   (regexp-match (pregexp "1001011011010(1[0-1]{11}0)+100101101101"))
   ))
