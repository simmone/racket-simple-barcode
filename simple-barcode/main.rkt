#lang racket

(provide (contract-out 
          [barcode-write (->* (string? path-string?) (#:type symbol? #:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          ))

(require "lib/lib.rkt")

(define (barcode-write ean13 file_name #:type [type 'ean13] #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (cond
   [(eq? type 'ean13)
    (draw-ean13 ean13 file_name #:color_pair color_pair #:brick_width brick_width)]
   ))
