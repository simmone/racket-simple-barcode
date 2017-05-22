#lang racket

(provide (contract-out
          [ean13-checksum (-> string? exact-nonnegative-integer?)]
          [char->barstring(-> char? symbol? string?)]
          [ean13->bar (-> string? string?)]
          ))

(define (ean13-checksum barcode)
  (let-values ([
                (even_sum odd_sum)
                (let loop ([number_list
                            (map
                             (lambda (ch)
                               (string->number (string ch)))
                             (string->list barcode))]
                           [index 0]
                           [even_sum 0]
                           [odd_sum 0])
                  (if (not (null? number_list))
                      (if (even? index)
                          (loop
                           (cdr number_list)
                           (add1 index)
                           (+ even_sum (car number_list))
                           odd_sum)
                          (loop
                           (cdr number_list)
                           (add1 index)
                           even_sum
                           (+ odd_sum (car number_list))))
                      (values even_sum odd_sum)))])
    (let ([step4 (+ (* odd_sum 3) even_sum)])
      (if (= (remainder step4 10) 0)
          0
          (- 10 (remainder step4 10))))))

(define char_bar_map
  '#hash(
         (#\0 . ("0001101" "0100111" "1110010"))
         (#\1 . ("0011001" "0110011" "1100110"))
         (#\2 . ("0010011" "0011011" "1101100"))
         (#\3 . ("0111101" "0100001" "1000010"))
         (#\4 . ("0100011" "0011101" "1011100"))
         (#\5 . ("0110001" "0111001" "1001110"))
         (#\6 . ("0101111" "0000101" "1010000"))
         (#\7 . ("0111011" "0010001" "1000100"))
         (#\8 . ("0110111" "0001001" "1001000"))
         (#\9 . ("0001011" "0010111" "1110100"))))

(define char_parity_map
  '#hash(
         (#\0 . (none odd  odd  odd  odd  odd  odd))
         (#\1 . (none odd  odd even  odd even  odd))
         (#\2 . (none odd  odd even even  odd even))
         (#\3 . (none odd  odd even even even  odd))
         (#\4 . (none odd  even odd  odd even even))
         (#\5 . (none odd even even  odd  odd even))
         (#\6 . (none odd even even even  odd  odd))
         (#\7 . (none odd even  odd even  odd even))
         (#\8 . (none odd even  odd even even  odd))
         (#\9 . (none odd even even  odd even  odd))
         ))

(define (char-parity ch place)
  (list-ref (hash-ref char_parity_map ch) place))

(define (char->barstring ch type)
  (let ([place
         (cond
          [(eq? type 'left_odd)
           0]
          [(eq? type 'left_even)
           1]
          [(eq? type 'right)
           2])])
    (list-ref (hash-ref char_bar_map ch) place)))

(define (ean13->bar ean13)
  (let* ([char_list (string->list ean13)]
         [parity_number (car char_list)])
    (string-append
     "101"
     (char->barstring (list-ref char_list 1) (if (eq? (char-parity parity_number 1) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 2) (if (eq? (char-parity parity_number 2) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 3) (if (eq? (char-parity parity_number 3) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 4) (if (eq? (char-parity parity_number 4) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 5) (if (eq? (char-parity parity_number 5) 'odd) 'left_odd 'left_even))
     (char->barstring (list-ref char_list 6) (if (eq? (char-parity parity_number 6) 'odd) 'left_odd 'left_even))
     "01010"
     (char->barstring (list-ref char_list 7) 'right)
     (char->barstring (list-ref char_list 8) 'right)
     (char->barstring (list-ref char_list 9) 'right)
     (char->barstring (list-ref char_list 10) 'right)
     (char->barstring (list-ref char_list 11) 'right)
     (char->barstring (list-ref char_list 12) 'right)
     "101")))
