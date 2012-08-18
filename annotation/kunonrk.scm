#! /usr/bin/env uim-sh
(require "util.scm")
(require (string-append (getenv "PWD") "/../tools/uimsh-rk.scm"))

(define uimsh-rk-opt-nn #t)

(define (rklist str hira-kata)
  (if (string=? str "")
    ""
    (apply string-append
      (cdr
        (append-map
          (lambda (x)
            (list
              " "
              (iconv-convert "UTF-8" "EUC-JP"
                (rk (reverse (string-to-list x)) hira-kata))))
          (string-split str " "))))))

(define (main args)
  (let ((cmd-action
          (lambda (str)
            (let* ((code-kun-on-def (string-split str "\t"))
                   (kun (cadr code-kun-on-def))
                   (on (caddr code-kun-on-def))
                   (kkun (rklist kun ja-type-hiragana))
                   (kon (rklist on ja-type-katakana))
                   (line
                    (apply string-append
                      (list (car code-kun-on-def) "\t" kkun "\t" kon "\t"
                            (list-ref code-kun-on-def 3)))))
              (display line)
              (newline)))))
    (let loop ((line (read-line)))
      (and
        line
        (not (eof-object? line))
        (begin
          (cmd-action line)
          (loop (read-line)))))))
