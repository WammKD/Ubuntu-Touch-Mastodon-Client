(define (masto-accounts-token mastoApp eMail username password locale)
  (http-post
    (string-append (masto-app-domain mastoApp) "/api/v1/accounts"
                   (assemble-params `(("username"  ,username)
                                      ("email"     ,eMail)
                                      ("password"  ,password)
                                      ("agreement" "true")
                                      ("locale"    ))))
    `(("Authorization" . ,(string-append
                            "Bearer "
                            (masto-app-token mastoApp))))))
