
(require "generic-key-custom.scm")

;;; user configs

;; key defs
(define-key test0001-on-key? 'generic-on-key?)
(define-key test0001-off-key? 'generic-off-key?)
(define-key test0001-backspace-key? 'generic-backspace-key?)
(define-key test0001-cancel-key? 'generic-cancel-key?)
(define-key test0001-commit-key? 'generic-commit-key?)

(define-key test0001-close-candidate-window-key? '("<Alt>c"))
(define-key test0001-open-candidate-window-key? '("<Alt>o"))

(define-key test0001-next-candidate-key? 'generic-next-candidate-key?)
(define-key test0001-prev-candidate-key? 'generic-prev-candidate-key?)
(define-key test0001-next-page-key? 'generic-next-page-key?)
(define-key test0001-prev-page-key? 'generic-prev-page-key?)

;; Number of candidates in candidate window at a time
(define test0001-nr-candidate-max 10)

;; test cands
(define test0001-cands
  '("one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten"
    "eleven" "twelve" "thirteen" "fourteen" "fifteen"
    "sixteen" "seventeen" "eighteen" "nineteen" "twenty"
    "twenty one" "twenty two" "twenty three" "twenty four" "twenty five"
    "twenty six" "twenty seven" "twenty eight" "twenty nine" "thirty"))

;; widgets and actions

;; widgets
(define test0001-widgets '(widget_test0001_input_mode))

;; default activity for each widgets
(define default-widget_test0001_input_mode 'action_test0001_off)

;; actions of widget_test0001_input_mode
(define test0001-input-mode-actions
  '(action_test0001_off
    action_test0001_on))


;;; implementations

(register-action 'action_test0001_off
                 (lambda (context)
                   (list
                    'off
                    "-"
                    (N_ "off")
                    (N_ "Direct Input Mode")))
                 (lambda (context)
                   (not (test0001-context-on context)))
                 #f)  ;; no action handler

(register-action 'action_test0001_on
                 (lambda (context)
                   (list
                    'on
                    "O"
                    (N_ "on")
                    (N_ "Test0001 Input Mode")))
                 (lambda (context)
                   (test0001-context-on context))
                 #f)  ;; no action handler

;; Update widget definitions based on action configurations. The
;; procedure is needed for on-the-fly reconfiguration involving the
;; custom API
(define test0001-configure-widgets
  (lambda ()
    (register-widget 'widget_test0001_input_mode
                     (activity-indicator-new test0001-input-mode-actions)
                     (actions-new test0001-input-mode-actions))))

(define test0001-context-rec-spec
  (append
   context-rec-spec
   '((on #f)
     (seq ())                           ; text currently being entered
     (candidate-window #f)              ; currently showing window?
     (cand-nth 0)                       ; currently selected cand index
     )))
(define-record 'test0001-context test0001-context-rec-spec)
(define test0001-context-new-internal test0001-context-new)

(define test0001-context-new
  (lambda args
    (let ((context (apply test0001-context-new-internal args)))
      (test0001-context-set-widgets! context test0001-widgets)
      context)))

(define test0001-push-back-mode
  (lambda (context lst)
    (if (car lst)
        (begin
          (im-pushback-mode-list context (caar lst))
          (test0001-push-back-mode context (cdr lst))))))

(define test0001-init-handler
  (lambda (id im arg)
    (let ((context (test0001-context-new id im)))
      ;;(im-clear-mode-list context)
      ;;(test0001-push-back-mode context im-list)
      ;;(im-update-mode-list context)
      ;;(im-update-mode context (- (length im-list) 1))
      context)))

(define test0001-release-handler
  (lambda (context)
    #f))

(define test0001-clear
  (lambda (context)
    (test0001-context-set-seq! context ())))

(define test0001-commit
  (lambda (context)
    (im-commit context (test0001-get-preedit-string context))
    (test0001-clear context)))

(define test0001-get-preedit-string
  (lambda (context)
    (apply string-append
           (reverse (test0001-context-seq context)))))

(define test0001-update-preedit
  (lambda (context)
    (im-clear-preedit context)
    (im-pushback-preedit context
                         preedit-underline
                         (test0001-get-preedit-string context))
    (im-update-preedit context)))

(define test0001-select-cand-index
  (lambda (context idx)
    (let ((len (length test0001-cands)))
      (if (< idx 0) (set! idx (- len 1)))
      (if (>= idx len) (set! idx 0))
      (test0001-context-set-cand-nth! context idx)
      (if (test0001-context-candidate-window context)
          (im-select-candidate context idx))
      )))

(define test0001-proc-on-state
  (lambda (context key key-state)
    (cond
     ;; off
     ((test0001-off-key? key key-state)
      (test0001-clear context)
      (test0001-context-set-on! context #f))
     ;; commit
     ((test0001-commit-key? key key-state)
      (let ((seq (test0001-context-seq context)))
        (if (null? seq)
            (im-commit-raw context)
            (test0001-commit context))))
     ;; open candidate window
     ((test0001-open-candidate-window-key? key key-state)
      (if (not (test0001-context-candidate-window context))
          (begin
            (im-activate-candidate-selector context
                                            (length test0001-cands)
                                            test0001-nr-candidate-max)
            (test0001-context-set-candidate-window! context #t)
            (im-select-candidate context (test0001-context-cand-nth context))
            )))
     ;; close candidate window
     ((test0001-close-candidate-window-key? key key-state)
      (if (test0001-context-candidate-window context)
          (begin
            (im-deactivate-candidate-selector context)
            (test0001-context-set-candidate-window! context #f)
            )))
     ;; next candidate
     ((test0001-next-candidate-key? key key-state)
      (if (test0001-context-candidate-window context)
          (test0001-select-cand-index
           context (+ (test0001-context-cand-nth context) 1))
          (im-commit-raw context)))
     ;; prev candidate
     ((test0001-prev-candidate-key? key key-state)
      (if (test0001-context-candidate-window context)
          (test0001-select-cand-index
           context (- (test0001-context-cand-nth context) 1))
          (im-commit-raw context)))
     ;; next candidate page
     ((test0001-next-page-key? key key-state)
      (if (test0001-context-candidate-window context)
          (begin
            (im-shift-page-candidate context #t)
            (test0001-select-cand-index
             context (+ (test0001-context-cand-nth context)
                        test0001-nr-candidate-max)))
          (im-commit-raw context)
          ))
     ;; prev candidate page
     ((test0001-prev-page-key? key key-state)
      (if (test0001-context-candidate-window context)
          (begin
            (im-shift-page-candidate context #f)
            (test0001-select-cand-index
             context (- (test0001-context-cand-nth context)
                        test0001-nr-candidate-max)))
          (im-commit-raw context)
          ))
     ;; backspace
     ((test0001-backspace-key? key key-state)
      (let ((seq (test0001-context-seq context)))
        (if (null? seq)
            (im-commit-raw context)
            (test0001-context-set-seq! context (cdr seq)))))
     ;; cancel
     ((test0001-cancel-key? key key-state)
      (if (null? (test0001-context-seq context))
          (im-commit-raw context)
          (test0001-clear context)))
     ;; modifier except shift
     ((and (modifier-key-mask key-state)
           (not (shift-key-mask key-state)))
      (im-commit-raw context))
     ;; input character
     ((not (symbol? key))
      (let ((key-str (charcode->string key)))
        (test0001-context-set-seq!
         context (cons key-str (test0001-context-seq context)))))
     )
    (test0001-update-preedit context)
    ))

(define test0001-proc-off-state
  (lambda (context key key-state)
    (if (test0001-on-key? key key-state)
        (test0001-context-set-on! context #t)
        (im-commit-raw context))))

(define test0001-key-press-handler
  (lambda (context key key-state)
    (if (ichar-control? key)
        (im-commit-raw context)
        (if (test0001-context-on context)
            (test0001-proc-on-state context key key-state)
            (test0001-proc-off-state context key key-state)))))

(define test0001-key-release-handler
  (lambda (context key key-state)
    (im-commit-raw context)))

(define test0001-reset-handler
  (lambda (context)
    #f))

;;(define test0001-mode-handler
;;  (lambda (context mode)
;;    (create-context (test0001-context-id context)
;;          #f
;;          (car (nth mode im-list)))
;;    #f))

(define test0001-get-candidate-handler
  (lambda (context idx accel-enum-hint)
    (let ((cand (nth idx test0001-cands)))
      (list cand (digit->string (+ idx 1)) ""))))

(define test0001-set-candidate-index-handler
  (lambda (context idx)
    #f))

(test0001-configure-widgets)

(register-im
 'test0001
 "*"
 "UTF-8"
 (N_ "test0001")
 (N_ "test0001 description")
 #f
 test0001-init-handler
 test0001-release-handler
 context-mode-handler
 test0001-key-press-handler
 test0001-key-release-handler
 test0001-reset-handler
 test0001-get-candidate-handler
 test0001-set-candidate-index-handler
 context-prop-activate-handler
 #f
 #f
 #f
 #f
 #f
 )
