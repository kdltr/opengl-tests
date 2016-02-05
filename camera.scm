(define camera-position (make-point 0 0 3))
(define camera-front (make-point 0 0 -1))
(define camera-up (make-point 0 1 0))
(define camera-speed 30)
(define pitch 0)
(define yaw 0)
(define fov 45)

(define keys (make-vector 1024 #f))
(glfw:key-callback
 (lambda (window key scancode action mods)
   (print (list key: key action: action))
   (vector-set! keys key
                (select action
                  ((glfw:+press+) #t)
                  ((glfw:+release+) #f)
                  (else (vector-ref keys key))))))

(define last-x 400)
(define last-y 300)
(glfw:cursor-position-callback
 (lambda (window x y)
   (let* ((sensitivity 0.1)
          (x-offset (* sensitivity (- x last-x)))
          (y-offset (* sensitivity (- y last-y))))
     (set! last-x x)
     (set! last-y y)
     (set! yaw (+ yaw x-offset))
     (set! pitch (min 89 (max -89 (+ pitch y-offset))))
     (set! camera-front
       (normalize!
        (make-point (* (cos (degrees->radians pitch)) (cos (degrees->radians yaw)))
                    (sin (degrees->radians pitch))
                    (* (cos (degrees->radians pitch)) (sin (degrees->radians yaw)))))))))

(glfw:scroll-callback
 (lambda (window x y)
   (set! fov
     (max 1 (min 45 (+ fov y))))))

(define (move-camera dt)
  (if (vector-ref keys glfw:+key-w+)
      (set! camera-position (v+ camera-position (v* camera-front (* dt camera-speed)))))
  (if (vector-ref keys glfw:+key-s+)
      (set! camera-position (v- camera-position (v* camera-front (* dt camera-speed)))))
  (if (vector-ref keys glfw:+key-a+)
      (set! camera-position (v- camera-position
                                (v* (normalize! (cross-product camera-front camera-up)) (* dt camera-speed)))))
  (if (vector-ref keys glfw:+key-d+)
      (set! camera-position (v+ camera-position
                                (v* (normalize! (cross-product camera-front camera-up)) (* dt camera-speed))))))
