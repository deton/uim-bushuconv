#! /usr/bin/env uim-sh
;;; uim-bushuconv(部首合成変換IM)を使ったコマンドラインツール。
;;;
;;; コマンドラインで指定された各引数に対して、部首合成変換を実行。
;;; 引数が無い場合は、標準入力の各行ごとに部首合成変換を実行。
;;; 入出力漢字コードはUTF-8。
;;;
;;; (入力:部首リスト、出力:合成される漢字の候補)
;;; $ echo '口木イ' | $PWD/uimsh-bushuconv.scm
;;; 保堡葆褒褓
(require "bushuconv.scm")
(define (main args)
  (define (setup-im-stub)
    (set! im-retrieve-context (lambda (uc) uc))
    (set! im-set-encoding (lambda (uc enc) #f))
    (set! im-convertible? (lambda (uc im-encoding) #t))
    (set! im-commit (lambda (uc str) #f))
    (set! im-clear-preedit (lambda (uc) #f))
    (set! im-pushback-preedit (lambda (uc attr str) #f))
    (set! im-update-preedit (lambda (uc) #f))
    (set! im-activate-candidate-selector (lambda (uc nr display-limit) #f))
    (set! im-select-candidate (lambda (uc idx) #f))
    (set! im-shift-page-candidate (lambda (uc dir) #f))
    (set! im-deactivate-candidate-selector (lambda (uc) #f))
    (set! im-delay-activate-candidate-selector (lambda (uc delay) #f))
    (set! im-delay-activate-candidate-selector-supported? (lambda (uc) #f))
    (set! im-acquire-text-internal
      (lambda (uc text-id origin former-len latter-len) #f))
    (set! im-delete-text-internal
      (lambda (uc text-id origin former-len latter-len) #f))
    (set! im-clear-mode-list (lambda (uc) #f))
    (set! im-pushback-mode-list (lambda (uc str) #f))
    (set! im-update-mode-list (lambda (uc) #f))
    (set! im-update-mode (lambda (uc mode) #f))
    (set! im-update-prop-list (lambda (uc prop) #f))
    (set! im-raise-configuration-change (lambda (uc) #t))
    (set! im-switch-app-global-im (lambda (uc name) #t))
    (set! im-switch-system-global-im (lambda (uc name) #t)))
  (define (setup-stub-context lang name)
    (let ((uc (context-new #f #f '() #f #f)))
      (context-set-uc! uc uc)
      (let ((c (create-context uc lang name)))
        (setup-context c)
        c)))
  (setup-im-stub)
  (let ((tc (setup-stub-context "ja" 'bushuconv))
        (cmd-action ; 各行ごとに実行する関数
          (lambda (tc str)
            (display
              (apply string-append
                (tutcode-bushu-compose-interactively
                  (reverse (bushuconv-string-to-list str)))))
            (newline)))
        (rest (cdr args)))
    (if (pair? rest)
      (let loop ((rest rest))
        (if (pair? rest)
          (begin
            (cmd-action tc (car rest))
            (loop (cdr rest)))))
      (let loop ((line (read-line)))
        (and
          line
          (not (eof-object? line))
          (begin
            (cmd-action tc line)
            (loop (read-line))))))))
