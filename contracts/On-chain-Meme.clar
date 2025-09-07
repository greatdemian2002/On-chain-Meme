;; On-chain Meme Factory Smart Contract
;; Generates new meme NFTs based on trending data

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-MEME-DATA (err u101))
(define-constant ERR-MEME-ALREADY-EXISTS (err u102))
(define-constant ERR-NFT-NOT-FOUND (err u103))

;; Data Variables
(define-data-var next-meme-id uint u1)
(define-data-var minting-enabled bool true)

;; Data Maps
(define-map meme-data
  { meme-id: uint }
  {
    creator: principal,
    title: (string-ascii 50),
    image-url: (string-ascii 200),
    trending-score: uint,
    created-at: uint
  }
)

(define-map meme-owners
  { meme-id: uint }
  { owner: principal }
)

(define-map trending-keywords
  { keyword: (string-ascii 30) }
  { popularity-score: uint, last-updated: uint }
)

;; NFT Definition
(define-non-fungible-token meme-nft uint)

;; Public Functions

;; Mint a new meme NFT based on trending data
(define-public (mint-meme (title (string-ascii 50)) (image-url (string-ascii 200)) (trending-keyword (string-ascii 30)))
  (let
    (
      (meme-id (var-get next-meme-id))
      (trending-data (map-get? trending-keywords { keyword: trending-keyword }))
      (trending-score (default-to u0 (get popularity-score trending-data)))
    )
    (asserts! (var-get minting-enabled) ERR-NOT-AUTHORIZED)
    (asserts! (> (len title) u0) ERR-INVALID-MEME-DATA)
    (asserts! (> (len image-url) u0) ERR-INVALID-MEME-DATA)

    (try! (nft-mint? meme-nft meme-id tx-sender))

    (map-set meme-data 
      { meme-id: meme-id }
      {
        creator: tx-sender,
        title: title,
        image-url: image-url,
        trending-score: trending-score,
        created-at: block-height
      }
    )

    (map-set meme-owners
      { meme-id: meme-id }
      { owner: tx-sender }
    )

    (var-set next-meme-id (+ meme-id u1))
    (ok meme-id)
  )
)

;; Update trending keyword data (admin function)
(define-public (update-trending-keyword (keyword (string-ascii 30)) (popularity-score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set trending-keywords
      { keyword: keyword }
      { popularity-score: popularity-score, last-updated: block-height }
    )
    (ok true)
  )
)

;; Transfer meme NFT
(define-public (transfer-meme (meme-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (nft-get-owner? meme-nft meme-id)) ERR-NFT-NOT-FOUND)

    (try! (nft-transfer? meme-nft meme-id sender recipient))

    (map-set meme-owners
      { meme-id: meme-id }
      { owner: recipient }
    )
    (ok true)
  )
)

;; Toggle minting (admin function)
(define-public (toggle-minting)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set minting-enabled (not (var-get minting-enabled)))
    (ok (var-get minting-enabled))
  )
)

;; Read-only Functions

;; Get meme data by ID
(define-read-only (get-meme-data (meme-id uint))
  (map-get? meme-data { meme-id: meme-id })
)

;; Get meme owner
(define-read-only (get-meme-owner (meme-id uint))
  (nft-get-owner? meme-nft meme-id)
)

;; Get trending keyword data
(define-read-only (get-trending-keyword (keyword (string-ascii 30)))
  (map-get? trending-keywords { keyword: keyword })
)

;; Get next meme ID
(define-read-only (get-next-meme-id)
  (var-get next-meme-id)
)

;; Check if minting is enabled
(define-read-only (is-minting-enabled)
  (var-get minting-enabled)
)

;; Get total memes created
(define-read-only (get-total-memes)
  (- (var-get next-meme-id) u1)
)