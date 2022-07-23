(use-trait math-alias 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.use-math-trait.math-alias)

(define-public (add-call (math-contract <math-alias>) (x uint) (y uint))
  (contract-call? math-contract add x y)
)

(define-public (sub-call (math-contract <math-alias>) (x uint) (y uint))
  (contract-call? math-contract sub x y)
)
