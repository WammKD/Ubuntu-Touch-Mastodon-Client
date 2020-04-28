(define-macro (generate-masto-object generate-funct jsObj . args)
  `(let ([alist (js-obj->alist ,jsObj)])
     (,generate-funct ,@(map (lambda (arg)
                               `(if-let ([value (lambda (elem)
                                                  (and
                                                    elem
                                                    (not (js-null? elem)))) (assoc-ref
                                                                              alist
                                                                              ,(car arg))])
                                    ,(if (= (length arg) 1)
                                         'value
                                       `(,(cadr arg) value))
                                  #f)) args))))



(define (generate-masto-object-array objects generate-fn)
  (map (lambda (object) (generate-fn object)) (js-array->list objects)))



(define-record-type (masto-page make-masto-page masto-page?)
  (fields (mutable objects)  (mutable url-prev)
          (mutable url-next) (mutable http-call) (mutable generate-fn)))



(define (generate-masto-page mastoApp http-type url generate-fn)
  (if-let* ([xhr                                             (http-type
                                                               url
                                                               (if (not mastoApp)
                                                                   '()
                                                                 `(("Authorization" . ,(string-append
                                                                                         "Bearer "
                                                                                         (masto-app-token mastoApp))))))]
            [links   (lambda (link)
                       (and link (not (string-null? link)))) (xhr-response-header xhr "link")]
            [objects                                         (string->json (xhr-response-text xhr))])
      (let ([pages (map
                     (lambda (elem)
                       (let ([page (reverse
                                     (map
                                       (lambda (e)
                                         (if-let ([refined (lambda (s)
                                                             (string-contains s "<")) (string-trim e)])
                                             (substring refined 1 (1- (string-length refined)))
                                           (substring refined 5 (1- (string-length refined)))))
                                       (string-split elem #\;)))])
                         (cons (car page) (cadr page))))
                     (map string-trim (string-split links #\,)))])
        (make-masto-page
          (generate-fn objects)
          (assoc-ref pages "prev")
          (assoc-ref pages "next")
          http-type
          generate-fn))
    (make-masto-page
      (generate-fn objects)
      #f
      #f
      http-type
      generate-fn)))


(define (masto-page-prev mastoApp page)
  (let ([prevURL     (masto-page-url-prev    page)]
        [http-type   (masto-page-http-call   page)]
        [generate-fn (masto-page-generate-fn page)])
    (if (not prevURL)
        #f
      (let ([newPage (generate-masto-page mastoApp http-type
                                          prevURL  generate-fn)])
        (if (and
              (masto-page-url-prev newPage)
              (masto-page-url-next newPage)
              (not (null? (masto-page-objects newPage))))
            newPage
          #f)))))

(define (masto-page-next mastoApp page)
  (let ([nextURL     (masto-page-url-next    page)]
        [http-type   (masto-page-http-call   page)]
        [generate-fn (masto-page-generate-fn page)])
    (if (not nextURL)
        #f
      (let ([newPage (generate-masto-page mastoApp http-type
                                          nextURL  generate-fn)])
        (if (and
              (masto-page-url-prev newPage)
              (masto-page-url-next newPage)
              (not (null? (masto-page-objects newPage))))
            newPage
          #f)))))



(define-record-type (masto-emoji make-masto-emoji masto-emoji?)
  (fields (mutable shortcode) (mutable static-url)
          (mutable url)       (mutable visible-in-picker)))

(define (generate-masto-emoji emoji)
  (generate-masto-object make-masto-emoji emoji
    ["shortcode"]              ["url" string->uri]
    ["static_url" string->uri] ["visible_in_picker"]))

(define (generate-masto-emoji-array emojis)
  (generate-masto-object-array emojis generate-masto-emoji))



(define-record-type (masto-field make-masto-field masto-field?)
  (fields (mutable name) (mutable value) (mutable verified-at)))

(define (generate-masto-field field)
  (generate-masto-object make-masto-field field
    ["name"] ["value"] ["verified_at" parse-date]))

(define (generate-masto-field-array fields)
  (generate-masto-object-array fields generate-masto-field))



(define-record-type (masto-account make-masto-account masto-account?)
  (fields (mutable id)              (mutable username)
          (mutable acct)            (mutable display-name)
          (mutable locked)          (mutable created-at)
          (mutable followers-count) (mutable following-count)
          (mutable statuses-count)  (mutable note)
          (mutable url)             (mutable avatar)
          (mutable avatar-static)   (mutable header)
          (mutable header-static)   (mutable emojis)
          (mutable moved)           (mutable fields)          (mutable bot)))

(define (generate-masto-account account)
  (generate-masto-object make-masto-account account
    ["id"]
    ["username"]
    ["acct"]
    ["display_name"]
    ["locked"]
    ["created_at"      parse-date]
    ["followers_count"]
    ["following_count"]
    ["statuses_count"]
    ["note"]
    ["url"             string->uri]
    ["avatar"          string->uri]
    ["avatar_static"   string->uri]
    ["header"          string->uri]
    ["header_static"   string->uri]
    ["emojis"          generate-masto-emoji-array]
    ["moved"           generate-masto-account]
    ["fields"          generate-masto-field-array]
    ["bot"]))

(define (generate-masto-account-array accounts)
  (generate-masto-object-array accounts generate-masto-account))



(define-record-type (masto-relationship make-masto-relationship masto-relationship?)
  (fields (mutable id)              (mutable following)
          (mutable followed-by)     (mutable blocking)
          (mutable muting)          (mutable muting-notifications)
          (mutable requested)       (mutable domain-blocking)
          (mutable showing-reblogs) (mutable endorsed)))

(define (generate-masto-relationship ship)
  (generate-masto-object make-masto-relationship ship
    ["id"]        ["following"]       ["followed_by"]
    ["blocking"]  ["muting"]          ["muting_notifications"]
    ["requested"] ["domain_blocking"] ["showing_reblogs"]      ["endorsed"]))



(define-record-type (masto-meta-subtree make-masto-meta-subtree masto-meta-subtree?)
  (fields (mutable width)      (mutable height)
          (mutable size)       (mutable aspect)
          (mutable frame-rate) (mutable duration) (mutable bitrate)))

(define (generate-masto-meta-subtree subtree)
  (generate-masto-object make-masto-meta-subtree subtree
    ["width"]  ["height"]     ["size"]
    ["aspect"] ["frame_rate"] ["duration"] ["bitrate"]))



(define-record-type (masto-meta-focus make-masto-meta-focus masto-meta-focus?)
  (fields (mutable x) (mutable y)))

(define (generate-masto-meta-focus focus)
  (generate-masto-object make-masto-meta-focus focus ["x"] ["y"]))



(define-record-type (masto-meta make-masto-meta masto-meta?)
  (fields (mutable small) (mutable original) (mutable focus)))

(define (generate-masto-meta meta)
  (generate-masto-object make-masto-meta meta
    ["small"    generate-masto-meta-subtree]
    ["original" generate-masto-meta-subtree]
    ["focus"    generate-masto-meta-focus]))



(define-record-type (masto-attachment make-masto-attachment masto-attachment?)
  (fields (mutable id)          (mutable type)
          (mutable url)         (mutable remote-url)
          (mutable preview-url) (mutable text-url)
          (mutable meta)        (mutable description) (mutable blurhash)))

(define (generate-masto-attachment attachment)
  (generate-masto-object make-masto-attachment attachment
    ["id"]                              ["type"        (lambda (type)
                                                         (enum-value-of
                                                           type
                                                           ATTACHMENT_TYPE_ENUM))]
    ["url"         string->uri]         ["remote_url"  string->uri]
    ["preview_url" string->uri]         ["text_url"    string->uri]
    ["meta"        generate-masto-meta] ["description"]
    ["blurhash"]))

(define (generate-masto-attachment-array attachments)
  (generate-masto-object-array attachments generate-masto-attachment))



(define-record-type (masto-mention make-masto-mention masto-mention?)
  (fields (mutable url) (mutable username) (mutable acct) (mutable id)))

(define (generate-masto-mention mention)
  (generate-masto-object make-masto-mention mention
    ["url" string->uri] ["username"] ["acct"] ["id"]))

(define (generate-masto-mention-array mentions)
  (generate-masto-object-array mentions generate-masto-mention))



(define-record-type (masto-history make-masto-history masto-history?)
  (fields (mutable day) (mutable uses) (mutable accounts)))

(define (generate-masto-history history)
  (make-masto-history
    (if-let ([day      (assoc-ref history "day"     )]) (string->number day) #f)
    (if-let ([uses     (assoc-ref history "uses"    )]) uses                 #f)
    (if-let ([accounts (assoc-ref history "accounts")]) accounts             #f)))

(define (generate-masto-history-array histories)
  (generate-masto-object-array histories generate-masto-history))



(define-record-type (masto-tag make-masto-tag masto-tag?)
  (fields (mutable name) (mutable url) (mutable history)))

(define (generate-masto-tag tag)
  (generate-masto-object make-masto-tag tag
    ["name"]
    ["url"     string->uri]
    ["history" generate-masto-history-array]))

(define (generate-masto-tag-array tags)
  (generate-masto-object-array tags generate-masto-tag))



(define-record-type (masto-card make-masto-card masto-card?)
  (fields (mutable url)          (mutable title)
          (mutable description)  (mutable image)
          (mutable type)         (mutable author-name)
          (mutable author-url)   (mutable provider-name)
          (mutable provider-url) (mutable html)
          (mutable width)        (mutable height)))

(define (generate-masto-card card)
  (generate-masto-object make-masto-card card
    ["url"           string->uri]
    ["title"]
    ["description"]
    ["image"         string->uri]
    ["type"          (lambda (type)
                       (enum-value-of type CARD_TYPE_ENUM))]
    ["author_name"]
    ["author_url"    string->uri]
    ["provider_name"]
    ["provider_url"  string->uri]
    ["html"]
    ["width"]
    ["height"]))



(define-record-type (masto-poll-option make-masto-poll-option masto-poll-option?)
  (fields (mutable title) (mutable votes-count)))

(define (generate-masto-poll-option pollOption)
  (generate-masto-object make-masto-poll-option pollOption
    ["title"]
    ["votes_count"]))

(define (generate-masto-poll-option-array pollOptions)
  (generate-masto-object-array pollOptions generate-masto-poll-option))



(define-record-type (masto-poll make-masto-poll masto-poll?)
  (fields (mutable id)          (mutable expires-at)
          (mutable expired)     (mutable multiple)
          (mutable votes-count) (mutable options)    (mutable voted)))

(define (generate-masto-poll poll)
  (generate-masto-object make-masto-poll poll
    ["id"]          ["expires_at" parse-date]
    ["expired"]     ["multiple"]
    ["votes_count"] ["options"    generate-masto-poll-option-array] ["voted"]))



(define-record-type (masto-application make-masto-application masto-application?)
  (fields (mutable name) (mutable website)))

(define (generate-masto-application application)
  (generate-masto-object make-masto-application application
    ["name"]
    ["website" string->uri]))



(define-record-type (masto-status make-masto-status masto-status?)
  (fields (mutable id)              (mutable uri)
          (mutable url)             (mutable account)
          (mutable in-reply-to-id)  (mutable in-reply-to-account-id)
          (mutable reblog-status)   (mutable content)
          (mutable created-at)      (mutable emojis)
          (mutable replies-count)   (mutable reblogs-count)
          (mutable favorites-count) (mutable reblogged)
          (mutable favorited)       (mutable muted)
          (mutable sensitive)       (mutable spoiler-text)
          (mutable visibility)      (mutable media-attachments)
          (mutable mentions)        (mutable tags)
          (mutable card)            (mutable poll)
          (mutable application)     (mutable language)               (mutable pinned)))

(define (generate-masto-status status)
  (generate-masto-object make-masto-status status
    ["id"]
    ["uri"]
    ["url"                    string->uri]
    ["account"                generate-masto-account]
    ["in_reply_to_id"]
    ["in_reply_to_account_id"]
    ["reblog"                 generate-masto-status]
    ["content"]
    ["created_at"             parse-date]
    ["emojis"                 generate-masto-emoji-array]
    ["replies_count"]
    ["reblogs_count"]
    ["favourites_count"]
    ["reblogged"]
    ["favourited"]
    ["muted"]
    ["sensitive"]
    ["spoiler_text"]
    ["visibility"             (lambda (vis)
                                (enum-value-of vis STATUS_VISIBILITY_ENUM))]
    ["media_attachments"      generate-masto-attachment-array]
    ["mentions"               generate-masto-mention-array]
    ["tags"                   generate-masto-tag-array]
    ["card"                   generate-masto-card]
    ["poll"                   generate-masto-poll]
    ["application"            generate-masto-application]
    ["language"]
    ["pinned"]))

(define (generate-masto-status-array statuses)
  (generate-masto-object-array statuses generate-masto-status))



(define-record-type (masto-filter make-masto-filter masto-filter?)
  (fields (mutable id)         (mutable phrase)       (mutable context)
          (mutable expires-at) (mutable irreversible) (mutable whole-word)))

(define (generate-masto-filter filter)
  (generate-masto-object make-masto-filter filter
    ["id"]
    ["phrase"]
    ["context"      (lambda (context)
                      (enum-value-of context FILTER_CONTEXT_ENUM))]
    ["expires_at"   parse-date]
    ["irreversible"]
    ["whole_word"]))



(define-record-type (masto-instance-urls make-masto-instance-urls masto-instance-urls?)
  (fields (mutable streaming-api)))

(define (generate-masto-instance-urls urls)
  (generate-masto-object make-masto-instance-urls urls
    ["streaming_api" string->uri]))



(define-record-type (masto-instance-stats make-masto-instance-stats masto-instance-stats?)
  (fields (mutable user-count) (mutable status-count) (mutable domain-count)))

(define (generate-masto-instance-stats stats)
  (generate-masto-object make-masto-instance-stats stats
    ["user_count"] ["status_count"] ["domain_count"]))



(define-record-type (masto-instance make-masto-instance masto-instance?)
  (fields (mutable uri)               (mutable title)
          (mutable short-description) (mutable description)
          (mutable email)             (mutable version)
          (mutable thumbnail)         (mutable urls)
          (mutable stats)             (mutable languages)   (mutable contact-account)))

(define (generate-masto-instance instance)
  (generate-masto-object make-masto-instance instance
    ["uri"]
    ["title"]
    ["short_description"]
    ["description"]
    ["email"]
    ["version"]
    ["thumbnail"         string->uri]
    ["urls"              generate-masto-instance-urls]
    ["stats"             generate-masto-instance-stats]
    ["languages"         vector->list]
    ["contact_account"   generate-masto-account]))



(define-record-type (masto-list make-masto-list masto-list?)
  (fields (mutable id) (mutable title)))

(define (generate-masto-list list)
  (generate-masto-object make-masto-list list
    ["id"] ["title"]))

(define (generate-masto-list-array lists)
  (generate-masto-object-array lists generate-masto-list))



(define-record-type (masto-notification make-masto-notification masto-notification?)
  (fields (mutable id)        (mutable type)
          (mutable create-at) (mutable account) (mutable status)))

(define (generate-masto-notification notification)
  (generate-masto-object make-masto-notification notification
    ["id"]
    ["type"      (lambda (type)
                   (enum-value-of type NOTIFICATION_TYPE_ENUM))]
    ["create_at" parse-date]
    ["account"   generate-masto-account]
    ["status"    generate-masto-status]))

(define (generate-masto-notification-array notifications)
  (generate-masto-object-array notifications generate-masto-notification))



(define-record-type (masto-web-push-subscription-alerts make-masto-web-push-subscription-alerts masto-web-push-subscription-alerts?)
  (fields (mutable poll)   (mutable mention)
          (mutable reblog) (mutable favorite) (mutable follow)))

(define (generate-masto-web-push-subscription-alerts web-push-subscription-alerts)
  (generate-masto-object make-masto-web-push-subscription-alerts web-push-subscription-alerts
    ["poll"] ["mention"] ["reblog"] ["favourite"] ["follow"]))



(define-record-type (masto-web-push-subscription make-masto-web-push-subscription masto-web-push-subscription?)
  (fields (mutable id) (mutable endpoint) (mutable server-key) (mutable alerts)))

(define (generate-masto-web-push-subscription web-push-subscription)
  (generate-masto-object make-masto-web-push-subscription web-push-subscription
    ["id"]         ["endpoint" string->uri]
    ["server_key"] ["alerts"   generate-masto-web-push-subscription-alerts]))



(define-record-type (masto-scheduled-status-params make-masto-scheduled-status-params masto-scheduled-status-params?)
  (fields (mutable text)         (mutable in-reply-to-id)
          (mutable media-ids)    (mutable sensitive)
          (mutable spoiler-text) (mutable visibility)
          (mutable scheduled-at) (mutable application-id)))

(define (generate-masto-scheduled-status-params scheduled-status-params)
  (generate-masto-object make-masto-scheduled-status-params scheduled-status-params
    ["text"]
    ["in_reply_to_id"]
    ["media_ids"      vector->list]
    ["sensitive"]
    ["spoiler_text"]
    ["visibility"     (lambda (vis)
                        (enum-value-of vis STATUS_VISIBILITY_ENUM))]
    ["scheduled_at"   parse-date]
    ["application_id"]))



(define-record-type (masto-scheduled-status make-masto-scheduled-status masto-scheduled-status?)
  (fields (mutable id)     (mutable scheduled-at)
          (mutable params) (mutable media-attachments)))

(define (generate-masto-scheduled-status scheduledStatus)
  (generate-masto-object make-masto-scheduled-status scheduledStatus
    ["id"]
    ["scheduled_at"      parse-date]
    ["params"            generate-masto-scheduled-status-params]
    ["media_attachments" generate-masto-attachment-array]))

(define (generate-masto-scheduled-status-array scheduledStatuses)
  (generate-masto-object-array scheduledStatuses generate-masto-scheduled-status))



(define-record-type (masto-results make-masto-results masto-results?)
  (fields (mutable accounts) (mutable statuses) (mutable hashtags)))

(define (generate-masto-results results)
  (generate-masto-object make-masto-results results
    ["accounts" generate-masto-account-array]
    ["statuses" generate-masto-status-array]
    ["hashtags" generate-masto-tag-array]))



(define-record-type (masto-context make-masto-context masto-context?)
  (fields (mutable ancestors) (mutable descendants)))

(define (generate-masto-context context)
  (generate-masto-object make-masto-context context
    ["ancestors" generate-masto-status] ["descendants" generate-masto-status]))



(define-record-type (masto-convo make-masto-convo masto-convo?)
  (fields (mutable id) (mutable accounts) (mutable last-status) (mutable unread)))

(define (generate-masto-convo convo)
  (generate-masto-object make-masto-convo convo
    ["id"]                               ["accounts" generate-masto-account-array]
    ["lastStatus" generate-masto-status] ["unread"]))

(define (generate-masto-convo-array convos)
  (generate-masto-object-array convos generate-masto-convo))
