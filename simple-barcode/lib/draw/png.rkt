#lang racket

(require racket/draw)

(require "parameters.rkt")

(provide (contract-out
          [draw-png (-> path-string? procedure? boolean?)]
          [draw-png-bars (-> string? #:x natural? #:y natural? #:bar_height natural? void?)]
          [draw-png-text (-> string? #:x natural? #:y natural? #:font_size natural? void?)]
          ))

(define *dc* (make-parameter #f))

(define (draw-png file_name draw-func)
  (let* ([x (* (add1 (*quiet_zone_width*)) (*brick_width*))]
         [y (* (add1 (*top_margin*)) (*brick_width*))]
         [bar_height (* (*brick_width*) (*bar_height*))]
         [target (make-bitmap (*width*) (*height*))])

    (printf "draw\n")

    (parameterize
     (
      [*dc* (new bitmap-dc% [bitmap target])]
      )

     (printf "~a,~a,~a\n" (*back_color*) (*width*) (*height*))

     (when (not (string=? (*back_color*) "transparent"))
           (send (*dc*) set-pen (*back_color*) 1 'solid)
           (send (*dc*) set-brush (*back_color*) 'solid)
           (send (*dc*) draw-rectangle 0 0 (*width*) (*height*)))
     
     (printf "s0\n")
     (send (*dc*) set-pen (*front_color*) 1 'solid)
     (send (*dc*) set-brush (*front_color*) 'solid)
     (printf "s1\n")
     (send (*dc*) set-text-foreground (*front_color*))
     (printf "s2\n")
     (send (*dc*) set-font (make-font #:size-in-pixels? #t #:size (* (*font_size*) (*brick_width*)) #:face "Monospace" #:family 'modern))

     (printf "s3\n")
     
     (draw-func)

     (printf "s4\n")

     (send (send (*dc*) get-bitmap) save-file file_name 'png))))

(define (draw-png-bars bars #:x x #:y y #:bar_height bar_height)
  (let loop ([loop_list (string->list bars)]
             [loop_x x])
    (when (not (null? loop_list))
          (when (char=? (car loop_list) #\1)
                (send (*dc*) draw-rectangle loop_x y (*brick_width*) bar_height))
          (loop (cdr loop_list) (+ loop_x (*brick_width*))))))

(define (draw-png-text txt #:x x #:y y #:font_size font_size)
  (send (*dc*) draw-text txt x y font_size))
