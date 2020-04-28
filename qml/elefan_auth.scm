(define-record-type (masto-app make-masto-app masto-instance-app?)
  (fields (mutable domain)    (mutable name)   (mutable website)
          (mutable redirects) (mutable id)     (mutable secret)
          (mutable key)       (mutable scopes) (mutable token)))

(define* (masto-app-instantiate domain #:key website id secret key
                                             [name                            "Elefan"]
                                             [redirects '("urn:ietf:wg:oauth:2.0:oob")]
                                             [scopes                         '("read")])
  (let ([app (if (or (not id) (not secret) (not key))
                 (js-obj->alist
                   (string->json
                     (xhr-response-text
                       (http-post
                         (string-append
                           domain
                           "/api/v1/apps"
                           (assemble-params `(("client_name"   ,name)
                                              ("redirect_uris" ,(string-join redirects  "\n"))
                                              ("scopes"        ,(string-join scopes    "%20"))
                                              ("website"       ,website))))
                         '()))))
               `(("name"          . ,name)
                 ("client_id"     . ,id)
                 ("client_secret" . ,secret)
                 ("vapid_key"     . ,key)
                 ("website"       . ,website)))])
    (make-masto-app domain                      (assoc-ref app "name")
                    (assoc-ref app "website")   redirects
                    (assoc-ref app "client_id") (assoc-ref app "client_secret")
                    (assoc-ref app "vapid_key") scopes)))





(define (masto-app-set-token-via-post-call! app queryParams)
  (masto-app-token-set! app (js-ref
                              (string->json (xhr-response-text
                                              (http-post
                                                (string-append
                                                  (masto-app-domain app)
                                                  "/oauth/token"
                                                  (assemble-params queryParams))
                                                '())))
                              "access_token"))

  app)





(define* (masto-app-authorize-uri mastoApp #:key redirect scopes)
  (string-append (masto-app-domain mastoApp) "/oauth/authorize"
                 (assemble-params
                   `(("scope"         ,(string-join (if scopes
                                                        scopes
                                                      (masto-app-scopes
                                                        mastoApp))        "%20"))
                     ("response_type" "code")
                     ("redirect_uri"  ,(if redirect
                                           redirect
                                         (car (masto-app-redirects mastoApp))))
                     ("client_id"     ,(masto-app-id     mastoApp))
                     ("client_secret" ,(masto-app-secret mastoApp))))))

(define* (masto-app-set-token-via-code! mastoApp code #:key redirect)
  (masto-app-set-token-via-post-call!
    mastoApp
    `(("client_id"     ,(masto-app-id     mastoApp))
      ("client_secret" ,(masto-app-secret mastoApp))
      ("grant_type"    "authorization_code")
      ("code"          ,code)
      ("redirect_uri"  ,(if redirect
                            redirect
                          (car (masto-app-redirects mastoApp)))))))



(define* (masto-app-set-token-via-user-cred! mastoApp username
                                             password #:key scopes)
  (masto-app-set-token-via-post-call!
    mastoApp
    `(("grant_type"    "password")
      ("username"      ,username)
      ("password"      ,password)
      ("client_id"     ,(masto-app-id     mastoApp))
      ("client_secret" ,(masto-app-secret mastoApp))
      ("scope"         ,(string-join
                          (if scopes scopes (masto-app-scopes mastoApp))
                          "%20")))))



(define (masto-app-set-token-via-client-cred! mastoApp)
  (masto-app-set-token-via-post-call!
    mastoApp
    `(("grant_type"    "client_credentials")
      ("client_id"     ,(masto-app-id     mastoApp))
      ("client_secret" ,(masto-app-secret mastoApp)))))





(define (masto-app-verify-cred mastoApp)
  (http-get (string-append/shared
              (masto-app-domain mastoApp)
              "/api/v1/apps/verify_credentials")))
