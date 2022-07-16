(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-public (sub-call (math-contract <math>) (x uint) (y uint))
  (let ((new-math-contract math-contract))
    (contract-call? new-math-contract sub x y)
  )
)
