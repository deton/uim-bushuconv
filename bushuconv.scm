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

(set! tutcode-show-stroke-help-window-on-no-input? #t)
(set! tutcode-use-kigou2-mode? #t)
(if (not (or (eq? candidate-window-style 'table)
              tutcode-use-pseudo-table-style?))
  (set! tutcode-auto-help-with-real-keys? #t))

(define bushuconv-heading-label-char-list-for-prediction-qwerty
  '("a" "s" "d" "f" "g"  "h" "j" "k" "l" ";"
    "z" "x" "c" "v" "b"  "n" "m" "," "." "/"
    "Q" "W" "E" "R" "T"  "Y" "U" "I" "O" "P"
    "A" "S" "D" "F" "G"  "H" "J" "K" "L" "+"
    "Z" "X" "C" "V" "B"  "N" "M" "<" ">" "?"))
(set! tutcode-heading-label-char-list-for-prediction-qwerty
  bushuconv-heading-label-char-list-for-prediction-qwerty)

(define bushuconv-heading-label-char-list-for-prediction-dvorak
  '("a" "s" "d" "f" "g"  "h" "j" "k" "l" ";"
    "z" "x" "c" "v" "b"  "n" "m" "," "." "/"
    "\"" "<" ">" "P" "Y" "F" "G" "C" "R" "L"
    "A" "O" "E" "U" "I"  "D" "H" "T" "N" "S"
    ":" "Q" "J" "K" "X"  "B" "M" "W" "V" "Z"))
(set! tutcode-heading-label-char-list-for-prediction-dvorak
  bushuconv-heading-label-char-list-for-prediction-dvorak)
(set! tutcode-heading-label-char-list-for-prediction
  bushuconv-heading-label-char-list-for-prediction-qwerty)

(define bushuconv-bushu-annotation-alist
  '(("1" "¤¿¤Æ¤Ü¤¦ (°ú ¾õ Ä¤ Ð¤)")
    ("7" "(¸¸ À® Ð¢)")
    ("¤¯" "(×À ¸ß ´¤)")
    ("¤·" "(µÚ ¾æ Ìè Ð©)")
    ("¤í" "(Çµ µÚ)")
    ("¥ì" "(»¥ Ìà ¶Ä)")
    ("²µ" "(¸ð ¶å ´Ý ¿×)")
    ("Ð¦" "¤Æ¤ó (´¤ ¼Û ¿Ï ËÞ)")
    ("Ð¨" "(²ð ¾¯ Ôð Ö¥)")
    ("Ð­" "¤Ï¤Í¤Ü¤¦ (»ö Ð¯)")
    ("5" "(µà ¹æ ¹Í Í¿ Òø)")
    ("¤¤" "(°Ê)")
    ("¤¦" "(±Ê)")
    ("¤Ø" "(²ð º£ Í¾ ¼Ë)")
    ("¤è" "(çÐ)")
    ("¥¤" "¤Ë¤ó¤Ù¤ó (²½ Âå)")
    ("¥¯" "(¿§ ´í Áè Ôë Øë)")
    ("¥³" "(µð ²Ë ¼¯)")
    ("¥½" "(±Ù Á¾ µÕ È¾ Ê¿ Öõ)")
    ("¥È" "¤Ü¤¯¤Î¤È (³° Àê Âî Ú½)")
    ("¥Ê" "(±¦ º¸ ÉÛ Ìà Í§ Í­)")
    ("¥Þ" "(ÄÌ Í¦)")
    ("¥á" "(´¢ ¶§ ¶è ºè »¦ ¼¤ Çý)")
    ("¥é" "(º£)")
    ("¥ê" "¤ê¤Ã¤È¤¦ (Íø Îó)")
    ("4" "(¼ý¡¢à­)")
    ("¥¢" "¤³¤¶¤È¤Ø¤ó (°¤ Î´)")
    ("¥ª" "¤Æ¤Ø¤ó (ÂÇ Ê§)")
    ("¥­" "(È¾ Êô)")
    ("¥±" "(ÃÝ ¸ð Õõ)")
    ("¥µ" "¤¯¤µ¤«¤ó¤à¤ê (Áð ³©)")
    ("¥·" "¤µ¤ó¤º¤¤ (³¤ ÇÈ)")
    ("¥Ä" "(á· óë Ã±)")
    ("¥è" "(¿» Åö)")
    ("¤¨" "(íè ô£ î±)")
    ("¥Í" "¤Í¤Ø¤ó (¼Ò µ§)")
    ("¥Û" "(áä)")
    ("¥ð" "(Á¤)")
    ("3" "(¿¹¡¢¹ì¡¢¾½)")))

(define bushuconv-widgets '(widget_bushuconv_input_mode))
(define default-widget_bushuconv_input_mode 'action_bushuconv_bushuconv)
(define bushuconv-input-mode-actions '(action_bushuconv_bushuconv))
(register-action 'action_bushuconv_bushuconv
                 (lambda (pc)
                  '(nonexisticon "Éô" "Éô¼ó¹çÀ®" "Éô¼ó¹çÀ®ÊÑ´¹¥â¡¼¥É"))
                 (lambda (pc)
                  #t)
                 (lambda (pc)
                  ;; bushuconv IM¤Ø¤ÎÀÚÂØÄ¾¸å¤Ëstroke-help¥¦¥£¥ó¥É¥¦É½¼¨¤Î¤¿¤á
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
    (set! tutcode-kigou-rule '()) ; XXX: should save old tutcode-kigou-rule
    (set! tutcode-kigou-rule bushuconv-rule)
    (set! tutcode-kigou-rule-stroke-help-top-page-alist
      bushuconv-rule-stroke-help-top-page-alist)
    (let ((pc (bushuconv-context-new id im))
          (tc (tutcode-init-handler id im arg)))
      (im-set-delay-activating-handler! im bushuconv-delay-activating-handler)
      (bushuconv-context-set-tc! pc tc)
      (tutcode-context-set-rk-context-another!
        tc (rk-context-new tutcode-kigou-rule #t #f))
      (tutcode-toggle-kigou2-mode tc)
      (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
      (tutcode-update-preedit tc);XXX:¤³¤³¤Çstroke-help window¤òÉ½¼¨¤·¤Æ¤âÃæ¿È¶õ
      ;; XXX: tutcode-candidate-window-use-delay?¤¬#f¤Î¾ì¹ç¡¢
      ;; bushuconv¤ËÀÚÂØ¤¨¤¿»þ¤Ëwidget-configuration¤Çerror¤¬È¯À¸¤¹¤ë
      ;; (widget¤Î½é´ü²½¤¬´°Î»¤¹¤ëÁ°¤Ëdefault-activity¤¬¸Æ¤Ð¤ì¤ë¤Î¤¬¸¶°ø?)
      (if (tutcode-candidate-window-enable-delay? tc
            tutcode-candidate-window-activate-delay-for-stroke-help)
        (bushuconv-context-set-widgets! pc bushuconv-widgets))
      pc)))

(define (bushuconv-release-handler pc)
  (im-deactivate-candidate-selector pc)
  (tutcode-release-handler (bushuconv-context-tc pc)))

(define (bushuconv-update-preedit pc)
  (let ((tc (bushuconv-context-tc pc)))
    (tutcode-update-preedit tc)
    (bushuconv-context-set-help-index! pc 0)
    (tutcode-check-stroke-help-window-begin tc)
    (if (eq? (tutcode-context-candidate-window tc)
              'tutcode-candidate-window-stroke-help)
      (tutcode-select-candidate tc 0))))

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
      ;; stroke-help¤ÏÉ½·Á¼°¸õÊä¥¦¥£¥ó¥É¥¦ÍÑ¤Ê¤Î¤ÇÁªÂò¤ä¥Ú¡¼¥¸ÀÚÂØÈóÂÐ±þ
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
        ;; stroke help¾å¤Î¸õÊä³ÎÄê¤ò¡¢¥é¥Ù¥ë¤ËÂÐ±þ¤¹¤ë¥­¡¼¤ÎÆþÎÏ¤È¤·¤Æ½èÍý
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
        (else
          (tutcode-proc-state-interactive-bushu tc key key-state)
          (if (not (eq? (tutcode-context-state tc)
                        'tutcode-state-interactive-bushu)) ; after commit
            (if bushuconv-switch-default-im-after-commit
              (im-switch-im pc default-im-name)
              (begin
                (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
                (tutcode-context-set-prediction-nr! tc 0))))
          (bushuconv-update-preedit pc))))))

(define (bushuconv-key-release-handler pc key state)
  (tutcode-key-release-handler (bushuconv-context-tc pc) key state))

(define (bushuconv-reset-handler pc)
  (tutcode-reset-handler (bushuconv-context-tc pc)))

(define (bushuconv-get-candidate-handler pc idx accel-enum-hint)
  (let*
    ((tc (bushuconv-context-tc pc))
     (cand-label-ann (tutcode-get-candidate-handler tc idx accel-enum-hint)))
    (if (and
          (eq? (tutcode-context-candidate-window tc)
                'tutcode-candidate-window-stroke-help)
          (not (or (eq? candidate-window-style 'table)
                    tutcode-use-pseudo-table-style?))
          (< 0 (length (rk-context-seq (tutcode-context-rk-context tc)))))
      (let ((ann (assoc (car cand-label-ann) bushuconv-bushu-annotation-alist)))
        (if ann
          (append (take cand-label-ann 2) (list (cadr ann)))
          cand-label-ann))
      cand-label-ann)))

(define (bushuconv-set-candidate-index-handler pc idx)
  (tutcode-set-candidate-index-handler (bushuconv-context-tc pc) idx))

(define (bushuconv-delay-activating-handler pc)
  (tutcode-delay-activating-handler (bushuconv-context-tc pc)))

(define (bushuconv-focus-in-handler pc)
  (tutcode-focus-in-handler (bushuconv-context-tc pc)))

(define (bushuconv-focus-out-handler pc)
  (tutcode-focus-out-handler (bushuconv-context-tc pc)))

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
