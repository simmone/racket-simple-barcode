#lang racket

(require simple-svg)

(barcode-write 'svg "750103131130" "barcode_ean13.svg")

(barcode-write 'svg "750103131130" "barcode_ean13_w5.svg" #:brick_width 5)

(barcode-write 'svg "750103131130" "barcode_ean13_w10.svg" #:brick_width 10)

(barcode-write 'svg "750103131130" "barcode_ean13_color.svg" #:color_pair '("red" . "gray"))

(barcode-write 'svg "750103131130" "barcode_ean13_trans.svg" #:color_pair '("red" . "transparent"))

(barcode-write 'svg "chenxiao770117" "barcode_code128.svg" #:code_type 'code128)

(barcode-write 'svg "CHEN" "barcode_code39.svg" #:code_type 'code39)

(barcode-write 'svg "CHEN" "barcode_code39_checksum.svg" #:code_type 'code39_checksum)


