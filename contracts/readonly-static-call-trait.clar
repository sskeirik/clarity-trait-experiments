(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-public (sub-call (math-contract <math>) (x uint) (y uint))
  (contract-call? math-contract sub x y)
)

(define-read-only (static-sub-call (x uint) (y uint))
  (sub-call 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.impl-math-trait x y)
)
