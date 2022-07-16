(define-read-only (baz)
  (ok true)
)

(define-read-only (bar)
  (baz)
)

(define-read-only (foo)
  (bar)
)
