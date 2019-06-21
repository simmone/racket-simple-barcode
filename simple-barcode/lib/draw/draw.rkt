#lang racket

(require "png.rkt")

(provide (contract-out
          [drawing (-> path-string? procedure? void?)]
          [*output_type* parameter?]
          ))

(define *output_type* (make-parameter 'png))

(define (drawing file_name draw-func)
  (cond
   [(eq? (*output_type*) 'png)
    (draw-png file_name draw-func)]
   [else
    (draw-png file_name draw-func)]
   ))

