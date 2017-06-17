#lang racket

(provide (contract-out
          [barcode-read (-> path-string? string?)]
          ))

(require "share.rkt")
(require "ean13-lib.rkt")
(require "code128-lib.rkt")

(define (barcode-read pic_path)
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
           (deal-result search_result)
           (let* ([strict_points (points->strict-bw step1_points_list)]
                  [search_result_twice (search-barcode strict_points)])
             (if search_result_twice
                 (deal-result search_result_twice)
                 ""))))))

(define (deal-result result)
  (let ([type (car result)]
        [bars (cdr result)])
    (cond
     [(eq? type 'ean13)
      (ean13-bar->string bars)]
     [(eq? type 'code128)
      (if (code128-verify bars)
          (code128-bar->string bars)
          "")]
     [else
      ""])))

