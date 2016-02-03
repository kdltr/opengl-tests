(use
  srfi-4
  miscmacros
  lolevel
  (prefix glfw3 glfw:)
  (prefix opengl-glew gl:)
  gl-utils-core
  soil)

(load "pipeline")
(import (prefix pipeline pipeline:))

(define (render)
  (gl:clear-color 0.2 0.3 0.3 1)
  (gl:clear gl:+color-buffer-bit+)
  (gl:use-program program)

  (gl:uniform3f offset-location 0 0 0)

  (gl:active-texture gl:+texture0+)
  (gl:bind-texture gl:+texture-2d+ wood-texture)
  (gl:uniform1i wood-texture-location 0)

  (gl:active-texture gl:+texture1+)
  (gl:bind-texture gl:+texture-2d+ smile-texture)
  (gl:uniform1i smile-texture-location 1)

  (gl:bind-vertex-array vao1)
  (gl:draw-elements gl:+triangles+ 6 gl:+unsigned-int+ #f)
  (gl:bind-vertex-array 0))

(glfw:init)
(define window
  (glfw:make-window 800 600 "Test"
                    resizable: #f
                    context-version-major: 3
                    context-version-minor: 3
                    opengl-forward-compat: #t
                    opengl-profile: glfw:+opengl-core-profile+))
(glfw:make-context-current window)
(print "init")
(gl:init)
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
(gl:viewport 0 0 800 600)
(gl:polygon-mode gl:+front-and-back+ gl:+fill+)
(check-error)

(define program
  (pipeline:make "vertex.glsl" "fragment.glsl"))

(define offset-location
  (gl:get-uniform-location program "offset"))

(define wood-texture-location
  (gl:get-uniform-location program "woodTexture"))

(define smile-texture-location
  (gl:get-uniform-location program "smileTexture"))

(print "VAO1")
(define vbo1 (gen-buffer))
(define vao1 (gen-vertex-array))
(define ebo1 (gen-buffer))
(define vertices1
  ;;    coordinates   color        texture coords
  #f32( 0.5  0.5 0.0  1.0 0.0 0.0  1.0 1.0
        0.5 -0.5 0.0  0.0 1.0 0.0  1.0 0.0
       -0.5 -0.5 0.0  0.0 0.0 1.0  0.0 0.0
       -0.5  0.5 0.0  1.0 1.0 0.0  0.0 1.0
       ))
(define indices1
  #u32(0 1 3
       1 2 3))

(gl:bind-vertex-array vao1)

(gl:bind-buffer gl:+array-buffer+ vbo1)
(gl:buffer-data gl:+array-buffer+ (size vertices1) (->pointer vertices1) gl:+static-draw+)
(gl:bind-buffer gl:+element-array-buffer+ ebo1)
(gl:buffer-data gl:+element-array-buffer+ (size indices1) (->pointer indices1) gl:+static-draw+)

(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 8 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:vertex-attrib-pointer 1 3 gl:+float+ #f (* 8 4) (address->pointer (* 3 4)))
(gl:enable-vertex-attrib-array 1)
(gl:vertex-attrib-pointer 2 2 gl:+float+ #f (* 8 4) (address->pointer (* 6 4)))
(gl:enable-vertex-attrib-array 2)

(gl:bind-vertex-array 0)
(check-error)


(while (not (glfw:window-should-close window))
  (glfw:poll-events)
  (render)
  (glfw:swap-buffers window))

(glfw:terminate)
