(use
  srfi-4
  miscmacros
  (prefix glfw3 glfw:)
  (prefix opengl-glew gl:)
  gl-utils-core)

(define vertex-shader-source #<<EOF
  #version 330 core
  layout (location = 0) in vec3 position;

  void main()
  {
   gl_Position = vec4(position.x, position.y, position.z, 1.0);
  }
EOF
)

(define fragment-shader-source1 #<<EOF
  #version 330 core
  out vec4 color;

  void main()
  {
   color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
  }
EOF
)

(define fragment-shader-source2 #<<EOF
  #version 330 core
  out vec4 color;

  void main()
  {
   color = vec4(0.0f, 1.0f, 1.0f, 1.0f);
  }
EOF
)

(define (render)
  (gl:clear-color 0.2 0.3 0.3 1)
  (gl:clear gl:+color-buffer-bit+)

  ;; first triangle
  (gl:use-program program1)
  (gl:bind-vertex-array vao1)
  (gl:draw-arrays gl:+triangles+ 0 3)

  ;; second triangle
  (gl:use-program program2)
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
(define fragment-shader1
  (make-shader gl:+fragment-shader+ fragment-shader-source1))
(gl:compile-shader fragment-shader1)
(check-error)

(print "fragment shader 2")
(define fragment-shader2
  (make-shader gl:+fragment-shader+ fragment-shader-source2))
(gl:compile-shader fragment-shader2)
(check-error)

(print "program 1")
(define program1
  (make-program (list vertex-shader fragment-shader1)))
(check-error)

(print "program 2")
(define program2
  (make-program (list vertex-shader fragment-shader2)))

(gl:delete-shader vertex-shader)
(gl:delete-shader fragment-shader1)
(gl:delete-shader fragment-shader2)

(print "VAO1")
(define vbo1 (gen-buffer))
(define vao1 (gen-vertex-array))
(define vertices1
  #f32( 0.8  0.5 0.0
        0.8 -0.5 0.0
        0.3 -0.5 0.0))

(gl:bind-vertex-array vao1)
(gl:bind-buffer gl:+array-buffer+ vbo1)
(gl:buffer-data gl:+array-buffer+ (size vertices1) (->pointer vertices1) gl:+static-draw+)
(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 3 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:bind-vertex-array 0)
(check-error)


(print "VAO2")
(define vbo2 (gen-buffer))
(define vao2 (gen-vertex-array))
(define vertices2
  #f32( -0.8  0.5 0.0
        -0.8 -0.5 0.0
        -0.3 -0.5 0.0))

(gl:bind-vertex-array vao2)
(gl:bind-buffer gl:+array-buffer+ vbo2)
(gl:buffer-data gl:+array-buffer+ (size vertices2) (->pointer vertices2) gl:+static-draw+)
(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 3 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:bind-vertex-array 0)
(check-error)


(while (not (glfw:window-should-close window))
  (glfw:poll-events)
  (render)
  (glfw:swap-buffers window))

(glfw:terminate)
