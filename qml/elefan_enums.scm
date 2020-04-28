(define (enum-value-of value enum)
  (if-let ([possMem (memq (string->symbol value) enum)]) (car possMem) possMem))

(define (enum-member? elem enum)
  (memq ((if (string? elem) string->symbol identity) elem) enum))

(define (enum-elem=? elemOrValue1 elemOrValue2)
  (eq?
    ((if (string? elemOrValue1) string->symbol identity) elemOrValue1)
    ((if (string? elemOrValue2) string->symbol identity) elemOrValue2)))

(define (enum-member-or-value->string member-or-value)
  ((if (string? member-or-value) identity symbol->string) member-or-value))



(define NOTIFICATION_TYPE_ENUM '(follow  mention       reblog  favourite))
(define   ATTACHMENT_TYPE_ENUM '(unknown image         gifv    video))
(define         CARD_TYPE_ENUM '(link    photo         video   rich))
(define    FILTER_CONTEXT_ENUM '(home    notifications public  thread))
(define STATUS_VISIBILITY_ENUM '(public  unlisted      private direct))
