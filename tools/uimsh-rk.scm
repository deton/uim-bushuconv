#! /usr/bin/env uim-sh
;;; ���޻������Ѵ����ޥ�ɥ饤��ġ��롣
;;;
;;; ���ޥ�ɥ饤��ǻ��ꤵ�줿�ư���(���޻�)�򤫤ʤ��Ѵ���
;;; ������̵�����ϡ�ɸ�����ϤγƹԤ��Ȥ˼¹ԡ�
;;; ���ϴ��������ɤ�EUC-JP��
;;;
;;; ���ץ����:
;;;   -k, --katakana  �������ʤǽ��Ϥ��롣
;;;
;;; $ $PWD/uimsh-rk.scm ittyoume
;;; ���ä��礦��
;;; $ $PWD/uimsh-rk.scm -k shoppingu
;;; ����åԥ�
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
         (residual-kana (rk-push-key-last! rkc))
         (kanalist
          (if residual-kana
            (append kanalist0 (list residual-kana))
            kanalist0)))
    ;; �ꥹ�ȤΥꥹ�ȤˤʤäƤ��Τ�Ÿ�����롣
    ;; ��: "kyaku" -> ((("��" "��" "�7") ("��" "��" "�,")) ("��" "��" "�8"))
    ;; -> (("��" "��" "�7") ("��" "��" "�,") ("��" "��" "�8"))
    (fold-right
      (lambda (x res)
        (if (pair? (car x))
          (append x res)
          (cons x res)))
      '()
      kanalist)))

(define (main args)
  (let ((cmd-action ; �ƹԤ��Ȥ˼¹Ԥ���ؿ�
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
