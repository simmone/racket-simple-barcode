#lang racket

(provide (contract-out
          [ean13-checksum (-> string? exact-nonnegative-integer?)]
          ))

(define (ean13-checksum barcode)
  (let-values ([
                (even_sum odd_sum)
                (let loop ([number_list
                            (map
                             (lambda (ch)
                               (string->number (string ch)))
                             (string->list barcode))]
                           [index 1]
                           [even_sum 0]
                           [odd_sum 0])
                  (if (not (null? number_list))
                      (if (even? (car number_list))
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
    (let* ([step2 (* even_sum 3)]
           [step4 (+ step2 odd_sum)])
      (if (= (remainder step4 10) 0)
          0
          (- 10 (remainder step4 10))))))


          
