;;; Bushu conversion IM.
;;;
;;; Copyright (c) 2012 KIHARA Hideto https://github.com/deton/uim-bushuconv
;;;
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;; 3. Neither the name of authors nor the names of its contributors
;;;    may be used to endorse or promote products derived from this software
;;;    without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS'' AND
;;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
;;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;;; SUCH DAMAGE.
;;;;

(require-extension (srfi 1))
(require "tutcode.scm")
(require-custom "bushuconv-custom.scm")
(require "bushuconv-rule.scm")

;; XXX: stroke-help candwin����å������
;; gtk2/immodule/uim-cand-win-vertical-gtk��SEGV���롣delay�Ǥǲ���
(set! tutcode-candidate-window-use-delay? #t)
(if (>= 0 tutcode-candidate-window-activate-delay-for-stroke-help)
  (set! tutcode-candidate-window-activate-delay-for-stroke-help 1))

(set! tutcode-use-interactive-bushu-conversion? #t)
(if (not (or (eq? candidate-window-style 'table)
              tutcode-use-pseudo-table-style?))
  (set! tutcode-auto-help-with-real-keys? #t))

(define bushuconv-heading-label-char-list-for-prediction-qwerty
  '("a" "s" "d" "f" "g"  "h" "j" "k" "l" ";"
    "z" "x" "c" "v" "b"  "n" "m" "," "." "/"
    "Q" "W" "E" "R" "T"  "Y" "U" "I" "O" "P"
    "A" "S" "D" "F" "G"  "H" "J" "K" "L" "+"
    "Z" "X" "C" "V" "B"  "N" "M" "<" ">" "?"))
(define bushuconv-heading-label-char-list-for-prediction-dvorak
  '("a" "o" "e" "u" "i"  "d" "h" "t" "n" "s"
    ";" "q" "j" "k" "x"  "b" "m" "w" "v" "z"
    "\"" "<" ">" "P" "Y" "F" "G" "C" "R" "L"
    "A" "O" "E" "U" "I"  "D" "H" "T" "N" "S"
    ":" "Q" "J" "K" "X"  "B" "M" "W" "V" "Z"))

(define bushuconv-save-tutcode-heading-label-char-list-for-prediction #f)
(define bushuconv-save-tutcode-use-stroke-help-window? #f)
(define bushuconv-save-tutcode-show-stroke-help-window-on-no-input? #f)
(define bushuconv-save-tutcode-show-pending-rk? #f)
(define bushuconv-save-tutcode-rule #f)
(define bushuconv-save-tutcode-reverse-rule-hash-table #f)
(define bushuconv-save-tutcode-stroke-help-top-page-alist #f)

;;; stroke-help candwin�Ѥ�annotation�ɲä����ظ���ʸ����ؤ��ִ���alist��
;;; ("����" "annotation" (("���" "���ظ���ʸ����")))
(define bushuconv-bushu-annotation-alist
  '(("1" "���Ƥܤ� (�� �� Ĥ Ф)")
    ("7" "(�� �� Т)")
    ("��" "(�� �� ��)")
    ("��" "(�� �� �� Щ)")
    ("��" "(ǵ ��)")
    ("��" "(�� �� ��)")
    ("��" "(�� �� �� ��)")
    ("Ц" "�Ƥ� (�� �� �� ��)")
    ("Ш" "(�� �� �� ֥)")
    ("Э" "�Ϥͤܤ� (�� Я)")
    ;; 2��
    ("5" "(�� �� �� Ϳ ��)")
    ("��" "(��)")
    ("��" "(��)")
    ("��" "(�� �� ; ��)")
    ("��" "(��)")
    ("��" "�ˤ�٤� (�� ��)" "�� (�ˤ�٤�)")
    ("��" "(�� �� �� �� ��)")
    ("��" "(�� �� ��)")
    ("��" "(�� �� �� Ⱦ ʿ ��)")
    ("��" "�ܤ��Τ� (�� �� �� ڽ)")
    ("��" "(�� �� �� �� ͧ ͭ)")
    ("��" "(�� ͦ)")
    ("��" "(�� �� �� �� �� �� ��)")
    ("��" "(��)")
    ("��" "��äȤ� (�� ��)")
    ("��" "(�� �� �� ˱ / �� �� �� �� �� � �)" (("2" "(��)"))) ; 2�� / 9��
    ;; 3��
    ("4" "(�����)")
    ("��" "�����Ȥؤ� (�� δ)" "�� (�����Ȥؤ�)")
    ("��" "�������� (�� ˮ)" "(��) (��������)")
    ("��" "�Ƥؤ� (�� ʧ)" "�� (�Ƥؤ�)")
    ("��" "��ä���٤� (�� ��)" "(��-��) (��ä���٤�)")
    ("��" "����Τؤ� (�� ǭ)" "(��-��) (����Τؤ�)")
    ("Ƿ" "����ˤ礦 (�� ��)" "Ƿ (����ˤ礦)")
    ("��" "(Ⱦ ��)")
    ("��" "(�� �� ��)")
    ("��" "���������� (�� ��)" "�� (����������)")
    ("��" "���󤺤� (�� ��)" "�� (���󤺤�)")
    ("��" "(� �� ñ)")
    ("��" "(�� ��)")
    ("��" "���ˤ��ޤ� (�� ��)")
    ;; 4��
    ("��" "2������ˤ礦 (�� �� �)" "�� (2������ˤ礦)")
    ("��" "�ͤؤ� (�� ��)")
    ("��" "(��)")
    ("��" "(��)")
    ("��" "��-�� (�� �� �� ȯ)" "(��-��)")
    ("��" "��-�� (ÿ ��)" "(��-��)")
    ("��" "��ä�/��� (�� ��)" "(��-��) (��ä�/���)")
    ;; 5��
    ("��" "��-�� (�� �� �� �� ϫ ��)" "(��-��)")
    ("��" "��-�� (�� �� �� �� �� ��)" "(��-��)")
    ("��" "�����ؤ� (µ ��)" "(��-��) (�����ؤ�)")
    ("��" "��-�� (�� �� ε �� ��)" "(��-��)")
    ("��" "(�� �� �� �� / �� ³)" (("5" "(��-ѹ)"))) ; 5�� / 7��
    ("��" "��ޤ����� (�� ��)" "(��-ʺ) (��ޤ�����)")
    ;; TODO: 8��¦��ɽ������ݤϡ����ظ���ʸ����Ǥʤ����δ�����Ȥ�
    ("��" "(�� �� �� �� �� �� ܮ ��)" (("5" "(�¤β�¦)"))) ; 5�� / 8��
    ("��" "���ߤ����� (�� ��)")
    ;; 6��
    ("��" "��-�� (�� �� Ŀ ޼ �)" "(��-��)")
    ("��" "(�� �� �� / �� ��)" (("6" "(��-��)"))) ; 6�� / 8��
    ("��" "��-Ƿ (�� �� ��)" "(��-Ƿ)")
    ("��" "��-�� (̮)" "(��-��)")
    ;; 7��
    ("��" "(�� �� / �� ��)" (("7" "(��-��)"))) ; 7�� / 9��
    ("ή" "ή-�� (�� ΰ β �� �� �� ��)" "(ή-��)")
    ;; 8��
    ("��" "��-�� (�� �� �� �� �� ��)" "(��-��)")
    ("��" "��-�� (õ)" "(��-��)")
    ("ī" "(�� �� �� �� �� �� / Ĭ �� ��)" (("8" "(ī-��)"))) ; 8�� / 12��
    ;; 9��
    ("��" "��-�� (�� ��)" "(��-��)")
    ("��" "��-�� (�� �)" "(��-��)")
    ("��" "(�� / �� ȸ)" (("9" "(��-��)"))) ; 9�� / 13��
    ("��" "(ʢ ʣ ؿ �� �� �� �� / ʤ ��)" (("9" "(��-��)"))) ; 9�� / 12��
    ;; 10��
    ("��" "��-�� (�� �� �� �� �� � ��)" "(��-��)")
    ("��" "��-�� (ò ÷ �� ��)" "(��-��)")
    ("ҩ" "ҩ-�� (�� �� � �� �� � ��)" "(ҩ-��)")
    ;; 11��
    ("��" "(�� �� �� �� �� � �)")
    ;; 12��
    ("��" "��-�� (�� ν �� �� �� �� ۢ ߳ �� �� �� �)" "(��-��)")
    ;; 13��
    ("��" "(�� �� �� �� �� / �� �� ڷ ۨ � �� � �� ��)") ; 13�� / 17��
    ;; ����¾
    ("3(����¾)" "��굡ס��ޡס��������Ʊ������3�Ĥ�����������ι�����")))

(define bushuconv-widgets '(widget_bushuconv_input_mode))
(define default-widget_bushuconv_input_mode 'action_bushuconv_bushuconv)
(define bushuconv-input-mode-actions '(action_bushuconv_bushuconv))
(register-action 'action_bushuconv_bushuconv
                 (lambda (pc)
                  '(nonexisticon "��" "�������" "��������Ѵ��⡼��"))
                 (lambda (pc)
                  #t)
                 (lambda (pc)
                  ;; bushuconv IM�ؤ�����ľ���stroke-help������ɥ�ɽ���Τ���
                  (bushuconv-update-preedit pc)))
(define (bushuconv-configure-widgets)
  (register-widget 'widget_bushuconv_input_mode
                   (activity-indicator-new bushuconv-input-mode-actions)
                   (actions-new bushuconv-input-mode-actions)))
(bushuconv-configure-widgets)

(define bushuconv-context-rec-spec
  (append
    context-rec-spec
    (list
      (list 'tc #f)
      (list 'help-index 0))))

(define-record 'bushuconv-context bushuconv-context-rec-spec)
(define bushuconv-context-new-internal bushuconv-context-new)

(define bushuconv-context-new
  (lambda args
    (let ((pc (apply bushuconv-context-new-internal args)))
      pc)))

(define bushuconv-init-handler
  (lambda (id im arg)
    (define (translate-stroke-help-alist lis translate-alist)
      (map
        (lambda (elem)
          (cons
            (let ((res (assoc (car elem) translate-alist)))
              (if res
                (cadr res)
                (car elem)))
            (cdr elem)))
        lis))
    (define (save-and-set! varsym value)
      (set-symbol-value! (symbol-append 'bushuconv-save- varsym)
        (symbol-value varsym))
      (set-symbol-value! varsym value))
    (save-and-set! 'tutcode-use-stroke-help-window? #t)
    (save-and-set! 'tutcode-show-stroke-help-window-on-no-input? #t)
    (save-and-set! 'tutcode-show-pending-rk? #t)
    (save-and-set! 'tutcode-reverse-rule-hash-table '())
    (if tutcode-use-dvorak?
      (begin
        (save-and-set! 'tutcode-rule
          (tutcode-rule-qwerty-to-dvorak bushuconv-rule))
        (save-and-set! 'tutcode-heading-label-char-list-for-prediction
          bushuconv-heading-label-char-list-for-prediction-dvorak)
        (save-and-set! 'tutcode-stroke-help-top-page-alist
          (translate-stroke-help-alist
            bushuconv-rule-stroke-help-top-page-alist
            tutcode-rule-qwerty-to-dvorak-alist)))
      (begin
        (save-and-set! 'tutcode-rule bushuconv-rule)
        (save-and-set! 'tutcode-heading-label-char-list-for-prediction
          bushuconv-heading-label-char-list-for-prediction-qwerty)
        (save-and-set! 'tutcode-stroke-help-top-page-alist
          bushuconv-rule-stroke-help-top-page-alist)))
    (let ((pc (bushuconv-context-new id im))
          (tc (tutcode-init-handler id im arg)))
      (im-set-delay-activating-handler! im bushuconv-delay-activating-handler)
      (bushuconv-context-set-tc! pc tc)
      (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
      (tutcode-update-preedit tc);XXX:������stroke-help window��ɽ�����Ƥ���ȶ�
      ;; XXX: tutcode-candidate-window-use-delay?��#f�ξ�硢
      ;; bushuconv�����ؤ�������widget-configuration��error��ȯ������
      ;; (widget�ν��������λ��������default-activity���ƤФ��Τ�����?)
      (if (tutcode-candidate-window-enable-delay? tc
            tutcode-candidate-window-activate-delay-for-stroke-help)
        (bushuconv-context-set-widgets! pc bushuconv-widgets))
      pc)))

(define (bushuconv-release-handler pc)
  (define (restore-var! varsym)
    (set-symbol-value! varsym
      (symbol-value (symbol-append 'bushuconv-save- varsym))))
  (im-deactivate-candidate-selector pc)
  (tutcode-release-handler (bushuconv-context-tc pc))
  (restore-var! 'tutcode-use-stroke-help-window?)
  (restore-var! 'tutcode-show-stroke-help-window-on-no-input?)
  (restore-var! 'tutcode-show-pending-rk?)
  (restore-var! 'tutcode-reverse-rule-hash-table)
  (restore-var! 'tutcode-rule)
  (restore-var! 'tutcode-heading-label-char-list-for-prediction)
  (restore-var! 'tutcode-stroke-help-top-page-alist))

(define (bushuconv-update-preedit pc)
  (let ((tc (bushuconv-context-tc pc)))
    (tutcode-update-preedit tc)
    (bushuconv-context-set-help-index! pc 0)
    (tutcode-check-stroke-help-window-begin tc)
    (if (eq? (tutcode-context-candidate-window tc)
              'tutcode-candidate-window-stroke-help)
      (tutcode-select-candidate tc 0))))

;;; ���������ꤵ�줿��硢��������Ū����������Ѵ��⡼�ɤ�����
(define (bushuconv-check-post-commit pc tc)
  (if (not (eq? (tutcode-context-state tc) 'tutcode-state-interactive-bushu))
    (if bushuconv-switch-default-im-after-commit
      (im-switch-im pc default-im-name)
      (begin
        (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
        (tutcode-context-set-prediction-nr! tc 0)
        (bushuconv-update-preedit pc)))
    (bushuconv-update-preedit pc)))

(define (bushuconv-key-press-handler pc key key-state)
  (define (change-help-index pc tc num)
    (let* ((nr-all (length (tutcode-context-stroke-help tc)))
           (idx (bushuconv-context-help-index pc))
           (n (+ idx num))
           (compensated-n
            (cond
             ((>= n nr-all) 0)
             ((< n 0) (- nr-all 1))
             (else n))))
      (bushuconv-context-set-help-index! pc compensated-n)
      (tutcode-select-candidate tc compensated-n)))
  (define (stroke-help-selection-keys? pc tc key key-state)
    (and
      (eq? (tutcode-context-candidate-window tc)
            'tutcode-candidate-window-stroke-help)
      ;; stroke-help�Ϥ�Ȥ��ɽ�������䥦����ɥ��ѤʤΤ�
      ;; �����ڡ����������б��Τ���bushuconv IM���б�
      (not (or (eq? candidate-window-style 'table)
                tutcode-use-pseudo-table-style?))
      (cond
        ((tutcode-next-page-key? key key-state)
          (change-help-index pc tc tutcode-nr-candidate-max-for-kigou-mode)
          #t)
        ((tutcode-prev-page-key? key key-state)
          (change-help-index pc tc (- tutcode-nr-candidate-max-for-kigou-mode))
          #t)
        ((tutcode-next-candidate-key? key key-state)
          (change-help-index pc tc 1)
          #t)
        ((tutcode-prev-candidate-key? key key-state)
          (change-help-index pc tc -1)
          #t)
        ;; stroke help��θ������򡢥�٥���б����륭�������ϤȤ��ƽ���
        ((or (tutcode-commit-key? key key-state)
             (tutcode-return-key? key key-state))
          (let*
            ((idx (bushuconv-context-help-index pc))
             (label (cadr (list-ref (tutcode-context-stroke-help tc) idx)))
             (key (string->ichar label)))
            (bushuconv-key-press-handler pc key 0))
          #t)
        (else
          #f))))
  (if (ichar-control? key)
    (im-commit-raw pc)
    (let ((tc (bushuconv-context-tc pc)))
      (cond
        ((stroke-help-selection-keys? pc tc key key-state)
          )
        ((bushuconv-switch-default-im-key? key key-state)
          (im-switch-im pc default-im-name))
        ((and (bushuconv-commit-bushu-key? key key-state)
              (pair? (tutcode-context-head tc)))
          (tutcode-commit tc (string-list-concat (tutcode-context-head tc)))
          (tutcode-flush tc)
          (bushuconv-check-post-commit pc tc))
        (else
          (tutcode-proc-state-interactive-bushu tc key key-state)
          (bushuconv-check-post-commit pc tc))))))

(define (bushuconv-key-release-handler pc key state)
  (tutcode-key-release-handler (bushuconv-context-tc pc) key state))

(define (bushuconv-reset-handler pc)
  (let ((tc (bushuconv-context-tc pc)))
    (tutcode-reset-handler tc)
    (tutcode-update-preedit tc))) ; ����IM�����ؤ�����preedit���Ĥ�ʤ��褦��

(define (bushuconv-get-candidate-handler pc idx accel-enum-hint)
  (let*
    ((tc (bushuconv-context-tc pc))
     (cand-label-ann (tutcode-get-candidate-handler tc idx accel-enum-hint))
     (cand (car cand-label-ann)))
    (if (and
          (eq? (tutcode-context-candidate-window tc)
                'tutcode-candidate-window-stroke-help)
          (not (or (eq? candidate-window-style 'table)
                    tutcode-use-pseudo-table-style?))
          (or (pair? (rk-context-seq (tutcode-context-rk-context tc)))
              (string=? cand "3(����¾)")))
      ;; annotation��Ϳ(�֥��פ򤳤��Ȥؤ�Ȥ��ư��äƤ�����)�ȡ�
      ;; ���ظ���ʸ����ؤ��ִ�("��"��"(��-��) (��ä���٤�)")
      (let*
        ((kanji-list (tutcode-bushu-included-char-list cand 1))
         (spann-altcand (assoc cand bushuconv-bushu-annotation-alist))
         (kakusu (car (rk-context-seq (tutcode-context-rk-context tc))))
         (altcands (and spann-altcand (safe-car (cddr spann-altcand))))
         (altcand
          (cond
            ((pair? altcands)
              (cond
                ((assoc kakusu altcands) => cadr)
                (else #f)))
            (else altcands)))
         (newcand (or altcand (car cand-label-ann)))
         (ann
          (apply string-append
            (append
              (if spann-altcand
                (list (cadr spann-altcand))
                '(""))
              '("\n")
              kanji-list))))
        (list newcand (cadr cand-label-ann) ann))
      cand-label-ann)))

(define (bushuconv-set-candidate-index-handler pc idx)
  (let ((tc (bushuconv-context-tc pc)))
    ;; stroke-help�Ϥ�Ȥ��ɽ�������䥦����ɥ��ѤʤΤǡ�candwin�����/��
    ;; �ڡ����ܥ��󤬲����줿���Υڡ������ؤ����б��Τ���bushuconv IM���б�
    (if (and
          (eq? (tutcode-context-candidate-window tc)
                'tutcode-candidate-window-stroke-help)
          (not (or (eq? candidate-window-style 'table)
                    tutcode-use-pseudo-table-style?)))
      (let*
        ((page-limit tutcode-nr-candidate-max-for-kigou-mode)
         (prev (bushuconv-context-help-index pc))
         (prev-page (quotient prev page-limit))
         (new-page (quotient idx page-limit)))
        (bushuconv-context-set-help-index! pc idx)
        (if (= new-page prev-page)
          (begin
            (tutcode-set-candidate-index-handler tc idx)
            ;; top stroke-help�����򤵤줿����stroke-help�ǥޥ����Ǥ������ǽ��
            (bushuconv-update-preedit pc))
          (tutcode-select-candidate tc idx)))
      (begin
        (tutcode-set-candidate-index-handler tc idx)
        (bushuconv-check-post-commit pc tc)))))

(define (bushuconv-delay-activating-handler pc)
  (tutcode-delay-activating-handler (bushuconv-context-tc pc)))

(define (bushuconv-focus-in-handler pc)
  (tutcode-focus-in-handler (bushuconv-context-tc pc)))

(define (bushuconv-focus-out-handler pc)
  ;; delayɽ������stroke-help candwin����å���focus-out�����礬�������͡�
  ;; tutcode-focus-out-handler���rk-flush�����Ⱥ���Τǡ��ƤФʤ���
  ;(tutcode-focus-out-handler (bushuconv-context-tc pc))
  #f)

(register-im
 'bushuconv
 "ja"
 "EUC-JP"
 (N_ "bushuconv")
 (N_ "Bushu conversion")
 #f
 bushuconv-init-handler
 bushuconv-release-handler
 context-mode-handler
 bushuconv-key-press-handler
 bushuconv-key-release-handler
 bushuconv-reset-handler
 bushuconv-get-candidate-handler
 bushuconv-set-candidate-index-handler
 context-prop-activate-handler
 #f
 bushuconv-focus-in-handler
 bushuconv-focus-out-handler
 #f
 #f
 )
