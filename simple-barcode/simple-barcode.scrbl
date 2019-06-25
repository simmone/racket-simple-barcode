#lang scribble/manual

@(require (for-label racket))
@(require (for-label simple-barcode))

@title{Simple-Barcode: Barcode reader and writer}

@author+email["Chen Xiao" "chenxiao770117@gmail.com"]

simple-barcode package is a package to read and write barcode file.

@table-of-contents[]

@section[#:tag "install"]{Install}

raco pkg install simple-barcode

@section{Usage}

@defmodule[simple-barcode]

@subsection{Write}

select a type, size, color, then write a string to barcode.

there is also a complete read and write example on github:@link["https://github.com/simmone/racket-simple-barcode/blob/master/simple-barcode/example/png/png-example.rkt"]{includedin the source}.

@defproc[(barcode-write
              [output_type (or/c 'png 'svg)]
              [code string?]
              [output_file_path path-string?]
              [#:code_type code_type symbol? 'ean13]
              [#:color_pair color_pair pair? '("black" . "white")]
              [#:brick_width brick_width natural? 3]
              [#:font_size font_size natural? 3])
            boolean?]{
support code_type: 'ean13, 'code128, 'code39, 'code39_checksum
}

@subsection{Read}

read barcode from a picture file.

@defproc[(barcode-read
              [barcode_file_path path-string?]
              [#:code_type code_type symbol? 'ean13]
              )
            string?]{
support code_type: 'ean13, 'code128, 'code39, 'code39_checksum
}

@section{Png Example}

@codeblock{
#lang racket

(require simple-barcode)

(barcode-write 'png "750103131130" "barcode_ean13.png")
}
@image{example/png/barcode_ean13.png}

@codeblock{
(barcode-write 'png "750103131130" "barcode_ean13_w5.png" #:brick_width 5)
}
@image{example/png/barcode_ean13_w5.png}

@codeblock{
(barcode-write 'png "750103131130" "barcode_ean13_w10.png" #:brick_width 10 #:font_size 6)
}
@image{example/png/barcode_ean13_w10.png}

@codeblock{
(barcode-write 'png "750103131130" "barcode_ean13_color.png" #:color_pair '("red" . "gray"))
}
@image{example/png/barcode_ean13_color.png}

@codeblock{
(barcode-write 'png "750103131130" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))
}
@image{example/png/barcode_ean13_trans.png}

@codeblock{
(printf "~a,~a,~a,~a\n"
  (barcode-read "barcode_ean13.png")
  
  (barcode-read "barcode_ean13_w5.png")
  
  (barcode-read "barcode_ean13_color.png")

  (barcode-read "barcode_ean13_trans.png"))

(barcode-write 'png "chenxiao770117" "barcode_code128.png" #:code_type 'code128)
}
@image{example/png/barcode_code128.png}

@codeblock{
(printf "~a\n" (barcode-read "barcode_code128.png" #:code_type 'code128))

(barcode-write 'png "CHEN" "barcode_code39.png" #:code_type 'code39)
}
@image{example/png/barcode_code39.png}

@codeblock{
(printf "~a\n" (barcode-read "barcode_code39.png" #:code_type 'code39))

(barcode-write 'png "CHEN" "barcode_code39_checksum.png" #:code_type 'code39_checksum)
}
@image{example/png/barcode_code39_checksum.png}

@codeblock{
(printf "~a\n" (barcode-read "barcode_code39_checksum.png" #:code_type 'code39_checksum))
}

@section{Svg Example}

@codeblock{
#lang racket

(require simple-barcode)

(barcode-write 'svg "750103131130" "barcode_ean13.svg")
}
@image{example/svg/barcode_ean13.svg}

@codeblock{
(barcode-write 'svg "750103131130" "barcode_ean13_w5.svg" #:brick_width 5)
}
@image{example/svg/barcode_ean13_w5.svg}

@codeblock{
(barcode-write 'svg "750103131130" "barcode_ean13_w10.svg" #:brick_width 10)
}
@image{example/svg/barcode_ean13_w10.svg}

@codeblock{
(barcode-write 'svg "750103131130" "barcode_ean13_color.svg" #:color_pair '("red" . "gray"))
}
@image{example/svg/barcode_ean13_color.svg}

@codeblock{
(barcode-write 'svg "750103131130" "barcode_ean13_trans.svg" #:color_pair '("red" . "transparent"))
}
@image{example/svg/barcode_ean13_trans.svg}

@codeblock{
(barcode-write 'svg "chenxiao770117" "barcode_code128.svg" #:code_type 'code128)
}
@image{example/svg/barcode_code128.svg}

@codeblock{
(barcode-write 'svg "CHEN" "barcode_code39.svg" #:code_type 'code39)
}
@image{example/svg/barcode_code39.svg}

@codeblock{
(barcode-write 'svg "CHEN" "barcode_code39_checksum.svg" #:code_type 'code39_checksum)
}
@image{example/svg/barcode_code39_checksum.svg}

