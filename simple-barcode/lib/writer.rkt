#lang racket

(provide (contract-out
          [barcode-write (->* (string? path-string?) (#:code_type symbol? #:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          ))

(require "share.rkt")
(require "ean13-lib.rkt")
(require "code128-lib.rkt")

(define (barcode-write code file_name #:code_type [code_type 'ean13] #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (cond
   [(eq? code_type 'ean13)
    (draw-ean13 code file_name #:color_pair color_pair #:brick_width brick_width)]
   [(eq? code_type 'code128)
    (draw-code128 code file_name #:color_pair color_pair #:brick_width brick_width)]
   ))
