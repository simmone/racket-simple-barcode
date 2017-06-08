#lang racket

(require simple-barcode)

(barcode-write "7501031311309" "barcode_ean13.png")

(barcode-write "7501031311309" "barcode_ean13_w5.png" #:brick_width 5)

(barcode-write "7501031311309" "barcode_ean13_color.png" #:color_pair '("red" . "black"))

(barcode-write "7501031311309" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))
