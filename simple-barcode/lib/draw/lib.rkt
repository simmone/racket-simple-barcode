#lang racket

(provide (contract-out
          [*output_type* parameter?]
          [*file_name* parameter?]
          [*width* parameter?]
          [*height* parameter?]
          [*front_color* parameter?]
          [*back_color* parameter?]
          [*brick_width* parameter?]
          [*quite_zone_width* parameter?]
          [*bar_height* parameter?]
          [*top_margin* parameter?]
          [*font_size* parameter?]
          [*ean13_down_margin* parameter?]
          ))

(define *output_type* (make-parameter 'png))
(define *file_name* (make-parameter #f))
(define *width* (make-parameter #f))
(define *height* (make-parameter #f))
(define *front_color* (make-parameter #f))
(define *back_color* (make-parameter #f))
(define *brick_width* (make-parameter #f))
(define *quiet_zone_width* (make-parameter 10))
(define *bar_height* (make-parameter 60))
(define *top_margin* (make-parameter 10))
(define *font_size* (make-parameter 5))
(define *ean13_down_margin* (make-parameter 20))
(define *code_down_margin* (make-parameter 15))



