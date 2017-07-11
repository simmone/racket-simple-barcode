#lang racket

(require rackunit/text-ui)

(require rackunit "../../main.rkt")

(require racket/runtime-path)
(define-runtime-path example_ean13_file "../../example/barcode_ean13.png")
(define-runtime-path example_ean13_w5_file "../../example/barcode_ean13_w5.png")
(define-runtime-path example_ean13_color_file "../../example/barcode_ean13_color.png")
(define-runtime-path example_ean13_trans_file "../../example/barcode_ean13_trans.png")

(define-runtime-path extern_ean13_test1 "extern_ean13_test1.png")
(define-runtime-path extern_code128_test1 "extern_code128_test1.png")
(define-runtime-path extern_code128_test2 "extern_code128_test2.png")

(define-runtime-path ean13_file "barcode_ean13.png")
(define-runtime-path ean13_w5_file "barcode_ean13_w5.png")
(define-runtime-path ean13_color_file "barcode_ean13_color.png")
(define-runtime-path ean13_trans_file "barcode_ean13_trans.png")

(define-runtime-path code128_file "barcode_code128.png")
(define-runtime-path code128_w5_file "barcode_code128_w5.png")
(define-runtime-path code128_color_file "barcode_code128_color.png")
(define-runtime-path code128_trans_file "barcode_code128_trans.png")

(define-runtime-path code39_file "barcode_code39.png")
(define-runtime-path code39_w5_file "barcode_code39_w5.png")
(define-runtime-path code39_color_file "barcode_code39_color.png")
(define-runtime-path code39_trans_file "barcode_code39_trans.png")

(define-runtime-path code39_checksum_file "barcode_code39_checksum.png")

(define tests
  (test-suite
   "test-barcode"

   (test-case
    "test-read"

    (check-equal? (barcode-read example_ean13_file) "7501031311309")
    (check-equal? (barcode-read example_ean13_w5_file) "7501031311309")
    (check-equal? (barcode-read example_ean13_color_file) "7501031311309")
    (check-equal? (barcode-read example_ean13_trans_file) "7501031311309")

    (check-equal? (barcode-read extern_ean13_test1) "5901234123457")
    (check-equal? (barcode-read extern_code128_test1 #:code_type 'code128) "Wikipedia")
    (check-equal? (barcode-read extern_code128_test2 #:code_type 'code128) "Barcode World")
    )

   (test-case
    "test-ean13-writer-reader"

    (dynamic-wind
        (lambda ()
          (barcode-write "750103131130" ean13_file)
          (barcode-write "750103131130" ean13_w5_file #:brick_width 5)
          (barcode-write "750103131130" ean13_color_file #:color_pair '("red" . "gray"))
          (barcode-write "750103131130" ean13_trans_file #:color_pair '("red" . "transparent")))
        (lambda ()
          (check-equal? (barcode-read ean13_file) "7501031311309")
          (check-equal? (barcode-read ean13_w5_file) "7501031311309")
          (check-equal? (barcode-read ean13_color_file) "7501031311309")
          (check-equal? (barcode-read ean13_trans_file) "7501031311309"))
        (lambda ()
          (delete-file ean13_file)
          (delete-file ean13_w5_file)
          (delete-file ean13_color_file)
          (delete-file ean13_trans_file)
          )))

   (test-case
    "test-code128-writer-reader"

    (dynamic-wind
        (lambda ()
          (barcode-write "chenxiao770117" code128_file #:code_type 'code128)
          (barcode-write "chenxiao770117" code128_w5_file #:code_type 'code128 #:brick_width 5)
          (barcode-write "chenxiao770117" code128_color_file #:code_type 'code128 #:color_pair '("red" . "gray"))
          (barcode-write "chenxiao770117" code128_trans_file #:code_type 'code128 #:color_pair '("red" . "transparent"))
          )
        (lambda ()
          (check-equal? (barcode-read code128_file #:code_type 'code128) "chenxiao770117")
          (check-equal? (barcode-read code128_w5_file #:code_type 'code128) "chenxiao770117")
          (check-equal? (barcode-read code128_color_file #:code_type 'code128) "chenxiao770117")
          (check-equal? (barcode-read code128_trans_file #:code_type 'code128) "chenxiao770117")
          )
        (lambda ()
          (delete-file code128_file)
          (delete-file code128_w5_file)
          (delete-file code128_color_file)
          (delete-file code128_trans_file)
          )))

   (test-case
    "test-code39"

    (dynamic-wind
        (lambda ()
          (barcode-write "chenxiao770117" code39_file #:code_type 'code39)
          (barcode-write "chenxiao770117" code39_w5_file #:code_type 'code39 #:brick_width 5)
          (barcode-write "chenxiao770117" code39_color_file #:code_type 'code39 #:color_pair '("red" . "gray"))
          (barcode-write "chenxiao770117" code39_trans_file #:code_type 'code39 #:color_pair '("red" . "transparent"))
          )
        (lambda ()
          (check-equal? (barcode-read code39_file #:code_type 'code39) "chenxiao770117")
          (check-equal? (barcode-read code39_w5_file #:code_type 'code39) "chenxiao770117")
          (check-equal? (barcode-read code39_color_file #:code_type 'code39) "chenxiao770117")
          (check-equal? (barcode-read code39_trans_file #:code_type 'code39) "chenxiao770117")
          )
        (lambda ()
          (delete-file code39_file)
          (delete-file code39_w5_file)
          (delete-file code39_color_file)
          (delete-file code39_trans_file)
          )))

   (test-case
    "test-code39_checksum"

    (dynamic-wind
        (lambda ()
          (barcode-write "chenxiao770117" code39_checksum_file #:code_type 'code39_checksum)
          )
        (lambda ()
          (check-equal? (barcode-read code39_checksum_file #:code_type 'code39_checksum) "chenxiao770117")
          )
        (lambda ()
          (delete-file code39_checksum_file)
          )))

   ))

(run-tests tests)
