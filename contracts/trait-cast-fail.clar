(use-trait empty 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty-trait.empty)
(use-trait math  'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-public (use-empty (empty-contract <empty>))
  (ok true)
)

(define-public (use-math (math-contract <math>))
  (use-empty math-contract)
)
