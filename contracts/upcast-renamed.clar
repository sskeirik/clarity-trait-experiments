(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-data-var trait-var principal tx-sender)

(define-public (store-and-read-trait (math-contract <math>))
  (let ((renamed-math-contract math-contract))
    (var-set trait-var renamed-math-contract)
    (var-get trait-var)
  )
)
