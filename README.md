A Barcode reader and writer for Racket
==================

# Install
    raco pkg install simple-barcode

# Basic Usage
```racket

#lang racket

(require simple-barcode)

(draw-ean13 "7501031311309" "barcode_ean13.png")

(draw-ean13 "7501031311309" "barcode_ean13_w5.png" #:brick_width 5)

(draw-ean13 "7501031311309" "barcode_ean13_color.png" #:color_pair '("red" . "blue"))

(draw-ean13 "7501031311309" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))
  
```

<p>
default, brick_width = 2:
![ScreenShot](simple-barcode/example/barcode_ean13.png)
</p>

brick_width = 5:<br>
![ScreenShot](simple-barcode/example/barcode_ean13.png)

change front and background color:<br>
![ScreenShot](simple-barcode/example/barcode_ean13.png)

set transparent background:<br>
![ScreenShot](simple-barcode/example/barcode_ean13.png)
