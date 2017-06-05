#lang scribble/manual

@(require (for-label racket))

@title{Simple-Barcode: Barcode reader and writer}

@author+email["Chen Xiao" "chenxiao770117@gmail.com"]

simple-barcode package is a package to read and write barcode file.

@table-of-contents[]

@section[#:tag "install"]{Install}

raco pkg install simple-barcode

@section{Write}

select a type, size, color, then write a string to barcode.

@defmodule[simple-barcode]
@(require (for-label simple-barcode))

there is also a complete read and write example on github:@link["https://github.com/simmone/racket-simple-barcode/blob/master/simple-barcode/example/example.rkt"]{includedin the source}.

@defproc[(barcode-write
              [code (string?)]
              [output_file_path (path-string?)]
              [#:type (symbol?) 'ean13]
              [#:color_pair (pair?) '("black" . "white")]
              [#:brick_width (exact-nonnegative-integer?) 2])
            boolean?]{
  default type is ean13.
}

@section{Complete Example}

@verbatim{
#lang racket

(require "simple-barcode")

(barcode-write "7501031311309" "barcode_ean13.png")

(barcode-write "7501031311309" "barcode_ean13_w5.png" #:brick_width 5)

(barcode-write "7501031311309" "barcode_ean13_color.png" #:color_pair '("red" . "blue"))

(barcode-write "7501031311309" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))

}
