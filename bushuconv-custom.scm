(require "i18n.scm")

(define bushuconv-im-name-label (N_ "bushuconv"))
(define bushuconv-im-short-desc (N_ "Bushu conversion"))

(define-custom-group 'bushuconv
                     bushuconv-im-name-label
                     bushuconv-im-short-desc)

(define-custom 'bushuconv-bushu-index2-filename ""
  '(bushuconv)
  '(pathname regular-file)
  (N_ "bushu.index2 file (UTF-8)")
  (N_ "long description will be here."))

(define-custom 'bushuconv-bushu-expand-filename ""
  '(bushuconv)
  '(pathname regular-file)
  (N_ "bushu.expand file (UTF-8)")
  (N_ "long description will be here."))

(define-custom 'bushuconv-bushu-help-filename ""
  '(bushuconv)
  '(pathname regular-file)
  (N_ "bushu.help file (UTF-8)")
  (N_ "long description will be here."))

(define-custom 'bushuconv-switch-default-im-after-commit #f
               '(bushuconv)
               '(boolean)
               (N_ "switch to default IM after commit")
               (N_ "long description will be here."))

(define-custom 'bushuconv-switch-default-im-key '("<IgnoreShift>~" "<IgnoreCase><Control>g")
               '(bushuconv)
	       '(key)
	       (N_ "[bushuconv] switch to default IM")
	       (N_ "long description will be here"))

(define-custom 'bushuconv-commit-bushu-key '("tab")
               '(bushuconv)
	       '(key)
	       (N_ "[bushuconv] commit this bushu")
	       (N_ "long description will be here"))

(define-custom 'bushuconv-kanji-as-bushu-key '("right")
               '(bushuconv)
	       '(key)
	       (N_ "[bushuconv] use kanji as bushu")
	       (N_ "long description will be here"))
