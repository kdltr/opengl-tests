(use
  srfi-4
  miscmacros
  lolevel
  (prefix glfw3 glfw:)
  (prefix opengl-glew gl:)
  gl-utils-core
  soil
  gl-math)

(load "pipeline")
(import (prefix pipeline pipeline:))

(define width 800)
(define height 600)


(define camera-position (make-point 0 0 3))
(define camera-front (make-point 0 0 -1))
(define camera-up (make-point 0 1 0))
(define camera-speed 30)


(define keys (make-vector 1024 #f))
(glfw:key-callback
 (lambda (window key scancode action mods)
   (print (list key: key action: action))
   (vector-set! keys key
                (select action
                  ((glfw:+press+) #t)
                  ((glfw:+release+) #f)
                  (else (vector-ref keys key))))))

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

(define cubes-pos
  '((0 0 0)
    (2 5 -15)
    (-1.5 -2.2 -2.5)
    (-3.8 -2 -12.3)
    (2.4 -0.5 -3.5)
    (-1.7 3 -7.5)
    (1.3 -2 -2.5)
    (1.5 2 -2.5)
    (1.5 0.5 -1.5)
    (-1.3 1 -1.5)))

(define (render-cube model-mat)
  (gl:bind-vertex-array vao1)
  (gl:uniform-matrix4fv model-location 1 #f model-mat)
  (gl:draw-arrays gl:+triangles+ 0 36))

(define (render)
  (define view (look-at camera-position (v+ camera-position camera-front) camera-up))
  (define projection (perspective width height 0.1 100 45))

  (gl:clear-color 0.2 0.3 0.3 1)
  (gl:clear (bitwise-ior gl:+color-buffer-bit+
                         gl:+depth-buffer-bit+))
  (gl:use-program program)

  (gl:uniform1f mix-factor-location (+ 0.5 (/ (sin (glfw:get-time)) 2)))
  (gl:active-texture gl:+texture0+)
  (gl:bind-texture gl:+texture-2d+ wood-texture)
  (gl:uniform1i wood-texture-location 0)
  (gl:active-texture gl:+texture1+)
  (gl:bind-texture gl:+texture-2d+ smile-texture)
  (gl:uniform1i smile-texture-location 1)

  (gl:uniform-matrix4fv view-location 1 #f view)
  (gl:uniform-matrix4fv projection-location 1 #f projection)

  (for-each
   (lambda (pos n)
     (render-cube (m*
                   (translation (apply make-point pos))
                   (axis-angle-rotation (make-point 1 0.3 0.5)
                                        (if (zero? (modulo n 3))
                                            (glfw:get-time)
                                            (* 20 n))))))
   cubes-pos
   (iota (length cubes-pos))))

(glfw:init)
(define window
  (glfw:make-window width height "Test"
                    resizable: #f
                    context-version-major: 3
                    context-version-minor: 3
                    opengl-forward-compat: #t
                    opengl-profile: glfw:+opengl-core-profile+))
(glfw:make-context-current window)
(print "init")
(gl:init)
(gl:enable gl:+depth-test+)
(check-error)

(define wood-texture
  (load-ogl-texture "container.jpg"
                    force-channels/rgb
                    texture-id/create-new-id
                    texture/mipmaps))

(define smile-texture
  (load-ogl-texture "awesomeface.png"
                    force-channels/rgb
                    texture-id/create-new-id
                    (bitwise-ior texture/mipmaps
                                 texture/invert-y)))

(print "viewport and draw mode")
(gl:viewport 0 0 width height)
(gl:polygon-mode gl:+front-and-back+ gl:+fill+)
(check-error)

(define program
  (pipeline:make "vertex.glsl" "fragment.glsl"))

(define model-location
  (gl:get-uniform-location program "model"))

(define view-location
  (gl:get-uniform-location program "view"))

(define projection-location
  (gl:get-uniform-location program "projection"))

(define mix-factor-location
  (gl:get-uniform-location program "mixFactor"))

(define wood-texture-location
  (gl:get-uniform-location program "woodTexture"))

(define smile-texture-location
  (gl:get-uniform-location program "smileTexture"))

(print "VAO1")
(define vbo1 (gen-buffer))
(define vao1 (gen-vertex-array))
(define ebo1 (gen-buffer))
(define vertices1
  #f32(
    -0.5 -0.5 -0.5  0.0 0.0
     0.5 -0.5 -0.5  1.0 0.0
     0.5  0.5 -0.5  1.0 1.0
     0.5  0.5 -0.5  1.0 1.0
    -0.5  0.5 -0.5  0.0 1.0
    -0.5 -0.5 -0.5  0.0 0.0

    -0.5 -0.5  0.5  0.0 0.0
     0.5 -0.5  0.5  1.0 0.0
     0.5  0.5  0.5  1.0 1.0
     0.5  0.5  0.5  1.0 1.0
    -0.5  0.5  0.5  0.0 1.0
    -0.5 -0.5  0.5  0.0 0.0

    -0.5  0.5  0.5  1.0 0.0
    -0.5  0.5 -0.5  1.0 1.0
    -0.5 -0.5 -0.5  0.0 1.0
    -0.5 -0.5 -0.5  0.0 1.0
    -0.5 -0.5  0.5  0.0 0.0
    -0.5  0.5  0.5  1.0 0.0

     0.5  0.5  0.5  1.0 0.0
     0.5  0.5 -0.5  1.0 1.0
     0.5 -0.5 -0.5  0.0 1.0
     0.5 -0.5 -0.5  0.0 1.0
     0.5 -0.5  0.5  0.0 0.0
     0.5  0.5  0.5  1.0 0.0

    -0.5 -0.5 -0.5  0.0 1.0
     0.5 -0.5 -0.5  1.0 1.0
     0.5 -0.5  0.5  1.0 0.0
     0.5 -0.5  0.5  1.0 0.0
    -0.5 -0.5  0.5  0.0 0.0
    -0.5 -0.5 -0.5  0.0 1.0

    -0.5  0.5 -0.5  0.0 1.0
     0.5  0.5 -0.5  1.0 1.0
     0.5  0.5  0.5  1.0 0.0
     0.5  0.5  0.5  1.0 0.0
    -0.5  0.5  0.5  0.0 0.0
    -0.5  0.5 -0.5  0.0 1.0))

(gl:bind-vertex-array vao1)

(gl:bind-buffer gl:+array-buffer+ vbo1)
(gl:buffer-data gl:+array-buffer+ (size vertices1) (->pointer vertices1) gl:+static-draw+)

(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 5 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:vertex-attrib-pointer 1 2 gl:+float+ #f (* 5 4) (address->pointer (* 3 4)))
(gl:enable-vertex-attrib-array 1)

(gl:bind-vertex-array 0)
(check-error)

(define last-clock (glfw:get-time))
(while (not (glfw:window-should-close window))
  (glfw:poll-events)
  (let* ((clock (glfw:get-time))
         (dt (- clock last-clock)))
    (set! last-clock clock)
    (move-camera dt))
  (render)
  (glfw:swap-buffers window))

(glfw:terminate)
