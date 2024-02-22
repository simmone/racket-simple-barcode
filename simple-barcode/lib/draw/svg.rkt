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
                         (let ([back_rect (svg-def-shape (new-rect width height))]
                               [back_sstyle (sstyle-new)])
                           
                           (set-SSTYLE-fill! back_sstyle (*back_color*))
                           (svg-place-widget back_rect #:style back_sstyle)))

                   (draw-func)))))))

(define (draw-svg-bars bars #:x x #:y y #:bar_height bar_height)
  (let ([bar_rect (svg-def-shape (new-rect (*brick_width*) bar_height))]
        [bar_sstyle (sstyle-new)])
    
    (set-SSTYLE-fill! bar_sstyle (*front_color*))

    (let loop ([loop_list (string->list bars)]
               [loop_x x])
      (when (not (null? loop_list))
            (when (char=? (car loop_list) #\1)
                  (svg-place-widget bar_rect #:style bar_sstyle #:at (cons loop_x y)))
            (loop (cdr loop_list) (+ loop_x (*brick_width*)))))))

(define (draw-svg-text txt #:x x #:y y)
  (let* ([actual_font_size (* (add1 (*brick_width*)) (*font_size*))]
         [text (svg-def-shape (new-text txt #:font-size actual_font_size))]
         [text_sstyle (sstyle-new)])
    (set-SSTYLE-fill! text_sstyle (*front_color*))
    (svg-place-widget text #:style text_sstyle #:at (cons x (+ y (floor (* actual_font_size (/ 2 3))))))))

