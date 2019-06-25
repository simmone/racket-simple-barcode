#lang racket

(provide (contract-out 
          [barcode-write (->* ((or/c 'png 'svg) string? path-string?) (#:code_type symbol? #:color_pair pair? #:brick_width natural? #:font_size natural?) void?)]
          [barcode-read (->* (path-string?) (#:code_type symbol?) string?)]
          ))

(require "lib/share.rkt")
(require "lib/draw/draw.rkt")
(require "lib/ean13-lib.rkt")
(require "lib/code128-lib.rkt")
(require "lib/code39-lib.rkt")

(define (barcode-write type code file_name
                       #:code_type [code_type 'ean13]
                       #:color_pair [color_pair '("black" . "white")]
                       #:brick_width [brick_width 3]
                       #:font_size [font_size 3]
                       )
  (parameterize
   (
    [*front_color* (car color_pair)]
    [*back_color* (cdr color_pair)]
    [*brick_width* brick_width]
    [*font_size* font_size]
    )

   (cond
    [(eq? code_type 'ean13)
     (draw-ean13 type code file_name)]
    [(eq? code_type 'code128)
     (draw-code128 type code file_name)]
    [(eq? code_type 'code39)
     (draw-code39 type code file_name)]
    [(eq? code_type 'code39_checksum)
     (draw-code39-checksum type code file_name)]
    )))

(define (print-points biaoshi points)
  (let loop ([loop_points points]
             [line 1])
    (when (not (null? loop_points))
          (loop (cdr loop_points) (add1 line)))))

(define (barcode-read pic_path #:code_type [code_type 'ean13])
   (let (
         [step1_points_list #f]
         [step2_threshold #f]
         )
     (set! step1_points_list (pic->points pic_path))
     (set! step2_threshold (find-threshold step1_points_list))
     (let ([search_result (search-pattern step1_points_list step2_threshold code_type)])
             (if search_result
                 (deal-result search_result code_type)
                 ""))))

(define (search-pattern points_list threshold code_type)
  (let* ([m1_bw_points (points->bw points_list threshold)]
         [m1_result (search-barcode m1_bw_points code_type)])
    (if m1_result
        m1_result
        (let* ([m2_bw_points (points->strict-bw points_list)]
               [m2_result (search-barcode m2_bw_points code_type)])
          (if m2_result
              m2_result
              #f)))))

(define (deal-result bars code_type)
    (cond
     [(eq? code_type 'ean13)
      (ean13-bar->string bars)]
     [(eq? code_type 'code128)
      (if (code128-verify bars)
          (code128-bar->string bars)
          "")]
     [(eq? code_type 'code39)
      (code39-bar->string bars #f)]
     [(eq? code_type 'code39_checksum)
      (code39-bar->string bars #t)]
     [else
      ""]))


