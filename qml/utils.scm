(define-macro (when-let bindings . body)
  (let ([symbols (map (lambda (lst)
                        (if (= (length lst) 2)
                            (car lst)
                          (list (cadr lst) (caddr lst)))) bindings)]
        [binds   (map (lambda (lst)
                        (if (= (length lst) 2)
                            lst
                          (list (car  lst) (caddr lst)))) bindings)])
    `(let ,binds (when (and ,@symbols) ,@body))))
(define-macro (when-let* bindings . body)
  (let ([symbols (map (lambda (lst)
                        (if (= (length lst) 2)
                            (car lst)
                          (list (cadr lst) (caddr lst)))) bindings)]
        [binds   (map (lambda (lst)
                        (if (= (length lst) 2)
                            lst
                          (list (car  lst) (caddr lst)))) bindings)])
    `(let* ,binds (when (and ,@symbols) ,@body))))

(define-macro (if-let bindings then else)
  (let ([symbols (map (lambda (lst)
                        (if (= (length lst) 2)
                            (car lst)
                          (list (cadr lst) (caddr lst)))) bindings)]
        [binds   (map (lambda (lst)
                        (if (= (length lst) 2)
                            lst
                          (list (car  lst) (caddr lst)))) bindings)])
    `(let ,binds (if (and ,@symbols) ,then ,else))))
(define-macro (if-let* bindings then else)
  (let ([symbols (map (lambda (lst)
                        (if (= (length lst) 2)
                            (car lst)
                          (list (cadr lst) (caddr lst)))) bindings)]
        [binds   (map (lambda (lst)
                        (if (= (length lst) 2)
                            lst
                          (list (car  lst) (caddr lst)))) bindings)])
    `(let* ,binds (if (and ,@symbols) ,then ,else))))

(define (1- n)
  (- n 1))
(define (1+ n)
  (+ n 1))

(define (assoc-ref alist key)
  (if-let ([elem (assoc key alist)]) (cdr elem) #f))

(define (list-head lst n)
  (if (zero? n) '() (cons (car lst) (list-head (cdr lst) (1- n)))))

;; (define-macro (apply-let bindings . body)
;;   `(if (even? (length ,bindings))
;;        (let ,@(map
;;                 (lambda (index)
;;                   (list (list-ref bindings index) (list-ref bindings (1+ index))))
;;                 (iota (/ (length bindings) 2) 0 2))
;;          ,@body)
;;      (display "Error")))

(define-macro (define* nameAndParameters . body)
  (let* ([parameters  (cdr nameAndParameters)]
         [keyPresent  (member '#:key parameters)]
         [mandatories (if keyPresent
                          (list-head parameters (-
                                                  (length parameters)
                                                  (length keyPresent)))
                        parameters)]
         [keys        (if keyPresent (cdr keyPresent) '())])
    `(define (,(car nameAndParameters) ,@mandatories . rest)
       (let ,(map (lambda (elem)
                    (let ([key (if (list? elem) (car elem) elem)])
                      (list key `(if-let ([var (member
                                                 (quote ,(string->symbol
                                                           (string-append
                                                             "#:"
                                                             (symbol->string key))))
                                                 rest)])
                                     (cadr var)
                                   ,(if (list? elem) (cadr elem) #f))))) keys)
         ,@body))))
;; (define-macro (define* nameAndParameters . body)
;;   (let* ([parameters      (cdr nameAndParameters)]
;;          [optionalPresent (member '#:optional parameters)]
;;          [mandatories     (if optionalPresent
;;                               (list-head parameters (-
;;                                                       (length parameters)
;;                                                       (length optionalPresent)))
;;                             parameters)]
;;          [optionals       (if optionalPresent (cdr optionalPresent) '())])
;;     `(define (,(car nameAndParameters) ,@mandatories . rest)
;;        (let ,@(map (lambda (elem)
;;                      (if (list? elem)
;;                          (list (car elem) (cadr elem))
;;                        (list elem #f))) optionals)
;;          ,@body))))

(define (assemble-params params)
  (string-append
    "?"
    (string-join
      (map
        (lambda (param)
          (if-let ([key            (car  param)]
                   [values string? (cadr param)])
              (string-join param "=")
            (string-join (let ([filteredValues (filter identity values)])
                           (map
                             (lambda (index value)
                               (string-append
                                 (uri-encode key)   "[" (number->string index) "]="
                                 (uri-encode value)))
                             (iota (length filteredValues))
                             filteredValues)) "&")))
        (filter (lambda (elem)
                  (and (cadr elem) (not (null? (cadr elem))))) params))
      "&")))

(define (boolean->string bool)
  (if bool "true" "false"))
