;; title: erc20
;; version:
;; summary:
;; description:

;; PARTIALLY COPIED from https://github.com/stacks-network/clarity-js-sdk/blob/master/packages/clarity-tutorials/contracts/tokens/fungible-token.clar

;; traits
;;

(use-trait erc20-trait .erc20-trait.erc20-trait)
(impl-trait .erc20-trait.erc20-trait)


;; token definitions
;;

;; constants
;;

(define-fungible-token token)

(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_NAME "Token name")
(define-constant TOKEN_SYMBOL "TOKEN")

(define-constant MIN_UINT u0)
(define-constant ZERO_ADDRESS tx-sender)

;; errors
;; sender does not have enough balance
(define-constant ERR_NOT_ENOUGH_BALANCE (err u1))
;; sender and recipient are the same principal
(define-constant ERR_SELF_TRANSFER (err u2))
;; amount is non-positive
(define-constant ERR_NON_POSITIVE_AMOUNT (err u3))
;; sender is not the same as tx-sender
(define-constant ERR_WRONG_SENDER (err u4))

(define-constant ERR_ONLY_OWNER (err u100))
(define-constant ERR_ONLY_TOKEN_OWNER (err u101))

(define-constant ERR_INCREASE_ALLOWANCE (err u2001))
(define-constant ERR_DECREASE_ALLOWANCE (err u2002))
(define-constant ERR_ALLOWANCE_NOT_ENOUGH (err u2003))
(define-constant ERR_TRANSFER_FROM_FAILED (err u2004))



;; data vars
;;

(define-data-var contract-owner principal tx-sender)
(define-data-var sender_temp principal ZERO_ADDRESS)
(define-data-var allowance_temp uint u0)

;; data maps
;;

(define-map allowances
  { spender: principal, owner: principal }
  { allowance: uint }
)

;; public functions
;;

(define-public (mint (amount uint) (recipient principal))
	(begin
	    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_ONLY_OWNER)
		(ft-mint? token amount recipient)
	)
)

(define-public (burn (amount uint))
	(begin
		(ft-burn? token amount tx-sender)
	)
)

(define-public (set-new-owner (account principal))
	(begin
	    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_ONLY_OWNER)
		(var-set contract-owner account)
		(ok true)
	)
)

(define-public (transfer (recipient principal) (amount uint))
	(begin
	    (var-set sender_temp tx-sender)

		(try! (ft-transfer? token amount (var-get sender_temp) recipient))

		(var-set sender_temp ZERO_ADDRESS)
		(ok true)
	)
)

(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
    (begin
        (var-set allowance_temp (allowance-of tx-sender owner))

        (asserts! (< amount (var-get allowance_temp))
            ERR_ALLOWANCE_NOT_ENOUGH)
        (asserts! (is-ok (ft-transfer? token amount owner recipient))
            ERR_TRANSFER_FROM_FAILED)
        (asserts! (decrease-allowance tx-sender owner amount)
            ERR_DECREASE_ALLOWANCE)

        (var-set allowance_temp u0)
        (ok true)
    )
)

(define-public (approve (spender principal) (amount uint))
    (begin
        (asserts! (increase-allowance spender tx-sender amount) ERR_INCREASE_ALLOWANCE)
        (ok true)
    )
)

;; read only functions
;;

(define-read-only (name)
	(ok TOKEN_NAME)
)

(define-read-only (symbol)
	(ok TOKEN_SYMBOL)
)

(define-read-only (decimals)
	(ok TOKEN_DECIMALS)
)

(define-read-only (balance-of (account principal))
	(ok (ft-get-balance token account))
)

(define-read-only (total-supply)
	(ok (ft-get-supply token))
)

(define-read-only (allowance (spender principal) (owner principal))
  (ok (allowance-of spender owner))
)

;; private functions
;;

(define-private (allowance-of (spender principal) (owner principal))
  (begin
    (print
      (map-get? allowances { spender: spender, owner: owner }))
    (print
      (get allowance
        (map-get? allowances { spender: spender, owner: owner })
      )
    )
    (default-to u0
      (get allowance
        (map-get? allowances { spender: spender, owner: owner })
      )
    )
  )
)

;; Decrease allowance of a specified spender.
(define-private (decrease-allowance (spender principal) (owner principal) (amount uint))
  (let ((allowance (allowance-of spender owner)))
    (if (or (> amount allowance) (<= amount MIN_UINT))
      true
      (begin
        (map-set allowances
          { spender: spender, owner: owner }
          { allowance: (- allowance amount) }
        )
        true
      )
    )
  )
)

;; Internal - Increase allowance of a specified spender.
(define-private (increase-allowance (spender principal) (owner principal) (amount uint))
  (let ((allowance (allowance-of spender owner)))
    (if (<= amount MIN_UINT)
      false
      (begin
        (print (tuple (spender spender) (owner owner)))
        (print (map-set allowances
          { spender: spender, owner: owner }
          { allowance: (+ allowance amount) }
          )
        )
        true
      )
    )
  )
)
