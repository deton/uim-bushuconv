#! /usr/bin/env uim-sh
;;; ���޻������Ѵ����ޥ�ɥ饤��ġ��롣
;;;
;;; ���ޥ�ɥ饤��ǻ��ꤵ�줿�ư���(���޻�)�򤫤ʤ��Ѵ���
;;; ������̵�����ϡ�ɸ�����ϤγƹԤ��Ȥ˼¹ԡ�
;;; ���ϴ��������ɤ�EUC-JP��
;;;
;;; ���ץ����:
;;;   -k, --katakana  �������ʤǽ��Ϥ��롣
;;;   -n              "nna"��"��"�Ǥʤ�"���"���Ѵ����롣
;;;
;;; $ $PWD/uimsh-rk.scm ittyoume
;;; ���ä��礦��
;;; $ $PWD/uimsh-rk.scm -k shoppingu
;;; ����åԥ�
;;; $ $PWD/uimsh-rk.scm shinnyuu
;;; ����椦
;;; $ $PWD/uimsh-rk.scm -n shinnyuu
;;; ����ˤ夦
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
              (cons '((("n" "n"). ("n"))("��" "��" "�]")) ja-rk-rule)
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
    ;; �ꥹ�ȤΥꥹ�ȤˤʤäƤ��Τ�Ÿ�����롣
    ;; ��: "kyaku" -> ((("��" "��" "�7") ("��" "��" "�,")) ("��" "��" "�8"))
    ;; -> "���㤯"
    (apply string-append
      (map
        (lambda (x)
          (skk-get-string '() x hira-kata))
        kanalist))))

(define (main args)
  (let ((cmd-action ; �ƹԤ��Ȥ˼¹Ԥ���ؿ�
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
