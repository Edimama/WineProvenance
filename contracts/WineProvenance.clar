;; WineProvenance - Specialty wine provenance tracking and sommelier verification system
(define-map wine-bottles uint {
  vintner: principal,
  wine-varietal: (string-utf8 64),
  vineyard-details: (string-utf8 256),
  vintage-year: uint,
  terroir-region: (string-utf8 64),
  quality-authenticated: bool
})

(define-map vintner-cellars principal (list 100 uint))
(define-map wine-sommeliers principal bool)
(define-data-var bottle-catalog-id uint u0)

;; Error codes
(define-constant err-not-vintner (err u800))
(define-constant err-not-sommelier (err u801))
(define-constant err-bottle-not-found (err u802))
(define-constant err-permission-restricted (err u403))
(define-constant err-cellar-limit-exceeded (err u804))
(define-constant err-invalid-sommelier-principal (err u805))
(define-constant err-invalid-wine-varietal (err u806))
(define-constant err-invalid-vineyard-details (err u807))
(define-constant err-invalid-vintage-year (err u808))
(define-constant err-invalid-terroir-region (err u809))
(define-constant err-invalid-bottle-catalog-id (err u810))

;; Contract steward for wine authentication
(define-constant contract-steward tx-sender)

;; Register wine sommelier
(define-public (register-wine-sommelier (sommelier principal))
  (begin
    ;; Check if sender is contract steward
    (asserts! (is-eq tx-sender contract-steward) err-permission-restricted)
    
    ;; Validate sommelier principal
    (asserts! (not (is-eq sommelier 'SP000000000000000000002Q6VF78)) err-invalid-sommelier-principal)
    
    ;; Add sommelier to registry
    (ok (map-set wine-sommeliers sommelier true))
  )
)

;; Register wine bottle
(define-public (register-wine-bottle 
  (wine-varietal (string-utf8 64)) 
  (vineyard-details (string-utf8 256)) 
  (vintage-year uint) 
  (terroir-region (string-utf8 64)))
  (let
    ((bottle-id (var-get bottle-catalog-id))
     (vintner tx-sender)
     (current-cellar (default-to (list) (map-get? vintner-cellars vintner))))
    
    ;; Validate inputs
    (asserts! (> (len wine-varietal) u0) err-invalid-wine-varietal)
    (asserts! (> (len vineyard-details) u0) err-invalid-vineyard-details)
    (asserts! (and (>= vintage-year u1900) (<= vintage-year u2030)) err-invalid-vintage-year)
    (asserts! (> (len terroir-region) u0) err-invalid-terroir-region)
    
    ;; Check cellar registration limit
    (asserts! (< (len current-cellar) u100) err-cellar-limit-exceeded)
    
    ;; Store wine bottle information
    (map-set wine-bottles bottle-id {
      vintner: vintner,
      wine-varietal: wine-varietal,
      vineyard-details: vineyard-details,
      vintage-year: vintage-year,
      terroir-region: terroir-region,
      quality-authenticated: false
    })
    
    ;; Update vintner's cellar list
    (let 
      ((updated-cellar-list (unwrap-panic (as-max-len? (concat (list bottle-id) current-cellar) u100))))
      (map-set vintner-cellars vintner updated-cellar-list)
    )
    
    ;; Increment bottle catalog ID
    (var-set bottle-catalog-id (+ bottle-id u1))
    
    (ok bottle-id)))

;; Authenticate wine quality
(define-public (authenticate-wine-quality (bottle-id uint))
  (begin
    ;; Validate bottle ID
    (asserts! (< bottle-id (var-get bottle-catalog-id)) err-invalid-bottle-catalog-id)
    
    (let
      ((wine-bottle (unwrap! (map-get? wine-bottles bottle-id) err-bottle-not-found)))
      
      ;; Check if sender is wine sommelier
      (asserts! (default-to false (map-get? wine-sommeliers tx-sender)) err-not-sommelier)
      
      ;; Update quality authentication status
      (ok (map-set wine-bottles bottle-id (merge wine-bottle {quality-authenticated: true})))
    )
  )
)

;; Get wine bottle details
(define-read-only (get-wine-bottle (bottle-id uint))
  (map-get? wine-bottles bottle-id))

;; Get vintner's cellar
(define-read-only (get-vintner-cellar (vintner principal))
  (default-to (list) (map-get? vintner-cellars vintner)))

;; Check wine sommelier status
(define-read-only (is-wine-sommelier (address principal))
  (default-to false (map-get? wine-sommeliers address)))