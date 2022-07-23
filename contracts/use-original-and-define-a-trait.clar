(use-trait a-alias 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.a-trait.a)

(define-trait a (
  (do-that () (response bool bool))
))

(define-public (call-do-it (a-contract <a-alias>))
  (contract-call? a-contract do-it)
)
