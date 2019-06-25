#lang racket

(require simple-svg)

(require "parameters.rkt")

(provide (contract-out
          [draw-svg (-> natural? natural? path-string? procedure? void?)]
          [draw-svg-bars (-> string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-svg-text (-> string? #:x natural? #:y natural? void?)]
          ))

(define (draw-svg width height file_name draw-func)
  (with-output-to-file
      file_name #:exists 'replace
      (lambda ()
        (printf "~a"
                (svg-out
                 width height
                 (lambda ()
                   (when (not (string=? (*back_color*) "transparent"))
                         (let ([back_rect (svg-def-rect width height)]
                               [back_sstyle (sstyle-new)])
                           
                           (sstyle-set! back_sstyle 'fill (*back_color*))
                           (svg-use-shape back_rect back_sstyle)))

                   (draw-func)

                   (svg-show-default)))))))

(define (draw-svg-bars bars #:x x #:y y #:bar_height bar_height)
  (let ([bar_rect (svg-def-rect (*brick_width*) bar_height)]
        [bar_sstyle (sstyle-new)])
    
    (sstyle-set! bar_sstyle 'fill (*front_color*))

    (let loop ([loop_list (string->list bars)]
               [loop_x x])
      (when (not (null? loop_list))
            (when (char=? (car loop_list) #\1)
                  (svg-use-shape bar_rect bar_sstyle #:at? (cons loop_x y)))
            (loop (cdr loop_list) (+ loop_x (*brick_width*)))))))

(define (draw-svg-text txt #:x x #:y y)
  (let* ([actual_font_size (* (add1 (*brick_width*)) (*font_size*))]
         [text (svg-def-text txt #:font-size? actual_font_size)]
         [text_sstyle (sstyle-new)])
    (sstyle-set! text_sstyle 'fill (*front_color*))
    (svg-use-shape text text_sstyle #:at? (cons x (+ y (floor (* actual_font_size (/ 2 3))))))))

