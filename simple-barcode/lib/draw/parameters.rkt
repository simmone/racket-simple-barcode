#lang racket

(provide (contract-out
          [*width* parameter?]
          [*height* parameter?]
          [*front_color* parameter?]
          [*back_color* parameter?]
          [*brick_width* parameter?]
          [*quiet_zone_width* parameter?]
          [*bar_height* parameter?]
          [*top_margin* parameter?]
          [*code_down_margin* parameter?]
          ))

(define *width* (make-parameter #f))
(define *height* (make-parameter #f))

(define *front_color* (make-parameter #f))
(define *back_color* (make-parameter #f))

(define *brick_width* (make-parameter #f))

(define *quiet_zone_width* (make-parameter 10))
(define *bar_height* (make-parameter 60))
(define *top_margin* (make-parameter 10))

(define *code_down_margin* (make-parameter 15))



