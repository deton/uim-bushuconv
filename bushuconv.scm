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

;; XXX: stroke-help candwinクリックすると
;; gtk2/immodule/uim-cand-win-vertical-gtkがSEGVする。delay版で回避
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

;;; stroke-help candwin用のannotation追加や代替候補文字列への置換用alist。
;;; ("候補" "annotation" (("画数" "代替候補文字列")))
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
    ;; 2画
    ("5" "(朽 号 考 与 咢)")
    ("い" "(以)")
    ("う" "(永)")
    ("へ" "(介 今 余 舎)")
    ("よ" "(與)")
    ("イ" "にんべん (化 代)" "イ (にんべん)")
    ("ク" "(色 危 争 夐 憺)")
    ("コ" "(巨 暇 鹿)")
    ("ソ" "(悦 曽 逆 半 平 并)")
    ("ト" "ぼくのと (外 占 卓 攴)")
    ("ナ" "(右 左 布 尤 友 有)")
    ("マ" "(通 勇)")
    ("メ" "(刈 凶 区 肴 殺 爾 駁)")
    ("ラ" "(今)")
    ("リ" "りっとう (利 列)")
    ("風" "(夙 凧 凪 鳳 / 楓 嵐 瘋 虱 諷 颪 颱)" (("2" "(風)"))) ; 2画 / 9画
    ;; 3画
    ("4" "(収、爿)")
    ("ア" "こざとへん (阿 隆)" "ア (こざとへん)")
    ("部" "おおざと (郊 邦)" "(部) (おおざと)")
    ("オ" "てへん (打 払)" "オ (てへん)")
    ("性" "りっしんべん (快 情)" "(性-生) (りっしんべん)")
    ("独" "けものへん (狩 猫)" "(独-虫) (けものへん)")
    ("之" "しんにょう (進 込)" "之 (しんにょう)")
    ("キ" "(半 奉)")
    ("ケ" "(竹 乞 尓)")
    ("サ" "くさかんむり (草 芥)" "サ (くさかんむり)")
    ("シ" "さんずい (海 波)" "シ (さんずい)")
    ("ツ" "(畄 鼡 単)")
    ("ヨ" "(浸 当)")
    ("囗" "くにがまえ (国 固)")
    ;; 4画
    ("え" "2点しんにょう (辷 遙 遽)" "え (2点しんにょう)")
    ("ネ" "ねへん (社 祈)")
    ("ホ" "(痲)")
    ("ヰ" "(舛)")
    ("開" "開-門 (刑 形 研 発)" "(開-門)")
    ("沈" "沈-シ (耽 枕)" "(沈-シ)")
    ("点" "れっか/れんが (焦 然)" "(点-占) (れっか/れんが)")
    ;; 5画
    ("学" "学-子 (営 栄 覚 蛍 労 鴬)" "(学-子)")
    ("実" "実-宀 (春 秦 奏 泰 奉 舂)" "(実-宀)")
    ("初" "ころもへん (袖 被)" "(初-刀) (ころもへん)")
    ("電" "電-雨 (奄 亀 竜 縄 黽)" "(電-雨)")
    ("売" "(壱 壷 壹 孛 / 殻 続)" (("5" "(売-儿)"))) ; 5画 / 7画
    ("病" "やまいだれ (疫 痛)" "(病-丙) (やまいだれ)")
    ;; TODO: 8画側に表示する際は、代替候補文字列でなく元の漢字を使う
    ("並" "(虚 業 晋 普 僕 霊 椪 黹)" (("5" "(並の下側)"))) ; 5画 / 8画
    ("四" "あみがしら (罪 置)")
    ;; 6画
    ("関" "関-門 (咲 送 朕 渕 鎹)" "(関-門)")
    ("受" "(妥 舜 爵 / 授 綬)" (("6" "(受-又)"))) ; 6画 / 8画
    ("追" "追-之 (師 帥 阜)" "(追-之)")
    ("派" "派-シ (脈)" "(派-シ)")
    ;; 7画
    ("度" "(庶 席 / 渡 鍍)" (("7" "(度-又)"))) ; 7画 / 9画
    ("流" "流-シ (疏 琉 硫 旒 梳 毓 醯)" "(流-シ)")
    ;; 8画
    ("検" "検-木 (倹 剣 険 験 鹸 剱)" "(検-木)")
    ("深" "深-シ (探)" "(深-シ)")
    ("朝" "(斡 乾 幹 翰 韓 戟 / 潮 廟 嘲)" (("8" "(朝-月)"))) ; 8画 / 12画
    ;; 9画
    ("滋" "滋-シ (慈 磁)" "(滋-シ)")
    ("湿" "湿-シ (顕 隰)" "(湿-シ)")
    ("新" "(親 / 薪 噺)" (("9" "(新-斤)"))) ; 9画 / 13画
    ("復" "(腹 複 愎 蝮 輹 馥 鰒 / 覆 履)" (("9" "(復-彳)"))) ; 9画 / 12画
    ;; 10画
    ("寒" "寒-冫 (塞 搴 寨 謇 賽 蹇 騫)" "(寒-冫)")
    ("漢" "漢-シ (嘆 歎 難 艱)" "(漢-シ)")
    ("勞" "勞-力 (榮 煢 犖 瑩 癆 螢 鶯)" "(勞-力)")
    ;; 11画
    ("菫" "(僅 勤 謹 槿 瑾 覲 饉)")
    ;; 12画
    ("寮" "寮-宀 (隙 僚 療 瞭 遼 撩 暸 潦 燎 繚 鐐 鷯)" "(寮-宀)")
    ;; 13画
    ("襄" "(壌 嬢 穣 譲 醸 / 壤 孃 攘 曩 禳 穰 讓 釀 驤)") ; 13画 / 17画
    ;; その他
    ("3(その他)" "「蟲」「毳」「橸」等、同じ部品3つから成る漢字の合成用")))

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
      (tutcode-update-preedit tc);XXX:ここでstroke-help windowを表示しても中身空
      ;; XXX: tutcode-candidate-window-use-delay?が#fの場合、
      ;; bushuconvに切替えた時にwidget-configurationでerrorが発生する
      ;; (widgetの初期化が完了する前にdefault-activityが呼ばれるのが原因?)
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
    (tutcode-update-preedit tc))) ; 次のIMに切替えた時preeditが残らないように

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
              (string=? cand "3(その他)")))
      ;; annotation付与(「ア」をこざとへんとして扱っている等)と、
      ;; 代替候補文字列への置換("性"→"(性-生) (りっしんべん)")
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
