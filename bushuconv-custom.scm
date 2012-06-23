(require "i18n.scm")

(define bushuconv-im-name-label (N_ "bushuconv"))
(define bushuconv-im-short-desc (N_ "Bushu conversion"))

(define-custom-group 'bushuconv
                     bushuconv-im-name-label
                     bushuconv-im-short-desc)

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
