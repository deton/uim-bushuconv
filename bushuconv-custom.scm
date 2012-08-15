(require "i18n.scm")

(define bushuconv-im-name-label (N_ "bushuconv"))
(define bushuconv-im-short-desc (N_ "Bushu conversion"))

(define-custom-group 'bushuconv
                     bushuconv-im-name-label
                     bushuconv-im-short-desc)

(define-custom 'bushuconv-kanjiset 'bushu34
  '(bushuconv)
  (list 'choice
    (list 'bushu34 (N_ "JIS X 0213")
      (N_ "JIS Kanji level 3 and 4 (includes level 1 and 2)"))
    (list 'bushu34h+ (N_ "JIS X 0213 and 0212")
      (N_ "JIS Kanji level 3 and 4 and Hojo Kanji (NOT WORKS on uim-1.8.2)")))
  (N_ "Kanji set")
  (N_ "Kanji set. 'JIS X 0213 and 0212' does not work on uim-1.8.2."))

(define-custom 'bushuconv-bushu-help-filename ""
  '(bushuconv)
  '(pathname regular-file)
  (N_ "bushu.help file (UTF-8)")
  (N_ "long description will be here."))

(define-custom 'bushuconv-on-selection #t
               '(bushuconv)
               '(boolean)
               (N_ "bushu conversion on selection on startup")
               (N_ "long description will be here."))

(define-custom 'bushuconv-use-only-index2-for-one-bushu #f
               '(bushuconv)
               '(boolean)
               (N_ "Use only index2 file for one bushu for performance")
               (N_ "long description will be here."))

(define-custom 'bushuconv-switch-default-im-after-commit #t
               '(bushuconv)
               '(boolean)
               (N_ "switch to default IM after commit")
               (N_ "long description will be here."))

(define-custom 'bushuconv-switch-default-im-key '("<IgnoreCase><Control>g")
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

(define-custom 'bushuconv-commit-as-ucs-key '("left")
               '(bushuconv)
	       '(key)
	       (N_ "[bushuconv] commit as unicode code point (U+xxxx)")
	       (N_ "long description will be here"))
