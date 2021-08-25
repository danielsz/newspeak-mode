;;; newspeak-mode.el --- Major mode for the Newspeak programming language  -*- lexical-binding:t -*-

;; Author: Daniel Szmulewicz
;; Maintainer: Daniel Szmulewicz <daniel.szmulewicz@gmail.com>
;; Version: 1.0
;; © 2021 Daniel Szmulewicz

;;; Commentary:

;; Major mode for Newspeak (https://newspeaklanguage.org//)

;; Provides the following functionality:
;; - Syntax highlighting.

;;; Code:

(require 'rx)
(require 'smie)

;;; syntax table

(defconst newspeak-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\( "() 1" table)
    (modify-syntax-entry ?\) ")( 4" table)
    (modify-syntax-entry ?* ". 23" table) ; Comment
    (modify-syntax-entry ?' "\"" table) ; String
    (modify-syntax-entry ?# "'" table) ; Expression prefix
    (modify-syntax-entry ?: "_" table)  ; colon is part of symbol
    (modify-syntax-entry ?< "(>" table) ; Type-hint-open interferes with rainbow-delimiters mode for symbol >
    (modify-syntax-entry ?> ")<" table) ; Type-hint-close
    table)
  "Newspeak mode syntax table.")

;;;;; Customization

(defgroup newspeak-mode ()
  "Custom group for the Newspeak major mode"
  :group 'languages)


(defgroup newspeak-mode-faces nil
  "Special faces for Newspeak mode."
  :group 'newspeak-mode)

;;;;; font-lock
;;;;; syntax highlighting

(defface newspeak--font-lock-type-face
  '((t (:inherit font-lock-type-face :bold t)))
  "Face description for types"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-builtin-face
  '((t (:inherit font-lock-builtin-face)))
  "Face description for access modifiers"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-constant-face
  '((t (:inherit font-lock-constant-face)))
  "Face description for reserved keywords"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-keyword-face
  '((t (:inherit font-lock-keyword-face)))
  "Face description for block arguments"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-warning-face
  '((t (:inherit font-lock-warning-face)))
  "Face description for `Newspeak3'"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-variable-name-face
  '((t (:inherit font-lock-variable-name-face)))
  "Face description for slot assignments"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-function-name-face
  '((t (:inherit font-lock-function-name-face)))
  "Face description for keyword and setter sends"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-string-face
  '((t (:inherit font-lock-string-face)))
  "Face description for strings"
  :group 'newspeak-mode-faces)

(defface newspeak--font-lock-comment-face
  '((t (:inherit font-lock-comment-face)))
  "Face description for comments"
  :group 'newspeak-mode-faces)

(defvar newspeak-prettify-symbols-alist
  '(("^" . ?⇑)
    ("::=" . ?⇐)))

(defconst newspeak-font-lock
  `(;; reserved words
    (,(rx (or "yourself" "self" "super" "outer" "true" "false" "nil" (seq symbol-start "class" symbol-end))) . 'newspeak--font-lock-constant-face)
    ;; access modifiers
    (,(rx (or "private" "public" "protected")) . 'newspeak--font-lock-builtin-face)
    ;; block arguments
    (,(rx word-start ":" (* alphanumeric)) . 'newspeak--font-lock-keyword-face)
    ;; symbol literals
    (,(rx (seq ?# (* alphanumeric))) . 'newspeak--font-lock-keyword-face)
    ;; peculiar construct
    (,(rx line-start "Newspeak3" line-end) . 'newspeak--font-lock-warning-face)
    ;; class names
    (,(rx word-start upper-case (* alphanumeric)) . 'newspeak--font-lock-type-face)
    ;; slots
    (,(rx (seq (or alpha ?_) (* (or alphanumeric ?_)) (+ whitespace) ?= (+ whitespace))) . 'newspeak--font-lock-variable-name-face)
    ;; type hints
    (,(rx (seq ?< (* alphanumeric) (zero-or-more (seq ?\[ (zero-or-more (seq (* alphanumeric) ?, whitespace)) (* alphanumeric) ?\])) ?>)) . 'newspeak--font-lock-type-face)
    ;; keyword send and setter send
    (,(rx (or alpha ?_) (* (or alphanumeric ?_)) (** 1 2 ?:)) . 'newspeak--font-lock-function-name-face)))

;;;;

(defcustom newspeak--indent-amount 2
  "'Tab size'; used for simple indentation alignment."
  :type 'integer)

;;;; SMIE
;;;; https://www.gnu.org/software/emacs/manual/html_node/elisp/SMIE.html

(defvar newspeak--smie-grammar
  (smie-prec2->grammar
   (smie-bnf->prec2
    '((id)
      (decls (id "=" exp)
	     (decls ":" decls))
      (exp (id)
	   (exp "." exp)))
    '((assoc ":"))
    '((assoc ".")))))

(defun newspeak--smie-rules (method arg)
  "METHOD and ARG is rad."
  (message (concat  "method: " (prin1-to-string method) " arg: " arg " hanging?: " (prin1-to-string (smie-rule-hanging-p))))
  (pcase (cons method arg)
    (`(:before . "=") 0)
    (`(:before . "(") newspeak--indent-amount)
    (`(:after . "(") 0)
    (`(:before . "|") (smie-rule-parent))
    (`(:after . "|") 0)
    (`(:before . ".") (smie-rule-parent))
    (`(:after . ".") 0)
    (`(:elem . arg) newspeak--indent-amount)
    (`(:list-intro . "(") (* 2 newspeak--indent-amount))
    (x newspeak--indent-amount)))

;;;;

(defgroup newspeak-mode nil
  "Major mode for the Newspeak language"
  :prefix "newspeak-mode-"
  :group 'languages)

;;;###autoload
(add-to-list 'auto-mode-alist `(,(rx ".ns" eos) . newspeak-mode))


;;;###autoload
(define-derived-mode newspeak-mode prog-mode "1984"
  "Major mode for editing Newspeak files."
  (setq-local font-lock-defaults '(newspeak-font-lock))
  (setq-local font-lock-string-face 'newspeak--font-lock-string-face)
  (setq-local font-lock-comment-face 'newspeak--font-lock-comment-face)
  (setq-local prettify-symbols-alist newspeak-prettify-symbols-alist)
  (setq-local comment-start "(*")
  (setq-local comment-end "*)")
  (smie-setup newspeak--smie-grammar #'newspeak--smie-rules))

(provide 'newspeak-mode)

;;; newspeak-mode.el ends here
