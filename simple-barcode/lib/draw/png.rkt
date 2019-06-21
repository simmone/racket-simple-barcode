#lang racket

(require racket/draw)

(require "lib.rkt")

(provide (contract-out
          [draw-png (-> path-string? procedure? void?)]
          [draw-bars (-> string? #:x natural? #:y natural? void?)]
          [save-bars (-> (is-a?/c bitmap-dc%) path-string? boolean?)]
          ))

(define *dc* (make-parameter #f))

(define (draw-png file_name draw-func)
  (let* ([x (* (add1 *quiet_zone_width*) (*brick_width*))]
         [y (* (add1 *top_margin*) (*brick_width*))]
         [bar_height (* (*brick_width*) (*bar_height*))]
         [target (make-bitmap (*width*) (*height*))])

    (parameterize
     (
      [dc (new bitmap-dc% [bitmap target])]
      )
     (when (not (string=? back_color "transparent"))
          (set-color (*dc*) (*back_color*))
          (send (*dc*) draw-rectangle 0 0 (*width*) (*height*)))

    (set-color (*front_color*))
    (send (*dc*) set-text-foreground (*front_color*))
    (send (*dc*) set-font (make-font #:size-in-pixels? #t #:size (* (*font_size*) (*brick_width*)) #:face "Monospace" #:family 'modern))
    
    (draw-func)

    (send (send (*dc*) get-bitmap) save-file file_name 'png))))

(define (set-color color)
  (when (not (string=? color "transparent"))
        (send (*dc*) set-pen color 1 'solid))

  (send (*dc*) set-brush color 'solid))

(define (draw-bars bars #:x x #:y y)
  (let loop ([loop_list (string->list bars)]
             [loop_x x])
    (when (not (null? loop_list))
          (when (char=? (car loop_list) #\1)
                (send (*dc*) draw-rectangle loop_x y (*bar_width*) (*bar_height*)))
          (loop (cdr loop_list) (+ loop_x (*bar_width*))))))

