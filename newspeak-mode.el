;;; newspeak-mode.el --- Major mode for the Newspeak programming language  -*- lexical-binding:t -*-

;; Author: Daniel Szmulewicz
;; Maintainer: Daniel Szmulewicz <daniel.szmulewicz@gmail.com>
;; Version: 1.0
;; © 2021 Daniel Szmulewicz

;;; Commentary:

;; Major mode to edit Newspeak code (https://newspeaklanguage.org//)

;; Provides the following functionality:
;; - Syntax highlighting.

;;; Code:

(require 'rx)

(defconst newspeak-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\( ". 1" table)
    (modify-syntax-entry ?\) ". 4" table)
    (modify-syntax-entry ?* ". 23" table) ; Comment
    (modify-syntax-entry ?' "\"" table) ; String
    (modify-syntax-entry ?\[ "(]" table) ; Block-open
    (modify-syntax-entry ?\] ")[" table) ; Block-close
    (modify-syntax-entry ?{ "(}" table) ; Array-open
    (modify-syntax-entry ?} "){" table) ; Array-close
    (modify-syntax-entry ?< "(>" table) ; Type-hint-open
    (modify-syntax-entry ?> ")<" table) ; Type-hint-close
    (modify-syntax-entry ?: "w" table)  ; colon is part of word
    table)
  "Newspeak mode syntax table.")

(defgroup newspeak-mode nil
  "Major mode for the Newspeak language"
  :prefix "newspeak-mode-"
  :group 'languages)

;;;###autoload
(add-to-list 'auto-mode-alist `(,(rx ".ns" eos) . newspeak-mode))

(defvar newspeak-prettify-symbols-alist
  '(("^" . ?⇑)
    ("::=" . ?⇐)))

(defconst newspeak-font-lock
  `(;; reserved words
    (,(rx (or "yourself" "self" "super" "outer" "true" "false" "nil" (seq symbol-start "class" symbol-end))) . font-lock-constant-face)
    ;; access modifiers
    (,(rx (or "private" "public" "protected")) . font-lock-builtin-face)
    ;; block arguments
    (,(rx word-start ":" (* alphanumeric)) . font-lock-keyword-face)
    ;; symbol literals
    (,(rx (seq ?# (* alphanumeric))) . font-lock-keyword-face)
    ;; peculiar construct
    (,(rx line-start "Newspeak3" line-end) . font-lock-warning-face)
    ;; class names
    (,(rx word-start upper-case (* alphanumeric)) . font-lock-type-face)
    ;; slots
    (,(rx (seq (or alpha ?_) (* (or alphanumeric ?_)) (+ whitespace) ?= (+ whitespace))) . font-lock-variable-name-face)
    ;; type hints
    (,(rx (seq ?< (* alphanumeric) (zero-or-more (seq ?\[ (zero-or-more (seq (* alphanumeric) ?, whitespace)) (* alphanumeric) ?\])) ?>)) . font-lock-type-face)
    ;; keyword send and setter send
    (,(rx (or alpha ?_) (* (or alphanumeric ?_)) (** 1 2 ?:)) . font-lock-function-name-face)))

;;;###autoload
(define-derived-mode newspeak-mode prog-mode "1984"
  "Major mode for editing Newspeak files."
  (setq-local font-lock-defaults '(newspeak-font-lock))
  (setq-local prettify-symbols-alist newspeak-prettify-symbols-alist))

(provide 'newspeak-mode)

;;; newspeak-mode.el ends here
