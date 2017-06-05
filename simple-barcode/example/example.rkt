#lang racket

(require "../main.rkt")

(barcode-write "7501031311309" "barcode_ean13.png")

(barcode-write "7501031311309" "barcode_ean13_w5.png" #:brick_width 5)

(barcode-write "7501031311309" "barcode_ean13_color.png" #:color_pair '("red" . "blue"))

(barcode-write "7501031311309" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))
