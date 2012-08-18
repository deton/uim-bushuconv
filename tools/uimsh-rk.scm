#! /usr/bin/env uim-sh
;;; ローマ字かな変換コマンドラインツール。
;;;
;;; コマンドラインで指定された各引数(ローマ字)をかなに変換。
;;; 引数が無い場合は、標準入力の各行ごとに実行。
;;; 出力漢字コードはEUC-JP。
;;;
;;; オプション:
;;;   -k, --katakana  カタカナで出力する。
;;;
;;; $ echo 'sakazuki' | $PWD/uimsh-rk.scm
;;; さかずき
(require-extension (srfi 1))
(require "rk.scm")
(require "japanese.scm")

(define uimsh-rk-option-table
  '((("-k" "--katakana") . katakana)))

(define (rk rseq)
  (let* ((rkc (rk-context-new ja-rk-rule #t #f))
         (kanalist0
          (filter pair?
            (map-in-order
              (lambda (x)
                (rk-push-key! rkc x))
              rseq)))
         (residual-kana (rk-push-key-last! rkc)))
    (if residual-kana
      (append kanalist0 (list residual-kana))
      kanalist0)))

(define (main args)
  (let ((cmd-action ; 各行ごとに実行する関数
          (lambda (str)
            (let*
              ((kanalist (rk (reverse (string-to-list str))))
               (kanastr (ja-make-kana-str (reverse kanalist)
                          (if uimsh-rk-opt-katakana
                            ja-type-katakana
                            ja-type-hiragana))))
              (display kanastr)
              (newline))))
        (str-args
          (uim-sh-parse-args uimsh-rk-option-table 'uimsh-rk (cdr args))))
    (if (pair? str-args)
      (let loop ((str-args str-args))
        (if (pair? str-args)
          (begin
            (cmd-action (car str-args))
            (loop (cdr str-args)))))
      (let loop ((line (read-line)))
        (and
          line
          (not (eof-object? line))
          (begin
            (cmd-action line)
            (loop (read-line))))))))
