#lang racket

(provide (contract-out
          [get-code39-map (-> #:type symbol? hash?)]
          [code39->bars (-> string? string?)]
          [get-code39-dimension (-> exact-nonnegative-integer? exact-nonnegative-integer? pair?)]
          [draw-code39 (->* (string? path-string?) (#:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
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
    (0  #\*  "100101101101")
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
  (let ([char_bar_map (make-hash)]
        [result_map (make-hash)])
    (for-each
     (lambda (rec)
       (hash-set! char_bar_map (list-ref rec 1) (list-ref rec 2)))
     *code_list*)

    (for-each
     (lambda (rec)
       (cond
        [(eq? type 'char->bar)
         (chars->bars (first rec) (second rec) char_bar_map result_map)]
        [(eq? type 'bar->char)
         (bars->chars (first rec) (second rec) char_bar_map result_map)]
        ))
     *ascii_table*)
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

(define (code39->bars code)
  (let ([char_bar_map (get-code39-map #:type 'char->bar)])
    (string-append
     "100101101101" "0"
     (foldr
      (lambda (a b)
        (string-append (hash-ref char_bar_map a a) "0" (hash-ref char_bar_map b b)))
      ""
      (string->list code))
     "100101101101")))

(define (get-code-length bars_length)
  (/ (add1 bars_length) 13))

(define *code39_bars_length* 12)

(define (get-code39-dimension bars_length brick_width)
  (cons
   (* (+ *quiet_zone_width* bars_length *quiet_zone_width*) brick_width)
   (* (+ *top_margin* *bar_height* *code_down_margin*) brick_width)))

(define (draw-code39 code39 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([bars (code39->bars code39)]
         [dimension (get-code39-dimension (string-length bars) brick_width)]
         [width (car dimension)]
         [height (cdr dimension)]
         [x (* *quiet_zone_width* brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [foot_height (* brick_width *bar_height*)]
         [dc #f])
    
    (set! dc (draw-init width height #:color_pair color_pair #:brick_width brick_width))
    
    (draw-bars dc bars #:x x #:y y #:bar_width brick_width #:bar_height bar_height)

    (let loop ([loop_list (string->list (string-append "*" code39 "*"))]
               [start_x x])
      (when (not (null? loop_list))
            (loop (cdr loop_list) (+ start_x (* (add1 *code39_bars_length*) brick_width)))))
    
    (save-bars dc file_name)))

(define (code39-checksum value_list)
  (modulo
   (+
    (car value_list)
    (let loop ([loop_list (cdr value_list)]
               [index 1]
               [sum 0])
      (if (not (null? loop_list))
          (loop
           (cdr loop_list)
           (add1 index)
           (+ sum (* (car loop_list) index)))
          sum)))
   103))