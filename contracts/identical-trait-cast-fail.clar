(use-trait empty      'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty-trait.empty)
(use-trait empty-copy 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty-trait-copy.empty)

(define-public (use-empty (empty-contract <empty>))
  (ok true)
)

(define-public (use-empty-copy (empty-contract <empty-copy>))
  (use-empty empty-contract)
)
