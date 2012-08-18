#! /usr/bin/env uim-sh
;;; ¥í¡¼¥Þ»ú¤«¤ÊÊÑ´¹¥³¥Þ¥ó¥É¥é¥¤¥ó¥Ä¡¼¥ë¡£
;;;
;;; ¥³¥Þ¥ó¥É¥é¥¤¥ó¤Ç»ØÄê¤µ¤ì¤¿³Æ°ú¿ô(¥í¡¼¥Þ»ú)¤ò¤«¤Ê¤ËÊÑ´¹¡£
;;; °ú¿ô¤¬Ìµ¤¤¾ì¹ç¤Ï¡¢É¸½àÆþÎÏ¤Î³Æ¹Ô¤´¤È¤Ë¼Â¹Ô¡£
;;; ½ÐÎÏ´Á»ú¥³¡¼¥É¤ÏEUC-JP¡£
;;;
;;; ¥ª¥×¥·¥ç¥ó:
;;;   -k, --katakana  ¥«¥¿¥«¥Ê¤Ç½ÐÎÏ¤¹¤ë¡£
;;;   -n              "nna"¤ò"¤ó¤¢"¤Ç¤Ê¤¯"¤ó¤Ê"¤ËÊÑ´¹¤¹¤ë¡£
;;;
;;; $ $PWD/uimsh-rk.scm ittyoume
;;; ¤¤¤Ã¤Á¤ç¤¦¤á
;;; $ $PWD/uimsh-rk.scm -k shoppingu
;;; ¥·¥ç¥Ã¥Ô¥ó¥°
;;; $ $PWD/uimsh-rk.scm shinnyuu
;;; ¤·¤ó¤æ¤¦
;;; $ $PWD/uimsh-rk.scm -n shinnyuu
;;; ¤·¤ó¤Ë¤å¤¦
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
              (cons '((("n" "n"). ("n"))("¤ó" "¥ó" "Ž]")) ja-rk-rule)
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
    ;; ¥ê¥¹¥È¤Î¥ê¥¹¥È¤Ë¤Ê¤Ã¤Æ¤ë¤â¤Î¤ÏÅ¸³«¤¹¤ë¡£
    ;; Îã: "kyaku" -> ((("¤­" "¥­" "Ž7") ("¤ã" "¥ã" "Ž,")) ("¤¯" "¥¯" "Ž8"))
    ;; -> "¤­¤ã¤¯"
    (apply string-append
      (map
        (lambda (x)
          (skk-get-string '() x hira-kata))
        kanalist))))

(define (main args)
  (let ((cmd-action ; ³Æ¹Ô¤´¤È¤Ë¼Â¹Ô¤¹¤ë´Ø¿ô
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
