#lang racket

(require "parameters.rkt")
(require "png.rkt")
(require "svg.rkt")

(provide (contract-out
          [*front_color* parameter?]
          [*font_size* parameter?]
          [*back_color* parameter?]
          [*brick_width* parameter?]
          [*bar_height* parameter?]
          [*quiet_zone_width* parameter?]
          [*top_margin* parameter?]
          [*code_down_margin* parameter?]
          [drawing (-> (or/c 'png 'svg) natural? natural? path-string? procedure? void?)]
          [draw-bars (-> (or/c 'png 'svg) string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-png-bars (-> string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-svg-bars (-> string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-text (-> (or/c 'png 'svg) string? #:x natural? #:y natural? void?)]
          [draw-png-text (-> string? #:x natural? #:y natural? void?)]
          [draw-svg-text (-> string? #:x natural? #:y natural? void?)]
          ))

(define (drawing type width height file_name draw-func)
  (cond
   [(eq? type 'png)
    (draw-png width height file_name draw-func)]
   [(eq? type 'svg)
    (draw-svg width height file_name draw-func)]
   [else
    (draw-png width height file_name draw-func)]
   ))

(define (draw-bars type bars #:x x #:y y #:bar_height bar_height)
  (cond
   [(eq? type 'png)
    (draw-png-bars bars #:x x #:y y #:bar_height bar_height)]
   [(eq? type 'svg)
    (draw-svg-bars bars #:x x #:y y #:bar_height bar_height)]
   [else
    (draw-png-bars bars #:x x #:y y #:bar_height bar_height)]
   ))

(define (draw-text type txt #:x x #:y y)
  (cond
   [(eq? type 'png)
    (draw-png-text txt #:x x #:y y)]
   [(eq? type 'svg)
    (draw-svg-text txt #:x x #:y y)]
   [else
    (draw-png-text txt #:x x #:y y)]
   ))
