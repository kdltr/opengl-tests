(module pipeline
    (make)

  (import scheme chicken)
  (use opengl-glew gl-utils-core extras)

  (define (make vertex-path fragment-path)
    (let* ((vertex-source (with-input-from-file vertex-path read-string))
           (fragment-source (with-input-from-file fragment-path read-string))
           (vertex-id (make-shader +vertex-shader+ vertex-source))
           (fragment-id (make-shader +fragment-shader+ fragment-source))
           (program (make-program (list vertex-id fragment-id))))
      (check-error)
      (delete-shader vertex-id)
      (delete-shader fragment-id)
      program))
  )
