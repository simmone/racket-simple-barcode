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

there is also a complete read and write example on github:@link["https://github.com/simmone/racket-simple-barcode/blob/master/simple-barcode/example/example.rkt"]{includedin the source}.

@defproc[(barcode-write
              [code string?]
              [output_file_path path-string?]
              [#:code_type code_type symbol? 'ean13]
              [#:color_pair color_pair pair? '("black" . "white")]
              [#:brick_width brick_width exact-nonnegative-integer? 2])
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

@subsection{Complete Example}

@codeblock{
#lang racket

(require simple-barcode)

(barcode-write "750103131130" "barcode_ean13.png")
}

@image{example/barcode_ean13.png}

@codeblock{
(barcode-write "750103131130" "barcode_ean13_w5.png" #:brick_width 5)
}

@image{example/barcode_ean13_w5.png}

@codeblock{
(barcode-write "750103131130" "barcode_ean13_color.png" #:color_pair '("red" . "gray"))
}

@image{example/barcode_ean13_color.png}

@codeblock{
(barcode-write "750103131130" "barcode_ean13_trans.png" #:color_pair '("red" . "transparent"))
}

@image{example/barcode_ean13_trans.png}

@codeblock{
(printf "~a,~a,~a,~a\n"
  (barcode-read "barcode_ean13.png")
  
  (barcode-read "barcode_ean13_w5.png")
  
  (barcode-read "barcode_ean13_color.png")

  (barcode-read "barcode_ean13_trans.png"))

(barcode-write "chenxiao770117" "barcode_code128.png" #:code_type 'code128)
}

@image{example/barcode_code128.png}

@codeblock{
(printf "~a\n" (barcode-read "barcode_code128.png" #:code_type 'code128))

(barcode-write "CHEN" "barcode_code39.png" #:code_type 'code39)
}

@image{example/barcode_code39.png}

@codeblock{
(printf "~a\n" (barcode-read "barcode_code39.png" #:code_type 'code39))

(barcode-write "CHEN" "barcode_code39_checksum.png" #:code_type 'code39_checksum)
}

@image{example/barcode_code39_checksum.png}

@codeblock{
(printf "~a\n" (barcode-read "barcode_code39_checksum.png" #:code_type 'code39_checksum))
}
