#lang racket

(provide (contract-out 
          [barcode-write (->* (string? path-string?) (#:code_type symbol? #:color_pair pair? #:brick_width exact-nonnegative-integer?) boolean?)]
          [barcode-read (-> path-string? string?)]
          ))

(require "lib/reader.rkt")
(require "lib/writer.rkt")

