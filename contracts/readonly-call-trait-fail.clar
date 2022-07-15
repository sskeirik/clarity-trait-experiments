(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-read-only (readonly-sub-call (math-contract <math>) (x uint) (y uint))
  (contract-call? math-contract sub x y)
)
