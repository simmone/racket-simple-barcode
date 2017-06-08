A Barcode reader and writer for Racket
==================

# Install
    raco pkg install simple-barcode

# Basic Usage
```racket

#lang racket

  (require simple-barcode)

  (barcode-write "7501031311309" "barcode_ean13.png")

  (barcode-write "7501031311309" "barcode_ean13_w5.png" #:brick_width 5)

  (barcode-write "7501031311309" "barcode_ean13_color.png" #:color_pair '("red" . "gray"))

  (barcode-write "7501031311309" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))

  (printf "~a,~a,~a,~a\n"
    (barcode-read "barcode_ean13.png")
  
    (barcode-read "barcode_ean13_w5.png")
  
    (barcode-read "barcode_ean13_color.png")

    (barcode-read "barcode_ean13_trans.png"))
  
```

default, brick_width = 2:<br>
![ScreenShot](simple-barcode/example/barcode_ean13.png)

brick_width = 5:<br>
![ScreenShot](simple-barcode/example/barcode_ean13_w5.png)

change front and background color:<br>
![ScreenShot](simple-barcode/example/barcode_ean13_color.png)

set transparent background:<br>
![ScreenShot](simple-barcode/example/barcode_ean13_trans.png)

7501031311309,7501031311309,7501031311309,7501031311309
