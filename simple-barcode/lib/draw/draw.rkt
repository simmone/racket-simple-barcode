#lang racket

(require "parameters.rkt")
(require "png.rkt")

(provide (contract-out
          [*width* parameter?]
          [*height* parameter?]
          [*front_color* parameter?]
          [*back_color* parameter?]
          [*brick_width* parameter?]
          [*quite_zone_width* parameter?]
          [*bar_height* parameter?]
          [*top_margin* parameter?]
          [*font_size* parameter?]
          [*code_down_margin* parameter?]
          [drawing (-> (or/c 'png 'svg) path-string? procedure? void?)]
          ))

(define (drawing type file_name draw-func)
  (cond
   [(eq? type 'png)
    (draw-png file_name draw-func)]
   [else
    (draw-png file_name draw-func)]
   ))

