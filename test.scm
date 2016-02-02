(use
  srfi-4
  miscmacros
  (prefix glfw3 glfw:)
  (prefix opengl-glew gl:)
  gl-utils-core)

(define vertices
  #f32( 0.5  0.5 0.0
        0.5 -0.5 0.0
       -0.5 -0.5 0.0
       -0.5  0.5 0.0))

(define indices
  #u32(0 1 3
       1 2 3))

(define vertex-shader-source #<<EOF
  #version 330 core
  layout (location = 0) in vec3 position;

  void main()
  {
   gl_Position = vec4(position.x, position.y, position.z, 1.0);
  }
EOF
)

(define fragment-shader-source #<<EOF
  #version 330 core
  out vec4 color;

  void main()
  {
   color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
  }
EOF
)

(define (render)
  (gl:clear-color 0.2 0.3 0.3 1)
  (gl:clear gl:+color-buffer-bit+)
  (gl:use-program program)
  (gl:bind-vertex-array vao)
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

(print "viewport and draw mode")
(gl:viewport 0 0 800 600)
(gl:polygon-mode gl:+front-and-back+ gl:+fill+)
(check-error)

(print "vertex shader")
(define vertex-shader
  (make-shader gl:+vertex-shader+ vertex-shader-source))
(gl:compile-shader vertex-shader)
(check-error)

(print "fragment shader")
(define fragment-shader
  (make-shader gl:+fragment-shader+ fragment-shader-source))
(gl:compile-shader fragment-shader)
(check-error)

(print "program")
(define program
  (make-program (list vertex-shader fragment-shader)))
(gl:use-program program)
(check-error)

(gl:delete-shader vertex-shader)
(gl:delete-shader fragment-shader)

(print "VAO")
(define vbo (gen-buffer))
(define ebo (gen-buffer))
(define vao (gen-vertex-array))

(gl:bind-vertex-array vao)
(gl:bind-buffer gl:+array-buffer+ vbo)
(gl:buffer-data gl:+array-buffer+ (size vertices) (->pointer vertices) gl:+static-draw+)
(gl:bind-buffer gl:+element-array-buffer+ ebo)
(gl:buffer-data gl:+element-array-buffer+ (size indices) (->pointer indices) gl:+static-draw+)
(gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 3 4) #f)
(gl:enable-vertex-attrib-array 0)
(gl:bind-vertex-array 0)
(check-error)

(while (not (glfw:window-should-close window))
  (glfw:poll-events)
  (render)
  (glfw:swap-buffers window))

(glfw:terminate)
