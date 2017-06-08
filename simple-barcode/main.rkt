#lang racket

(provide (contract-out 
          [barcode-write (->* (string? path-string?) (#:code_type symbol? #:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [barcode-read (->* (path-string?) (#:code_type symbol?) string?)]
          ))

(require "lib/lib.rkt")

(define (barcode-write ean13 file_name #:code_type [code_type 'ean13] #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (cond
   [(eq? code_type 'ean13)
    (draw-ean13 ean13 file_name #:color_pair color_pair #:brick_width brick_width)]
   ))

(define (barcode-read file_name #:code_type [code_type 'ean13])
  (cond
   [(eq? code_type 'ean13)
    (read-ean13 file_name)]
   ))

