#! /usr/bin/env uim-sh
;;; ローマ字かな変換コマンドラインツール。
;;;
;;; コマンドラインで指定された各引数(ローマ字)をかなに変換。
;;; 引数が無い場合は、標準入力の各行ごとに実行。
;;; 出力漢字コードはEUC-JP。
;;;
;;; オプション:
;;;   -k, --katakana  カタカナで出力する。
;;;   -n              "nna"を"んあ"でなく"んな"に変換する。
;;;
;;; $ $PWD/uimsh-rk.scm ittyoume
;;; いっちょうめ
;;; $ $PWD/uimsh-rk.scm -k shoppingu
;;; ショッピング
;;; $ $PWD/uimsh-rk.scm shinnyuu
;;; しんゆう
;;; $ $PWD/uimsh-rk.scm -n shinnyuu
;;; しんにゅう
(require-extension (srfi 1))
(require "rk.scm")
(require "japanese.scm")
(require "skk.scm")

(define uimsh-rk-option-table
  '((("-k" "--katakana") . katakana)
    (("-n") . nn)))

(define (rk rseq hira-kata)
  (let* ((rkc
          (rk-context-new
            (if uimsh-rk-opt-nn
              (cons '((("n" "n"). ("n"))("ん" "ン" "�]")) ja-rk-rule)
              ja-rk-rule)
            #t #f))
         (kanalist0
          (filter pair?
            (map-in-order
              (lambda (x)
                (rk-push-key! rkc x))
              rseq)))
         (residual-kana (rk-push-key-last! rkc))
         (kanalist
          (if residual-kana
            (append kanalist0 (list residual-kana))
            kanalist0)))
    ;; リストのリストになってるものは展開する。
    ;; 例: "kyaku" -> ((("き" "キ" "�7") ("ゃ" "ャ" "�,")) ("く" "ク" "�8"))
    ;; -> "きゃく"
    (apply string-append
      (map
        (lambda (x)
          (skk-get-string '() x hira-kata))
        kanalist))))

(define (main args)
  (let ((cmd-action ; 各行ごとに実行する関数
          (lambda (str)
            (let ((kanastr (rk (reverse (string-to-list str))
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
