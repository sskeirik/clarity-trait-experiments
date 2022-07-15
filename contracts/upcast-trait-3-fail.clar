(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-private (identity (x principal)) x)

(define-public (upcast (math-contract <math>))
  (ok (identity math-contract))
)
