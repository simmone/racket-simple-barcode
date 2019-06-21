#lang racket

(provide (contract-out
          [set-color (-> (is-a?/c bitmap-dc%) (or/c (is-a?/c color%) string?) void?)]
          [drawing (->* (natural? natural? path-string? procedure?)
                        (
                         #:color_pair (cons/c string? string?)
                         #:brick_width natural?
                        )
                        void?)]
          [draw-bars (-> (is-a?/c bitmap-dc%) string? #:x exact-nonnegative-integer? #:y exact-nonnegative-integer? #:bar_width exact-nonnegative-integer? #:bar_height exact-nonnegative-integer? void?)]
          [save-bars (-> (is-a?/c bitmap-dc%) path-string? boolean?)]
          ))

(require racket/draw)

(define (drawing width height file_name draw-func #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([front_color (car color_pair)]
         [back_color (cdr color_pair)]
         [x (* (add1 *quiet_zone_width*) brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [target (make-bitmap width height)]
         [dc (new bitmap-dc% [bitmap target])])

    (when (not (string=? back_color "transparent"))
          (set-color dc back_color)
          (send dc draw-rectangle 0 0 width height))

    (set-color dc front_color)
    (send dc set-text-foreground front_color)
    (send dc set-font (make-font #:size-in-pixels? #t #:size (* *font_size* brick_width) #:face "Monospace" #:family 'modern))
    dc))


(define (set-color dc color)
  (when (not (string=? color "transparent"))
        (send dc set-pen color 1 'solid))

  (send dc set-brush color 'solid))

(define (draw-init width height #:color_pair [color_pair '("black" . "white")] #:brick_width [brick_width 2])
  (let* ([front_color (car color_pair)]
         [back_color (cdr color_pair)]
         [x (* (add1 *quiet_zone_width*) brick_width)]
         [y (* (add1 *top_margin*) brick_width)]
         [bar_height (* brick_width *bar_height*)]
         [target (make-bitmap width height)]
         [dc (new bitmap-dc% [bitmap target])])

    (when (not (string=? back_color "transparent"))
          (set-color dc back_color)
          (send dc draw-rectangle 0 0 width height))

    (set-color dc front_color)
    (send dc set-text-foreground front_color)
    (send dc set-font (make-font #:size-in-pixels? #t #:size (* *font_size* brick_width) #:face "Monospace" #:family 'modern))
    dc))

(define (save-bars dc file_name)
    (send (send dc get-bitmap) save-file file_name 'png))

(define (draw-bars dc bars #:x x #:y y #:bar_width bar_width #:bar_height bar_height)
  (let loop ([loop_list (string->list bars)]
             [loop_x x])
    (when (not (null? loop_list))
          (when (char=? (car loop_list) #\1)
                (send dc draw-rectangle loop_x y bar_width bar_height))
          (loop (cdr loop_list) (+ loop_x bar_width)))))

