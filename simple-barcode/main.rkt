#lang racket

(provide (contract-out 
          [barcode-write (->* (string? path-string?) (#:code_type symbol? #:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [barcode-read (->* (path-string?) (#:code_type symbol?) string?)]
          [code39-verify (-> string? boolean?)]
          [search-barcode (-> (listof list?) symbol? (or/c string? #f))]
          ))

(require "lib/share.rkt")
(require "lib/ean13-lib.rkt")
(require "lib/code128-lib.rkt")
(require "lib/code39-lib.rkt")

(define (barcode-write code file_name #:code_type [code_type 'ean13] #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (cond
   [(eq? code_type 'ean13)
    (draw-ean13 code file_name #:color_pair color_pair #:brick_width brick_width)]
   [(eq? code_type 'code128)
    (draw-code128 code file_name #:color_pair color_pair #:brick_width brick_width)]
   [(eq? code_type 'code39)
    (draw-code39 code file_name #:color_pair color_pair #:brick_width brick_width)]
   [(eq? code_type 'code39_checksum)
    (draw-code39-checksum code file_name #:color_pair color_pair #:brick_width brick_width)]
   ))

(define (barcode-read pic_path #:code_type [code_type 'ean13])
   (let (
         [step1_points_list #f]
         [step2_threshold #f]
         [step3_bw_points #f]
         )
     (set! step1_points_list (pic->points pic_path))
     (set! step2_threshold (find-threshold step1_points_list))
     (set! step3_bw_points (points->bw step1_points_list step2_threshold))
     (let ([search_result (search-barcode step3_bw_points code_type)])
       (if search_result
           (deal-result search_result code_type)
           (let* ([strict_points (points->strict-bw step1_points_list)]
                  [search_result_twice (search-barcode strict_points code_type)])
             (if search_result_twice
                 (deal-result search_result_twice code_type)
                 ""))))))

(define (search-barcode rows code_type)
  (let loop ([loop_rows rows]
             [loop_count 1])
    (if (and (not (null? loop_rows)) (>= (length loop_rows) 6))
        (let ([result (search-barcode-on-row (car loop_rows) code_type)])
          (if (and
               result
               (cond
                [(eq? code_type 'ean13)
                 (ean13-check-bars result)]
                [(eq? code_type 'code128)
                 (code128-check-bars result)]
                [(eq? code_type 'ean39)
                 (ean39-check-bars result)]
                [(eq? code_type 'ean39_checksum)
                 (ean39-checksum-check-bars result)]))
              result
              (loop (list-tail loop_rows 5) (+ loop_count 5))))
        #f)))

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


