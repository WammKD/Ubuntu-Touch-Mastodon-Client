(define* (masto-blocks-all mastoApp #:key [limit 40])
  (generate-masto-page
    mastoApp
    http-get
    (string-append (masto-app-domain mastoApp) "/api/v1/blocks"
                   "?limit="                   (number->string limit))
    generate-masto-account-array))

(define (masto-block-account mastoApp accountID)
  (generate-masto-relationship
    (http-post
      (string-append (masto-app-domain mastoApp) "/api/v1/accounts/"
                     accountID                   "/block")
      `(("Authorization" . ,(string-append
                              "Bearer "
                              (masto-app-token mastoApp)))))))

(define (masto-unblock-account mastoApp accountID)
  (generate-masto-relationship
    (http-post
      (string-append (masto-app-domain mastoApp) "/api/v1/accounts/"
                     accountID                   "/unblock")
      `(("Authorization" . ,(string-append
                              "Bearer "
                              (masto-app-token mastoApp)))))))
