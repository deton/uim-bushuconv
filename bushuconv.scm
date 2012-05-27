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

(set! tutcode-use-stroke-help-window? #t)
(set! tutcode-show-stroke-help-window-on-no-input? #t)

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
    (set! tutcode-rule '()) ; XXX: should save old tutcode-rule
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

(define (bushuconv-key-press-handler pc key key-state)
  (if (ichar-control? key)
    (im-commit-raw pc)
    (let ((tc (bushuconv-context-tc pc)))
      (cond
        ((bushuconv-switch-default-im-key? key key-state)
          (im-switch-im pc default-im-name))
        (else
          (tutcode-proc-state-interactive-bushu tc key key-state)
          (if (not (eq? (tutcode-context-state tc)
                        'tutcode-state-interactive-bushu)) ;; after commit
            (if bushuconv-switch-default-im-after-commit
              (im-switch-im pc default-im-name)
              (begin
                (tutcode-context-set-state! tc 'tutcode-state-interactive-bushu)
                (tutcode-context-set-prediction-nr! tc 0))))
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
