(define (make-cube)
  (let ((vbo (gen-buffer))
        (ebo (gen-buffer))
        (vao (gen-vertex-array))
        (vertices
         (f32vector
          -0.5 -0.5 -0.5  0.0  0.0 -1.0
          0.5 -0.5 -0.5  0.0  0.0 -1.0
          0.5  0.5 -0.5  0.0  0.0 -1.0
          0.5  0.5 -0.5  0.0  0.0 -1.0
          -0.5  0.5 -0.5  0.0  0.0 -1.0
          -0.5 -0.5 -0.5  0.0  0.0 -1.0

          -0.5 -0.5  0.5  0.0  0.0 1.0
          0.5 -0.5  0.5  0.0  0.0 1.0
          0.5  0.5  0.5  0.0  0.0 1.0
          0.5  0.5  0.5  0.0  0.0 1.0
          -0.5  0.5  0.5  0.0  0.0 1.0
          -0.5 -0.5  0.5  0.0  0.0 1.0

          -0.5  0.5  0.5 -1.0  0.0  0.0
          -0.5  0.5 -0.5 -1.0  0.0  0.0
          -0.5 -0.5 -0.5 -1.0  0.0  0.0
          -0.5 -0.5 -0.5 -1.0  0.0  0.0
          -0.5 -0.5  0.5 -1.0  0.0  0.0
          -0.5  0.5  0.5 -1.0  0.0  0.0

          0.5  0.5  0.5  1.0  0.0  0.0
          0.5  0.5 -0.5  1.0  0.0  0.0
          0.5 -0.5 -0.5  1.0  0.0  0.0
          0.5 -0.5 -0.5  1.0  0.0  0.0
          0.5 -0.5  0.5  1.0  0.0  0.0
          0.5  0.5  0.5  1.0  0.0  0.0

          -0.5 -0.5 -0.5  0.0 -1.0  0.0
          0.5 -0.5 -0.5  0.0 -1.0  0.0
          0.5 -0.5  0.5  0.0 -1.0  0.0
          0.5 -0.5  0.5  0.0 -1.0  0.0
          -0.5 -0.5  0.5  0.0 -1.0  0.0
          -0.5 -0.5 -0.5  0.0 -1.0  0.0

          -0.5  0.5 -0.5  0.0  1.0  0.0
          0.5  0.5 -0.5  0.0  1.0  0.0
          0.5  0.5  0.5  0.0  1.0  0.0
          0.5  0.5  0.5  0.0  1.0  0.0
          -0.5  0.5  0.5  0.0  1.0  0.0
          -0.5  0.5 -0.5  0.0  1.0  0.0
          )))

    (gl:bind-vertex-array vao)
    (gl:bind-buffer gl:+array-buffer+ vbo)
    (gl:buffer-data gl:+array-buffer+ (size vertices) (->pointer vertices) gl:+static-draw+)
    (gl:vertex-attrib-pointer 0 3 gl:+float+ #f (* 6 4) #f)
    (gl:enable-vertex-attrib-array 0)
    (gl:vertex-attrib-pointer 1 3 gl:+float+ #f (* 6 4) (address->pointer (* 3 4)))
    (gl:enable-vertex-attrib-array 1)
    (gl:bind-vertex-array 0)
    vao))

(define (render-cube model-location model-mat)
  (gl:bind-vertex-array cube)
  (gl:uniform-matrix4fv model-location 1 #f model-mat)
  (gl:draw-arrays gl:+triangles+ 0 36))
