(define (masto-emojis-on-instance domainOrApp)
  (generate-masto-emoji-array
    (string->json
      (xhr-response-text 
        (http-get (string-append
                    (if (masto-instance-app? domainOrApp)
                        (masto-app-domain domainOrApp)
                      (if (string-contains-ci domainOrApp "https://")
                          domainOrApp
                        (string-append/shared "https://" domainOrApp)))
                    "/api/v1/custom_emojis")                             '())))))
