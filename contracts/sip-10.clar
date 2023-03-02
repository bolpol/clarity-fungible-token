;; title: sip-10
;; version:
;; summary:
;; description:

;; traits
;;

;;(impl-trait .sip-10-trait.sip-010-trait)


;; token definitions
;;

;; constants
;;

(define-fungible-token token)

(define-constant TOKEN_DECIMALS 6)
(define-constant TOKEN_NAME "Token name")
(define-constant TOKEN_SYMBOL "TOKEN")

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

;; data vars
;;

(define-data-var contract-owner principal tx-sender)
(define-data-var token_uri (string-utf8 256) u"")

;; data maps
;;

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

(define-public (set-token-uri (uri (string-utf8 256)))
	(begin
	    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_ONLY_OWNER)
		(var-set token_uri uri)
		(ok true)
	)
)

(define-public (set-new-owner (account principal))
	(begin
	    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_ONLY_OWNER)
		(var-set contract-owner account)
		(ok true)
	)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) ERR_ONLY_TOKEN_OWNER)
		(try! (ft-transfer? token amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

;; read only functions
;;

(define-read-only (get-name)
	(ok TOKEN_NAME)
)

(define-read-only (get-symbol)
	(ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
	(ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (account principal))
	(ok (ft-get-balance token account))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply token))
)

(define-read-only (get-token-uri)
	(ok (var-get token_uri))
)

;; private functions
;;
