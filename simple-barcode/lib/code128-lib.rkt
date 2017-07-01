#lang racket

(provide (contract-out
          [get-code128-map (-> #:type symbol? #:code symbol? hash?)]
          [encode-c128 (-> string? list?)]
          [code->value (-> list? list?)]
          [shift-compress (-> list? list?)]
          [code128-checksum (-> (listof exact-nonnegative-integer?) exact-nonnegative-integer?)]
          [code128->bars (-> list? string?)]
          ))

(require "share.rkt")

(define *code_list*
  '(
    (0      #\u0020      #\u0020     "00"     "11011001100")
    (1      #\u0021      #\u0021     "01"     "11001101100")
    (2      #\u0022      #\u0022     "02"     "11001100110")
    (3      #\u0023      #\u0023     "03"     "10010011000")
    (4      #\u0024      #\u0024     "04"     "10010001100")
    (5      #\u0025      #\u0025     "05"     "10001001100")
    (6      #\u0026      #\u0026     "06"     "10011001000")
    (7      #\u0027      #\u0027     "07"     "10011000100")
    (8      #\u0028      #\u0028     "08"     "10001100100")
    (9      #\u0028      #\u0029     "09"     "11001001000")
    (10     #\u002A      #\u002A     "10"     "11001000100")
    (11     #\u002B      #\u002B     "11"     "11000100100")
    (12     #\u002C      #\u002C     "12"     "10110011100")
    (13     #\u002D      #\u002D     "13"     "10011011100")
    (14     #\u002E      #\u002E     "14"     "10011001110")
    (15     #\u002F      #\u002F     "15"     "10111001100")
    (16     #\u0030      #\u0030     "16"     "10011101100")
    (17     #\u0031      #\u0031     "17"     "10011100110")
    (18     #\u0032      #\u0032     "18"     "11001110010")
    (19     #\u0033      #\u0033     "19"     "11001011100")
    (20     #\u0034      #\u0034     "20"     "11001001110")
    (21     #\u0035      #\u0035     "21"     "11011100100")
    (22     #\u0036      #\u0036     "22"     "11001110100")
    (23     #\u0037      #\u0037     "23"     "11101101110")
    (24     #\u0038      #\u0038     "24"     "11101001100")
    (25     #\u0039      #\u0039     "25"     "11100101100")
    (26     #\u003A      #\u003A     "26"     "11100100110")
    (27     #\u003B      #\u003B     "27"     "11101100100")
    (28     #\u003C      #\u003C     "28"     "11100110100")
    (29     #\u003D      #\u003D     "29"     "11100110010")
    (30     #\u003E      #\u003E     "30"     "11011011000")
    (31     #\u003F      #\u003F     "31"     "11011000110")
    (32     #\u0040      #\u0040     "32"     "11000110110")
    (33     #\u0041      #\u0041     "33"     "10100011000")
    (34     #\u0042      #\u0042     "34"     "10001011000")
    (35     #\u0043      #\u0043     "35"     "10001000110")
    (36     #\u0044      #\u0044     "36"     "10110001000")
    (37     #\u0045      #\u0045     "37"     "10001101000")
    (38     #\u0046      #\u0046     "38"     "10001100010")
    (39     #\u0047      #\u0047     "39"     "11010001000")
    (40     #\u0048      #\u0048     "40"     "11000101000")
    (41     #\u0049      #\u0049     "41"     "11000100010")
    (42     #\u004A      #\u004A     "42"     "10110111000")
    (43     #\u004B      #\u004B     "43"     "10110001110")
    (44     #\u004C      #\u004C     "44"     "10001101110")
    (45     #\u004D      #\u004D     "45"     "10111011000")
    (46     #\u004E      #\u004E     "46"     "10111000110")
    (47     #\u004F      #\u004F     "47"     "10001110110")
    (48     #\u0050      #\u0050     "48"     "11101110110")
    (49     #\u0051      #\u0051     "49"     "11010001110")
    (50     #\u0052      #\u0052     "50"     "11000101110")
    (51     #\u0053      #\u0053     "51"     "11011101000")
    (52     #\u0054      #\u0054     "52"     "11011100010")
    (53     #\u0055      #\u0055     "53"     "11011101110")
    (54     #\u0056      #\u0056     "54"     "11101011000")
    (55     #\u0057      #\u0057     "55"     "11101000110")
    (56     #\u0058      #\u0058     "56"     "11100010110")
    (57     #\u0059      #\u0059     "57"     "11101101000")
    (58     #\u005A      #\u005A     "58"     "11101100010")
    (59     #\u005B      #\u005B     "59"     "11100011010")
    (60     #\u005C      #\u005C     "60"     "11101111010")
    (61     #\u005D      #\u005D     "61"     "11001000010")
    (62     #\u005E      #\u005E     "62"     "11110001010")
    (63     #\u005F      #\u005F     "63"     "10100110000")
    (64     #\u0000      #\u0060     "64"     "10100001100")
    (65     #\u0001      #\u0061     "65"     "10010110000")
    (66     #\u0002      #\u0062     "66"     "10010000110")
    (67     #\u0003      #\u0063     "67"     "10000101100")
    (68     #\u0004      #\u0064     "68"     "10000100110")
    (69     #\u0005      #\u0065     "69"     "10110010000")
    (70     #\u0006      #\u0066     "70"     "10110000100")
    (71     #\u0007      #\u0067     "71"     "10011010000")
    (72     #\u0008      #\u0068     "72"     "10011000010")
    (73     #\u0009      #\u0069     "73"     "10000110100")
    (74     #\u000A      #\u006A     "74"     "10000110010")
    (75     #\u000B      #\u006B     "75"     "11000010010")
    (76     #\u000C      #\u006C     "76"     "11001010000")
    (77     #\u000D      #\u006D     "77"     "11110111010")
    (78     #\u000E      #\u006E     "78"     "11000010100")
    (79     #\u000F      #\u006F     "79"     "10001111010")
    (80     #\u0010      #\u0070     "80"     "10100111100")
    (81     #\u0011      #\u0071     "81"     "10010111100")
    (82     #\u0012      #\u0072     "82"     "10010011110")
    (83     #\u0013      #\u0073     "83"     "10111100100")
    (84     #\u0014      #\u0074     "84"     "10011110100")
    (85     #\u0015      #\u0075     "85"     "10011110010")
    (86     #\u0016      #\u0076     "86"     "11110100100")
    (87     #\u0017      #\u0077     "87"     "11110010100")
    (88     #\u0018      #\u0078     "88"     "11110010010")
    (89     #\u0019      #\u0079     "89"     "11011011110")
    (90     #\u001A      #\u007A     "90"     "11011110110")
    (91     #\u001B      #\u007B     "91"     "11110110110")
    (92     #\u001C      #\u007C     "92"     "10101111000")
    (93     #\u001D      #\u007D     "93"     "10100011110")
    (94     #\u001E      #\u007E     "94"     "10001011110")
    (95     #\u001F      #\u007F     "95"     "10111101000")
    (96     "FNC3"      "FNC3"       "96"     "10111100010")
    (97     "FNC2"      "FNC2"       "97"     "11110101000")
    (98     "Shift"     "Shift"      "98"     "11110100010")
    (99     "CodeC"     "CodeC"      "99"     "10111011110")
    (100    "CodeB"     "FNC4"       "CodeB"  "10111101110")
    (101    "FNC4"      "CodeA"      "CodeA"  "11101011110")
    (102    "FNC1"      "FNC1"       "FNC1"   "11110101110")
    (103    "StartA"    "StartA"     "StartA" "11010000100")
    (104    "StartB"    "StartB"     "StartB" "11010010000")
    (105    "StartC"    "StartC"     "StartC" "11010011100")
    (106    "Stop"      "Stop"       "Stop"   "1100011101011")))

(define (get-code128-map #:type type #:code code)
  (let ([result_map (make-hash)])
    (for-each
     (lambda (rec)
       (let ([ch #f])
         (cond
          [(eq? code 'A)
           (set! ch (list-ref rec 1))]
          [(eq? code 'B)
           (set! ch (list-ref rec 2))]
          [(eq? code 'C)
           (set! ch (list-ref rec 3))])
       (cond
        [(eq? type 'char->bar)
         (hash-set! result_map ch (list-ref rec 4))]
        [(eq? type 'bar->char)
         (hash-set! result_map (list-ref rec 4) ch)]
        [(eq? type 'char->weight)
         (hash-set! result_map ch (list-ref rec 0))])))
     *code_list*)
    result_map))

(define (encode-c128 content)
  (let ([code_b_char_bar_map (get-code128-map #:code 'B #:type 'char->bar)]
        [code_a_char_bar_map (get-code128-map #:code 'A #:type 'char->bar)]
        [code_c_char_bar_map (get-code128-map #:code 'C #:type 'char->bar)])
    (let loop ([loop_list (string->list content)]
               [current_mode #f]
               [result_list '()])
      (if (not (null? loop_list))
          (cond
           [(and (not current_mode) (hash-has-key? code_a_char_bar_map (car loop_list)))
            (loop (cdr loop_list) 'A 
                  (cons
                   (car loop_list)
                   (cons "StartA" result_list)))]
           [(and (not current_mode) (hash-has-key? code_b_char_bar_map (car loop_list)))
            (loop (cdr loop_list) 'B (cons 
                                      (car loop_list)
                                      (cons "StartB" result_list)))]
           [(and (not current_mode) (regexp-match #px"^[0-9]{4}" (list->string loop_list)))
            (loop
             (list-tail loop_list 4)
             'C
             (cons 
              (substring (list->string loop_list) 2 4)
              (cons
               (substring (list->string loop_list) 0 2)
               (cons "StartC" result_list))))]
           [(regexp-match #px"^[0-9]{4}" (list->string loop_list))
            (if (eq? current_mode 'C)
                (loop
                 (list-tail loop_list 4)
                 'C
                 (cons 
                  (substring (list->string loop_list) 2 4)
                  (cons
                   (substring (list->string loop_list) 0 2)
                   result_list)))
                (loop
                 (list-tail loop_list 4)
                 'C
                 (cons 
                  (substring (list->string loop_list) 2 4)
                  (cons
                   (substring (list->string loop_list) 0 2)
                   (cons "CodeC" result_list)))))]
           [(and
             (eq? current_mode 'C)
             (regexp-match #px"^[0-9]{2}" (list->string loop_list)))
            (loop
             (list-tail loop_list 2)
             'C
             (cons 
              (substring (list->string loop_list) 0 2)
              result_list))]
           [(or
             (hash-has-key? code_a_char_bar_map (car loop_list))
             (hash-has-key? code_b_char_bar_map (car loop_list)))
            (cond 
             [(and (eq? current_mode 'A)
                   (hash-has-key? code_a_char_bar_map (car loop_list)))
              (loop
               (cdr loop_list)
               'A
               (cons (car loop_list) result_list))]
             [(and (eq? current_mode 'B)
                   (hash-has-key? code_b_char_bar_map (car loop_list)))
              (loop
               (cdr loop_list)
               'B
               (cons (car loop_list) result_list))]
             [(and (not (eq? current_mode 'B))
                   (hash-has-key? code_b_char_bar_map (car loop_list)))
              (loop
               (cdr loop_list)
               'B
               (cons (car loop_list) 
                     (cons "CodeB" result_list)))]
             [(and (not (eq? current_mode 'A))
                   (hash-has-key? code_a_char_bar_map (car loop_list)))
              (loop
               (cdr loop_list)
               'A
               (cons (car loop_list) 
                     (cons "CodeA" result_list)))])]
           [else
            (error (format "invalid char[~a]" (car loop_list)))])
          (reverse (cons "Stop" result_list))))))

(define (shift-compress code_list)
  (let loop ([loop_list code_list]
             [current_mode #f]
             [result_list '()])
    (if (not (null? loop_list))
        (if (string? (car loop_list))
            (cond
             [(string=? (car loop_list) "StartA")
              (loop (cdr loop_list) 'A (cons "StartA" result_list))]
             [(string=? (car loop_list) "StartB")
              (loop (cdr loop_list) 'B (cons "StartB" result_list))]
             [(string=? (car loop_list) "StartC")
              (loop (cdr loop_list) 'C (cons "StartC" result_list))]
             [(string=? (car loop_list) "CodeA")
              (loop (cdr loop_list) 'A (cons "CodeA" result_list))]
             [(string=? (car loop_list) "CodeB")
              (loop (cdr loop_list) 'B (cons "CodeB" result_list))]
             [(string=? (car loop_list) "CodeC")
              (loop (cdr loop_list) 'C (cons "CodeC" result_list))]
             [(string=? (car loop_list) "Stop")
              (reverse (cons "Stop" result_list))]
             [else
              (loop (cdr loop_list) 'C (cons (car loop_list) result_list))])
            (cond
             [(and
               (eq? current_mode 'A)
               (>= (length loop_list) 5)
               (string? (list-ref loop_list 1)) (string=? (list-ref loop_list 1) "CodeB")
               (string? (list-ref loop_list 3)) (string=? (list-ref loop_list 3) "CodeA"))
              (loop
               (list-tail loop_list 4)
               current_mode
               (cons
                (list-ref loop_list 2)
                (cons
                 "Shift"
                 (cons (car loop_list) result_list))))]
             [(and
               (eq? current_mode 'B)
               (>= (length loop_list) 5)
               (string? (list-ref loop_list 1)) (string=? (list-ref loop_list 1) "CodeA")
               (string? (list-ref loop_list 3)) (string=? (list-ref loop_list 3) "CodeB"))
              (loop
               (list-tail loop_list 4)
               current_mode
               (cons
                (list-ref loop_list 2)
                (cons
                 "Shift"
                 (cons
                  (car loop_list) result_list))))]
             [else
              (loop (cdr loop_list) current_mode (cons (car loop_list) result_list))]))
        (reverse result_list))))

(define (code->value code_list)
  (let* ([a_map (get-code128-map #:code 'A #:type 'char->weight)]
         [b_map (get-code128-map #:code 'B #:type 'char->weight)]
         [c_map (get-code128-map #:code 'C #:type 'char->weight)]
         [mode_map (hash 'A a_map 'B b_map 'C c_map)])
    (let loop ([loop_list code_list]
               [current_mode #f]
               [result_list '()])
      (if (not (null? loop_list))
          (if (string? (car loop_list))
              (cond
               [(string=? (car loop_list) "StartA")
                (loop (cdr loop_list) 'A (cons 103 result_list))]
               [(string=? (car loop_list) "StartB")
                (loop (cdr loop_list) 'B (cons 104 result_list))]
               [(string=? (car loop_list) "StartC")
                (loop (cdr loop_list) 'C (cons 105 result_list))]
               [(string=? (car loop_list) "CodeA")
                (loop (cdr loop_list) 'A (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))]
               [(string=? (car loop_list) "CodeB")
                (loop (cdr loop_list) 'B (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))]
               [(string=? (car loop_list) "CodeC")
                (loop (cdr loop_list) 'C (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))]
               [(and (eq? current_mode 'A) (string=? (car loop_list) "Shift"))
                (loop (cddr loop_list)
                      current_mode
                      (cons
                       (hash-ref b_map (cadr loop_list))
                       (cons 98 result_list)))]
               [(and (eq? current_mode 'B) (string=? (car loop_list) "Shift"))
                (loop (cddr loop_list)
                      current_mode
                      (cons
                       (hash-ref a_map (cadr loop_list))
                       (cons 98 result_list)))]
               [(string=? (car loop_list) "Stop")
                (reverse result_list)]
               [else
                (loop (cdr loop_list) current_mode (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))])
              (loop (cdr loop_list) current_mode (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list)))
          (reverse result_list)))))

(define (code128-checksum value_list)
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

(define (code128->bars code_list)
  (foldr
   (lambda (a b)
     (string-append a b))
   ""
   (let* ([a_map (get-code128-map #:code 'A #:type 'char->bar)]
          [b_map (get-code128-map #:code 'B #:type 'char->bar)]
          [c_map (get-code128-map #:code 'C #:type 'char->bar)]
          [mode_map (hash 'A a_map 'B b_map 'C c_map)])
     (let loop ([loop_list code_list]
                [current_mode #f]
                [result_list '()])
       (if (not (null? loop_list))
           (if (string? (car loop_list))
               (cond
                [(string=? (car loop_list) "StartA")
                 (loop (cdr loop_list) 'A (cons (hash-ref a_map "StartA") result_list))]
                [(string=? (car loop_list) "StartB")
                 (loop (cdr loop_list) 'B (cons (hash-ref b_map "StartB") result_list))]
                [(string=? (car loop_list) "StartC")
                 (loop (cdr loop_list) 'C (cons (hash-ref c_map "StartC") result_list))]
                [(string=? (car loop_list) "CodeA")
                 (loop (cdr loop_list) 'A (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))]
                [(string=? (car loop_list) "CodeB")
                 (loop (cdr loop_list) 'B (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))]
                [(string=? (car loop_list) "CodeC")
                 (loop (cdr loop_list) 'C (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))]
                [(and (eq? current_mode 'A) (string=? (car loop_list) "Shift"))
                 (loop (cddr loop_list)
                       current_mode
                       (cons
                        (hash-ref b_map (cadr loop_list))
                        (cons (hash-ref a_map "Shift") result_list)))]
                [(and (eq? current_mode 'B) (string=? (car loop_list) "Shift"))
                 (loop (cddr loop_list)
                       current_mode
                       (cons
                        (hash-ref a_map (cadr loop_list))
                        (cons (hash-ref b_map "Shift") result_list)))]
                [(string=? (car loop_list) "Stop")
                 (reverse (cons (hash-ref a_map "Stop") result_list))]
                [else
                 (loop (cdr loop_list) current_mode (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list))])
               (loop (cdr loop_list) current_mode (cons (hash-ref (hash-ref mode_map current_mode) (car loop_list)) result_list)))
           (reverse result_list))))))

(define (get-dimension code_length brick_width)
  (cons
   (* (+ *quiet_zone_width* code_length *quiet_zone_width*) brick_width)
   (* (+ *top_margin* *bar_height* *down_margin*) brick_width)))

(define (draw-code128 code128 file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([encoded_list (encode-c128 code128)]
         [code_list (shift-compress encoded_list)]
         [checksum (code128-checksum (code->value (code_list)))])
    (draw-code128-raw 
     (string-append
      code_list
      (number->string checksum)
      file_name
      #:color_pair color_pair
      #:brick_width brick_width))))

(define (draw-code128-raw code_list checksum file_name #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([dimension (get-dimension brick_width)]
         [width (car dimension)]
         [height (cdr dimension)]
         [x (* (add1 *quiet_zone_width*) brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [foot_height (* brick_width *bar_height*)]
         [bars (code128->bars code_list)]
         [dc #f])

    (set! dc (draw-init width height #:color_pair color_pair #:brick_width brick_width))
    
    (draw-bars dc bars #:x x #:y y #:bar_width brick_width #:bar_height bar_height)
    
    ;; left split
    (draw-bars dc "101" #:x x #:y y #:bar_width brick_width #:bar_height foot_height)

    ;; middle split
    (draw-bars dc "01010" #:x (+ x (* 45 brick_width)) #:y y #:bar_width brick_width #:bar_height foot_height)

    ;; right split
    (draw-bars dc "101" #:x (+ x (* 92 brick_width)) #:y y #:bar_width brick_width #:bar_height foot_height)

    ;; first char
    (send dc draw-text (substring code_list 0 1) (- x (* 6 brick_width)) (* (+ *top_margin* *bar_height*) brick_width))

    (let loop ([loop_list (cdr (string->list code_list))]
               [start_x (+ x (* 3 brick_width))])
      (when (not (null? loop_list))
            (send dc draw-text (string (car loop_list)) (+ start_x (* 2 brick_width)) (* (+ *top_margin* *bar_height* 2) brick_width))
            (if (= (length loop_list) 7)
                (loop (cdr loop_list) (+ start_x (* 12 brick_width)))
                (loop (cdr loop_list) (+ start_x (* 7 brick_width))))))

    ;; last char
    (send dc draw-text ">" (+ x (* (+ 95 3) brick_width)) (* (+ *top_margin* *bar_height*) brick_width))
    
    (save-bars dc file_name)))
