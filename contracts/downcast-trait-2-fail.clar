(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-data-var principal-value principal 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.impl-math-trait)

(define-public (use (math-contract <math>))
  (ok true)
)

(define-public (downcast)
  (use (var-get principal-value))
)
