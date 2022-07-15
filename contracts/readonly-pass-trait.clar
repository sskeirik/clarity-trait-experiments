(use-trait empty 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty-trait.empty)

(define-read-only (use-empty (empty-contract <empty>))
  (ok true)
)

(define-read-only (use-empty-2 (empty-contract <empty>))
  (use-empty empty-contract)
)
