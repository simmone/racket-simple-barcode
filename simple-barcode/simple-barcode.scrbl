#lang scribble/manual

@(require (for-label racket))
@(require (for-label simple-barcode))

@title{Simple-Barcode: Barcode reader and writer}

@author+email["Chen Xiao" "chenxiao770117@gmail.com"]

simple-barcode package is a package to read and write barcode file.

@table-of-contents[]

@section[#:tag "install"]{Install}

raco pkg install simple-barcode

@section{Write}

select a type, size, color, then write a string to barcode.

there is also a complete read and write example on github:@link["https://github.com/simmone/racket-simple-barcode/blob/master/simple-barcode/example/example.rkt"]{includedin the source}.

@defproc[(barcode-write
              [code string?]
              [output_file_path path-string?]
              [#:code_type code_type symbol? 'ean13]
              [#:color_pair color_pair pair? '("black" . "white")]
              [#:brick_width brick_width exact-nonnegative-integer? 2])
            boolean?]{
support code_type: 'ean13, 'code128
}

@section{Read}

read barcode from a picture file.

@defproc[(barcode-read
              [barcode_file_path path-string?]
              )
            string?]{
}

@section{Complete Example}

@verbatim{
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

(barcode-write "chenxiao770117" "barcode_code128.png" #:code_type 'code128)
(printf "~a\n" (barcode-read "barcode_code128.png"))
}
