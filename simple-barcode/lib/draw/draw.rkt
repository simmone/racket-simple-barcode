#lang racket

(require "lib.rkt")
(require "png.rkt")

(provide (contract-out
          [drawing (-> path-string? procedure? void?)]
          [*output_type* parameter?]
          [*file_name* parameter?]
          [*width* parameter?]
          [*height* parameter?]
          [*front_color* parameter?]
          [*back_color* parameter?]
          [*brick_width* parameter?]
          [draw-png (-> path-string? procedure? void?)]
          ))

(define (drawing file_name draw-func)
  (cond
   [(eq? type 'png)
    (draw-png file_name draw-func)]
   [else
    (draw-png file_name draw-func)]
   ))

