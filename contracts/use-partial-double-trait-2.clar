(use-trait double 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.double-trait.double-method)

(define-public (call-double (double <double>))
  (contract-call? double foo true)
)
