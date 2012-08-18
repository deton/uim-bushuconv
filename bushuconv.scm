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

(require-extension (srfi 1 2 8))
(require "tutcode.scm")
(require-custom "bushuconv-custom.scm")
(require "bushuconv-rule.scm")

;;; XXX: bushu34h+.index2は長い行があるためUTF-8が途中で切れてエラーになる。
;;; /usr/local/share/uim/bushuconv-data/bushu34h+.{index2,expand}
(define bushuconv-bushu-index2-filename
  (string-append (sys-pkgdatadir) "/bushuconv-data/"
    (symbol->string bushuconv-kanjiset) ".index2"))
(define bushuconv-bushu-expand-filename
  (string-append (sys-pkgdatadir) "/bushuconv-data/"
    (symbol->string bushuconv-kanjiset) ".expand"))

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

;;; uim-tutcodeと併用可能にするため、変数値の一時保存・再設定用
(define bushuconv-save-vars
  '((tutcode-bushu-index2-filename)
    (tutcode-bushu-expand-filename)
    (tutcode-bushu-help-filename)
    (tutcode-bushu-help)
    (tutcode-bushu-for-char-hash-table)
    (tutcode-heading-label-char-list-for-prediction)
    (tutcode-nr-candidate-max-for-prediction)
    (tutcode-use-stroke-help-window?)
    (tutcode-use-auto-help-window?)
    (tutcode-show-stroke-help-window-on-no-input?)
    (tutcode-show-pending-rk?)
    (tutcode-rule)
    (tutcode-reverse-rule-hash-table)
    (tutcode-stroke-help-top-page-alist)
    (tutcode-bushu-inhibited-output-chars)
    (string-to-list)
    (tutcode-euc-jp-string->ichar)
    (tutcode-do-update-preedit)
    (tutcode-bushu-compose-explicitly)
    (tutcode-bushu-compose-interactively)))

(define (bushuconv-saved-value varsym)
  (cdr (assq varsym bushuconv-save-vars)))

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

;;; EUC-JP前提のuim-tutcodeをUTF-8で使うための差し換え用変数・関数

(define bushuconv-bushu-inhibited-output-chars
  '("え" "し" "へ" "ア" "イ" "ウ" "エ" "オ" "カ" "ク" "ケ" "サ" "シ"
    "タ" "チ" "テ" "ト" "ニ" "ヌ" "ネ" "ノ" "ハ" "ヒ" "ホ" "ム" "メ"
    "ヨ" "リ" "ル" "レ" "ロ" "ワ" "ン"))

;; string-to-list in deprecated-util.scm for "UTF-8"
(define (bushuconv-string-to-list s)
  (with-char-codec "UTF-8"
    (lambda ()
      (map! (lambda (c)
              (let ((str (list->string (list c))))
                (with-char-codec "ISO-8859-1"
                  (lambda ()
                    (%%string-reconstruct! str)))))
            (reverse! (string->list s))))))

;;; hash-tableのキー用に、漢字1文字の文字列から漢字コードに変換する
;;; @param s 文字列
;;; @return 漢字コード。文字列の長さが1でない場合は#f
(define (bushuconv-utf8-string->ichar s)
  ;; ichar.scmのstring->ichar(string->charcode)のUTF-8版
  (let ((sl (with-char-codec "UTF-8"
              (lambda ()
                (string->list s)))))
    (cond
      ((null? sl)
        0)
      ((null? (cdr sl))
        (char->integer (car sl)))
      (else
        #f))))

;;; UTF-8で"▼"を表示するため
(define (bushuconv-do-update-preedit pc)
  (let ((stat (tutcode-context-state pc))
        (cpc (tutcode-context-child-context pc))
        (cursor-shown? #f))
    (case stat
      ((tutcode-state-interactive-bushu)
        (im-pushback-preedit pc preedit-none "▼")
        (let ((h (string-list-concat (tutcode-context-head pc))))
          (if (string? h)
            (im-pushback-preedit pc preedit-none h)))
        (if tutcode-show-pending-rk?
          (im-pushback-preedit pc preedit-underline
            (rk-pending (tutcode-context-rk-context pc))))
        (im-pushback-preedit pc preedit-cursor "")
        (set! cursor-shown? #t)
        (if (> (tutcode-lib-get-nr-predictions pc) 0)
          (begin
            (im-pushback-preedit pc preedit-underline "=>")
            (im-pushback-preedit pc preedit-underline
              (tutcode-get-prediction-string pc
                (tutcode-context-prediction-index pc))))))))) ; 熟語ガイド無し

(define (bushuconv-bushu-lookup-index2 char-list)
  (if (null? (cdr char-list)) ; 部首1つ?
    (delete (car char-list)
      (tutcode-bushu-lookup-index2-entry-internal (car char-list)))
    '()))

;;; 部首1つの場合、その部首を含む漢字のリストをindex2から取得する。
;;; uim-tutcodeでは、部首を2つ以上入力することが前提のため、
;;; 部首1つの場合にindex2の漢字リストが候補に含まれないが、
;;; 部首合成変換IMとしては、部首1つの場合でも漢字候補は出したい。
;;; (XXX:tutcode-bushu-weak-compose-setで1文字の場合に空を返すチェックを外せば
;;; 含まれるようになるが、index2以外の大量の漢字が含まれるので、いまいち)
(define (bushuconv-bushu-compose-explicitly char-list)
  (let
    ((exp ((bushuconv-saved-value 'tutcode-bushu-compose-explicitly) char-list))
     (index2 (bushuconv-bushu-lookup-index2 char-list)))
    (append exp index2)))

;;; 遅いマシン用に、部首1つの時の漢字候補リストとして、
;;; index2ファイルを検索して得られたものだけを使うようにする。
;;; ただし、部首に含まれる部品は漢字候補に含まれなくなる。
(define (bushuconv-bushu-compose-interactively char-list)
  (tutcode-bushu-compose-tc23 char-list
    (and bushuconv-use-only-index2-for-one-bushu
         (pair? (bushuconv-bushu-lookup-index2 char-list)))))

(define bushuconv-context-rec-spec
  (append
    context-rec-spec
    (list
      (list 'tc #f)
      (list 'help-index 0)
      (list 'selection #f)
      (list 'acquire-count 0))))

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
      (set-cdr! (assq varsym bushuconv-save-vars) (symbol-value varsym))
      (set-symbol-value! varsym value))
    (save-and-set! 'tutcode-bushu-index2-filename
      bushuconv-bushu-index2-filename)
    (save-and-set! 'tutcode-bushu-expand-filename
      bushuconv-bushu-expand-filename)
    (save-and-set! 'tutcode-bushu-help-filename bushuconv-bushu-help-filename)
    (save-and-set! 'tutcode-bushu-help '())
    (save-and-set! 'tutcode-bushu-for-char-hash-table (make-hash-table =))
    (save-and-set! 'tutcode-use-stroke-help-window? #t)
    ;; XXX: auto-helpオフ。uim-1.8.1のtutcode-bushu.scmのバグによるerror回避用
    (save-and-set! 'tutcode-use-auto-help-window? #f)
    (save-and-set! 'tutcode-show-stroke-help-window-on-no-input? #t)
    (save-and-set! 'tutcode-show-pending-rk? #t)
    (save-and-set! 'tutcode-reverse-rule-hash-table '())
    (save-and-set! 'tutcode-bushu-inhibited-output-chars
      bushuconv-bushu-inhibited-output-chars)
    (save-and-set! 'string-to-list bushuconv-string-to-list)
    (save-and-set! 'tutcode-euc-jp-string->ichar bushuconv-utf8-string->ichar)
    (save-and-set! 'tutcode-do-update-preedit bushuconv-do-update-preedit)
    (save-and-set! 'tutcode-bushu-compose-explicitly
      bushuconv-bushu-compose-explicitly)
    (save-and-set! 'tutcode-bushu-compose-interactively
      bushuconv-bushu-compose-interactively)
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
    (save-and-set! 'tutcode-nr-candidate-max-for-prediction
      (if (or (eq? candidate-window-style 'table)
              tutcode-use-pseudo-table-style?)
        (length tutcode-heading-label-char-list-for-prediction)
        tutcode-nr-candidate-max-for-prediction))
    (let ((pc (bushuconv-context-new id im))
          (tc (tutcode-init-handler id im arg)))
      (im-set-delay-activating-handler! im bushuconv-delay-activating-handler)
      (bushuconv-context-set-tc! pc tc)
      (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
      (if bushuconv-on-selection
        (let ((sel (tutcode-selection-acquire-text-wo-nl tc)))
          (if (pair? sel)
            (begin
              (bushuconv-context-set-selection! pc sel)
              (tutcode-context-set-head! tc sel)
              (tutcode-begin-interactive-bushu-conversion tc)))))
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
    (set-symbol-value! varsym (cdr (assq varsym bushuconv-save-vars))))
  (let ((sel (bushuconv-context-selection pc)))
    ;; 何も確定せずに戻る場合は、selection文字列を書き戻す。
    ;; Firefoxやqt4の場合、preedit表示時にselectionが上書きされ、
    ;; cancelしても消えたままになるので。
    (if (pair? sel)
      (tutcode-commit (bushuconv-context-tc pc) (string-list-concat sel))))
  (im-deactivate-candidate-selector pc)
  (tutcode-release-handler (bushuconv-context-tc pc))
  (for-each restore-var!
    '(tutcode-bushu-index2-filename tutcode-bushu-expand-filename
      tutcode-bushu-help-filename tutcode-bushu-help
      tutcode-bushu-for-char-hash-table
      tutcode-use-stroke-help-window? tutcode-use-auto-help-window?
      tutcode-show-stroke-help-window-on-no-input? tutcode-show-pending-rk?
      tutcode-reverse-rule-hash-table tutcode-rule
      tutcode-heading-label-char-list-for-prediction 
      tutcode-stroke-help-top-page-alist tutcode-bushu-inhibited-output-chars
      string-to-list tutcode-euc-jp-string->ichar tutcode-do-update-preedit
      tutcode-nr-candidate-max-for-prediction
      tutcode-bushu-compose-explicitly)))

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
    (begin
      (bushuconv-context-set-selection! pc #f)
      (bushuconv-context-set-acquire-count! pc 0)
      (if bushuconv-switch-default-im-after-commit
        (im-switch-im pc default-im-name)
        (begin
          (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
          (tutcode-context-set-prediction-nr! tc 0)
          (bushuconv-update-preedit pc))))
    (bushuconv-update-preedit pc)))

(define (bushuconv-ichar-hexa-numeric? c)
  (or (ichar-numeric? c)
      (and (integer? c)
           (or (<= 65 c 70) (<= 97 c 102)))))

(define (bushuconv-ucsseq->utf8-string ucsseq)
  (and-let*
    ((ucs (string->number (apply string-append ucsseq) 16))
     ;; range check to avoid error
     (valid? ; sigscheme/src/sigschemeinternal.h:ICHAR_VALID_UNICODEP()
      (or
        (<= 0 ucs #xd7ff)
        (<= #xe000 ucs #x10ffff)))
     (utf8-str (ucs->utf8-string ucs)))))
 
;;; U+XXXXXがあったら対応する文字に置換
(define (bushuconv-translate-ucs seq)
  (define (hexloop result seq)
    (receive
      (hexseq rest)
      (span
        (lambda (x)
          (bushuconv-ichar-hexa-numeric? (bushuconv-utf8-string->ichar x)))
        seq)
      (let ((utf8str (bushuconv-ucsseq->utf8-string hexseq)))
        (seqloop
          (if utf8str
            (append! result (list utf8str))
            (append! result '("U" "+") hexseq))
          rest))))
  (define (seqloop result seq)
    (cond
      ((> 3 (length seq))
        (append! result seq))
      ((equal? '("U" "+") (take seq 2))
        (hexloop result (cddr seq)))
      (else
        (seqloop (append! result (list (car seq))) (cdr seq)))))
  (seqloop '() seq))

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
             (tutcode-return-key? key key-state)
             (bushuconv-kanji-as-bushu-key? key key-state))
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
    (let* ((tc (bushuconv-context-tc pc))
           (head (tutcode-context-head tc)))
      (cond
        ((stroke-help-selection-keys? pc tc key key-state)
          )
        ((bushuconv-switch-default-im-key? key key-state)
          (im-switch-im pc default-im-name))
        ((and (bushuconv-commit-bushu-key? key key-state)
              (pair? head))
          (tutcode-commit tc (string-list-concat head))
          (tutcode-flush tc)
          (bushuconv-check-post-commit pc tc))
        ((and (bushuconv-commit-bushu-as-ucs-key? key key-state)
              (pair? head))
          (tutcode-commit tc
            (string-list-concat
              (map
                (lambda (x)
                  (let ((ucs (bushuconv-utf8-string->ichar x)))
                    (if (number? ucs)
                      (format "U+~X" ucs)
                      x)))
                head)))
          (tutcode-flush tc)
          (bushuconv-check-post-commit pc tc))
        ((and (bushuconv-kanji-as-bushu-key? key key-state)
              (> (tutcode-context-prediction-nr tc) 0)) ; has-candidate?
          (let ((str (tutcode-get-prediction-string tc
                      (tutcode-context-prediction-index tc))))
            (if str
              (begin
                (tutcode-context-set-head! tc (list str)) ;合成後の漢字を部首に
                (tutcode-begin-interactive-bushu-conversion tc)
                (bushuconv-update-preedit pc)))))
        ((tutcode-paste-key? key key-state)
          (let ((latter-seq (tutcode-clipboard-acquire-text-wo-nl tc 'full)))
            (if (pair? latter-seq)
              ;; U+XXXXXがあったら対応する文字として貼り付け。
              ;; XXX: 貼り付けた文字を含めると部首合成後の漢字候補が無くなる
              ;; 場合は貼り付けた文字を削除するので、
              ;; 任意の文字が入力できるわけではない。
              (let ((seq
                      (reverse (bushuconv-translate-ucs (reverse latter-seq)))))
                (tutcode-context-set-head! tc (append seq head))
                (tutcode-begin-interactive-bushu-conversion tc)
                (bushuconv-update-preedit pc)))))
        ((bushuconv-acquire-former-char-key? key key-state)
          (let* ((cnt (+ 1 (bushuconv-context-acquire-count pc)))
                 (former-seq (tutcode-postfix-acquire-text tc cnt)))
            (if (<= cnt (length former-seq))
              (begin
                (bushuconv-context-set-acquire-count! pc cnt)
                (tutcode-context-set-head! tc (cons (last former-seq) head))
                (tutcode-begin-interactive-bushu-conversion tc)
                (bushuconv-update-preedit pc))
              (bushuconv-context-set-acquire-count! pc 0))))
        (else
          (tutcode-proc-state-interactive-bushu tc key key-state)
          (bushuconv-check-post-commit pc tc))))))

(define (bushuconv-key-release-handler pc key state)
  (tutcode-key-release-handler (bushuconv-context-tc pc) key state))

(define (bushuconv-reset-handler pc)
  (let ((tc (bushuconv-context-tc pc)))
    (tutcode-reset-handler tc)
    (tutcode-update-preedit tc))) ; 次のIMに切替えた時preeditが残らないように

;;; 指定された漢字がどの集合に含まれるかを判定する
;;; @param str 漢字1文字
;;; @return '(jisx0208 jisx0213-1 jisx0213-2 jisx0212
;;;          ksc5601 gb2312 unicode ascii)のいずれか
(define (bushuconv-detect-kanjiset str)
  ;; uimのtrunkのutil.scmに追加された関数をベースに、
  ;; 呼び出し元でiconv-open失敗#fがわかるようにしたもの
  (define (bushuconv-iconv-convert to-code from-code from-str)
    (and-let* ((ic (iconv-open to-code from-code))
               (to-str (iconv-code-conv ic from-str)))
      (iconv-release ic)
      to-str))
  ;; XXX: ISO-2022-JP-3-strict な変換を期待
  ;; ISO-2022-JP-2004はglibcのiconvには無いが、
  ;; ISO-2022-JP-3で\x1b;$(Qも対応している模様
  (let* ((jis3str (or (bushuconv-iconv-convert "ISO-2022-JP-2004" "UTF-8" str)
                      (bushuconv-iconv-convert "ISO-2022-JP-3" "UTF-8" str)
                      ""))
         (jis3strlen (string-length jis3str)))
    (cond
      ((> jis3strlen 4)
        (let ((escseq (substring jis3str 0 4)))
          (cond
            ((string=? "\x1b;$(P" escseq)
              'jisx0213-2)
            ((string=? "\x1b;$(O" escseq)
              'jisx0213-1)
            ((string=? "\x1b;$(Q" escseq)
              'jisx0213-1) ; 'jisx0213:2004-1
            ((string=? "\x1b;$B" (substring jis3str 0 3))
              'jisx0208)
            (else
              'ascii))))
      ((> jis3strlen 0)
        'ascii)
      (else
        (let ((jisstr (or (bushuconv-iconv-convert "ISO-2022-JP-2" "UTF-8" str)
                          "")))
          (if (> (string-length jisstr) 4)
            (let ((escseq (substring jisstr 0 4)))
              (cond
                ((string=? "\x1b;$(D" escseq)
                  'jisx0212)
                ((string=? "\x1b;$(C" escseq)
                  'ksc5601)
                ((string=? "\x1b;$A" (substring jisstr 0 3))
                  'gb2312)
                (else
                  'unicode)))
            'unicode))))))

(define (bushuconv-get-candidate-handler pc idx accel-enum-hint)
  (define (make-annotation cand spann-altcand kanji-list)
    (if (and enable-annotation?
             ;; 表形式候補ウィンドウはannotation表示未対応
             (not (or (eq? candidate-window-style 'table)
                      tutcode-use-pseudo-table-style?)))
      (let*
        ((ucs (bushuconv-utf8-string->ichar cand))
         (ucsstr (if (number? ucs) (format "U+~X" ucs) ""))
         (kanjiset
          (symbol->string (bushuconv-detect-kanjiset cand))))
        (apply string-append
          (append
            (if spann-altcand
              (list (cadr spann-altcand))
              '(""))
            '("\n")
            (list ucsstr " (" kanjiset ")\n")
            kanji-list)))
      ""))
  (let*
    ((tc (bushuconv-context-tc pc))
     (cand-label-ann (tutcode-get-candidate-handler tc idx accel-enum-hint))
     (cand (car cand-label-ann)))
    (cond
      ;; 対話的な部首合成変換の漢字候補表示
      ((eq? (tutcode-context-candidate-window tc)
        'tutcode-candidate-window-interactive-bushu)
        (let*
          ((ucs (bushuconv-utf8-string->ichar cand))
           (ucsstr (if (number? ucs) (format "U+~X" ucs) ""))
           (kanjiset (symbol->string (bushuconv-detect-kanjiset cand)))
           (ann (string-append ucsstr " (" kanjiset ")")))
          (append (take cand-label-ann 2) (list ann))))
      ;; 仮想鍵盤
      ((eq? (tutcode-context-candidate-window tc)
            'tutcode-candidate-window-stroke-help)
        (cond
          ((pair? (rk-context-seq (tutcode-context-rk-context tc)))
            ;; annotation付与(「ア」をこざとへんとして扱っている等)と、
            ;; 代替候補文字列への置換("性"→"(性-生) (りっしんべん)")
            (let*
              ((spann-altcand (assoc cand bushuconv-bushu-annotation-alist))
               (kakusu
                (safe-car (rk-context-seq (tutcode-context-rk-context tc))))
               (altcands (and spann-altcand (safe-car (cddr spann-altcand))))
               (altcand
                (cond
                  ((pair? altcands)
                    (cond
                      ((assoc kakusu altcands) => cadr)
                      (else #f)))
                  (else altcands)))
               (newcand (or altcand (car cand-label-ann)))
               (ann (make-annotation cand spann-altcand
                      (tutcode-bushu-lookup-index2-entry-internal cand))))
              (list newcand (cadr cand-label-ann) ann)))
          ((and bushuconv-describe-char (string=? cand "*1画"))
            (let ((former-seq (tutcode-postfix-acquire-text tc 1)))
              (if (pair? former-seq)
                (let ((ann (make-annotation
                            (car former-seq) (list #f (car former-seq)) '())))
                  (list cand (cadr cand-label-ann) ann))
                cand-label-ann)))
          (else
            cand-label-ann)))
      (else
        cand-label-ann))))

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
 "UTF-8"
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
