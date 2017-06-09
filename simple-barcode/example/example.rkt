#lang racket

(require simple-barcode)

(barcode-write "750103131130" "barcode_ean13.png")

(barcode-write "750103131130" "barcode_ean13_w5.png" #:brick_width 5)

(barcode-write "750103131130" "barcode_ean13_color.png" #:color_pair '("red" . "gray"))

(barcode-write "750103131130" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))

(printf "~a,~a,~a,~a\n"
  (barcode-read "barcode_ean13.png")
  
  (barcode-read "barcode_ean13_w5.png")
  
  (barcode-read "barcode_ean13_color.png")

  (barcode-read "barcode_ean13_trans.png"))

