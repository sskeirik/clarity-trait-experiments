(use-trait a-alias 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.use-redefined-and-define-a-trait.a)

(define-public (call-do-that (a-contract <a-alias>))
  (contract-call? a-contract do-it)
)
