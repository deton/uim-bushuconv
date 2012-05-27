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

(define bushuconv-switch-default-im-key? (make-key-predicate '("<IgnoreShift>~")))

(define bushuconv-context-rec-spec
  (append
    context-rec-spec
    (list
      (list 'tc #f))))

(define-record 'bushuconv-context bushuconv-context-rec-spec)
(define bushuconv-context-new-internal bushuconv-context-new)

(define bushuconv-context-new
  (lambda args
    (let ((pc (apply bushuconv-context-new-internal args)))
      pc)))

(define bushuconv-init-handler
  (lambda (id im arg)
    (set! tutcode-rule-filename bushuconv-rule-filename)
    (let ((pc (bushuconv-context-new id im))
          (tc (tutcode-init-handler id im arg)))
      (im-set-delay-activating-handler! im bushuconv-delay-activating-handler)
      (bushuconv-context-set-tc! pc tc)
      (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
      pc)))

(define (bushuconv-release-handler pc)
  (im-deactivate-candidate-selector pc)
  (tutcode-release-handler (bushuconv-context-tc pc)))

;;; copy and modified from tutcode-proc-state-interactive-bushu
(define (bushuconv-proc-state-interactive-bushu c key key-state)
  (let*
    ((pc (tutcode-find-descendant-context c))
     (rkc (tutcode-context-rk-context pc))
     (head (tutcode-context-head pc))
     (res #f)
     (has-candidate? (> (tutcode-context-prediction-nr pc) 0))
     ;; 候補表示のページ移動時は、reset-candidate-windowしたら駄目
     (candidate-selection-keys-handled?
      (if has-candidate?
        (cond
          ((tutcode-next-page-key? key key-state)
            (tutcode-change-prediction-page pc #t)
            #t)
          ((tutcode-prev-page-key? key key-state)
            (tutcode-change-prediction-page pc #f)
            #t)
          ((and (tutcode-next-candidate-key? key key-state)
                ;; 2打鍵目のスペースキーの場合は候補選択ではない
                (= (length (rk-context-seq rkc)) 0))
            (tutcode-change-prediction-index pc 1)
            #t)
          ((tutcode-prev-candidate-key? key key-state)
            (tutcode-change-prediction-index pc -1)
            #t)
          (else
            #f))
        #f)))
    (if (not candidate-selection-keys-handled?)
      (begin
        (tutcode-reset-candidate-window pc)
        (cond
          ((tutcode-off-key? key key-state)
           (tutcode-flush pc)
           (tutcode-context-set-prediction-nr! pc 0)
           (tutcode-context-set-state! pc 'tutcode-state-off))
          ;((and (tutcode-kana-toggle-key? key key-state)
          ;      (not (tutcode-kigou2-mode? pc)))
          ; (rk-flush rkc)
          ; (tutcode-context-kana-toggle pc))
          ;((tutcode-kigou2-toggle-key? key key-state)
          ; (rk-flush rkc)
          ; (tutcode-toggle-kigou2-mode pc))
          ((tutcode-backspace-key? key key-state)
           (if (> (length (rk-context-seq rkc)) 0)
            (rk-flush rkc)
            (if (> (length head) 0)
              (begin
                (tutcode-context-set-head! pc (cdr head))
                (if has-candidate?
                  (tutcode-begin-interactive-bushu-conversion pc))))))
          ((or
            (tutcode-commit-key? key key-state)
            (tutcode-return-key? key key-state))
           (let ((str
                  (cond
                    (has-candidate?
                      (tutcode-get-prediction-string pc
                        (tutcode-context-prediction-index pc))) ; 熟語ガイド無
                    ((> (length head) 0)
                      (string-list-concat (tutcode-context-head pc)))
                    (else
                      #f))))
             (if str (tutcode-commit pc str))
             (tutcode-flush pc)
             (tutcode-context-set-prediction-nr! pc 0)
             (if str (tutcode-check-auto-help-window-begin pc (list str) ()))))
          ((tutcode-cancel-key? key key-state)
           (tutcode-context-set-prediction-nr! pc 0)
           (tutcode-flush pc))
          ((tutcode-stroke-help-toggle-key? key key-state)
           (tutcode-toggle-stroke-help pc))
          ((tutcode-paste-key? key key-state)
            (let ((latter-seq (tutcode-clipboard-acquire-text-wo-nl pc 'full)))
              (if (pair? latter-seq)
                (begin
                  (tutcode-context-set-head! pc (append latter-seq head))
                  (tutcode-begin-interactive-bushu-conversion pc)))))
          ((or
            (symbol? key)
            (and
              (modifier-key-mask key-state)
              (not (shift-key-mask key-state))))
           (tutcode-context-set-prediction-nr! pc 0)
           (tutcode-flush pc)
           ;(tutcode-proc-state-on pc key key-state)
           )
          ((and (tutcode-heading-label-char-for-prediction? key)
                (= (length (rk-context-seq rkc)) 0)
                (tutcode-commit-by-label-key-for-prediction pc
                  (charcode->string key)
                  'tutcode-predicting-interactive-bushu)))
          ((not (rk-expect-key? rkc (charcode->string key)))
           (if (> (length (rk-context-seq rkc)) 0)
             (begin
               (if (tutcode-verbose-stroke-key? key key-state)
                 (set! res (last (rk-context-seq rkc))))
               (rk-flush rkc))
             (set! res (charcode->string key))))
          (else
           (set! res (tutcode-push-key! pc (charcode->string key)))))
        (cond
          ((string? res)
            (tutcode-append-string pc res)
            (tutcode-begin-interactive-bushu-conversion pc))
          ((symbol? res)
           (case res
            ((tutcode-auto-help-redisplay)
              (tutcode-auto-help-redisplay pc))
            ;;XXX 部首合成変換中は交ぜ書き変換等は無効にする
            ))
          ((procedure? res)
           (res 'tutcode-state-interactive-bushu pc)))))))

(define (bushuconv-key-press-handler pc key key-state)
  (if (ichar-control? key)
    (im-commit-raw pc)
    (let ((tc (bushuconv-context-tc pc)))
      (cond
        ((bushuconv-switch-default-im-key? key key-state)
          (im-switch-im pc default-im-name))
        (else
          (bushuconv-proc-state-interactive-bushu tc key key-state)
          (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
          (tutcode-update-preedit tc)
          (tutcode-check-stroke-help-window-begin tc))))))

(define (bushuconv-key-release-handler pc key state)
  (tutcode-key-release-handler (bushuconv-context-tc pc) key state))

(define (bushuconv-reset-handler pc)
  (tutcode-reset-handler (bushuconv-context-tc pc)))

(define (bushuconv-get-candidate-handler pc idx accel-enum-hint)
  (tutcode-get-candidate-handler (bushuconv-context-tc pc) idx accel-enum-hint))

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
