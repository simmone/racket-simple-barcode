#lang racket

(require rackunit/text-ui)

(require rackunit "../lib/reader.rkt")

(require racket/runtime-path)
(define-runtime-path ean13_file "../example/barcode_ean13.png")
(define-runtime-path ean13_w5_file "../example/barcode_ean13_w5.png")
(define-runtime-path ean13_color_file "../example/barcode_ean13_color.png")
(define-runtime-path ean13_trans_file "../example/barcode_ean13_trans.png")
(define-runtime-path ean13_test1 "ean13/ean13_test1.png")

(define tests
  (test-suite
   "test-barcode-read"

   (test-case
    "test-ean13"

    (check-equal? (barcode-read ean13_file) "7501031311309")
    (check-equal? (barcode-read ean13_w5_file) "7501031311309")
    (check-equal? (barcode-read ean13_color_file) "7501031311309")
    (check-equal? (barcode-read ean13_trans_file) "7501031311309")
    (check-equal? (barcode-read ean13_test1) "5901234123457")
    )

   ))

(run-tests tests)
