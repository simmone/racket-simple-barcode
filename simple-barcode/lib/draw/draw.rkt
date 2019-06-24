#lang racket

(require "parameters.rkt")
(require "png.rkt")

(provide (contract-out
          [*width* parameter?]
          [*height* parameter?]
          [*front_color* parameter?]
          [*back_color* parameter?]
          [*brick_width* parameter?]
          [*bar_height* parameter?]
          [*quiet_zone_width* parameter?]
          [*top_margin* parameter?]
          [*font_size* parameter?]
          [*code_down_margin* parameter?]
          [drawing (-> (or/c 'png 'svg) path-string? procedure? boolean?)]
          [draw-bars (-> (or/c 'png 'svg) string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-png-bars (-> string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-text (-> (or/c 'png 'svg) string? #:x natural? #:y natural? #:font_size natural? void?)]
          [draw-png-text (-> string? #:x natural? #:y natural? #:font_size natural? void?)]
          ))

(define (drawing type file_name draw-func)
  (cond
   [(eq? type 'png)
    (draw-png file_name draw-func)]
   [else
    (draw-png file_name draw-func)]
   ))

(define (draw-bars type bars #:x x #:y y #:bar_height bar_height)
  (cond
   [(eq? type 'png)
    (draw-png-bars bars #:x x #:y y #:bar_height bar_height)]
   [else
    (draw-png-bars bars #:x x #:y y #:bar_height bar_height)]
   ))

(define (draw-text type txt #:x x #:y y #:font_size font_size)
  (cond
   [(eq? type 'png)
    (draw-png-text txt #:x x #:y y #:font_size font_size)]
   [else
    (draw-png-text txt #:x x #:y y #:font_size font_size)]
   ))
