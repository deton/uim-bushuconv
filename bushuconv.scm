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
  '(("1" "たてぼう (引 状 弔 个)")
    ("7" "(幻 成 丐)")
    ("く" "(彑 互 瓦)")
    ("し" "右はらい (及 丈 匁 乂)")
    ("ろ" "(乃 及)")
    ("レ" "(札 尤 仰)")
    ("一" "(旦 亰 弖 辷 閂)")
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
    ("七" "(虎 切 宅)")
    ("十" "(支 真 辛 早 直 噴)")
    ("人" "(坐 夾 亥 内)")
    ("丁" "(打 庁 停 寧)")
    ("刀" "(召 切 分)")
    ("二" "(云 元 竺 仁 弐 亘 亞)")
    ("入" "(込 兩)")
    ("八" "(公 穴 只 兵)")
    ("又" "(支 奴 反 殳 曼)")
    ("了" "(亨 丞)")
    ("力" "(加 功 男 労)")
    ("亠" "なべぶた (交 市 卒 亢)")
    ("儿" "(兄 元 兜 虎 俊)")
    ("冂" "(岡 冊 周 舟)")
    ("冖" "わかんむり (軍 冥)")
    ("冫" "(次 冬)")
    ("几" "(机 冗 凡 亢 殳)")
    ("凵" "(凶 凹 函)")
    ("勹" "(句 勺 旬 包)")
    ("匕" "(化 旨 尼 比)")
    ("匚" "")
    ("匸" "")
    ("卩" "")
    ("厂" "")
    ("厶" "(広、払、台)")
    ("4" "(収、爿)")
    ("ア" "こざとへん (阿の左側)")
    ("キ" "(半)")
    ("ケ" "")
    ("サ" "くさかんむり (草の上側)")
    ("シ" "さんずい (海の左側)")
    ("ツ" "(畄の上側)")
    ("ヨ" "(浸、当)")
    ("干" "")
    ("久" "")
    ("弓" "")
    ("巾" "")
    ("己" "")
    ("口" "")
    ("工" "")
    ("才" "てへん (打の左側)")
    ("三" "")
    ("山" "")
    ("士" "")
    ("子" "")
    ("女" "")
    ("小" "")
    ("上" "")
    ("寸" "")
    ("千" "")
    ("川" "")
    ("大" "")
    ("土" "")
    ("之" "")
    ("万" "")
    ("巳" "")
    ("也" "")
    ("夕" "")
    ("于" "")
    ("囗" "")
    ("夂" "")
    ("宀" "うかんむり")
    ("尸" "")
    ("巛" "")
    ("幺" "")
    ("广" "")
    ("廴" "")
    ("廾" "")
    ("弋" "")
    ("彡" "")
    ("彳" "")
    ("え" "えんにょう")
    ("ネ" "ねへん")
    ("ホ" "(痲)")
    ("ヰ" "")
    ("王" "")
    ("火" "")
    ("牙" "")
    ("牛" "")
    ("斤" "")
    ("欠" "")
    ("月" "")
    ("戸" "")
    ("五" "")
    ("午" "")
    ("止" "")
    ("氏" "")
    ("尺" "")
    ("手" "")
    ("心" "")
    ("水" "")
    ("太" "")
    ("中" "")
    ("爪" "")
    ("斗" "")
    ("日" "")
    ("巴" "")
    ("不" "")
    ("夫" "")
    ("父" "")
    ("文" "")
    ("片" "")
    ("方" "")
    ("毛" "")
    ("木" "")
    ("勿" "")
    ("予" "")
    ("六" "")
    ("夬" "")
    ("尹" "")
    ("戈" "")
    ("攵" "")
    ("歹" "")
    ("毋" "")
    ("气" "")
    ("央" "")
    ("可" "")
    ("禾" "")
    ("且" "")
    ("甘" "")
    ("丘" "")
    ("去" "")
    ("玄" "")
    ("乎" "")
    ("古" "")
    ("甲" "")
    ("皿" "")
    ("司" "")
    ("史" "")
    ("四" "")
    ("示" "")
    ("失" "")
    ("主" "")
    ("出" "")
    ("申" "")
    ("世" "")
    ("生" "")
    ("石" "")
    ("田" "")
    ("乍" "")
    ("白" "")
    ("皮" "")
    ("疋" "")
    ("付" "")
    ("戊" "")
    ("母" "")
    ("北" "")
    ("本" "")
    ("末" "")
    ("未" "")
    ("民" "")
    ("目" "")
    ("矢" "")
    ("由" "")
    ("用" "")
    ("立" "")
    ("令" "")
    ("冉" "")
    ("戉" "")
    ("旡" "")
    ("朮" "")
    ("癶" "")
    ("衣" "")
    ("羽" "")
    ("臼" "")
    ("回" "")
    ("休" "")
    ("共" "")
    ("曲" "")
    ("向" "")
    ("行" "")
    ("合" "")
    ("艮" "")
    ("糸" "")
    ("至" "")
    ("寺" "")
    ("而" "")
    ("耳" "")
    ("自" "")
    ("朱" "")
    ("州" "")
    ("西" "")
    ("虫" "")
    ("兆" "")
    ("同" "")
    ("米" "")
    ("亦" "")
    ("羊" "")
    ("朿" "")
    ("耒" "")
    ("聿" "")
    ("亜" "")
    ("貝" "")
    ("角" "")
    ("求" "")
    ("見" "")
    ("言" "")
    ("呉" "")
    ("更" "")
    ("告" "")
    ("車" "")
    ("初" "")
    ("臣" "")
    ("身" "")
    ("赤" "")
    ("走" "")
    ("束" "")
    ("足" "")
    ("辰" "")
    ("谷" "")
    ("沈" "")
    ("弟" "")
    ("豆" "")
    ("酉" "")
    ("売" "")
    ("里" "")
    ("呂" "")
    ("冏" "")
    ("豕" "")
    ("豸" "")
    ("雨" "")
    ("果" "")
    ("学" "")
    ("官" "")
    ("京" "")
    ("金" "")
    ("実" "")
    ("者" "")
    ("受" "")
    ("尚" "")
    ("垂" "")
    ("性" "")
    ("青" "")
    ("斉" "")
    ("其" "")
    ("長" "")
    ("東" "")
    ("非" "")
    ("並" "")
    ("免" "")
    ("門" "")
    ("亟" "")
    ("侖" "")
    ("帚" "")
    ("隹" "")
    ("革" "")
    ("首" "")
    ("乗" "")
    ("食" "")
    ("是" "")
    ("前" "")
    ("段" "")
    ("追" "")
    ("点" "")
    ("度" "")
    ("独" "")
    ("南" "")
    ("派" "")
    ("飛" "")
    ("品" "")
    ("風" "")
    ("頁" "")
    ("面" "")
    ("兪" "")
    ("咸" "")
    ("咼" "")
    ("奐" "")
    ("昜" "")
    ("曷" "")
    ("禺" "")
    ("華" "")
    ("害" "")
    ("鬼" "")
    ("兼" "")
    ("高" "")
    ("骨" "")
    ("馬" "")
    ("莫" "")
    ("病" "")
    ("流" "")
    ("冓" "")
    ("叟" "")
    ("韋" "")
    ("魚" "")
    ("深" "")
    ("部" "")
    ("菫" "")
    ("開" "")
    ("寒" "")
    ("検" "")
    ("滋" "")
    ("湿" "")
    ("朝" "")
    ("復" "")
    ("無" "")
    ("愛" "")
    ("漢" "")
    ("新" "")
    ("鼠" "")
    ("電" "")
    ("関" "")
    ("寮" "")
    ("襄" "")
    ("3" "(森、轟、晶)")))

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
      pc)))

(define (bushuconv-release-handler pc)
  (im-deactivate-candidate-selector pc)
  (tutcode-release-handler (bushuconv-context-tc pc)))

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
      ;; stroke-helpは表形式候補ウィンドウ用なので選択やページ切替非対応
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
          (if (not (eq? (tutcode-context-state tc)
                        'tutcode-state-interactive-bushu)) ; after commit
            (if bushuconv-switch-default-im-after-commit
              (im-switch-im pc default-im-name)
              (begin
                (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
                (tutcode-context-set-prediction-nr! tc 0))))
          (tutcode-update-preedit tc)
          (bushuconv-context-set-help-index! pc 0)
          (tutcode-check-stroke-help-window-begin tc)
          (if (eq? (tutcode-context-candidate-window tc)
                    'tutcode-candidate-window-stroke-help)
            (tutcode-select-candidate tc 0)))))))

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
