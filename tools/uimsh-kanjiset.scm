#! /usr/bin/env uim-sh
;;; uim-bushuconv(部首合成変換IM)を使った漢字集合判別コマンドラインツール。
;;;
;;; コマンドラインで指定された各引数(漢字1文字)に対して、漢字集合を判別
;;; (jisx0208, jisx0213-1, jisx0213-2, jisx0212, ksc5601, gb2312,
;;; unicode, ascii)。
;;; 引数が無い場合は、標準入力の各行ごとに実行。
;;; 入力漢字コードはUTF-8。
;;;
;;; (入力:漢字1文字、出力:漢字集合)
;;; $ echo '口' | $PWD/uimsh-kanjiset.scm
;;; jisx0208
(require "bushuconv.scm")
(define (main args)
  (let ((cmd-action ; 各行ごとに実行する関数
          (lambda (str)
            (display
              (apply string-append
                (cdr
                  (append-map
                    (lambda (kanji)
                      (list " "
                        (symbol->string (bushuconv-detect-kanjiset kanji))))
                    (reverse (bushuconv-string-to-list str))))))
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
