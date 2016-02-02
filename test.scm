(use
  srfi-4
  miscmacros
  lolevel
  (prefix glfw3 glfw:)
  (prefix opengl-glew gl:)
  gl-utils-core)

(define vertex-shader-source #<<EOF
  #version 330 core
  layout (location = 0) in vec3 position;
  layout (location = 1) in vec3 color;
  out vec3 fragColor;

  void main()
  {
   gl_Position = vec4(position, 1.0);
   fragColor = color;
  }
EOF
)

(define fragment-shader-source #<<EOF
  #version 330 core
  in vec3 fragColor;
  out vec4 color;

  void main()
  {
   color = vec4(fragColor, 1.0f);
  }
EOF
)

(define (render)
  (gl:clear-color 0.2 0.3 0.3 1)
  (gl:clear gl:+color-buffer-bit+)
  (gl:use-program program)

  ;; first triangle
  (gl:bind-vertex-array vao1)
  (gl:draw-arrays gl:+triangles+ 0 3)

  ;; second triangle
  (gl:bind-vertex-array vao2)
  (gl:draw-arrays gl:+triangles+ 0 3)
)

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

(print "viewport and draw mode")
(gl:viewport 0 0 800 600)
(gl:polygon-mode gl:+front-and-back+ gl:+fill+)
(check-error)

(print "vertex shader")
(define vertex-shader
  (make-shader gl:+vertex-shader+ vertex-shader-source))
(gl:compile-shader vertex-shader)
(check-error)

(print "fragment shader 1")
(define fragment-shader
  (make-shader gl:+fragment-shader+ fragment-shader-source))
(gl:compile-shader fragment-shader)
(check-error)

(print "program 1")
(define program
  (make-program (list vertex-shader fragment-shader)))
(check-error)

(define color-location
  (gl:get-uniform-location program "outColor"))

(gl:delete-shader vertex-shader)
(gl:delete-shader fragment-shader)

(print "VAO1")
(define vbo1 (gen-buffer))
(define vao1 (gen-vertex-array))
(define vertices1
  #f32( 0.8  0.5 0.0  1.0 0.0 0.0
        0.8 -0.5 0.0  0.0 1.0 0.0
        0.3 -0.5 0.0  0.0 0.0 1.0))

(gl:bind-vertex-array vao1)
(gl:bind-buffer gl:+array-buffer+ vbo1)
(gl:buffer-data gl:+array-buffer+ (size vertices1) (->pointer vertices1) gl:+static-draw+)
(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 6 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:vertex-attrib-pointer 1 3 gl:+float+ #f (* 6 4) (address->pointer (* 3 4)))
(gl:enable-vertex-attrib-array 1)
(gl:bind-vertex-array 0)
(check-error)


(print "VAO2")
(define vbo2 (gen-buffer))
(define vao2 (gen-vertex-array))
(define vertices2
  #f32( -0.8  0.5 0.0  0.3 0.5 0.5
        -0.8 -0.5 0.0  0.3 0.5 0.5
        -0.3 -0.5 0.0  0.3 0.5 0.5))

(gl:bind-vertex-array vao2)
(gl:bind-buffer gl:+array-buffer+ vbo2)
(gl:buffer-data gl:+array-buffer+ (size vertices2) (->pointer vertices2) gl:+static-draw+)
(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 3 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:vertex-attrib-pointer 1 3 gl:+float+ #f (* 6 4) (address->pointer (* 3 4)))
(gl:enable-vertex-attrib-array 1)
(gl:bind-vertex-array 0)
(check-error)


(while (not (glfw:window-should-close window))
  (glfw:poll-events)
  (render)
  (glfw:swap-buffers window))

(glfw:terminate)
