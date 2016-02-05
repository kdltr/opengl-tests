(use
  srfi-4
  miscmacros
  lolevel
  (prefix glfw3 glfw:)
  (prefix opengl-glew gl:)
  gl-utils-core
  soil
  gl-math)

(define width 1280)
(define height 720)

(load "pipeline")
(import (prefix pipeline pipeline:))

(load "cube")
(load "camera")


(define (render)
  (define view (look-at camera-position (v+ camera-position camera-front) camera-up))
  (define projection (perspective width height 0.1 100 fov))
  (define object-color '(1 0.5 0.31))
  (define light-color (list (+ 0.5 (/ (sin (glfw:get-time)) 2))
                            (+ 0.5 (/ (sin (* 3 (glfw:get-time))) 2))
                            (+ 0.5 (/ (sin (* 5 (glfw:get-time))) 2))))
  (define light-position (m*vector!
                          (y-rotation (/ (glfw:get-time) 10))
                          (make-point 1 -1 -1)))

  (gl:clear-color 0 0 0 1)
  (gl:clear (bitwise-ior gl:+color-buffer-bit+
                         gl:+depth-buffer-bit+))

  (gl:use-program object-program)
  (gl:uniform-matrix4fv object-view-location 1 #f view)
  (gl:uniform-matrix4fv object-projection-location 1 #f projection)
  (apply gl:uniform3f object-color-location object-color)
  (apply gl:uniform3f object-light-color-location light-color)
  (gl:uniform3fv object-light-position-location 1 light-position)
  (gl:uniform3fv object-viewer-position-location 1 camera-position)
  (render-cube object-model-location (rotate-y (glfw:get-time) (rotate-x (glfw:get-time)
                                                                         (3d-scaling 0.5 0.5 0.5))))

  (gl:use-program light-program)
  (gl:uniform-matrix4fv light-view-location 1 #f view)
  (gl:uniform-matrix4fv light-projection-location 1 #f projection)
  (apply gl:uniform3f light-light-color-location light-color)
  (render-cube light-model-location (translate light-position (3d-scaling 0.1 0.1 0.1)))

  )

(glfw:init)
(define window
  (glfw:make-window width height "Test"
                    resizable: #f
                    context-version-major: 3
                    context-version-minor: 3
                    opengl-forward-compat: #t
                    opengl-profile: glfw:+opengl-core-profile+))
(glfw:set-input-mode window glfw:+cursor+ glfw:+cursor-disabled+)
(glfw:make-context-current window)
(print "init")
(gl:init)
(gl:enable gl:+depth-test+)
(check-error)
(define cube (make-cube))

(print "viewport and draw mode")
(gl:viewport 0 0 width height)
(gl:polygon-mode gl:+front-and-back+ gl:+fill+)
(check-error)

(define object-program
  (pipeline:make "vertex.glsl" "fragment.glsl"))
(define object-model-location
  (gl:get-uniform-location object-program "model"))
(define object-view-location
  (gl:get-uniform-location object-program "view"))
(define object-projection-location
  (gl:get-uniform-location object-program "projection"))
(define object-color-location
  (gl:get-uniform-location object-program "objectColor"))
(define object-light-color-location
  (gl:get-uniform-location object-program "lightColor"))
(define object-light-position-location
  (gl:get-uniform-location object-program "lightPosition"))
(define object-viewer-position-location
  (gl:get-uniform-location object-program "viewerPosition"))

(define light-program
  (pipeline:make "vertex.glsl" "light-fragment.glsl"))
(define light-model-location
  (gl:get-uniform-location light-program "model"))
(define light-view-location
  (gl:get-uniform-location light-program "view"))
(define light-projection-location
  (gl:get-uniform-location light-program "projection"))
(define light-light-color-location
  (gl:get-uniform-location light-program "lightColor"))


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
