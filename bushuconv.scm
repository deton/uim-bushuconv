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

;; XXX: stroke-help candwinクリックすると
;; gtk2/immodule/uim-cand-win-vertical-gtkがSEGVする。delay版で回避
(set! tutcode-candidate-window-use-delay? #t)
(set! tutcode-candidate-window-activate-delay-for-stroke-help 1)

(set! tutcode-use-stroke-help-window? #t)
(set! tutcode-show-stroke-help-window-on-no-input? #t)
(set! tutcode-show-pending-rk? #t)
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
  '(("1" "たてぼう (引 状 弔 个)")
    ("7" "(幻 成 丐)")
    ("く" "(彑 互 瓦)")
    ("し" "(及 丈 匁 乂)")
    ("ろ" "(乃 及)")
    ("レ" "(札 尤 仰)")
    ("乙" "(乞 九 丸 迅)")
    ("丶" "てん (瓦 勺 刃 凡)")
    ("丿" "(介 少 夭 屮)")
    ("亅" "はねぼう (事 亊)")
    ("5" "(朽 号 考 与 咢)")
    ("い" "(以)")
    ("う" "(永)")
    ("へ" "(介 今 余 舎)")
    ("よ" "(與)")
    ("イ" "にんべん (化 代)")
    ("ク" "(色 危 争 夐 憺)")
    ("コ" "(巨 暇 鹿)")
    ("ソ" "(悦 曽 逆 半 平 并)")
    ("ト" "ぼくのと (外 占 卓 攴)")
    ("ナ" "(右 左 布 尤 友 有)")
    ("マ" "(通 勇)")
    ("メ" "(刈 凶 区 肴 殺 爾 駁)")
    ("ラ" "(今)")
    ("リ" "りっとう (利 列)")
    ("4" "(収、爿)")
    ("ア" "こざとへん (阿 隆)")
    ("オ" "てへん (打 払)")
    ("キ" "(半 奉)")
    ("ケ" "(竹 乞 尓)")
    ("サ" "くさかんむり (草 芥)")
    ("シ" "さんずい (海 波)")
    ("ツ" "(畄 鼡 単)")
    ("ヨ" "(浸 当)")
    ("え" "(辷 遙 遽)")
    ("ネ" "ねへん (社 祈)")
    ("ホ" "(痲)")
    ("ヰ" "(舛)")
    ("3" "(森、轟、晶)")))

(define bushuconv-widgets '(widget_bushuconv_input_mode))
(define default-widget_bushuconv_input_mode 'action_bushuconv_bushuconv)
(define bushuconv-input-mode-actions '(action_bushuconv_bushuconv))
(register-action 'action_bushuconv_bushuconv
                 (lambda (pc)
                  '(nonexisticon "部" "部首合成" "部首合成変換モード"))
                 (lambda (pc)
                  #t)
                 (lambda (pc)
                  ;; bushuconv IMへの切替直後にstroke-helpウィンドウ表示のため
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
    (set! tutcode-rule '()) ; XXX: should save old tutcode-rule
    (set! tutcode-rule-filename bushuconv-rule-filename)
    (let ((pc (bushuconv-context-new id im))
          (tc (tutcode-init-handler id im arg)))
      (im-set-delay-activating-handler! im bushuconv-delay-activating-handler)
      (bushuconv-context-set-tc! pc tc)
      (set! tutcode-stroke-help-top-page-alist
        bushuconv-rule-stroke-help-top-page-alist)
      (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
      (tutcode-update-preedit tc);XXX:ここでstroke-help windowを表示しても中身空
      ;; XXX: tutcode-candidate-window-use-delay?が#fの場合、
      ;; bushuconvに切替えた時にwidget-configurationでerrorが発生する
      ;; (widgetの初期化が完了する前にdefault-activityが呼ばれるのが原因?)
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

;;; 漢字が確定された場合、再度対話的な部首合成変換モードに入る
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
      ;; stroke-helpはもともと表形式候補ウィンドウ用なので
      ;; 選択やページ切替非対応のためbushuconv IMで対応
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
        ;; stroke help上の候補確定を、ラベルに対応するキーの入力として処理
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
    (tutcode-update-preedit tc))) ; 次のIMに切替えた時preeditが残らないように

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
      ;; annotationを付与(「ア」をこざとへんとして扱っている等)
      (let ((ann (assoc (car cand-label-ann) bushuconv-bushu-annotation-alist)))
        (if ann
          (append (take cand-label-ann 2) (list (cadr ann)))
          cand-label-ann))
      cand-label-ann)))

(define (bushuconv-set-candidate-index-handler pc idx)
  (let ((tc (bushuconv-context-tc pc)))
    ;; stroke-helpはもともと表形式候補ウィンドウ用なので、candwin上で前/次
    ;; ページボタンが押された時のページ切替え非対応のためbushuconv IMで対応
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
            ;; top stroke-helpで選択された次のstroke-helpでマウスでの選択可能に
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
  ;; delay表示時、stroke-help candwinクリックでfocus-outする場合がある模様。
  ;; tutcode-focus-out-handler内でrk-flushされると困るので、呼ばない。
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
