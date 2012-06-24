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

;; XXX: stroke-help candwin¥¯¥ê¥Ã¥¯¤¹¤ë¤È
;; gtk2/immodule/uim-cand-win-vertical-gtk¤¬SEGV¤¹¤ë¡£delayÈÇ¤Ç²óÈò
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
    ;; 2²è
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
    ("É÷" "(½È Âü Æä Ë± / Éö Íò áæ éÍ ëå ñ¤ ñ¦)") ; 2²è / 9²è
    ;; 3²è
    ("4" "(¼ý¡¢à­)")
    ("¥¢" "¤³¤¶¤È¤Ø¤ó (°¤ Î´)")
    ("Éô" "¤ª¤ª¤¶¤È (¹Ù Ë®)")
    ("¥ª" "¤Æ¤Ø¤ó (ÂÇ Ê§)")
    ("À­" "¤ê¤Ã¤·¤ó¤Ù¤ó (²÷ ¾ð)")
    ("ÆÈ" "¤±¤â¤Î¤Ø¤ó (¼í Ç­)")
    ("Ç·" "¤·¤ó¤Ë¤ç¤¦ (¿Ê ¹þ)")
    ("¥­" "(È¾ Êô)")
    ("¥±" "(ÃÝ ¸ð Õõ)")
    ("¥µ" "¤¯¤µ¤«¤ó¤à¤ê (Áð ³©)")
    ("¥·" "¤µ¤ó¤º¤¤ (³¤ ÇÈ)")
    ("¥Ä" "(á· óë Ã±)")
    ("¥è" "(¿» Åö)")
    ("Óø" "¤¯¤Ë¤¬¤Þ¤¨ (¹ñ ¸Ç)")
    ;; 4²è
    ("¤¨" "2ÅÀ¤·¤ó¤Ë¤ç¤¦ (íè ô£ î±)")
    ("¥Í" "¤Í¤Ø¤ó (¼Ò µ§)")
    ("¥Û" "(áä)")
    ("¥ð" "(Á¤)")
    ("³«" "-Ìç (·º ·Á ¸¦ È¯)")
    ("ÄÀ" "-¥· (Ã¿ Ëí)")
    ("ÅÀ" "¤ì¤Ã¤«/¤ì¤ó¤¬ (¾Ç Á³)")
    ;; 5²è
    ("³Ø" "-»Ò (±Ä ±É ³Ð ·Ö Ï« ²©)")
    ("¼Â" "-Õß (½Õ ¿Á ÁÕ ÂÙ Êô çÎ)")
    ("½é" "¤³¤í¤â¤Ø¤ó (Âµ Èï)")
    ("ÅÅ" "-±« (±â µµ Îµ Æì óæ)")
    ("Çä" "-Ñ¹ (°í ÄÛ Ôå ÕÖ / ³Ì Â³)") ; 5²è / 7²è
    ("ÉÂ" "¤ä¤Þ¤¤¤À¤ì (±Ö ÄË)")
    ("ÊÂ" "(µõ ¶È ¿¸ Éá ËÍ Îî Ü® óã)")
    ("»Í" "¤¢¤ß¤¬¤·¤é (ºá ÃÖ)")
    ;; 6²è
    ("´Ø" "-Ìç (ºé Á÷ Ä¿ Þ¼ ï±)")
    ("¼õ" "-Ëô (ÂÅ ½Ø ¼ß / ¼ø ¼ú)") ; 6²è¡¢8²è
    ("ÄÉ" "-Ç· (»Õ ¿ã Éì)")
    ("ÇÉ" "-¥· (Ì®)")
    ;; 7²è
    ("ÅÙ" "-Ëô (½î ÀÊ / ÅÏ ÅÕ)") ; 7²è / 9²è
    ("Î®" "-¥· (ÁÁ Î° Î² ÚØ Ûà ÝÚ îÑ)")
    ;; 8²è
    ("¸¡" "-ÌÚ (·ð ·õ ¸± ¸³ ¸´ Ñû)")
    ("¿¼" "-¥· (Ãµ)")
    ("Ä«" "-·î (°¶ ´¥ ´´ ´Í ´Ú ·á / Ä¬ ÉÀ ÓÞ)") ; 8²è / 12²è
    ;; 9²è
    ("¼¢" "-¥· (»ü ¼§)")
    ("¼¾" "-¥· (¸² ð®)")
    ("¿·" "-¶Ô (¿Æ / ¿Å È¸)") ; 9²è / 13²è
    ("Éü" "-×Æ (Ê¢ Ê£ Ø¿ éý íÖ ñÆ òØ / Ê¤ Íú)") ; 9²è / 12²è
    ;; 10²è
    ("´¨" "-ÑÒ (ºÉ Ùë ÜÍ ëé ìÐ í¡ ñÚ)")
    ("´Á" "-¥· (Ã² Ã· Æñ çå)")
    ("Ò©" "-ÎÏ (ÜÆ ßé à¸ àò áô ê¥ òô)")
    ;; 11²è
    ("èÁ" "(¶Ï ¶Ð ¶à ÜÝ à÷ ë³ ñ¼)")
    ;; 12²è
    ("ÎÀ" "-Õß (·ä Î½ ÎÅ ÎÆ ÎË Ùü Û¢ ß³ ßù åç ïÁ ó¾)")
    ;; 13²è
    ("ê÷" "(¾í ¾î ¾÷ ¾ù ¾ú / Ôá ÕÐ Ú· Û¨ ãº ãÕ ìª îÖ ñè)") ; 13²è / 17²è
    ;; ¤½¤ÎÂ¾
    ("3(¤½¤ÎÂ¾)" "¡Öêµ¡×¡ÖÝÞ¡×¡ÖÜñ¡×Åù¡¢Æ±¤¸ÉôÉÊ3¤Ä¤«¤éÀ®¤ë´Á»ú¤Î¹çÀ®ÍÑ")))

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
      (tutcode-update-preedit tc);XXX:¤³¤³¤Çstroke-help window¤òÉ½¼¨¤·¤Æ¤âÃæ¿È¶õ
      ;; XXX: tutcode-candidate-window-use-delay?¤¬#f¤Î¾ì¹ç¡¢
      ;; bushuconv¤ËÀÚÂØ¤¨¤¿»þ¤Ëwidget-configuration¤Çerror¤¬È¯À¸¤¹¤ë
      ;; (widget¤Î½é´ü²½¤¬´°Î»¤¹¤ëÁ°¤Ëdefault-activity¤¬¸Æ¤Ð¤ì¤ë¤Î¤¬¸¶°ø?)
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

;;; ´Á»ú¤¬³ÎÄê¤µ¤ì¤¿¾ì¹ç¡¢ºÆÅÙÂÐÏÃÅª¤ÊÉô¼ó¹çÀ®ÊÑ´¹¥â¡¼¥É¤ËÆþ¤ë
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
      ;; stroke-help¤Ï¤â¤È¤â¤ÈÉ½·Á¼°¸õÊä¥¦¥£¥ó¥É¥¦ÍÑ¤Ê¤Î¤Ç
      ;; ÁªÂò¤ä¥Ú¡¼¥¸ÀÚÂØÈóÂÐ±þ¤Î¤¿¤ábushuconv IM¤ÇÂÐ±þ
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
          (bushuconv-check-post-commit pc tc))))))

(define (bushuconv-key-release-handler pc key state)
  (tutcode-key-release-handler (bushuconv-context-tc pc) key state))

(define (bushuconv-reset-handler pc)
  (let ((tc (bushuconv-context-tc pc)))
    (tutcode-reset-handler tc)
    (tutcode-update-preedit tc))) ; ¼¡¤ÎIM¤ËÀÚÂØ¤¨¤¿»þpreedit¤¬»Ä¤é¤Ê¤¤¤è¤¦¤Ë

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
              (string=? cand "3(¤½¤ÎÂ¾)")))
      ;; annotation¤òÉÕÍ¿(¡Ö¥¢¡×¤ò¤³¤¶¤È¤Ø¤ó¤È¤·¤Æ°·¤Ã¤Æ¤¤¤ëÅù)
      (let*
        ((kanji-list (tutcode-bushu-included-char-list cand 1))
         (spann (assoc cand bushuconv-bushu-annotation-alist))
         (ann
          (apply string-append
            (append
              (if spann
                (cdr spann)
                '(""))
              '("\n")
              kanji-list))))
        (append (take cand-label-ann 2) (list ann)))
      cand-label-ann)))

(define (bushuconv-set-candidate-index-handler pc idx)
  (let ((tc (bushuconv-context-tc pc)))
    ;; stroke-help¤Ï¤â¤È¤â¤ÈÉ½·Á¼°¸õÊä¥¦¥£¥ó¥É¥¦ÍÑ¤Ê¤Î¤Ç¡¢candwin¾å¤ÇÁ°/¼¡
    ;; ¥Ú¡¼¥¸¥Ü¥¿¥ó¤¬²¡¤µ¤ì¤¿»þ¤Î¥Ú¡¼¥¸ÀÚÂØ¤¨ÈóÂÐ±þ¤Î¤¿¤ábushuconv IM¤ÇÂÐ±þ
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
            ;; top stroke-help¤ÇÁªÂò¤µ¤ì¤¿¼¡¤Îstroke-help¤Ç¥Þ¥¦¥¹¤Ç¤ÎÁªÂò²ÄÇ½¤Ë
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
  ;; delayÉ½¼¨»þ¡¢stroke-help candwin¥¯¥ê¥Ã¥¯¤Çfocus-out¤¹¤ë¾ì¹ç¤¬¤¢¤ëÌÏÍÍ¡£
  ;; tutcode-focus-out-handlerÆâ¤Çrk-flush¤µ¤ì¤ë¤Èº¤¤ë¤Î¤Ç¡¢¸Æ¤Ð¤Ê¤¤¡£
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
