#! /usr/bin/env uim-sh
;;; UnicodeコードポイントのU+XXXXX表記があったら対応する文字に置換する
;;; コマンドラインツール。
;;;
;;; コマンドラインで指定された各引数に対して実行。
;;; 引数が無い場合は、標準入力の各行ごとに実行。
;;; 入力漢字コードはUTF-8。
;;;
;;; $ echo '例えば、U+8a3bU+91c8とか' | nkf -w | $PWD/uimsh-ucs.scm
;;; 例えば、註釈とか
(require "bushuconv.scm")
(define (main args)
  (let ((cmd-action ; 各行ごとに実行する関数
          (lambda (str)
            (display
              (apply string-append
                (bushuconv-translate-ucs
                  (reverse (bushuconv-string-to-list str)))))
            (newline)))
        (rest (cdr args)))
    (if (pair? rest)
      (let loop ((rest rest))
        (if (pair? rest)
          (begin
            (cmd-action (car rest))
            (loop (cdr rest)))))
      (let loop ((line (read-line)))
        (and
          line
          (not (eof-object? line))
          (begin
            (cmd-action line)
            (loop (read-line))))))))
