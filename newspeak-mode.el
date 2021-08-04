;;; newspeak-mode.el --- Major mode for the Newspeak programming language  -*- lexical-binding:t -*-

;; Author: Daniel Szmulewicz
;; Maintainer: Daniel Szmulewicz <daniel.szmulewicz@gmail.com>
;; Version: 1.0
;; © 2021 Daniel Szmulewicz

;;; Commentary:

;; Major mode to edit Newspeak code (https://newspeaklanguage.org//)

;; Provides the following functionality:
;; - Keyword highlighting.

;;; Code:

(require 'rx)

(defconst newspeak-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?:  "." table) ; Symbol-char
    (modify-syntax-entry ?_  "_" table) ; Symbol-char
    (modify-syntax-entry ?\" "!" table) ; Comment (generic)
    (modify-syntax-entry ?'  "\"" table) ; String
    (modify-syntax-entry ?#  "'" table) ; Symbol or Array constant
    (modify-syntax-entry ?\( "()" table) ; Grouping
    (modify-syntax-entry ?\) ")(" table) ; Grouping
    (modify-syntax-entry ?\[ "(]" table) ; Block-open
    (modify-syntax-entry ?\] ")[" table) ; Block-close
    (modify-syntax-entry ?{  "(}" table) ; Array-open
    (modify-syntax-entry ?}  "){" table) ; Array-close
    (modify-syntax-entry ?$  "/" table) ; Character literal
    (modify-syntax-entry ?!  "." table) ; End message / Delimit defs
    (modify-syntax-entry ?\; "." table) ; Cascade
    (modify-syntax-entry ?|  "." table) ; Temporaries
    (modify-syntax-entry ?^  "." table) ; Return
    table)
  "Newspeak mode syntax table.")

(defgroup newspeak-mode nil
  "Major mode for the Newspeak language"
  :prefix "newspeak-mode-"
  :group 'languages)

(add-to-list 'auto-mode-alist '("\\.ns\\'" . newspeak-mode))

(defvar newspeak-identifier (rx (or alpha ?_) (* (or alphanumeric ?_)))
  "A regular expression that matches a Newspeak identifier.")

(defvar newspeak-keyword (concat newspeak-identifier ":") ; (rx (or alpha ?_) (* (or alphanumeric ?_)) ?:)
  "A regular expression that matches a Newspeak keyword.")

(defconst newspeak-font-lock
  `(;; reserved words
    (,(rx (or "self" "super" "outer" "true" "false" "nil")) . font-lock-keyword-face)
    ;; keyword send
    (,(rx (or alpha ?_) (* (or alphanumeric ?_)) ?:) . font-lock-function-name-face)
    ;; numbers
    (,(rx (+ digit)) . font-lock-constant-face)))

(define-derived-mode newspeak-mode prog-mode "1984"
  "Major mode for editing Newspeak files."
  (setq-local font-lock-defaults '(newspeak-font-lock)))

(provide 'newspeak-mode)

;;; newspeak-mode.el ends here
