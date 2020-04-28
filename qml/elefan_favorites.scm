(define* (masto-favorites-all mastoApp #:key [limit 20])
  (generate-masto-page
    mastoApp
    http-get
    (string-append (masto-app-domain mastoApp) "/api/v1/favourites"
                   "?limit="                   (number->string limit))
    generate-masto-status-array))
