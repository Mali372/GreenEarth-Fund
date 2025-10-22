(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROJECT-NOT-FOUND (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-PROJECT-INACTIVE (err u103))
(define-constant ERR-FUNDING-COMPLETE (err u104))
(define-constant ERR-MILESTONE-NOT-FOUND (err u105))
(define-constant ERR-ALREADY-VERIFIED (err u106))
(define-constant ERR-NOT-FUNDED (err u107))
(define-constant ERR-INSUFFICIENT-FUNDS (err u108))
(define-constant ERR-INVALID-CATEGORY (err u109))

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-FUNDING-GOAL u10000)
(define-constant MAX-FUNDING-GOAL u100000000)
(define-constant PLATFORM-FEE-RATE u30)
(define-constant IMPACT-MULTIPLIER u100)

(define-data-var project-counter uint u0)
(define-data-var milestone-counter uint u0)
(define-data-var total-projects uint u0)
(define-data-var total-funded uint u0)
(define-data-var platform-treasury uint u0)
(define-data-var carbon-offset-total uint u0)

(define-map projects
  uint
  {
    creator: principal,
    title: (string-ascii 256),
    description: (string-ascii 512),
    category: uint,
    funding-goal: uint,
    current-funding: uint,
    deadline: uint,
    is-active: bool,
    is-funded: bool,
    created-at: uint,
    carbon-offset: uint,
    impact-score: uint
  }
)

(define-map project-funders
  {project-id: uint, funder: principal}
  {
    amount: uint,
    funded-at: uint,
    refunded: bool
  }
)

(define-map milestones
  uint
  {
    project-id: uint,
    title: (string-ascii 256),
    target-amount: uint,
    is-verified: bool,
    verified-at: uint,
    verifier: principal,
    impact-data: (string-ascii 256)
  }
)

(define-map project-milestones
  uint
  (list 20 uint)
)

(define-map funder-projects
  principal
  (list 100 uint)
)

(define-map categories
  uint
  (string-ascii 128)
)

(define-map verifiers
  principal
  {
    is-authorized: bool,
    verifications-count: uint,
    joined-at: uint
  }
)

(define-read-only (get-project (project-id uint))
  (map-get? projects project-id)
)

(define-read-only (get-project-funding (project-id uint) (funder principal))
  (map-get? project-funders {project-id: project-id, funder: funder})
)

(define-read-only (get-milestone (milestone-id uint))
  (map-get? milestones milestone-id)
)

(define-read-only (get-project-milestones (project-id uint))
  (default-to (list) (map-get? project-milestones project-id))
)

(define-read-only (get-funder-projects (funder principal))
  (default-to (list) (map-get? funder-projects funder))
)

(define-read-only (get-category (category-id uint))
  (map-get? categories category-id)
)

(define-read-only (get-verifier (verifier principal))
  (map-get? verifiers verifier)
)

(define-read-only (get-platform-stats)
  {
    total-projects: (var-get total-projects),
    total-funded: (var-get total-funded),
    treasury: (var-get platform-treasury),
    carbon-offset: (var-get carbon-offset-total),
    active-projects: (len (get-active-projects))
  }
)

(define-read-only (calculate-platform-fee (amount uint))
  (/ (* amount PLATFORM-FEE-RATE) u1000)
)

(define-read-only (is-project-expired (project-id uint))
  (match (get-project project-id)
    project-data (> stacks-block-height (get deadline project-data))
    true
  )
)

(define-private (add-funder-project (funder principal) (project-id uint))
  (let (
    (current-projects (get-funder-projects funder))
  )
    (map-set funder-projects funder
      (unwrap-panic (as-max-len? (append current-projects project-id) u100))
    )
  )
)

(define-private (add-milestone-to-project (project-id uint) (milestone-id uint))
  (let (
    (current-milestones (get-project-milestones project-id))
  )
    (map-set project-milestones project-id
      (unwrap-panic (as-max-len? (append current-milestones milestone-id) u20))
    )
  )
)

(define-public (initialize-categories)
  (begin
    (map-set categories u1 "Renewable Energy")
    (map-set categories u2 "Reforestation")
    (map-set categories u3 "Clean Water")
    (map-set categories u4 "Waste Management")
    (map-set categories u5 "Wildlife Conservation")
    (map-set categories u6 "Sustainable Agriculture")
    (ok true)
  )
)

(define-public (create-project
  (title (string-ascii 256))
  (description (string-ascii 512))
  (category uint)
  (funding-goal uint)
  (deadline uint)
  (carbon-offset uint))
  (let (
    (project-id (+ (var-get project-counter) u1))
  )
    (asserts! (and (>= funding-goal MIN-FUNDING-GOAL) (<= funding-goal MAX-FUNDING-GOAL)) ERR-INVALID-AMOUNT)
    (asserts! (> deadline stacks-block-height) ERR-INVALID-AMOUNT)
    (asserts! (and (>= category u1) (<= category u6)) ERR-INVALID-CATEGORY)
    
    (map-set projects project-id
      {
        creator: tx-sender,
        title: title,
        description: description,
        category: category,
        funding-goal: funding-goal,
        current-funding: u0,
        deadline: deadline,
        is-active: true,
        is-funded: false,
        created-at: stacks-block-height,
        carbon-offset: carbon-offset,
        impact-score: u0
      }
    )
    
    (var-set project-counter project-id)
    (var-set total-projects (+ (var-get total-projects) u1))
    
    (ok project-id)
  )
)

(define-public (fund-project (project-id uint) (amount uint))
  (let (
    (project-data (unwrap! (get-project project-id) ERR-PROJECT-NOT-FOUND))
    (platform-fee (calculate-platform-fee amount))
    (net-amount (- amount platform-fee))
    (existing-funding (map-get? project-funders {project-id: project-id, funder: tx-sender}))
  )
    (asserts! (get is-active project-data) ERR-PROJECT-INACTIVE)
    (asserts! (not (is-project-expired project-id)) ERR-PROJECT-INACTIVE)
    (asserts! (< (get current-funding project-data) (get funding-goal project-data)) ERR-FUNDING-COMPLETE)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (map-set project-funders {project-id: project-id, funder: tx-sender}
      {
        amount: (+ (match existing-funding fund-data (get amount fund-data) u0) net-amount),
        funded-at: stacks-block-height,
        refunded: false
      }
    )
    
    (let (
      (new-funding (+ (get current-funding project-data) net-amount))
      (is-now-funded (>= new-funding (get funding-goal project-data)))
    )
      (map-set projects project-id
        (merge project-data {
          current-funding: new-funding,
          is-funded: is-now-funded
        })
      )
      
      (if is-now-funded
        (var-set total-funded (+ (var-get total-funded) u1))
        false
      )
    )
    
    (if (is-none existing-funding)
      (add-funder-project tx-sender project-id)
      false
    )
    
    (var-set platform-treasury (+ (var-get platform-treasury) platform-fee))
    
    (ok true)
  )
)

(define-public (create-milestone
  (project-id uint)
  (title (string-ascii 256))
  (target-amount uint)
  (impact-data (string-ascii 256)))
  (let (
    (project-data (unwrap! (get-project project-id) ERR-PROJECT-NOT-FOUND))
    (milestone-id (+ (var-get milestone-counter) u1))
  )
    (asserts! (is-eq tx-sender (get creator project-data)) ERR-NOT-AUTHORIZED)
    (asserts! (get is-funded project-data) ERR-NOT-FUNDED)
    
    (map-set milestones milestone-id
      {
        project-id: project-id,
        title: title,
        target-amount: target-amount,
        is-verified: false,
        verified-at: u0,
        verifier: tx-sender,
        impact-data: impact-data
      }
    )
    
    (add-milestone-to-project project-id milestone-id)
    (var-set milestone-counter milestone-id)
    
    (ok milestone-id)
  )
)

(define-public (verify-milestone (milestone-id uint))
  (let (
    (milestone-data (unwrap! (get-milestone milestone-id) ERR-MILESTONE-NOT-FOUND))
    (verifier-data (unwrap! (get-verifier tx-sender) ERR-NOT-AUTHORIZED))
    (project-data (unwrap! (get-project (get project-id milestone-data)) ERR-PROJECT-NOT-FOUND))
  )
    (asserts! (get is-authorized verifier-data) ERR-NOT-AUTHORIZED)
    (asserts! (not (get is-verified milestone-data)) ERR-ALREADY-VERIFIED)
    
    (map-set milestones milestone-id
      (merge milestone-data {
        is-verified: true,
        verified-at: stacks-block-height,
        verifier: tx-sender
      })
    )
    
    (map-set verifiers tx-sender
      (merge verifier-data {verifications-count: (+ (get verifications-count verifier-data) u1)})
    )
    
    (let (
      (impact-increase (* (get target-amount milestone-data) IMPACT-MULTIPLIER))
    )
      (map-set projects (get project-id milestone-data)
        (merge project-data {
          impact-score: (+ (get impact-score project-data) impact-increase)
        })
      )
      (var-set carbon-offset-total (+ (var-get carbon-offset-total) (get carbon-offset project-data)))
    )
    
    (ok true)
  )
)

(define-public (withdraw-funds (project-id uint))
  (let (
    (project-data (unwrap! (get-project project-id) ERR-PROJECT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get creator project-data)) ERR-NOT-AUTHORIZED)
    (asserts! (get is-funded project-data) ERR-NOT-FUNDED)
    (asserts! (> (get current-funding project-data) u0) ERR-INSUFFICIENT-FUNDS)
    
    (try! (as-contract (stx-transfer? (get current-funding project-data) tx-sender (get creator project-data))))
    
    (map-set projects project-id
      (merge project-data {current-funding: u0})
    )
    
    (ok (get current-funding project-data))
  )
)

(define-public (refund-expired-project (project-id uint))
  (let (
    (project-data (unwrap! (get-project project-id) ERR-PROJECT-NOT-FOUND))
    (funding-data (unwrap! (get-project-funding project-id tx-sender) ERR-NOT-AUTHORIZED))
  )
    (asserts! (is-project-expired project-id) ERR-PROJECT-INACTIVE)
    (asserts! (not (get is-funded project-data)) ERR-FUNDING-COMPLETE)
    (asserts! (not (get refunded funding-data)) ERR-INVALID-AMOUNT)
    
    (try! (as-contract (stx-transfer? (get amount funding-data) tx-sender tx-sender)))
    
    (map-set project-funders {project-id: project-id, funder: tx-sender}
      (merge funding-data {refunded: true})
    )
    
    (ok (get amount funding-data))
  )
)

(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set verifiers verifier
      {
        is-authorized: true,
        verifications-count: u0,
        joined-at: stacks-block-height
      }
    )
    (ok true)
  )
)

(define-public (deactivate-project (project-id uint))
  (let (
    (project-data (unwrap! (get-project project-id) ERR-PROJECT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get creator project-data)) ERR-NOT-AUTHORIZED)
    (map-set projects project-id
      (merge project-data {is-active: false})
    )
    (ok true)
  )
)

(define-public (withdraw-treasury (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= amount (var-get platform-treasury)) ERR-INSUFFICIENT-FUNDS)
    (try! (as-contract (stx-transfer? amount tx-sender recipient)))
    (var-set platform-treasury (- (var-get platform-treasury) amount))
    (ok true)
  )
)

(define-read-only (get-active-projects)
  (filter is-project-active (list 
    u1 u2 u3 u4 u5 u6 u7 u8 u9 u10
    u11 u12 u13 u14 u15 u16 u17 u18 u19 u20
    u21 u22 u23 u24 u25 u26 u27 u28 u29 u30
    u31 u32 u33 u34 u35 u36 u37 u38 u39 u40
    u41 u42 u43 u44 u45 u46 u47 u48 u49 u50
  ))
)

(define-private (is-project-active (project-id uint))
  (match (get-project project-id)
    project-data (and (get is-active project-data) (not (is-project-expired project-id)))
    false
  )
)
