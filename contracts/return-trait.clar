(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-public (add-call (math-contract <math>) (x uint) (y uint))
  (contract-call? math-contract add x y)
)

(define-public (add-call-indirect (math-contract <math>) (x uint) (y uint))
  (add-call (math-contract-id math-contract) x y)
)

(define-private (math-contract-id (math-contract <math>))
  math-contract
)
