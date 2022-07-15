(use-trait math 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait.math)

(define-map trait-map { id: uint } { val: principal } )

(define-public (upcast (math-contract <math>))
  (begin
    (map-set trait-map { id: u5 } { val: math-contract } )
    (ok (map-get? trait-map { id: u5 } ))
  )
)
