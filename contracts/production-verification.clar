;; production-verification.clar
;; This contract validates legitimate dance projects

(define-data-var admin principal tx-sender)

(define-map verified-productions
  { production-id: uint }
  {
    name: (string-utf8 100),
    director: principal,
    description: (string-utf8 500),
    start-date: uint,
    end-date: uint,
    verified: bool
  }
)

(define-read-only (get-admin)
  (var-get admin)
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)

(define-read-only (get-production (production-id uint))
  (map-get? verified-productions { production-id: production-id })
)

(define-public (register-production
    (production-id uint)
    (name (string-utf8 100))
    (description (string-utf8 500))
    (start-date uint)
    (end-date uint))
  (begin
    (asserts! (> end-date start-date) (err u101))
    (asserts! (is-none (get-production production-id)) (err u102))
    (ok (map-set verified-productions
      { production-id: production-id }
      {
        name: name,
        director: tx-sender,
        description: description,
        start-date: start-date,
        end-date: end-date,
        verified: false
      }
    ))
  )
)

(define-public (verify-production (production-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (get-production production-id)) (err u103))
    (let ((production (unwrap-panic (get-production production-id))))
      (ok (map-set verified-productions
        { production-id: production-id }
        (merge production { verified: true })
      ))
    )
  )
)

(define-public (revoke-verification (production-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (get-production production-id)) (err u103))
    (let ((production (unwrap-panic (get-production production-id))))
      (ok (map-set verified-productions
        { production-id: production-id }
        (merge production { verified: false })
      ))
    )
  )
)
