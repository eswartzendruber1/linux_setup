;; vpp-mode.el --- major mode for editing vpp source in Emacs

;; Copyright (C) 1996-2013 Free Software Foundation, Inc.

;; Author: Michael McNamara (mac@vpp.com),
;;    Wilson Snyder (wsnyder@wsnyder.org)
;; Please see our web sites:
;;    http://www.vpp.com
;;    http://www.veripool.org
;;
;; Keywords: languages

;; Yoni Rabkin <yoni@rabkins.net> contacted the maintainer of this
;; file on 19/3/2008, and the maintainer agreed that when a bug is
;; filed in the Emacs bug reporting system against this file, a copy
;; of the bug report be sent to the maintainer's email address.

;;    This code supports Emacs 21.1 and later
;;    And XEmacs 21.1 and later
;;    Please do not make changes that break Emacs 21.  Thanks!
;;
;;

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This mode borrows heavily from the Pascal-mode and the cc-mode of Emacs

;; USAGE
;; =====

;; A major mode for editing Vpp HDL source code.  When you have
;; entered Vpp mode, you may get more info by pressing C-h m. You
;; may also get online help describing various functions by: C-h f
;; <Name of function you want described>

;; KNOWN BUGS / BUG REPORTS
;; =======================

;; Vpp is a rapidly evolving language, and hence this mode is
;; under continuous development.  Hence this is beta code, and likely
;; has bugs.  Please report any issues to the issue tracker at
;; http://www.veripool.org/vpp-mode
;; Please use vpp-submit-bug-report to submit a report; type C-c
;; C-b to invoke this and as a result I will have a much easier time
;; of reproducing the bug you find, and hence fixing it.

;; INSTALLING THE MODE
;; ===================

;; An older version of this mode may be already installed as a part of
;; your environment, and one method of updating would be to update
;; your Emacs environment.  Sometimes this is difficult for local
;; political/control reasons, and hence you can always install a
;; private copy (or even a shared copy) which overrides the system
;; default.

;; You can get step by step help in installing this file by going to
;; <http://www.vpp.com/emacs_install.html>

;; The short list of installation instructions are: To set up
;; automatic Vpp mode, put this file in your load path, and put
;; the following in code (please un comment it first!) in your
;; .emacs, or in your site's site-load.el

; (autoload 'vpp-mode "vpp-mode" "Vpp mode" t )
; (add-to-list 'auto-mode-alist '("\\.[ds]?vh?\\'" . vpp-mode))

;; Be sure to examine at the help for vpp-auto, and the other
;; vpp-auto-* functions for some major coding time savers.
;;
;; If you want to customize Vpp mode to fit your needs better,
;; you may add the below lines (the values of the variables presented
;; here are the defaults). Note also that if you use an Emacs that
;; supports custom, it's probably better to use the custom menu to
;; edit these.  If working as a member of a large team these settings
;; should be common across all users (in a site-start file), or set
;; in Local Variables in every file.  Otherwise, different people's
;; AUTO expansion may result different whitespace changes.
;;
; ;; Enable syntax highlighting of **all** languages
; (global-font-lock-mode t)
;
; ;; User customization for Vpp mode
; (setq vpp-indent-level             3
;       vpp-indent-level-module      3
;       vpp-indent-level-declaration 3
;       vpp-indent-level-behavioral  3
;       vpp-indent-level-directive   1
;       vpp-case-indent              2
;       vpp-auto-newline             t
;       vpp-auto-indent-on-newline   t
;       vpp-tab-always-indent        t
;       vpp-auto-endcomments         t
;       vpp-minimum-comment-distance 40
;       vpp-indent-begin-after-if    t
;       vpp-auto-lineup              'declarations
;       vpp-highlight-p1800-keywords nil
;	vpp-linter			 "my_lint_shell_command"
;	)

;; 

;;; History:
;;
;; See commit history at http://www.veripool.org/vpp-mode.html
;; (This section is required to appease checkdoc.)

;;; Code:

;; This variable will always hold the version number of the mode
(defconst vpp-mode-version (substring "$$Revision: 840 $$" 12 -3)
  "Version of this Vpp mode.")
(defconst vpp-mode-release-date (substring "$$Date: 2013-01-03 05:29:05 -0800 (Thu, 03 Jan 2013) $$" 8 -3)
  "Release date of this Vpp mode.")
(defconst vpp-mode-release-emacs nil
  "If non-nil, this version of Vpp mode was released with Emacs itself.")

(defun vpp-version ()
  "Inform caller of the version of this file."
  (interactive)
  (message "Using vpp-mode version %s" vpp-mode-version))

;; Insure we have certain packages, and deal with it if we don't
;; Be sure to note which Emacs flavor and version added each feature.
(eval-when-compile
  ;; Provide stuff if we are XEmacs
  (when (featurep 'xemacs)
    (condition-case nil
        (require 'easymenu)
      (error nil))
    (condition-case nil
        (require 'regexp-opt)
      (error nil))
    ;; Bug in 19.28 through 19.30 skeleton.el, not provided.
    (condition-case nil
        (load "skeleton")
      (error nil))
    (condition-case nil
        (if (fboundp 'when)
            nil ;; fab
          (defmacro when (cond &rest body)
            (list 'if cond (cons 'progn body))))
      (error nil))
    (condition-case nil
        (if (fboundp 'unless)
            nil ;; fab
          (defmacro unless (cond &rest body)
            (cons 'if (cons cond (cons nil body)))))
      (error nil))
    (condition-case nil
        (if (fboundp 'store-match-data)
            nil ;; fab
          (defmacro store-match-data (&rest args) nil))
      (error nil))
    (condition-case nil
        (if (fboundp 'char-before)
            nil ;; great
          (defmacro char-before (&rest body)
            (char-after (1- (point)))))
      (error nil))
    (condition-case nil
        (if (fboundp 'when)
            nil ;; fab
          (defsubst point-at-bol (&optional N)
            (save-excursion (beginning-of-line N) (point))))
      (error nil))
    (condition-case nil
        (if (fboundp 'when)
            nil ;; fab
          (defsubst point-at-eol (&optional N)
            (save-excursion (end-of-line N) (point))))
      (error nil))
    (condition-case nil
        (require 'custom)
      (error nil))
    (condition-case nil
        (if (fboundp 'match-string-no-properties)
            nil ;; great
          (defsubst match-string-no-properties (num &optional string)
            "Return string of text matched by last search, without text properties.
NUM specifies which parenthesized expression in the last regexp.
 Value is nil if NUMth pair didn't match, or there were less than NUM pairs.
Zero means the entire text matched by the whole regexp or whole string.
STRING should be given if the last search was by `string-match' on STRING."
            (if (match-beginning num)
                (if string
                    (let ((result
                           (substring string
				      (match-beginning num) (match-end num))))
                      (set-text-properties 0 (length result) nil result)
                      result)
                  (buffer-substring-no-properties (match-beginning num)
                                                  (match-end num)
                                                  (current-buffer)))))
	  )
      (error nil))
    (if (and (featurep 'custom) (fboundp 'custom-declare-variable))
        nil ;; We've got what we needed
      ;; We have the old custom-library, hack around it!
      (defmacro defgroup (&rest args)  nil)
      (defmacro customize (&rest args)
        (message
	 "Sorry, Customize is not available with this version of Emacs"))
      (defmacro defcustom (var value doc &rest args)
        `(defvar ,var ,value ,doc))
      )
    (if (fboundp 'defface)
        nil				; great!
      (defmacro defface (var values doc &rest args)
        `(make-face ,var))
      )

    (if (and (featurep 'custom) (fboundp 'customize-group))
        nil ;; We've got what we needed
      ;; We have an intermediate custom-library, hack around it!
      (defmacro customize-group (var &rest args)
        `(customize ,var))
      )

    (unless (boundp 'inhibit-point-motion-hooks)
      (defvar inhibit-point-motion-hooks nil))
    (unless (boundp 'deactivate-mark)
      (defvar deactivate-mark nil))
    )
  ;;
  ;; OK, do this stuff if we are NOT XEmacs:
  (unless (featurep 'xemacs)
    (unless (fboundp 'region-active-p)
      (defmacro region-active-p ()
	`(and transient-mark-mode mark-active))))
  )

;; Provide a regular expression optimization routine, using regexp-opt
;; if provided by the user's elisp libraries
(eval-and-compile
  ;; The below were disabled when GNU Emacs 22 was released;
  ;; perhaps some still need to be there to support Emacs 21.
  (if (featurep 'xemacs)
      (if (fboundp 'regexp-opt)
          ;; regexp-opt is defined, does it take 3 or 2 arguments?
          (if (fboundp 'function-max-args)
              (let ((args (function-max-args `regexp-opt)))
                (cond
                 ((eq args 3) ;; It takes 3
                  (condition-case nil	; Hide this defun from emacses
					;with just a two input regexp
                      (defun vpp-regexp-opt (a b)
                        "Deal with differing number of required arguments for  `regexp-opt'.
         Call 'regexp-opt' on A and B."
                        (regexp-opt a b 't))
                    (error nil))
                  )
                 ((eq args 2) ;; It takes 2
                  (defun vpp-regexp-opt (a b)
                    "Call 'regexp-opt' on A and B."
                    (regexp-opt a b))
                  )
                 (t nil)))
            ;; We can't tell; assume it takes 2
            (defun vpp-regexp-opt (a b)
              "Call 'regexp-opt' on A and B."
              (regexp-opt a b))
            )
        ;; There is no regexp-opt, provide our own
        (defun vpp-regexp-opt (strings &optional paren shy)
          (let ((open (if paren "\\(" "")) (close (if paren "\\)" "")))
            (concat open (mapconcat 'regexp-quote strings "\\|") close)))
        )
    ;; Emacs.
    (defalias 'vpp-regexp-opt 'regexp-opt)))

(eval-and-compile
  ;; Both xemacs and emacs
  (condition-case nil
      (require 'diff) ;; diff-command and diff-switches
    (error nil))
  (condition-case nil
      (require 'compile) ;; compilation-error-regexp-alist-alist
    (error nil))
  (condition-case nil
      (unless (fboundp 'buffer-chars-modified-tick)  ;; Emacs 22 added
	(defmacro buffer-chars-modified-tick () (buffer-modified-tick)))
    (error nil))
  ;; Added in Emacs 24.1
  (condition-case nil
      (unless (fboundp 'prog-mode)
	(define-derived-mode prog-mode fundamental-mode "Prog"))
    (error nil)))

(eval-when-compile
  (defun vpp-regexp-words (a)
    "Call 'regexp-opt' with word delimiters for the words A."
    (concat "\\<" (vpp-regexp-opt a t) "\\>")))
(defun vpp-regexp-words (a)
  "Call 'regexp-opt' with word delimiters for the words A."
  ;; The FAQ references this function, so user LISP sometimes calls it
  (concat "\\<" (vpp-regexp-opt a t) "\\>"))

(defun vpp-easy-menu-filter (menu)
  "Filter `easy-menu-define' MENU to support new features."
  (cond ((not (featurep 'xemacs))
	 menu) ;; GNU Emacs - passthru
	;; XEmacs doesn't support :help.  Strip it.
	;; Recursively filter the a submenu
	((listp menu)
	 (mapcar 'vpp-easy-menu-filter menu))
	;; Look for [:help "blah"] and remove
	((vectorp menu)
	 (let ((i 0) (out []))
	   (while (< i (length menu))
	     (if (equal `:help (aref menu i))
		 (setq i (+ 2 i))
	       (setq out (vconcat out (vector (aref menu i)))
		     i (1+ i))))
	   out))
	(t menu))) ;; Default - ok
;;(vpp-easy-menu-filter
;;  `("Vpp" ("MA" ["SAA" nil :help "Help SAA"] ["SAB" nil :help "Help SAA"])
;;     "----" ["MB" nil :help "Help MB"]))

(defun vpp-define-abbrev (table name expansion &optional hook)
  "Filter `define-abbrev' TABLE NAME EXPANSION and call HOOK.
Provides SYSTEM-FLAG in newer Emacs."
  (condition-case nil
      (define-abbrev table name expansion hook 0 t)
    (error
     (define-abbrev table name expansion hook))))

(defun vpp-customize ()
  "Customize variables and other settings used by Vpp-Mode."
  (interactive)
  (customize-group 'vpp-mode))

(defun vpp-font-customize ()
  "Customize fonts used by Vpp-Mode."
  (interactive)
  (if (fboundp 'customize-apropos)
      (customize-apropos "font-lock-*" 'faces)))

(defun vpp-booleanp (value)
  "Return t if VALUE is boolean.
This implements GNU Emacs 22.1's `booleanp' function in earlier Emacs.
This function may be removed when Emacs 21 is no longer supported."
  (or (equal value t) (equal value nil)))

(defun vpp-insert-last-command-event ()
  "Insert the `last-command-event'."
  (insert (if (featurep 'xemacs)
	      ;; XEmacs 21.5 doesn't like last-command-event
	      last-command-char
	    ;; And GNU Emacs 22 has obsoleted last-command-char
	    last-command-event)))

(defvar vpp-no-change-functions nil
  "True if `after-change-functions' is disabled.
Use of `syntax-ppss' may break, as ppss's cache may get corrupted.")

(defvar vpp-in-hooks nil
  "True when within a `vpp-run-hooks' block.")

(defmacro vpp-run-hooks (&rest hooks)
  "Run each hook in HOOKS using `run-hooks'.
Set `vpp-in-hooks' during this time, to assist AUTO caches."
  `(let ((vpp-in-hooks t))
     (run-hooks ,@hooks)))

(defun vpp-syntax-ppss (&optional pos)
  (when vpp-no-change-functions
    (if vpp-in-hooks
	(vpp-scan-cache-flush)
      ;; else don't let the AUTO code itself get away with flushing the cache,
      ;; as that'll make things very slow
      (backtrace)
      (error "%s: Internal problem; use of syntax-ppss when cache may be corrupt"
	     (vpp-point-text))))
  (if (fboundp 'syntax-ppss)
      (syntax-ppss pos)
    (parse-partial-sexp (point-min) (or pos (point)))))

(defgroup vpp-mode nil
  "Major mode for Vpp source code."
  :version "22.2"
  :group 'languages)

; (defgroup vpp-mode-fonts nil
;   "Facilitates easy customization fonts used in Vpp source text"
;   :link '(customize-apropos "font-lock-*" 'faces)
;  :group 'vpp-mode)

(defgroup vpp-mode-indent nil
  "Customize indentation and highlighting of Vpp source text."
  :group 'vpp-mode)

(defgroup vpp-mode-actions nil
  "Customize actions on Vpp source text."
  :group 'vpp-mode)

(defgroup vpp-mode-auto nil
  "Customize AUTO actions when expanding Vpp source text."
  :group 'vpp-mode)

(defvar vpp-debug nil
  "Non-nil means enable debug messages for `vpp-mode' internals.")

(defvar vpp-warn-fatal nil
  "Non-nil means `vpp-warn-error' warnings are fatal `error's.")

(defcustom vpp-linter
  "echo 'No vpp-linter set, see \"M-x describe-variable vpp-linter\"'"
  "Unix program and arguments to call to run a lint checker on Vpp source.
Depending on the `vpp-set-compile-command', this may be invoked when
you type \\[compile].  When the compile completes, \\[next-error] will take
you to the next lint error."
  :type 'string
  :group 'vpp-mode-actions)
;; We don't mark it safe, as it's used as a shell command

(defcustom vpp-coverage
  "echo 'No vpp-coverage set, see \"M-x describe-variable vpp-coverage\"'"
  "Program and arguments to use to annotate for coverage Vpp source.
Depending on the `vpp-set-compile-command', this may be invoked when
you type \\[compile].  When the compile completes, \\[next-error] will take
you to the next lint error."
  :type 'string
  :group 'vpp-mode-actions)
;; We don't mark it safe, as it's used as a shell command

(defcustom vpp-simulator
  "echo 'No vpp-simulator set, see \"M-x describe-variable vpp-simulator\"'"
  "Program and arguments to use to interpret Vpp source.
Depending on the `vpp-set-compile-command', this may be invoked when
you type \\[compile].  When the compile completes, \\[next-error] will take
you to the next lint error."
  :type 'string
  :group 'vpp-mode-actions)
;; We don't mark it safe, as it's used as a shell command

(defcustom vpp-compiler
  "echo 'No vpp-compiler set, see \"M-x describe-variable vpp-compiler\"'"
  "Program and arguments to use to compile Vpp source.
Depending on the `vpp-set-compile-command', this may be invoked when
you type \\[compile].  When the compile completes, \\[next-error] will take
you to the next lint error."
  :type 'string
  :group 'vpp-mode-actions)
;; We don't mark it safe, as it's used as a shell command

(defcustom vpp-preprocessor
  ;; Very few tools give preprocessed output, so we'll default to Vpp-Perl
  "vppreproc __FLAGS__ __FILE__"
  "Program and arguments to use to preprocess Vpp source.
This is invoked with `vpp-preprocess', and depending on the
`vpp-set-compile-command', may also be invoked when you type
\\[compile].  When the compile completes, \\[next-error] will
take you to the next lint error."
  :type 'string
  :group 'vpp-mode-actions)
;; We don't mark it safe, as it's used as a shell command

(defvar vpp-preprocess-history nil
  "History for `vpp-preprocess'.")

(defvar vpp-tool 'vpp-linter
  "Which tool to use for building compiler-command.
Either nil, `vpp-linter, `vpp-compiler,
`vpp-coverage, `vpp-preprocessor, or `vpp-simulator.
Alternatively use the \"Choose Compilation Action\" menu.  See
`vpp-set-compile-command' for more information.")

(defcustom vpp-highlight-translate-off nil
  "Non-nil means background-highlight code excluded from translation.
That is, all code between \"// synopsys translate_off\" and
\"// synopsys translate_on\" is highlighted using a different background color
\(face `vpp-font-lock-translate-off-face').

Note: This will slow down on-the-fly fontification (and thus editing).

Note: Activate the new setting in a Vpp buffer by re-fontifying it (menu
entry \"Fontify Buffer\").  XEmacs: turn off and on font locking."
  :type 'boolean
  :group 'vpp-mode-indent)
;; Note we don't use :safe, as that would break on Emacsen before 22.0.
(put 'vpp-highlight-translate-off 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-lineup 'declarations
  "Type of statements to lineup across multiple lines.
If 'all' is selected, then all line ups described below are done.

If 'declarations', then just declarations are lined up with any
preceding declarations, taking into account widths and the like,
so or example the code:
 	reg [31:0] a;
 	reg b;
would become
 	reg [31:0] a;
 	reg        b;

If 'assignment', then assignments are lined up with any preceding
assignments, so for example the code
	a_long_variable <= b + c;
	d = e + f;
would become
	a_long_variable <= b + c;
	d                = e + f;

In order to speed up editing, large blocks of statements are lined up
only when a \\[vpp-pretty-expr] is typed; and large blocks of declarations
are lineup only when \\[vpp-pretty-declarations] is typed."

  :type '(radio (const :tag "Line up Assignments and Declarations" all)
		(const :tag "Line up Assignment statements" assignments )
		(const :tag "Line up Declarations" declarations)
		(function :tag "Other"))
  :group 'vpp-mode-indent )
(put 'vpp-auto-lineup 'safe-local-variable
     '(lambda (x) (memq x '(nil all assignments declarations))))

(defcustom vpp-indent-level 3
  "Indentation of Vpp statements with respect to containing block."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-indent-level 'safe-local-variable 'integerp)

(defcustom vpp-indent-level-module 3
  "Indentation of Module level Vpp statements (eg always, initial).
Set to 0 to get initial and always statements lined up on the left side of
your screen."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-indent-level-module 'safe-local-variable 'integerp)

(defcustom vpp-indent-level-declaration 3
  "Indentation of declarations with respect to containing block.
Set to 0 to get them list right under containing block."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-indent-level-declaration 'safe-local-variable 'integerp)

(defcustom vpp-indent-declaration-macros nil
  "How to treat macro expansions in a declaration.
If nil, indent as:
	input [31:0] a;
	input        `CP;
	output       c;
If non nil, treat as:
	input [31:0] a;
	input `CP    ;
	output       c;"
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-indent-declaration-macros 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-indent-lists t
  "How to treat indenting items in a list.
If t (the default), indent as:
	always @( posedge a or
	          reset ) begin

If nil, treat as:
	always @( posedge a or
	   reset ) begin"
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-indent-lists 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-indent-level-behavioral 3
  "Absolute indentation of first begin in a task or function block.
Set to 0 to get such code to start at the left side of the screen."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-indent-level-behavioral 'safe-local-variable 'integerp)

(defcustom vpp-indent-level-directive 1
  "Indentation to add to each level of `ifdef declarations.
Set to 0 to have all directives start at the left side of the screen."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-indent-level-directive 'safe-local-variable 'integerp)

(defcustom vpp-cexp-indent 2
  "Indentation of Vpp statements split across lines."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-cexp-indent 'safe-local-variable 'integerp)

(defcustom vpp-case-indent 2
  "Indentation for case statements."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-case-indent 'safe-local-variable 'integerp)

(defcustom vpp-auto-newline t
  "Non-nil means automatically newline after semicolons."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-auto-newline 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-indent-on-newline t
  "Non-nil means automatically indent line after newline."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-auto-indent-on-newline 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-tab-always-indent t
  "Non-nil means TAB should always re-indent the current line.
A nil value means TAB will only reindent when at the beginning of the line."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-tab-always-indent 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-tab-to-comment nil
  "Non-nil means TAB moves to the right hand column in preparation for a comment."
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-tab-to-comment 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-indent-begin-after-if t
  "Non-nil means indent begin statements following if, else, while, etc.
Otherwise, line them up."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-indent-begin-after-if 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-align-ifelse nil
  "Non-nil means align `else' under matching `if'.
Otherwise else is lined up with first character on line holding matching if."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-align-ifelse 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-minimum-comment-distance 10
  "Minimum distance (in lines) between begin and end required before a comment.
Setting this variable to zero results in every end acquiring a comment; the
default avoids too many redundant comments in tight quarters."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-minimum-comment-distance 'safe-local-variable 'integerp)

(defcustom vpp-highlight-p1800-keywords nil
  "Non-nil means highlight words newly reserved by IEEE-1800.
These will appear in `vpp-font-lock-p1800-face' in order to gently
suggest changing where these words are used as variables to something else.
A nil value means highlight these words as appropriate for the SystemVpp
IEEE-1800 standard.  Note that changing this will require restarting Emacs
to see the effect as font color choices are cached by Emacs."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-highlight-p1800-keywords 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-highlight-grouping-keywords nil
  "Non-nil means highlight grouping keywords 'begin' and 'end' more dramatically.
If false, these words are in the `font-lock-type-face'; if True then they are in
`vpp-font-lock-ams-face'.  Some find that special highlighting on these
grouping constructs allow the structure of the code to be understood at a glance."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-highlight-grouping-keywords 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-highlight-modules nil
  "Non-nil means highlight module statements for `vpp-load-file-at-point'.
When true, mousing over module names will allow jumping to the
module definition.  If false, this is not supported.  Setting
this is experimental, and may lead to bad performance."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-highlight-modules 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-highlight-includes t
  "Non-nil means highlight module statements for `vpp-load-file-at-point'.
When true, mousing over include file names will allow jumping to the
file referenced.  If false, this is not supported."
  :group 'vpp-mode-indent
  :type 'boolean)
(put 'vpp-highlight-includes 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-declare-nettype nil
  "Non-nil specifies the data type to use with `vpp-auto-input' etc.
Set this to \"wire\" if the Vpp code uses \"`default_nettype
none\".  Note using `default_nettype none isn't recommended practice; this
mode is experimental."
  :version "24.1"  ;; rev670
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-declare-nettype 'safe-local-variable `stringp)

(defcustom vpp-auto-wire-type nil
  "Non-nil specifies the data type to use with `vpp-auto-wire' etc.
Set this to \"logic\" for SystemVpp code, or use `vpp-auto-logic'."
  :version "24.1"  ;; rev673
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-wire-type 'safe-local-variable `stringp)

(defcustom vpp-auto-endcomments t
  "Non-nil means insert a comment /* ... */ after 'end's.
The name of the function or case will be set between the braces."
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-endcomments 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-delete-trailing-whitespace nil
  "Non-nil means to `delete-trailing-whitespace' in `vpp-auto'."
  :version "24.1"  ;; rev703
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-delete-trailing-whitespace 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-ignore-concat nil
  "Non-nil means ignore signals in {...} concatenations for AUTOWIRE etc.
This will exclude signals referenced as pin connections in {...}
from AUTOWIRE, AUTOOUTPUT and friends.  This flag should be set
for backward compatibility only and not set in new designs; it
may be removed in future versions."
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-ignore-concat 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-read-includes nil
  "Non-nil means to automatically read includes before AUTOs.
This will do a `vpp-read-defines' and `vpp-read-includes' before
each AUTO expansion.  This makes it easier to embed defines and includes,
but can result in very slow reading times if there are many or large
include files."
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-read-includes 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-save-policy nil
  "Non-nil indicates action to take when saving a Vpp buffer with AUTOs.
A value of `force' will always do a \\[vpp-auto] automatically if
needed on every save.  A value of `detect' will do \\[vpp-auto]
automatically when it thinks necessary.  A value of `ask' will query the
user when it thinks updating is needed.

You should not rely on the 'ask or 'detect policies, they are safeguards
only.  They do not detect when AUTOINSTs need to be updated because a
sub-module's port list has changed."
  :group 'vpp-mode-actions
  :type '(choice (const nil) (const ask) (const detect) (const force)))

(defcustom vpp-auto-star-expand t
  "Non-nil means to expand SystemVpp .* instance ports.
They will be expanded in the same way as if there was an AUTOINST in the
instantiation.  See also `vpp-auto-star' and `vpp-auto-star-save'."
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-star-expand 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-star-save nil
  "Non-nil means save to disk SystemVpp .* instance expansions.
A nil value indicates direct connections will be removed before saving.
Only meaningful to those created due to `vpp-auto-star-expand' being set.

Instead of setting this, you may want to use /*AUTOINST*/, which will
always be saved."
  :group 'vpp-mode-actions
  :type 'boolean)
(put 'vpp-auto-star-save 'safe-local-variable 'vpp-booleanp)

(defvar vpp-auto-update-tick nil
  "Modification tick at which autos were last performed.")

(defvar vpp-auto-last-file-locals nil
  "Text from file-local-variables during last evaluation.")

(defvar vpp-diff-function 'vpp-diff-report
  "Function to run when `vpp-diff-auto' detects differences.
Function takes three arguments, the original buffer, the
difference buffer, and the point in original buffer with the
first difference.")

;;; Compile support
(require 'compile)
(defvar vpp-error-regexp-added nil)

(defvar vpp-error-regexp-emacs-alist
  '(
    (vpp-xl-1
     "\\(Error\\|Warning\\)!.*\n?.*\"\\([^\"]+\\)\", \\([0-9]+\\)" 2 3)
    (vpp-xl-2
     "([WE][0-9A-Z]+)[ \t]+\\([^ \t\n,]+\\)[, \t]+\\(line[ \t]+\\)?\\([0-9]+\\):.*$" 1 3)
    (vpp-IES
     ".*\\*[WE],[0-9A-Z]+\\(\[[0-9A-Z_,]+\]\\)? (\\([^ \t,]+\\),\\([0-9]+\\)" 2 3)
    (vpp-surefire-1
     "[^\n]*\\[\\([^:]+\\):\\([0-9]+\\)\\]" 1 2)
    (vpp-surefire-2
     "\\(WARNING\\|ERROR\\|INFO\\)[^:]*: \\([^,]+\\),\\s-+\\(line \\)?\\([0-9]+\\):" 2 4 )
    (vpp-verbose
     "\
\\([a-zA-Z]?:?[^:( \t\n]+\\)[:(][ \t]*\\([0-9]+\\)\\([) \t]\\|\
:\\([^0-9\n]\\|\\([0-9]+:\\)\\)\\)" 1 2 5)
    (vpp-xsim
     "\\(Error\\|Warning\\).*in file (\\([^ \t]+\\) at line *\\([0-9]+\\))" 2 3)
    (vpp-vcs-1
     "\\(Error\\|Warning\\):[^(]*(\\([^ \t]+\\) line *\\([0-9]+\\))" 2 3)
    (vpp-vcs-2
     "Warning:.*(port.*(\\([^ \t]+\\) line \\([0-9]+\\))" 1 2)
    (vpp-vcs-3
     "\\(Error\\|Warning\\):[\n.]*\\([^ \t]+\\) *\\([0-9]+\\):" 2 3)
    (vpp-vcs-4
     "syntax error:.*\n\\([^ \t]+\\) *\\([0-9]+\\):" 1 2)
    (vpp-verilator
     "%?\\(Error\\|Warning\\)\\(-[^:]+\\|\\):[\n ]*\\([^ \t:]+\\):\\([0-9]+\\):" 3 4)
    (vpp-leda
     "^In file \\([^ \t]+\\)[ \t]+line[ \t]+\\([0-9]+\\):\n[^\n]*\n[^\n]*\n\\(Warning\\|Error\\|Failure\\)[^\n]*" 1 2)
    )
  "List of regexps for Vpp compilers.
See `compilation-error-regexp-alist' for the formatting.  For Emacs 22+.")

(defvar vpp-error-regexp-xemacs-alist
  ;; Emacs form is '((v-tool "re" 1 2) ...)
  ;; XEmacs form is '(vpp ("re" 1 2) ...)
  ;; So we can just map from Emacs to XEmacs
  (cons 'vpp (mapcar 'cdr vpp-error-regexp-emacs-alist))
  "List of regexps for Vpp compilers.
See `compilation-error-regexp-alist-alist' for the formatting.  For XEmacs.")

(defvar vpp-error-font-lock-keywords
  '(
    ;; vpp-xl-1
    ("\\(Error\\|Warning\\)!.*\n?.*\"\\([^\"]+\\)\", \\([0-9]+\\)" 2 bold t)
    ("\\(Error\\|Warning\\)!.*\n?.*\"\\([^\"]+\\)\", \\([0-9]+\\)" 2 bold t)
    ;; vpp-xl-2
    ("([WE][0-9A-Z]+)[ \t]+\\([^ \t\n,]+\\)[, \t]+\\(line[ \t]+\\)?\\([0-9]+\\):.*$" 1 bold t)
    ("([WE][0-9A-Z]+)[ \t]+\\([^ \t\n,]+\\)[, \t]+\\(line[ \t]+\\)?\\([0-9]+\\):.*$" 3 bold t)
    ;; vpp-IES (nc-vpp)
    (".*\\*[WE],[0-9A-Z]+\\(\[[0-9A-Z_,]+\]\\)? (\\([^ \t,]+\\),\\([0-9]+\\)|" 2 bold t)
    (".*\\*[WE],[0-9A-Z]+\\(\[[0-9A-Z_,]+\]\\)? (\\([^ \t,]+\\),\\([0-9]+\\)|" 3 bold t)
    ;; vpp-surefire-1
    ("[^\n]*\\[\\([^:]+\\):\\([0-9]+\\)\\]" 1 bold t)
    ("[^\n]*\\[\\([^:]+\\):\\([0-9]+\\)\\]" 2 bold t)
    ;; vpp-surefire-2
    ("\\(WARNING\\|ERROR\\|INFO\\): \\([^,]+\\), line \\([0-9]+\\):" 2 bold t)
    ("\\(WARNING\\|ERROR\\|INFO\\): \\([^,]+\\), line \\([0-9]+\\):" 3 bold t)
    ;; vpp-verbose
    ("\
\\([a-zA-Z]?:?[^:( \t\n]+\\)[:(][ \t]*\\([0-9]+\\)\\([) \t]\\|\
:\\([^0-9\n]\\|\\([0-9]+:\\)\\)\\)" 1 bold t)
    ("\
\\([a-zA-Z]?:?[^:( \t\n]+\\)[:(][ \t]*\\([0-9]+\\)\\([) \t]\\|\
:\\([^0-9\n]\\|\\([0-9]+:\\)\\)\\)" 1 bold t)
    ;; vpp-vcs-1
    ("\\(Error\\|Warning\\):[^(]*(\\([^ \t]+\\) line *\\([0-9]+\\))" 2 bold t)
    ("\\(Error\\|Warning\\):[^(]*(\\([^ \t]+\\) line *\\([0-9]+\\))" 3 bold t)
    ;; vpp-vcs-2
    ("Warning:.*(port.*(\\([^ \t]+\\) line \\([0-9]+\\))" 1 bold t)
    ("Warning:.*(port.*(\\([^ \t]+\\) line \\([0-9]+\\))" 1 bold t)
    ;; vpp-vcs-3
    ("\\(Error\\|Warning\\):[\n.]*\\([^ \t]+\\) *\\([0-9]+\\):" 2 bold t)
    ("\\(Error\\|Warning\\):[\n.]*\\([^ \t]+\\) *\\([0-9]+\\):" 3 bold t)
    ;; vpp-vcs-4
    ("syntax error:.*\n\\([^ \t]+\\) *\\([0-9]+\\):" 1 bold t)
    ("syntax error:.*\n\\([^ \t]+\\) *\\([0-9]+\\):" 2 bold t)
    ;; vpp-verilator
    (".*%?\\(Error\\|Warning\\)\\(-[^:]+\\|\\):[\n ]*\\([^ \t:]+\\):\\([0-9]+\\):" 3 bold t)
    (".*%?\\(Error\\|Warning\\)\\(-[^:]+\\|\\):[\n ]*\\([^ \t:]+\\):\\([0-9]+\\):" 4 bold t)
    ;; vpp-leda
    ("^In file \\([^ \t]+\\)[ \t]+line[ \t]+\\([0-9]+\\):\n[^\n]*\n[^\n]*\n\\(Warning\\|Error\\|Failure\\)[^\n]*" 1 bold t)
    ("^In file \\([^ \t]+\\)[ \t]+line[ \t]+\\([0-9]+\\):\n[^\n]*\n[^\n]*\n\\(Warning\\|Error\\|Failure\\)[^\n]*" 2 bold t)
    )
  "Keywords to also highlight in Vpp *compilation* buffers.
Only used in XEmacs; GNU Emacs uses `vpp-error-regexp-emacs-alist'.")

(defcustom vpp-library-flags '("")
  "List of standard Vpp arguments to use for /*AUTOINST*/.
These arguments are used to find files for `vpp-auto', and match
the flags accepted by a standard Vpp-XL simulator.

    -f filename     Reads more `vpp-library-flags' from the filename.
    +incdir+dir     Adds the directory to `vpp-library-directories'.
    -Idir           Adds the directory to `vpp-library-directories'.
    -y dir          Adds the directory to `vpp-library-directories'.
    +libext+.v      Adds the extensions to `vpp-library-extensions'.
    -v filename     Adds the filename to `vpp-library-files'.

    filename        Adds the filename to `vpp-library-files'.
                    This is not recommended, -v is a better choice.

You might want these defined in each file; put at the *END* of your file
something like:

    // Local Variables:
    // vpp-library-flags:(\"-y dir -y otherdir\")
    // End:

Vpp-mode attempts to detect changes to this local variable, but they
are only insured to be correct when the file is first visited.  Thus if you
have problems, use \\[find-alternate-file] RET to have these take effect.

See also the variables mentioned above."
  :group 'vpp-mode-auto
  :type '(repeat string))
(put 'vpp-library-flags 'safe-local-variable 'listp)

(defcustom vpp-library-directories '(".")
  "List of directories when looking for files for /*AUTOINST*/.
The directory may be relative to the current file, or absolute.
Environment variables are also expanded in the directory names.
Having at least the current directory is a good idea.

You might want these defined in each file; put at the *END* of your file
something like:

    // Local Variables:
    // vpp-library-directories:(\".\" \"subdir\" \"subdir2\")
    // End:

Vpp-mode attempts to detect changes to this local variable, but they
are only insured to be correct when the file is first visited.  Thus if you
have problems, use \\[find-alternate-file] RET to have these take effect.

See also `vpp-library-flags', `vpp-library-files'
and `vpp-library-extensions'."
  :group 'vpp-mode-auto
  :type '(repeat file))
(put 'vpp-library-directories 'safe-local-variable 'listp)

(defcustom vpp-library-files '()
  "List of files to search for modules.
AUTOINST will use this when it needs to resolve a module name.
This is a complete path, usually to a technology file with many standard
cells defined in it.

You might want these defined in each file; put at the *END* of your file
something like:

    // Local Variables:
    // vpp-library-files:(\"/some/path/technology.v\" \"/some/path/tech2.v\")
    // End:

Vpp-mode attempts to detect changes to this local variable, but they
are only insured to be correct when the file is first visited.  Thus if you
have problems, use \\[find-alternate-file] RET to have these take effect.

See also `vpp-library-flags', `vpp-library-directories'."
  :group 'vpp-mode-auto
  :type '(repeat directory))
(put 'vpp-library-files 'safe-local-variable 'listp)

(defcustom vpp-library-extensions '(".v" ".sv")
  "List of extensions to use when looking for files for /*AUTOINST*/.
See also `vpp-library-flags', `vpp-library-directories'."
  :type '(repeat string)
  :group 'vpp-mode-auto)
(put 'vpp-library-extensions 'safe-local-variable 'listp)

(defcustom vpp-active-low-regexp nil
  "If set, treat signals matching this regexp as active low.
This is used for AUTORESET and AUTOTIEOFF.  For proper behavior,
you will probably also need `vpp-auto-reset-widths' set."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-active-low-regexp 'safe-local-variable 'stringp)

(defcustom vpp-auto-sense-include-inputs nil
  "Non-nil means AUTOSENSE should include all inputs.
If nil, only inputs that are NOT output signals in the same block are
included."
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-sense-include-inputs 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-sense-defines-constant nil
  "Non-nil means AUTOSENSE should assume all defines represent constants.
When true, the defines will not be included in sensitivity lists.  To
maintain compatibility with other sites, this should be set at the bottom
of each Vpp file that requires it, rather than being set globally."
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-sense-defines-constant 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-reset-blocking-in-non t
  "Non-nil means AUTORESET will reset blocking statements.
When true, AUTORESET will reset in blocking statements those
signals which were assigned with blocking assignments (=) even in
a block with non-blocking assignments (<=).

If nil, all blocking assigned signals are ignored when any
non-blocking assignment is in the AUTORESET block.  This allows
blocking assignments to be used for temporary values and not have
those temporaries reset.  See example in `vpp-auto-reset'."
  :version "24.1"  ;; rev718
  :type 'boolean
  :group 'vpp-mode-auto)
(put 'vpp-auto-reset-blocking-in-non 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-reset-widths t
  "True means AUTORESET should determine the width of signals.
This is then used to set the width of the zero (32'h0 for example).  This
is required by some lint tools that aren't smart enough to ignore widths of
the constant zero. This may result in ugly code when parameters determine
the MSB or LSB of a signal inside an AUTORESET.

If nil, AUTORESET uses \"0\" as the constant.

If 'unbased', AUTORESET used the unbased unsized literal \"'0\"
as the constant. This setting is strongly recommended for
SystemVpp designs."
  :type 'boolean
  :group 'vpp-mode-auto)
(put 'vpp-auto-reset-widths 'safe-local-variable
     '(lambda (x) (memq x '(nil t unbased))))

(defcustom vpp-assignment-delay ""
  "Text used for delays in delayed assignments.  Add a trailing space if set."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-assignment-delay 'safe-local-variable 'stringp)

(defcustom vpp-auto-arg-sort nil
  "Non-nil means AUTOARG signal names will be sorted, not in declaration order.
Declaration order is advantageous with order based instantiations
and is the default for backward compatibility.  Sorted order
reduces changes when declarations are moved around in a file, and
it's bad practice to rely on order based instantiations anyhow.

See also `vpp-auto-inst-sort'."
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-arg-sort 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-inst-dot-name nil
  "Non-nil means when creating ports with AUTOINST, use .name syntax.
This will use \".port\" instead of \".port(port)\" when possible.
This is only legal in SystemVpp files, and will confuse older
simulators.  Setting `vpp-auto-inst-vector' to nil may also
be desirable to increase how often .name will be used."
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-inst-dot-name 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-inst-param-value nil
  "Non-nil means AUTOINST will replace parameters with the parameter value.
If nil, leave parameters as symbolic names.

Parameters must be in Vpp 2001 format #(...), and if a parameter is not
listed as such there (as when the default value is acceptable), it will not
be replaced, and will remain symbolic.

For example, imagine a submodule uses parameters to declare the size of its
inputs.  This is then used by an upper module:

	module InstModule (o,i);
	   parameter WIDTH;
	   input [WIDTH-1:0] i;
	endmodule

	module ExampInst;
	   InstModule
 	     #(PARAM(10))
	    instName
	     (/*AUTOINST*/
	      .i 	(i[PARAM-1:0]));

Note even though PARAM=10, the AUTOINST has left the parameter as a
symbolic name.  If `vpp-auto-inst-param-value' is set, this will
instead expand to:

	module ExampInst;
	   InstModule
 	     #(PARAM(10))
	    instName
	     (/*AUTOINST*/
	      .i 	(i[9:0]));"
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-inst-param-value 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-inst-sort nil
  "Non-nil means AUTOINST signals will be sorted, not in declaration order.
Also affects AUTOINSTPARAM.  Declaration order is the default for
backward compatibility, and as some teams prefer signals that are
declared together to remain together.  Sorted order reduces
changes when declarations are moved around in a file.

See also `vpp-auto-arg-sort'."
  :version "24.1"  ;; rev688
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-inst-sort 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-inst-vector t
  "Non-nil means when creating default ports with AUTOINST, use bus subscripts.
If nil, skip the subscript when it matches the entire bus as declared in
the module (AUTOWIRE signals always are subscripted, you must manually
declare the wire to have the subscripts removed.)  Setting this to nil may
speed up some simulators, but is less general and harder to read, so avoid."
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-inst-vector 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-inst-template-numbers nil
  "If true, when creating templated ports with AUTOINST, add a comment.

If t, the comment will add the line number of the template that
was used for that port declaration.  This setting is suggested
only for debugging use, as regular use may cause a large numbers
of merge conflicts.

If 'lhs', the comment will show the left hand side of the
AUTO_TEMPLATE rule that is matched.  This is less precise than
numbering (t) when multiple rules have the same pin name, but
won't merge conflict."
  :group 'vpp-mode-auto
  :type '(choice (const nil) (const t) (const lhs)))
(put 'vpp-auto-inst-template-numbers 'safe-local-variable
     '(lambda (x) (memq x '(nil t lhs))))

(defcustom vpp-auto-inst-column 40
  "Indent-to column number for net name part of AUTOINST created pin."
  :group 'vpp-mode-indent
  :type 'integer)
(put 'vpp-auto-inst-column 'safe-local-variable 'integerp)

(defcustom vpp-auto-inst-interfaced-ports nil
  "Non-nil means include interfaced ports in AUTOINST expansions."
  :version "24.3"  ;; rev773, default change rev815
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-inst-interfaced-ports 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-input-ignore-regexp nil
  "If set, when creating AUTOINPUT list, ignore signals matching this regexp.
See the \\[vpp-faq] for examples on using this."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-auto-input-ignore-regexp 'safe-local-variable 'stringp)

(defcustom vpp-auto-inout-ignore-regexp nil
  "If set, when creating AUTOINOUT list, ignore signals matching this regexp.
See the \\[vpp-faq] for examples on using this."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-auto-inout-ignore-regexp 'safe-local-variable 'stringp)

(defcustom vpp-auto-output-ignore-regexp nil
  "If set, when creating AUTOOUTPUT list, ignore signals matching this regexp.
See the \\[vpp-faq] for examples on using this."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-auto-output-ignore-regexp 'safe-local-variable 'stringp)

(defcustom vpp-auto-template-warn-unused nil
  "Non-nil means report warning if an AUTO_TEMPLATE line is not used.
This feature is not supported before Emacs 21.1 or XEmacs 21.4."
  :version "24.3"  ;;rev787
  :group 'vpp-mode-auto
  :type 'boolean)
(put 'vpp-auto-template-warn-unused 'safe-local-variable 'vpp-booleanp)

(defcustom vpp-auto-tieoff-declaration "wire"
  "Data type used for the declaration for AUTOTIEOFF.
If \"wire\" then create a wire, if \"assign\" create an
assignment, else the data type for variable creation."
  :version "24.1"  ;; rev713
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-auto-tieoff-declaration 'safe-local-variable 'stringp)

(defcustom vpp-auto-tieoff-ignore-regexp nil
  "If set, when creating AUTOTIEOFF list, ignore signals matching this regexp.
See the \\[vpp-faq] for examples on using this."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-auto-tieoff-ignore-regexp 'safe-local-variable 'stringp)

(defcustom vpp-auto-unused-ignore-regexp nil
  "If set, when creating AUTOUNUSED list, ignore signals matching this regexp.
See the \\[vpp-faq] for examples on using this."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-auto-unused-ignore-regexp 'safe-local-variable 'stringp)

(defcustom vpp-typedef-regexp nil
  "If non-nil, regular expression that matches Vpp-2001 typedef names.
For example, \"_t$\" matches typedefs named with _t, as in the C language."
  :group 'vpp-mode-auto
  :type 'string)
(put 'vpp-typedef-regexp 'safe-local-variable 'stringp)

(defcustom vpp-mode-hook   'vpp-set-compile-command
  "Hook run after Vpp mode is loaded."
  :type 'hook
  :group 'vpp-mode)

(defcustom vpp-auto-hook nil
  "Hook run after `vpp-mode' updates AUTOs."
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-before-auto-hook nil
  "Hook run before `vpp-mode' updates AUTOs."
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-delete-auto-hook nil
  "Hook run after `vpp-mode' deletes AUTOs."
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-before-delete-auto-hook nil
  "Hook run before `vpp-mode' deletes AUTOs."
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-getopt-flags-hook nil
  "Hook run after `vpp-getopt-flags' determines the Vpp option lists."
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-before-getopt-flags-hook nil
  "Hook run before `vpp-getopt-flags' determines the Vpp option lists."
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-before-save-font-hook nil
  "Hook run before `vpp-save-font-mods' removes highlighting."
  :version "24.3"  ;;rev735
  :group 'vpp-mode-auto
  :type 'hook)

(defcustom vpp-after-save-font-hook nil
  "Hook run after `vpp-save-font-mods' restores highlighting."
  :version "24.3"  ;;rev735
  :group 'vpp-mode-auto
  :type 'hook)

(defvar vpp-imenu-generic-expression
  '((nil "^\\s-*\\(\\(m\\(odule\\|acromodule\\)\\)\\|primitive\\)\\s-+\\([a-zA-Z0-9_.:]+\\)" 4)
    ("*Vars*" "^\\s-*\\(reg\\|wire\\)\\s-+\\(\\|\\[[^]]+\\]\\s-+\\)\\([A-Za-z0-9_]+\\)" 3))
  "Imenu expression for Vpp mode.  See `imenu-generic-expression'.")

;;
;; provide a vpp-header function.
;; Customization variables:
;;
(defvar vpp-date-scientific-format nil
  "If non-nil, dates are written in scientific format (e.g.  1997/09/17).
If nil, in European format (e.g.  17.09.1997).  The brain-dead American
format (e.g.  09/17/1997) is not supported.")

(defvar vpp-company nil
  "Default name of Company for Vpp header.
If set will become buffer local.")
(make-variable-buffer-local 'vpp-company)

(defvar vpp-project nil
  "Default name of Project for Vpp header.
If set will become buffer local.")
(make-variable-buffer-local 'vpp-project)

(defvar vpp-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map ";"        'electric-vpp-semi)
    (define-key map [(control 59)]    'electric-vpp-semi-with-comment)
    (define-key map ":"        'electric-vpp-colon)
    ;;(define-key map "="        'electric-vpp-equal)
    (define-key map "\`"       'electric-vpp-tick)
    (define-key map "\t"       'electric-vpp-tab)
    (define-key map "\r"       'electric-vpp-terminate-line)
    ;; backspace/delete key bindings
    (define-key map [backspace]    'backward-delete-char-untabify)
    (unless (boundp 'delete-key-deletes-forward) ; XEmacs variable
      (define-key map [delete]       'delete-char)
      (define-key map [(meta delete)] 'kill-word))
    (define-key map "\M-\C-b"  'electric-vpp-backward-sexp)
    (define-key map "\M-\C-f"  'electric-vpp-forward-sexp)
    (define-key map "\M-\r"    `electric-vpp-terminate-and-indent)
    (define-key map "\M-\t"    'vpp-complete-word)
    (define-key map "\M-?"     'vpp-show-completions)
    ;; Note \C-c and letter are reserved for users
    (define-key map "\C-c\`"   'vpp-lint-off)
    (define-key map "\C-c\*"   'vpp-delete-auto-star-implicit)
    (define-key map "\C-c\?"   'vpp-diff-auto)
    (define-key map "\C-c\C-r" 'vpp-label-be)
    (define-key map "\C-c\C-i" 'vpp-pretty-declarations)
    (define-key map "\C-c="    'vpp-pretty-expr)
    (define-key map "\C-c\C-b" 'vpp-submit-bug-report)
    (define-key map "\M-*"     'vpp-star-comment)
    (define-key map "\C-c\C-c" 'vpp-comment-region)
    (define-key map "\C-c\C-u" 'vpp-uncomment-region)
    (when (featurep 'xemacs)
      (define-key map [(meta control h)] 'vpp-mark-defun)
      (define-key map "\M-\C-a"  'vpp-beg-of-defun)
      (define-key map "\M-\C-e"  'vpp-end-of-defun))
    (define-key map "\C-c\C-d" 'vpp-goto-defun)
    (define-key map "\C-c\C-k" 'vpp-delete-auto)
    (define-key map "\C-c\C-a" 'vpp-auto)
    (define-key map "\C-c\C-s" 'vpp-auto-save-compile)
    (define-key map "\C-c\C-p" 'vpp-preprocess)
    (define-key map "\C-c\C-z" 'vpp-inject-auto)
    (define-key map "\C-c\C-e" 'vpp-expand-vector)
    (define-key map "\C-c\C-h" 'vpp-header)
    map)
  "Keymap used in Vpp mode.")

;; menus
(easy-menu-define
  vpp-menu vpp-mode-map "Menu for Vpp mode"
  (vpp-easy-menu-filter
   '("Vpp"
     ("Choose Compilation Action"
      ["None"
       (progn
	 (setq vpp-tool nil)
	 (vpp-set-compile-command))
       :style radio
       :selected (equal vpp-tool nil)
       :help "When invoking compilation, use compile-command"]
      ["Lint"
       (progn
	 (setq vpp-tool 'vpp-linter)
	 (vpp-set-compile-command))
       :style radio
       :selected (equal vpp-tool `vpp-linter)
       :help "When invoking compilation, use lint checker"]
      ["Coverage"
       (progn
	 (setq vpp-tool 'vpp-coverage)
	 (vpp-set-compile-command))
       :style radio
       :selected (equal vpp-tool `vpp-coverage)
       :help "When invoking compilation, annotate for coverage"]
      ["Simulator"
       (progn
	 (setq vpp-tool 'vpp-simulator)
	 (vpp-set-compile-command))
       :style radio
       :selected (equal vpp-tool `vpp-simulator)
       :help "When invoking compilation, interpret Vpp source"]
      ["Compiler"
       (progn
	 (setq vpp-tool 'vpp-compiler)
	 (vpp-set-compile-command))
       :style radio
       :selected (equal vpp-tool `vpp-compiler)
       :help "When invoking compilation, compile Vpp source"]
      ["Preprocessor"
       (progn
	 (setq vpp-tool 'vpp-preprocessor)
	 (vpp-set-compile-command))
       :style radio
       :selected (equal vpp-tool `vpp-preprocessor)
       :help "When invoking compilation, preprocess Vpp source, see also `vpp-preprocess'"]
      )
     ("Move"
      ["Beginning of function"		vpp-beg-of-defun
       :keys "C-M-a"
       :help		"Move backward to the beginning of the current function or procedure"]
      ["End of function"		vpp-end-of-defun
       :keys "C-M-e"
       :help		"Move forward to the end of the current function or procedure"]
      ["Mark function"			vpp-mark-defun
       :keys "C-M-h"
       :help		"Mark the current Vpp function or procedure"]
      ["Goto function/module"		vpp-goto-defun
       :help		"Move to specified Vpp module/task/function"]
      ["Move to beginning of block"	electric-vpp-backward-sexp
       :help		"Move backward over one balanced expression"]
      ["Move to end of block"		electric-vpp-forward-sexp
       :help		"Move forward over one balanced expression"]
      )
     ("Comments"
      ["Comment Region"			vpp-comment-region
       :help		"Put marked area into a comment"]
      ["UnComment Region"		vpp-uncomment-region
       :help		"Uncomment an area commented with Comment Region"]
      ["Multi-line comment insert"	vpp-star-comment
       :help		"Insert Vpp /* */ comment at point"]
      ["Lint error to comment"		vpp-lint-off
       :help		"Convert a Vpp linter warning line into a disable statement"]
      )
     "----"
     ["Compile"				compile
      :help		"Perform compilation-action (above) on the current buffer"]
     ["AUTO, Save, Compile"		vpp-auto-save-compile
      :help		"Recompute AUTOs, save buffer, and compile"]
     ["Next Compile Error"		next-error
      :help		"Visit next compilation error message and corresponding source code"]
     ["Ignore Lint Warning at point"	vpp-lint-off
      :help		"Convert a Vpp linter warning line into a disable statement"]
     "----"
     ["Line up declarations around point"	vpp-pretty-declarations
      :help		"Line up declarations around point"]
     ["Line up equations around point"		vpp-pretty-expr
      :help		"Line up expressions around point"]
     ["Redo/insert comments on every end"	vpp-label-be
      :help		"Label matching begin ... end statements"]
     ["Expand [x:y] vector line"	vpp-expand-vector
      :help		"Take a signal vector on the current line and expand it to multiple lines"]
     ["Insert begin-end block"		vpp-insert-block
      :help		"Insert begin ... end"]
     ["Complete word"			vpp-complete-word
      :help		"Complete word at point"]
     "----"
     ["Recompute AUTOs"			vpp-auto
      :help		"Expand AUTO meta-comment statements"]
     ["Kill AUTOs"			vpp-delete-auto
      :help		"Remove AUTO expansions"]
     ["Diff AUTOs"			vpp-diff-auto
      :help		"Show differences in AUTO expansions"]
     ["Inject AUTOs"			vpp-inject-auto
      :help		"Inject AUTOs into legacy non-AUTO buffer"]
     ("AUTO Help..."
      ["AUTO General"			(describe-function 'vpp-auto)
       :help		"Help introduction on AUTOs"]
      ["AUTO Library Flags"		(describe-variable 'vpp-library-flags)
       :help		"Help on vpp-library-flags"]
      ["AUTO Library Path"		(describe-variable 'vpp-library-directories)
       :help		"Help on vpp-library-directories"]
      ["AUTO Library Files"		(describe-variable 'vpp-library-files)
       :help		"Help on vpp-library-files"]
      ["AUTO Library Extensions"	(describe-variable 'vpp-library-extensions)
       :help		"Help on vpp-library-extensions"]
      ["AUTO `define Reading"		(describe-function 'vpp-read-defines)
       :help		"Help on reading `defines"]
      ["AUTO `include Reading"		(describe-function 'vpp-read-includes)
       :help		"Help on parsing `includes"]
      ["AUTOARG"			(describe-function 'vpp-auto-arg)
       :help		"Help on AUTOARG - declaring module port list"]
      ["AUTOASCIIENUM"			(describe-function 'vpp-auto-ascii-enum)
       :help		"Help on AUTOASCIIENUM - creating ASCII for enumerations"]
      ["AUTOASSIGNMODPORT"		(describe-function 'vpp-auto-assign-modport)
       :help		"Help on AUTOASSIGNMODPORT - creating assignments to/from modports"]
      ["AUTOINOUTCOMP"			(describe-function 'vpp-auto-inout-comp)
       :help		"Help on AUTOINOUTCOMP - copying complemented i/o from another file"]
      ["AUTOINOUTIN"			(describe-function 'vpp-auto-inout-in)
       :help		"Help on AUTOINOUTIN - copying i/o from another file as all inputs"]
      ["AUTOINOUTMODPORT"		(describe-function 'vpp-auto-inout-modport)
       :help		"Help on AUTOINOUTMODPORT - copying i/o from an interface modport"]
      ["AUTOINOUTMODULE"		(describe-function 'vpp-auto-inout-module)
       :help		"Help on AUTOINOUTMODULE - copying i/o from another file"]
      ["AUTOINOUTPARAM"			(describe-function 'vpp-auto-inout-param)
       :help		"Help on AUTOINOUTPARAM - copying parameters from another file"]
      ["AUTOINSERTLISP"			(describe-function 'vpp-auto-insert-lisp)
       :help		"Help on AUTOINSERTLISP - insert text from a lisp function"]
      ["AUTOINOUT"			(describe-function 'vpp-auto-inout)
       :help		"Help on AUTOINOUT - adding inouts from cells"]
      ["AUTOINPUT"			(describe-function 'vpp-auto-input)
       :help		"Help on AUTOINPUT - adding inputs from cells"]
      ["AUTOINST"			(describe-function 'vpp-auto-inst)
       :help		"Help on AUTOINST - adding pins for cells"]
      ["AUTOINST (.*)"			(describe-function 'vpp-auto-star)
       :help		"Help on expanding Vpp-2001 .* pins"]
      ["AUTOINSTPARAM"			(describe-function 'vpp-auto-inst-param)
       :help		"Help on AUTOINSTPARAM - adding parameter pins to cells"]
      ["AUTOLOGIC"			(describe-function 'vpp-auto-logic)
       :help		"Help on AUTOLOGIC - declaring logic signals"]
      ["AUTOOUTPUT"			(describe-function 'vpp-auto-output)
       :help		"Help on AUTOOUTPUT - adding outputs from cells"]
      ["AUTOOUTPUTEVERY"		(describe-function 'vpp-auto-output-every)
       :help		"Help on AUTOOUTPUTEVERY - adding outputs of all signals"]
      ["AUTOREG"			(describe-function 'vpp-auto-reg)
       :help		"Help on AUTOREG - declaring registers for non-wires"]
      ["AUTOREGINPUT"			(describe-function 'vpp-auto-reg-input)
       :help		"Help on AUTOREGINPUT - declaring inputs for non-wires"]
      ["AUTORESET"			(describe-function 'vpp-auto-reset)
       :help		"Help on AUTORESET - resetting always blocks"]
      ["AUTOSENSE"			(describe-function 'vpp-auto-sense)
       :help		"Help on AUTOSENSE - sensitivity lists for always blocks"]
      ["AUTOTIEOFF"			(describe-function 'vpp-auto-tieoff)
       :help		"Help on AUTOTIEOFF - tying off unused outputs"]
      ["AUTOUNDEF"			(describe-function 'vpp-auto-undef)
       :help		"Help on AUTOUNDEF - undefine all local defines"]
      ["AUTOUNUSED"			(describe-function 'vpp-auto-unused)
       :help		"Help on AUTOUNUSED - terminating unused inputs"]
      ["AUTOWIRE"			(describe-function 'vpp-auto-wire)
       :help		"Help on AUTOWIRE - declaring wires for cells"]
      )
     "----"
     ["Submit bug report"		vpp-submit-bug-report
      :help		"Submit via mail a bug report on vpp-mode.el"]
     ["Version and FAQ"			vpp-faq
      :help		"Show the current version, and where to get the FAQ etc"]
     ["Customize Vpp Mode..."	vpp-customize
      :help		"Customize variables and other settings used by Vpp-Mode"]
     ["Customize Vpp Fonts & Colors"	vpp-font-customize
      :help		"Customize fonts used by Vpp-Mode."])))

(easy-menu-define
  vpp-stmt-menu vpp-mode-map "Menu for statement templates in Vpp."
  (vpp-easy-menu-filter
   '("Statements"
     ["Header"		vpp-sk-header
      :help		"Insert a header block at the top of file"]
     ["Comment"		vpp-sk-comment
      :help		"Insert a comment block"]
     "----"
     ["Module"		vpp-sk-module
      :help		"Insert a module .. (/*AUTOARG*/);.. endmodule block"]
     ["OVM Class"	vpp-sk-ovm-class
      :help		"Insert an OVM class block"]
     ["UVM Class"	vpp-sk-uvm-class
      :help		"Insert an UVM class block"]
     ["Primitive"	vpp-sk-primitive
      :help		"Insert a primitive .. (.. );.. endprimitive block"]
     "----"
     ["Input"		vpp-sk-input
      :help		"Insert an input declaration"]
     ["Output"		vpp-sk-output
      :help		"Insert an output declaration"]
     ["Inout"		vpp-sk-inout
      :help		"Insert an inout declaration"]
     ["Wire"		vpp-sk-wire
      :help		"Insert a wire declaration"]
     ["Reg"		vpp-sk-reg
      :help		"Insert a register declaration"]
     ["Define thing under point as a register" vpp-sk-define-signal
      :help		"Define signal under point as a register at the top of the module"]
     "----"
     ["Initial"		vpp-sk-initial
      :help		"Insert an initial begin .. end block"]
     ["Always"		vpp-sk-always
      :help		"Insert an always @(AS) begin .. end block"]
     ["Function"	vpp-sk-function
      :help		"Insert a function .. begin .. end endfunction block"]
     ["Task"		vpp-sk-task
      :help		"Insert a task .. begin .. end endtask block"]
     ["Specify"		vpp-sk-specify
      :help		"Insert a specify .. endspecify block"]
     ["Generate"	vpp-sk-generate
      :help		"Insert a generate .. endgenerate block"]
     "----"
     ["Begin"		vpp-sk-begin
      :help		"Insert a begin .. end block"]
     ["If"		vpp-sk-if
      :help		"Insert an if (..) begin .. end block"]
     ["(if) else"	vpp-sk-else-if
      :help		"Insert an else if (..) begin .. end block"]
     ["For"		vpp-sk-for
      :help		"Insert a for (...) begin .. end block"]
     ["While"		vpp-sk-while
      :help		"Insert a while (...) begin .. end block"]
     ["Fork"		vpp-sk-fork
      :help		"Insert a fork begin .. end .. join block"]
     ["Repeat"		vpp-sk-repeat
      :help		"Insert a repeat (..) begin .. end block"]
     ["Case"		vpp-sk-case
      :help		"Insert a case block, prompting for details"]
     ["Casex"		vpp-sk-casex
      :help		"Insert a casex (...) item: begin.. end endcase block"]
     ["Casez"		vpp-sk-casez
      :help		"Insert a casez (...) item: begin.. end endcase block"])))

(defvar vpp-mode-abbrev-table nil
  "Abbrev table in use in Vpp-mode buffers.")

(define-abbrev-table 'vpp-mode-abbrev-table ())
(vpp-define-abbrev vpp-mode-abbrev-table "class" "" 'vpp-sk-ovm-class)
(vpp-define-abbrev vpp-mode-abbrev-table "always" "" 'vpp-sk-always)
(vpp-define-abbrev vpp-mode-abbrev-table "begin" nil `vpp-sk-begin)
(vpp-define-abbrev vpp-mode-abbrev-table "case" "" `vpp-sk-case)
(vpp-define-abbrev vpp-mode-abbrev-table "for" "" `vpp-sk-for)
(vpp-define-abbrev vpp-mode-abbrev-table "generate" "" `vpp-sk-generate)
(vpp-define-abbrev vpp-mode-abbrev-table "initial" "" `vpp-sk-initial)
(vpp-define-abbrev vpp-mode-abbrev-table "fork" "" `vpp-sk-fork)
(vpp-define-abbrev vpp-mode-abbrev-table "module" "" `vpp-sk-module)
(vpp-define-abbrev vpp-mode-abbrev-table "primitive" "" `vpp-sk-primitive)
(vpp-define-abbrev vpp-mode-abbrev-table "repeat" "" `vpp-sk-repeat)
(vpp-define-abbrev vpp-mode-abbrev-table "specify" "" `vpp-sk-specify)
(vpp-define-abbrev vpp-mode-abbrev-table "task" "" `vpp-sk-task)
(vpp-define-abbrev vpp-mode-abbrev-table "while" "" `vpp-sk-while)
(vpp-define-abbrev vpp-mode-abbrev-table "casex" "" `vpp-sk-casex)
(vpp-define-abbrev vpp-mode-abbrev-table "casez" "" `vpp-sk-casez)
(vpp-define-abbrev vpp-mode-abbrev-table "if" "" `vpp-sk-if)
(vpp-define-abbrev vpp-mode-abbrev-table "else if" "" `vpp-sk-else-if)
(vpp-define-abbrev vpp-mode-abbrev-table "assign" "" `vpp-sk-assign)
(vpp-define-abbrev vpp-mode-abbrev-table "function" "" `vpp-sk-function)
(vpp-define-abbrev vpp-mode-abbrev-table "input" "" `vpp-sk-input)
(vpp-define-abbrev vpp-mode-abbrev-table "output" "" `vpp-sk-output)
(vpp-define-abbrev vpp-mode-abbrev-table "inout" "" `vpp-sk-inout)
(vpp-define-abbrev vpp-mode-abbrev-table "wire" "" `vpp-sk-wire)
(vpp-define-abbrev vpp-mode-abbrev-table "reg" "" `vpp-sk-reg)

;;
;;  Macros
;;

(defsubst vpp-within-string ()
  (nth 3 (parse-partial-sexp (point-at-bol) (point))))

(defsubst vpp-string-replace-matches (from-string to-string fixedcase literal string)
  "Replace occurrences of FROM-STRING with TO-STRING.
FIXEDCASE and LITERAL as in `replace-match`.  STRING is what to replace.
The case (vpp-string-replace-matches \"o\" \"oo\" nil nil \"foobar\")
will break, as the o's continuously replace.  xa -> x works ok though."
  ;; Hopefully soon to an Emacs built-in
  ;; Also note \ in the replacement prevent multiple replacements; IE
  ;;   (vpp-string-replace-matches "@" "\\\\([0-9]+\\\\)" nil nil "wire@_@")
  ;;   Gives "wire\([0-9]+\)_@" not "wire\([0-9]+\)_\([0-9]+\)"
  (let ((start 0))
    (while (string-match from-string string start)
      (setq string (replace-match to-string fixedcase literal string)
	    start (min (length string) (+ (match-beginning 0) (length to-string)))))
    string))

(defsubst vpp-string-remove-spaces (string)
  "Remove spaces surrounding STRING."
  (save-match-data
    (setq string (vpp-string-replace-matches "^\\s-+" "" nil nil string))
    (setq string (vpp-string-replace-matches "\\s-+$" "" nil nil string))
    string))

(defsubst vpp-re-search-forward (REGEXP BOUND NOERROR)
  ; checkdoc-params: (REGEXP BOUND NOERROR)
  "Like `re-search-forward', but skips over match in comments or strings."
  (let ((mdata '(nil nil)))  ;; So match-end will return nil if no matches found
    (while (and
	    (re-search-forward REGEXP BOUND NOERROR)
	    (setq mdata (match-data))
	    (and (vpp-skip-forward-comment-or-string)
		 (progn
		   (setq mdata '(nil nil))
		   (if BOUND
		       (< (point) BOUND)
		     t)))))
    (store-match-data mdata)
    (match-end 0)))

(defsubst vpp-re-search-backward (REGEXP BOUND NOERROR)
  ; checkdoc-params: (REGEXP BOUND NOERROR)
  "Like `re-search-backward', but skips over match in comments or strings."
  (let ((mdata '(nil nil)))  ;; So match-end will return nil if no matches found
    (while (and
	    (re-search-backward REGEXP BOUND NOERROR)
	    (setq mdata (match-data))
	    (and (vpp-skip-backward-comment-or-string)
		 (progn
		   (setq mdata '(nil nil))
		   (if BOUND
		       (> (point) BOUND)
		     t)))))
    (store-match-data mdata)
    (match-end 0)))

(defsubst vpp-re-search-forward-quick (regexp bound noerror)
  "Like `vpp-re-search-forward', including use of REGEXP BOUND and NOERROR,
but trashes match data and is faster for REGEXP that doesn't match often.
This uses `vpp-scan' and text properties to ignore comments,
so there may be a large up front penalty for the first search."
  (let (pt)
    (while (and (not pt)
		(re-search-forward regexp bound noerror))
      (if (vpp-inside-comment-or-string-p)
	  (re-search-forward "[/\"\n]" nil t) ;; Only way a comment or quote can end
	(setq pt (match-end 0))))
    pt))

(defsubst vpp-re-search-backward-quick (regexp bound noerror)
  ; checkdoc-params: (REGEXP BOUND NOERROR)
  "Like `vpp-re-search-backward', including use of REGEXP BOUND and NOERROR,
but trashes match data and is faster for REGEXP that doesn't match often.
This uses `vpp-scan' and text properties to ignore comments,
so there may be a large up front penalty for the first search."
  (let (pt)
    (while (and (not pt)
		(re-search-backward regexp bound noerror))
      (if (vpp-inside-comment-or-string-p)
	  (re-search-backward "[/\"]" nil t) ;; Only way a comment or quote can begin
	(setq pt (match-beginning 0))))
    pt))

(defsubst vpp-re-search-forward-substr (substr regexp bound noerror)
  "Like `re-search-forward', but first search for SUBSTR constant.
Then searched for the normal REGEXP (which contains SUBSTR), with given
BOUND and NOERROR.  The REGEXP must fit within a single line.
This speeds up complicated regexp matches."
  ;; Problem with overlap: search-forward BAR then FOOBARBAZ won't match.
  ;; thus require matches to be on one line, and use beginning-of-line.
  (let (done)
    (while (and (not done)
		(search-forward substr bound noerror))
      (save-excursion
	(beginning-of-line)
	(setq done (re-search-forward regexp (point-at-eol) noerror)))
      (unless (and (<= (match-beginning 0) (point))
		   (>= (match-end 0) (point)))
	(setq done nil)))
    (when done (goto-char done))
    done))
;;(vpp-re-search-forward-substr "-end" "get-end-of" nil t) ;;-end (test bait)

(defsubst vpp-re-search-backward-substr (substr regexp bound noerror)
  "Like `re-search-backward', but first search for SUBSTR constant.
Then searched for the normal REGEXP (which contains SUBSTR), with given
BOUND and NOERROR.  The REGEXP must fit within a single line.
This speeds up complicated regexp matches."
  ;; Problem with overlap: search-backward BAR then FOOBARBAZ won't match.
  ;; thus require matches to be on one line, and use beginning-of-line.
  (let (done)
    (while (and (not done)
		(search-backward substr bound noerror))
      (save-excursion
	(end-of-line)
	(setq done (re-search-backward regexp (point-at-bol) noerror)))
      (unless (and (<= (match-beginning 0) (point))
		   (>= (match-end 0) (point)))
	(setq done nil)))
    (when done (goto-char done))
    done))
;;(vpp-re-search-backward-substr "-end" "get-end-of" nil t) ;;-end (test bait)

(defun vpp-delete-trailing-whitespace ()
  "Delete trailing spaces or tabs, but not newlines nor linefeeds.
Also add missing final newline.

To call this from the command line, see \\[vpp-batch-diff-auto].

To call on \\[vpp-auto], set `vpp-auto-delete-trailing-whitespace'."
  ;; Similar to `delete-trailing-whitespace' but that's not present in XEmacs
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "[ \t]+$" nil t)  ;; Not syntactic WS as no formfeed
      (replace-match "" nil nil))
    (goto-char (point-max))
    (unless (bolp) (insert "\n"))))

(defvar compile-command)

;; compilation program
(defun vpp-set-compile-command ()
  "Function to compute shell command to compile Vpp.

This reads `vpp-tool' and sets `compile-command'.  This specifies the
program that executes when you type \\[compile] or
\\[vpp-auto-save-compile].

By default `vpp-tool' uses a Makefile if one exists in the
current directory.  If not, it is set to the `vpp-linter',
`vpp-compiler', `vpp-coverage', `vpp-preprocessor',
or `vpp-simulator' variables, as selected with the Vpp ->
\"Choose Compilation Action\" menu.

You should set `vpp-tool' or the other variables to the path and
arguments for your Vpp simulator.  For example:
    \"vcs -p123 -O\"
or a string like:
    \"(cd /tmp; surecov %s)\".

In the former case, the path to the current buffer is concat'ed to the
value of `vpp-tool'; in the later, the path to the current buffer is
substituted for the %s.

Where __FLAGS__ appears in the string `vpp-current-flags'
will be substituted.

Where __FILE__ appears in the string, the variable
`buffer-file-name' of the current buffer, without the directory
portion, will be substituted."
  (interactive)
  (cond
   ((or (file-exists-p "makefile")	;If there is a makefile, use it
	(file-exists-p "Makefile"))
    (set (make-local-variable 'compile-command) "make "))
   (t
    (set (make-local-variable 'compile-command)
	 (if vpp-tool
	     (if (string-match "%s" (eval vpp-tool))
		 (format (eval vpp-tool) (or buffer-file-name ""))
	       (concat (eval vpp-tool) " " (or buffer-file-name "")))
	   ""))))
  (vpp-modify-compile-command))

(defun vpp-expand-command (command)
  "Replace meta-information in COMMAND and return it.
Where __FLAGS__ appears in the string `vpp-current-flags'
will be substituted.  Where __FILE__ appears in the string, the
current buffer's file-name, without the directory portion, will
be substituted."
  (setq command	(vpp-string-replace-matches
		 ;; Note \\b only works if under vpp syntax table
		 "\\b__FLAGS__\\b" (vpp-current-flags)
		 t t command))
  (setq command	(vpp-string-replace-matches
		 "\\b__FILE__\\b" (file-name-nondirectory
				   (or (buffer-file-name) ""))
		 t t command))
  command)

(defun vpp-modify-compile-command ()
  "Update `compile-command' using `vpp-expand-command'."
  (when (and
	 (stringp compile-command)
	 (string-match "\\b\\(__FLAGS__\\|__FILE__\\)\\b" compile-command))
    (set (make-local-variable 'compile-command)
	 (vpp-expand-command compile-command))))

(if (featurep 'xemacs)
    ;; Following code only gets called from compilation-mode-hook on XEmacs to add error handling.
    (defun vpp-error-regexp-add-xemacs ()
      "Teach XEmacs about vpp errors.
Called by `compilation-mode-hook'.  This allows \\[next-error] to
find the errors."
      (interactive)
      (if (boundp 'compilation-error-regexp-systems-alist)
	  (if (and
	       (not (equal compilation-error-regexp-systems-list 'all))
	       (not (member compilation-error-regexp-systems-list 'vpp)))
	      (push 'vpp compilation-error-regexp-systems-list)))
      (if (boundp 'compilation-error-regexp-alist-alist)
	  (if (not (assoc 'vpp compilation-error-regexp-alist-alist))
	      (setcdr compilation-error-regexp-alist-alist
		      (cons vpp-error-regexp-xemacs-alist
			    (cdr compilation-error-regexp-alist-alist)))))
      (if (boundp 'compilation-font-lock-keywords)
	  (progn
	    (set (make-local-variable 'compilation-font-lock-keywords)
		 vpp-error-font-lock-keywords)
	    (font-lock-set-defaults)))
      ;; Need to re-run compilation-error-regexp builder
      (if (fboundp 'compilation-build-compilation-error-regexp-alist)
	  (compilation-build-compilation-error-regexp-alist))
      ))

;; Following code only gets called from compilation-mode-hook on Emacs to add error handling.
(defun vpp-error-regexp-add-emacs ()
   "Tell Emacs compile that we are Vpp.
Called by `compilation-mode-hook'.  This allows \\[next-error] to
find the errors."
   (interactive)
   (if (boundp 'compilation-error-regexp-alist-alist)
       (progn
         (if (not (assoc 'vpp-xl-1 compilation-error-regexp-alist-alist))
             (mapcar
              (lambda (item)
                (push (car item) compilation-error-regexp-alist)
                (push item compilation-error-regexp-alist-alist)
                )
              vpp-error-regexp-emacs-alist)))))

(if (featurep 'xemacs) (add-hook 'compilation-mode-hook 'vpp-error-regexp-add-xemacs))
(if (featurep 'emacs) (add-hook 'compilation-mode-hook 'vpp-error-regexp-add-emacs))

(defconst vpp-directive-re
  (eval-when-compile
    (vpp-regexp-words
     '(
   "`case" "`default" "`define" "`else" "`elsif" "`endfor" "`endif"
   "`endprotect" "`endswitch" "`endwhile" "`for" "`format" "`if" "`ifdef"
   "`ifndef" "`include" "`let" "`protect" "`switch" "`timescale"
   "`time_scale" "`undef" "`while" ))))

(defconst vpp-directive-re-1
  (concat "[ \t]*"  vpp-directive-re))

(defconst vpp-directive-begin
  "\\<`\\(for\\|i\\(f\\|fdef\\|fndef\\)\\|switch\\|while\\)\\>")

(defconst vpp-directive-middle
  "\\<`\\(else\\|elsif\\|default\\|case\\)\\>")

(defconst vpp-directive-end
  "`\\(endfor\\|endif\\|endswitch\\|endwhile\\)\\>")

(defconst vpp-ovm-begin-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       "`ovm_component_utils_begin"
       "`ovm_component_param_utils_begin"
       "`ovm_field_utils_begin"
       "`ovm_object_utils_begin"
       "`ovm_object_param_utils_begin"
       "`ovm_sequence_utils_begin"
       "`ovm_sequencer_utils_begin"
       ) nil )))

(defconst vpp-ovm-end-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       "`ovm_component_utils_end"
       "`ovm_field_utils_end"
       "`ovm_object_utils_end"
       "`ovm_sequence_utils_end"
       "`ovm_sequencer_utils_end"
       ) nil )))

(defconst vpp-uvm-begin-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       "`uvm_component_utils_begin"
       "`uvm_component_param_utils_begin"
       "`uvm_field_utils_begin"
       "`uvm_object_utils_begin"
       "`uvm_object_param_utils_begin"
       "`uvm_sequence_utils_begin"
       "`uvm_sequencer_utils_begin"
       ) nil )))

(defconst vpp-uvm-end-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       "`uvm_component_utils_end"
       "`uvm_field_utils_end"
       "`uvm_object_utils_end"
       "`uvm_sequence_utils_end"
       "`uvm_sequencer_utils_end"
       ) nil )))

(defconst vpp-vmm-begin-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       "`vmm_data_member_begin"
       "`vmm_env_member_begin"
       "`vmm_scenario_member_begin"
       "`vmm_subenv_member_begin"
       "`vmm_xactor_member_begin"
       ) nil ) ) )

(defconst vpp-vmm-end-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       "`vmm_data_member_end"
       "`vmm_env_member_end"
       "`vmm_scenario_member_end"
       "`vmm_subenv_member_end"
       "`vmm_xactor_member_end"
       ) nil ) ) )

(defconst vpp-vmm-statement-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
;;       "`vmm_xactor_member_enum_array"
       "`vmm_\\(data\\|env\\|scenario\\|subenv\\|xactor\\)_member_\\(scalar\\|string\\|enum\\|vmm_data\\|channel\\|xactor\\|subenv\\|user_defined\\)\\(_array\\)?"
;;       "`vmm_xactor_member_scalar_array"
;;       "`vmm_xactor_member_scalar"
       ) nil )))

(defconst vpp-ovm-statement-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       ;; Statements
       "`DUT_ERROR"
       "`MESSAGE"
       "`dut_error"
       "`message"
       "`ovm_analysis_imp_decl"
       "`ovm_blocking_get_imp_decl"
       "`ovm_blocking_get_peek_imp_decl"
       "`ovm_blocking_master_imp_decl"
       "`ovm_blocking_peek_imp_decl"
       "`ovm_blocking_put_imp_decl"
       "`ovm_blocking_slave_imp_decl"
       "`ovm_blocking_transport_imp_decl"
       "`ovm_component_registry"
       "`ovm_component_registry_param"
       "`ovm_component_utils"
       "`ovm_create"
       "`ovm_create_seq"
       "`ovm_declare_sequence_lib"
       "`ovm_do"
       "`ovm_do_seq"
       "`ovm_do_seq_with"
       "`ovm_do_with"
       "`ovm_error"
       "`ovm_fatal"
       "`ovm_field_aa_int_byte"
       "`ovm_field_aa_int_byte_unsigned"
       "`ovm_field_aa_int_int"
       "`ovm_field_aa_int_int_unsigned"
       "`ovm_field_aa_int_integer"
       "`ovm_field_aa_int_integer_unsigned"
       "`ovm_field_aa_int_key"
       "`ovm_field_aa_int_longint"
       "`ovm_field_aa_int_longint_unsigned"
       "`ovm_field_aa_int_shortint"
       "`ovm_field_aa_int_shortint_unsigned"
       "`ovm_field_aa_int_string"
       "`ovm_field_aa_object_int"
       "`ovm_field_aa_object_string"
       "`ovm_field_aa_string_int"
       "`ovm_field_aa_string_string"
       "`ovm_field_array_int"
       "`ovm_field_array_object"
       "`ovm_field_array_string"
       "`ovm_field_enum"
       "`ovm_field_event"
       "`ovm_field_int"
       "`ovm_field_object"
       "`ovm_field_queue_int"
       "`ovm_field_queue_object"
       "`ovm_field_queue_string"
       "`ovm_field_sarray_int"
       "`ovm_field_string"
       "`ovm_field_utils"
       "`ovm_file"
       "`ovm_get_imp_decl"
       "`ovm_get_peek_imp_decl"
       "`ovm_info"
       "`ovm_info1"
       "`ovm_info2"
       "`ovm_info3"
       "`ovm_info4"
       "`ovm_line"
       "`ovm_master_imp_decl"
       "`ovm_msg_detail"
       "`ovm_non_blocking_transport_imp_decl"
       "`ovm_nonblocking_get_imp_decl"
       "`ovm_nonblocking_get_peek_imp_decl"
       "`ovm_nonblocking_master_imp_decl"
       "`ovm_nonblocking_peek_imp_decl"
       "`ovm_nonblocking_put_imp_decl"
       "`ovm_nonblocking_slave_imp_decl"
       "`ovm_object_registry"
       "`ovm_object_registry_param"
       "`ovm_object_utils"
       "`ovm_peek_imp_decl"
       "`ovm_phase_func_decl"
       "`ovm_phase_task_decl"
       "`ovm_print_aa_int_object"
       "`ovm_print_aa_string_int"
       "`ovm_print_aa_string_object"
       "`ovm_print_aa_string_string"
       "`ovm_print_array_int"
       "`ovm_print_array_object"
       "`ovm_print_array_string"
       "`ovm_print_object_queue"
       "`ovm_print_queue_int"
       "`ovm_print_string_queue"
       "`ovm_put_imp_decl"
       "`ovm_rand_send"
       "`ovm_rand_send_with"
       "`ovm_send"
       "`ovm_sequence_utils"
       "`ovm_slave_imp_decl"
       "`ovm_transport_imp_decl"
       "`ovm_update_sequence_lib"
       "`ovm_update_sequence_lib_and_item"
       "`ovm_warning"
       "`static_dut_error"
       "`static_message") nil )))

(defconst vpp-uvm-statement-re
  (eval-when-compile
    (vpp-regexp-opt
     '(
       ;; Statements
       "`uvm_analysis_imp_decl"
       "`uvm_blocking_get_imp_decl"
       "`uvm_blocking_get_peek_imp_decl"
       "`uvm_blocking_master_imp_decl"
       "`uvm_blocking_peek_imp_decl"
       "`uvm_blocking_put_imp_decl"
       "`uvm_blocking_slave_imp_decl"
       "`uvm_blocking_transport_imp_decl"
       "`uvm_component_param_utils"
       "`uvm_component_registry"
       "`uvm_component_registry_param"
       "`uvm_component_utils"
       "`uvm_create"
       "`uvm_create_on"
       "`uvm_create_seq"		;; Undocumented in 1.1
       "`uvm_declare_p_sequencer"
       "`uvm_declare_sequence_lib"	;; Deprecated in 1.1
       "`uvm_do"
       "`uvm_do_callbacks"
       "`uvm_do_callbacks_exit_on"
       "`uvm_do_obj_callbacks"
       "`uvm_do_obj_callbacks_exit_on"
       "`uvm_do_on"
       "`uvm_do_on_pri"
       "`uvm_do_on_pri_with"
       "`uvm_do_on_with"
       "`uvm_do_pri"
       "`uvm_do_pri_with"
       "`uvm_do_seq"			;; Undocumented in 1.1
       "`uvm_do_seq_with"		;; Undocumented in 1.1
       "`uvm_do_with"
       "`uvm_error"
       "`uvm_error_context"
       "`uvm_fatal"
       "`uvm_fatal_context"
       "`uvm_field_aa_int_byte"
       "`uvm_field_aa_int_byte_unsigned"
       "`uvm_field_aa_int_enum"
       "`uvm_field_aa_int_int"
       "`uvm_field_aa_int_int_unsigned"
       "`uvm_field_aa_int_integer"
       "`uvm_field_aa_int_integer_unsigned"
       "`uvm_field_aa_int_key"
       "`uvm_field_aa_int_longint"
       "`uvm_field_aa_int_longint_unsigned"
       "`uvm_field_aa_int_shortint"
       "`uvm_field_aa_int_shortint_unsigned"
       "`uvm_field_aa_int_string"
       "`uvm_field_aa_object_int"
       "`uvm_field_aa_object_string"
       "`uvm_field_aa_string_int"
       "`uvm_field_aa_string_string"
       "`uvm_field_array_enum"
       "`uvm_field_array_int"
       "`uvm_field_array_object"
       "`uvm_field_array_string"
       "`uvm_field_enum"
       "`uvm_field_event"
       "`uvm_field_int"
       "`uvm_field_object"
       "`uvm_field_queue_enum"
       "`uvm_field_queue_int"
       "`uvm_field_queue_object"
       "`uvm_field_queue_string"
       "`uvm_field_real"
       "`uvm_field_sarray_enum"
       "`uvm_field_sarray_int"
       "`uvm_field_sarray_object"
       "`uvm_field_sarray_string"
       "`uvm_field_string"
       "`uvm_field_utils"
       "`uvm_file"		;; Undocumented in 1.1, use `__FILE__
       "`uvm_get_imp_decl"
       "`uvm_get_peek_imp_decl"
       "`uvm_info"
       "`uvm_info_context"
       "`uvm_line"		;; Undocumented in 1.1, use `__LINE__
       "`uvm_master_imp_decl"
       "`uvm_non_blocking_transport_imp_decl"	;; Deprecated in 1.1
       "`uvm_nonblocking_get_imp_decl"
       "`uvm_nonblocking_get_peek_imp_decl"
       "`uvm_nonblocking_master_imp_decl"
       "`uvm_nonblocking_peek_imp_decl"
       "`uvm_nonblocking_put_imp_decl"
       "`uvm_nonblocking_slave_imp_decl"
       "`uvm_nonblocking_transport_imp_decl"
       "`uvm_object_param_utils"
       "`uvm_object_registry"
       "`uvm_object_registry_param"	;; Undocumented in 1.1
       "`uvm_object_utils"
       "`uvm_pack_array"
       "`uvm_pack_arrayN"
       "`uvm_pack_enum"
       "`uvm_pack_enumN"
       "`uvm_pack_int"
       "`uvm_pack_intN"
       "`uvm_pack_queue"
       "`uvm_pack_queueN"
       "`uvm_pack_real"
       "`uvm_pack_sarray"
       "`uvm_pack_sarrayN"
       "`uvm_pack_string"
       "`uvm_peek_imp_decl"
       "`uvm_put_imp_decl"
       "`uvm_rand_send"
       "`uvm_rand_send_pri"
       "`uvm_rand_send_pri_with"
       "`uvm_rand_send_with"
       "`uvm_record_attribute"
       "`uvm_record_field"
       "`uvm_register_cb"
       "`uvm_send"
       "`uvm_send_pri"
       "`uvm_sequence_utils"		;; Deprecated in 1.1
       "`uvm_set_super_type"
       "`uvm_slave_imp_decl"
       "`uvm_transport_imp_decl"
       "`uvm_unpack_array"
       "`uvm_unpack_arrayN"
       "`uvm_unpack_enum"
       "`uvm_unpack_enumN"
       "`uvm_unpack_int"
       "`uvm_unpack_intN"
       "`uvm_unpack_queue"
       "`uvm_unpack_queueN"
       "`uvm_unpack_real"
       "`uvm_unpack_sarray"
       "`uvm_unpack_sarrayN"
       "`uvm_unpack_string"
       "`uvm_update_sequence_lib"		;; Deprecated in 1.1
       "`uvm_update_sequence_lib_and_item"	;; Deprecated in 1.1
       "`uvm_warning"
       "`uvm_warning_context") nil )))


;;
;; Regular expressions used to calculate indent, etc.
;;
(defconst vpp-symbol-re      "\\<[a-zA-Z_][a-zA-Z_0-9.]*\\>")
;; Want to match
;; aa :
;; aa,bb :
;; a[34:32] :
;; a,
;;   b :
(defconst vpp-assignment-operator-re
  (eval-when-compile
     (vpp-regexp-opt
      `(
	;; blocking assignment_operator
	"=" "+=" "-=" "*=" "/=" "%=" "&=" "|=" "^=" "<<=" ">>=" "<<<=" ">>>="
	;; non blocking assignment operator
	"<="
	;; comparison
	"==" "!=" "===" "!===" "<=" ">=" "==\?" "!=\?"
	;; event_trigger
	"->" "->>"
	;; property_expr
	"|->" "|=>"
	;; Is this a legal vpp operator?
	":="
	) 't
      )))
(defconst vpp-assignment-operation-re
  (concat
;     "\\(^\\s-*[A-Za-z0-9_]+\\(\\[\\([A-Za-z0-9_]+\\)\\]\\)*\\s-*\\)"
;     "\\(^\\s-*[^=<>+-*/%&|^:\\s-]+[^=<>+-*/%&|^\n]*?\\)"
     "\\(^.*?\\)" "\\B" vpp-assignment-operator-re "\\B" ))

(defconst vpp-label-re (concat vpp-symbol-re "\\s-*:\\s-*"))
(defconst vpp-property-re
  (concat "\\(" vpp-label-re "\\)?"
	  "\\(\\(assert\\|assume\\|cover\\)\\>\\s-+\\<property\\>\\)\\|\\(assert\\)"))
	  ;;  "\\(assert\\|assume\\|cover\\)\\s-+property\\>"

(defconst vpp-no-indent-begin-re
  "\\<\\(if\\|else\\|while\\|for\\|repeat\\|always\\|always_comb\\|always_ff\\|always_latch\\)\\>")

(defconst vpp-ends-re
  ;; Parenthesis indicate type of keyword found
  (concat
   "\\(\\<else\\>\\)\\|"		; 1
   "\\(\\<if\\>\\)\\|"			; 2
   "\\(\\<assert\\>\\)\\|"              ; 3
   "\\(\\<end\\>\\)\\|"			; 3.1
   "\\(\\<endcase\\>\\)\\|"		; 4
   "\\(\\<endfunction\\>\\)\\|"		; 5
   "\\(\\<endtask\\>\\)\\|"		; 6
   "\\(\\<endspecify\\>\\)\\|"		; 7
   "\\(\\<endtable\\>\\)\\|"		; 8
   "\\(\\<endgenerate\\>\\)\\|"         ; 9
   "\\(\\<join\\(_any\\|_none\\)?\\>\\)\\|" ; 10
   "\\(\\<endclass\\>\\)\\|"            ; 11
   "\\(\\<endgroup\\>\\)\\|"            ; 12
   ;; VMM
   "\\(\\<`vmm_data_member_end\\>\\)\\|"
   "\\(\\<`vmm_env_member_end\\>\\)\\|"
   "\\(\\<`vmm_scenario_member_end\\>\\)\\|"
   "\\(\\<`vmm_subenv_member_end\\>\\)\\|"
   "\\(\\<`vmm_xactor_member_end\\>\\)\\|"
   ;; OVM
   "\\(\\<`ovm_component_utils_end\\>\\)\\|"
   "\\(\\<`ovm_field_utils_end\\>\\)\\|"
   "\\(\\<`ovm_object_utils_end\\>\\)\\|"
   "\\(\\<`ovm_sequence_utils_end\\>\\)\\|"
   "\\(\\<`ovm_sequencer_utils_end\\>\\)"
   ;; UVM
   "\\(\\<`uvm_component_utils_end\\>\\)\\|"
   "\\(\\<`uvm_field_utils_end\\>\\)\\|"
   "\\(\\<`uvm_object_utils_end\\>\\)\\|"
   "\\(\\<`uvm_sequence_utils_end\\>\\)\\|"
   "\\(\\<`uvm_sequencer_utils_end\\>\\)"
   ))

(defconst vpp-auto-end-comment-lines-re
  ;; Matches to names in this list cause auto-end-commenting
  (concat "\\("
	  vpp-directive-re "\\)\\|\\("
	  (eval-when-compile
	    (vpp-regexp-words
	     `( "begin"
		"else"
		"end"
		"endcase"
		"endclass"
		"endclocking"
		"endgroup"
		"endfunction"
		"endmodule"
		"endprogram"
		"endprimitive"
		"endinterface"
		"endpackage"
		"endsequence"
		"endspecify"
		"endtable"
		"endtask"
		"join"
		"join_any"
		"join_none"
		"module"
		"defmod"
		"macromodule"
		"primitive"
		"interface"
		"package")))
	  "\\)"))

;;; NOTE: vpp-leap-to-head expects that vpp-end-block-re and
;;; vpp-end-block-ordered-re matches exactly the same strings.
(defconst vpp-end-block-ordered-re
  ;; Parenthesis indicate type of keyword found
  (concat "\\(\\<endcase\\>\\)\\|" ; 1
	  "\\(\\<end\\>\\)\\|"     ; 2
	  "\\(\\<end"              ; 3, but not used
	  "\\("                    ; 4, but not used
	  "\\(function\\)\\|"      ; 5
	  "\\(task\\)\\|"          ; 6
	  "\\(module\\)\\|"        ; 7
	  "\\(primitive\\)\\|"     ; 8
	  "\\(interface\\)\\|"     ; 9
	  "\\(package\\)\\|"       ; 10
	  "\\(class\\)\\|"         ; 11
          "\\(group\\)\\|"         ; 12
          "\\(program\\)\\|"	   ; 13
          "\\(sequence\\)\\|"	   ; 14
	  "\\(clocking\\)\\|"      ; 15
	  "\\)\\>\\)"))
(defconst vpp-end-block-re
  (eval-when-compile
    (vpp-regexp-words

     `("end"  ;; closes begin
       "endcase" ;; closes any of case, casex casez or randcase
       "join" "join_any" "join_none" ;; closes fork
       "endclass"
       "endtable"
       "endspecify"
       "endfunction"
       "endgenerate"
       "endtask"
       "endgroup"
       "endproperty"
       "endinterface"
       "endpackage"
       "endprogram"
       "endsequence"
       "endclocking"
       ;; OVM
       "`ovm_component_utils_end"
       "`ovm_field_utils_end"
       "`ovm_object_utils_end"
       "`ovm_sequence_utils_end"
       "`ovm_sequencer_utils_end"
       ;; UVM
       "`uvm_component_utils_end"
       "`uvm_field_utils_end"
       "`uvm_object_utils_end"
       "`uvm_sequence_utils_end"
       "`uvm_sequencer_utils_end"
       ;; VMM
       "`vmm_data_member_end"
       "`vmm_env_member_end"
       "`vmm_scenario_member_end"
       "`vmm_subenv_member_end"
       "`vmm_xactor_member_end"
       ))))


(defconst vpp-endcomment-reason-re
  ;; Parenthesis indicate type of keyword found
  (concat
   "\\(\\<begin\\>\\)\\|"		         ; 1
   "\\(\\<else\\>\\)\\|"		         ; 2
   "\\(\\<end\\>\\s-+\\<else\\>\\)\\|"	         ; 3
   "\\(\\<always_comb\\>\\(\[ \t\]*@\\)?\\)\\|"  ; 4
   "\\(\\<always_ff\\>\\(\[ \t\]*@\\)?\\)\\|"    ; 5
   "\\(\\<always_latch\\>\\(\[ \t\]*@\\)?\\)\\|" ; 6
   "\\(\\<fork\\>\\)\\|"			 ; 7
   "\\(\\<always\\>\\(\[ \t\]*@\\)?\\)\\|"
   "\\(\\<if\\>\\)\\|"
   vpp-property-re "\\|"
   "\\(\\(" vpp-label-re "\\)?\\<assert\\>\\)\\|"
   "\\(\\<clocking\\>\\)\\|"
   "\\(\\<task\\>\\)\\|"
   "\\(\\<function\\>\\)\\|"
   "\\(\\<initial\\>\\)\\|"
   "\\(\\<interface\\>\\)\\|"
   "\\(\\<package\\>\\)\\|"
   "\\(\\<final\\>\\)\\|"
   "\\(@\\)\\|"
   "\\(\\<while\\>\\)\\|"
   "\\(\\<for\\(ever\\|each\\)?\\>\\)\\|"
   "\\(\\<repeat\\>\\)\\|\\(\\<wait\\>\\)\\|"
   "#"))

(defconst vpp-named-block-re  "begin[ \t]*:")

;; These words begin a block which can occur inside a module which should be indented,
;; and closed with the respective word from the end-block list

(defconst vpp-beg-block-re
  (eval-when-compile
    (vpp-regexp-words
     `("begin"
       "case" "casex" "casez" "randcase"
       "clocking"
       "generate"
       "fork"
       "function"
       "property"
       "specify"
       "table"
       "task"
       ;; OVM
       "`ovm_component_utils_begin"
       "`ovm_component_param_utils_begin"
       "`ovm_field_utils_begin"
       "`ovm_object_utils_begin"
       "`ovm_object_param_utils_begin"
       "`ovm_sequence_utils_begin"
       "`ovm_sequencer_utils_begin"
       ;; UVM
       "`uvm_component_utils_begin"
       "`uvm_component_param_utils_begin"
       "`uvm_field_utils_begin"
       "`uvm_object_utils_begin"
       "`uvm_object_param_utils_begin"
       "`uvm_sequence_utils_begin"
       "`uvm_sequencer_utils_begin"
       ;; VMM
       "`vmm_data_member_begin"
       "`vmm_env_member_begin"
       "`vmm_scenario_member_begin"
       "`vmm_subenv_member_begin"
       "`vmm_xactor_member_begin"
       ))))
;; These are the same words, in a specific order in the regular
;; expression so that matching will work nicely for
;; vpp-forward-sexp and vpp-calc-indent
(defconst vpp-beg-block-re-ordered
  ( concat "\\(\\<begin\\>\\)"		;1
	   "\\|\\(\\<randcase\\>\\|\\(\\<unique\\s-+\\|priority\\s-+\\)?case[xz]?\\>\\)" ; 2,3
	   "\\|\\(\\(\\<disable\\>\\s-+\\|\\<wait\\>\\s-+\\)?fork\\>\\)" ;4,5
	   "\\|\\(\\<class\\>\\)"		;6
	   "\\|\\(\\<table\\>\\)"		;7
	   "\\|\\(\\<specify\\>\\)"		;8
	   "\\|\\(\\<function\\>\\)"		;9
	   "\\|\\(\\(\\(\\<virtual\\>\\s-+\\)\\|\\(\\<protected\\>\\s-+\\)\\)*\\<function\\>\\)"	;10
	   "\\|\\(\\<task\\>\\)"		;14
	   "\\|\\(\\(\\(\\<virtual\\>\\s-+\\)\\|\\(\\<protected\\>\\s-+\\)\\)*\\<task\\>\\)"	;15
	   "\\|\\(\\<generate\\>\\)"		;18
	   "\\|\\(\\<covergroup\\>\\)"	;16 20
	   "\\|\\(\\(\\(\\<cover\\>\\s-+\\)\\|\\(\\<assert\\>\\s-+\\)\\)*\\<property\\>\\)"	;17 21
	   "\\|\\(\\<\\(rand\\)?sequence\\>\\)" ;21 25
	   "\\|\\(\\<clocking\\>\\)"          ;22 27
	   "\\|\\(\\<`[ou]vm_[a-z_]+_begin\\>\\)" ;28
           "\\|\\(\\<`vmm_[a-z_]+_member_begin\\>\\)"
	   ;;
	   ))

(defconst vpp-end-block-ordered-rry
  [ "\\(\\<begin\\>\\)\\|\\(\\<end\\>\\)\\|\\(\\<endcase\\>\\)\\|\\(\\<join\\(_any\\|_none\\)?\\>\\)"
    "\\(\\<randcase\\>\\|\\<case[xz]?\\>\\)\\|\\(\\<endcase\\>\\)"
    "\\(\\<fork\\>\\)\\|\\(\\<join\\(_any\\|_none\\)?\\>\\)"
    "\\(\\<class\\>\\)\\|\\(\\<endclass\\>\\)"
    "\\(\\<table\\>\\)\\|\\(\\<endtable\\>\\)"
    "\\(\\<specify\\>\\)\\|\\(\\<endspecify\\>\\)"
    "\\(\\<function\\>\\)\\|\\(\\<endfunction\\>\\)"
    "\\(\\<generate\\>\\)\\|\\(\\<endgenerate\\>\\)"
    "\\(\\<task\\>\\)\\|\\(\\<endtask\\>\\)"
    "\\(\\<covergroup\\>\\)\\|\\(\\<endgroup\\>\\)"
    "\\(\\<property\\>\\)\\|\\(\\<endproperty\\>\\)"
    "\\(\\<\\(rand\\)?sequence\\>\\)\\|\\(\\<endsequence\\>\\)"
    "\\(\\<clocking\\>\\)\\|\\(\\<endclocking\\>\\)"
    ] )

(defconst vpp-nameable-item-re
  (eval-when-compile
    (vpp-regexp-words
     `("begin"
       "fork"
       "join" "join_any" "join_none"
       "end"
       "endcase"
       "endconfig"
       "endclass"
       "endclocking"
       "endfunction"
       "endgenerate"
       "endmodule"
       "endprimitive"
       "endinterface"
       "endpackage"
       "endspecify"
       "endtable"
       "endtask" )
     )))

(defconst vpp-declaration-opener
  (eval-when-compile
    (vpp-regexp-words
     `("module" "defmod" "begin" "task" "function"))))

(defconst vpp-declaration-prefix-re
  (eval-when-compile
    (vpp-regexp-words
     `(
       ;; port direction
       "inout" "input" "output" "ref"
       ;; changeableness
       "const" "static" "protected" "local"
       ;; parameters
       "localparam" "parameter" "var"
       ;; type creation
       "typedef"
       ))))
(defconst vpp-declaration-core-re
  (eval-when-compile
    (vpp-regexp-words
     `(
       ;; port direction (by themselves)
       "inout" "input" "output"
       ;; integer_atom_type
       "byte" "shortint" "int" "longint" "integer" "time"
       ;; integer_vector_type
       "bit" "logic" "reg"
       ;; non_integer_type
       "shortreal" "real" "realtime"
       ;; net_type
       "supply0" "supply1" "tri" "triand" "trior" "trireg" "tri0" "tri1" "uwire" "wire" "wand" "wor"
       ;; misc
       "string" "event" "chandle" "virtual" "enum" "genvar"
       "struct" "union"
       ;; builtin classes
       "mailbox" "semaphore"
       ))))
(defconst vpp-declaration-re
  (concat "\\(" vpp-declaration-prefix-re "\\s-*\\)?" vpp-declaration-core-re))
(defconst vpp-range-re "\\(\\[[^]]*\\]\\s-*\\)+")
(defconst vpp-optional-signed-re "\\s-*\\(signed\\)?")
(defconst vpp-optional-signed-range-re
  (concat
   "\\s-*\\(\\<\\(reg\\|wire\\)\\>\\s-*\\)?\\(\\<signed\\>\\s-*\\)?\\(" vpp-range-re "\\)?"))
(defconst vpp-macroexp-re "`\\sw+")

(defconst vpp-delay-re "#\\s-*\\(\\([0-9_]+\\('s?[hdxbo][0-9a-fA-F_xz]+\\)?\\)\\|\\(([^()]*)\\)\\|\\(\\sw+\\)\\)")
(defconst vpp-declaration-re-2-no-macro
  (concat "\\s-*" vpp-declaration-re
	  "\\s-*\\(\\(" vpp-optional-signed-range-re "\\)\\|\\(" vpp-delay-re "\\)"
	  "\\)?"))
(defconst vpp-declaration-re-2-macro
  (concat "\\s-*" vpp-declaration-re
	  "\\s-*\\(\\(" vpp-optional-signed-range-re "\\)\\|\\(" vpp-delay-re "\\)"
	  "\\|\\(" vpp-macroexp-re "\\)"
	  "\\)?"))
(defconst vpp-declaration-re-1-macro
  (concat "^" vpp-declaration-re-2-macro))

(defconst vpp-declaration-re-1-no-macro (concat "^" vpp-declaration-re-2-no-macro))

(defconst vpp-defun-re
  (eval-when-compile (vpp-regexp-words `("macromodule" "module" "defmod" "class" "program" "interface" "package" "primitive" "config"))))
(defconst vpp-end-defun-re
  (eval-when-compile (vpp-regexp-words `("endmodule" "endclass" "endprogram" "endinterface" "endpackage" "endprimitive" "endconfig"))))
(defconst vpp-zero-indent-re
  (concat vpp-defun-re "\\|" vpp-end-defun-re))
(defconst vpp-inst-comment-re
  (eval-when-compile (vpp-regexp-words `("Outputs" "Inouts" "Inputs" "Interfaces" "Interfaced"))))

(defconst vpp-behavioral-block-beg-re
  (eval-when-compile (vpp-regexp-words `("initial" "final" "always" "always_comb" "always_latch" "always_ff"
					     "function" "task"))))
(defconst vpp-coverpoint-re "\\w+\\s*:\\s*\\(coverpoint\\|cross\\constraint\\)"  )
(defconst vpp-indent-re
  (eval-when-compile
    (vpp-regexp-words
     `(
       "{"
       "always" "always_latch" "always_ff" "always_comb"
       "begin" "end"
;       "unique" "priority"
       "case" "casex" "casez" "randcase" "endcase"
       "class" "endclass"
       "clocking" "endclocking"
       "config" "endconfig"
       "covergroup" "endgroup"
       "fork" "join" "join_any" "join_none"
       "function" "endfunction"
       "final"
       "generate" "endgenerate"
       "initial"
       "interface" "endinterface"
       "module" "macromodule" "endmodule" "defmod"
       "package" "endpackage"
       "primitive" "endprimitive"
       "program" "endprogram"
       "property" "endproperty"
       "sequence" "randsequence" "endsequence"
       "specify" "endspecify"
       "table" "endtable"
       "task" "endtask"
       "virtual"
       "`case"
       "`default"
       "`define" "`undef"
       "`if" "`ifdef" "`ifndef" "`else" "`elsif" "`endif"
       "`while" "`endwhile"
       "`for" "`endfor"
       "`format"
       "`include"
       "`let"
       "`protect" "`endprotect"
       "`switch" "`endswitch"
       "`timescale"
       "`time_scale"
       ;; OVM Begin tokens
       "`ovm_component_utils_begin"
       "`ovm_component_param_utils_begin"
       "`ovm_field_utils_begin"
       "`ovm_object_utils_begin"
       "`ovm_object_param_utils_begin"
       "`ovm_sequence_utils_begin"
       "`ovm_sequencer_utils_begin"
       ;; OVM End tokens
       "`ovm_component_utils_end"
       "`ovm_field_utils_end"
       "`ovm_object_utils_end"
       "`ovm_sequence_utils_end"
       "`ovm_sequencer_utils_end"
       ;; UVM Begin tokens
       "`uvm_component_utils_begin"
       "`uvm_component_param_utils_begin"
       "`uvm_field_utils_begin"
       "`uvm_object_utils_begin"
       "`uvm_object_param_utils_begin"
       "`uvm_sequence_utils_begin"
       "`uvm_sequencer_utils_begin"
       ;; UVM End tokens
       "`uvm_component_utils_end"	;; Typo in spec, it's not uvm_component_end
       "`uvm_field_utils_end"
       "`uvm_object_utils_end"
       "`uvm_sequence_utils_end"
       "`uvm_sequencer_utils_end"
       ;; VMM Begin tokens
       "`vmm_data_member_begin"
       "`vmm_env_member_begin"
       "`vmm_scenario_member_begin"
       "`vmm_subenv_member_begin"
       "`vmm_xactor_member_begin"
       ;; VMM End tokens
       "`vmm_data_member_end"
       "`vmm_env_member_end"
       "`vmm_scenario_member_end"
       "`vmm_subenv_member_end"
       "`vmm_xactor_member_end"
       ))))

(defconst vpp-defun-level-not-generate-re
  (eval-when-compile
    (vpp-regexp-words
     `( "module" "defmod" "macromodule" "primitive" "class" "program"
	"interface" "package" "config"))))

(defconst vpp-defun-level-re
  (eval-when-compile
    (vpp-regexp-words
     (append
      `( "module" "defmod" "macromodule" "primitive" "class" "program"
	 "interface" "package" "config")
      `( "initial" "final" "always" "always_comb" "always_ff"
	 "always_latch" "endtask" "endfunction" )))))

(defconst vpp-defun-level-generate-only-re
  (eval-when-compile
    (vpp-regexp-words
     `( "initial" "final" "always" "always_comb" "always_ff"
	"always_latch" "endtask" "endfunction" ))))

(defconst vpp-cpp-level-re
  (eval-when-compile
    (vpp-regexp-words
     `(
       "endmodule" "endprimitive" "endinterface" "endpackage" "endprogram" "endclass"
       ))))
(defconst vpp-disable-fork-re "\\(disable\\|wait\\)\\s-+fork\\>")
(defconst vpp-extended-case-re "\\(\\(unique\\s-+\\|priority\\s-+\\)?case[xz]?\\)")
(defconst vpp-extended-complete-re
  (concat "\\(\\(\\<extern\\s-+\\|\\<\\(\\<pure\\>\\s-+\\)?virtual\\s-+\\|\\<protected\\s-+\\)*\\(\\<function\\>\\|\\<task\\>\\)\\)"
	  "\\|\\(\\(\\<typedef\\>\\s-+\\)*\\(\\<struct\\>\\|\\<union\\>\\|\\<class\\>\\)\\)"
	  "\\|\\(\\(\\<import\\>\\s-+\\)?\\(\"DPI-C\"\\s-+\\)?\\(\\<pure\\>\\s-+\\)?\\(function\\>\\|task\\>\\)\\)"
	  "\\|" vpp-extended-case-re ))
(defconst vpp-basic-complete-re
  (eval-when-compile
    (vpp-regexp-words
     `(
       "always" "assign" "always_latch" "always_ff" "always_comb" "constraint"
       "import" "initial" "final" "module" "defmod" "macromodule" "repeat" "randcase" "while"
       "if" "for" "forever" "foreach" "else" "parameter" "do" "localparam" "assert"
       ))))
(defconst vpp-complete-reg
  (concat
   vpp-extended-complete-re "\\|\\(" vpp-basic-complete-re "\\)"))

(defconst vpp-end-statement-re
  (concat "\\(" vpp-beg-block-re "\\)\\|\\("
	  vpp-end-block-re "\\)"))

(defconst vpp-endcase-re
  (concat vpp-extended-case-re "\\|"
	  "\\(endcase\\)\\|"
	  vpp-defun-re
	  ))

(defconst vpp-exclude-str-start "/* -----\\/----- EXCLUDED -----\\/-----"
  "String used to mark beginning of excluded text.")
(defconst vpp-exclude-str-end " -----/\\----- EXCLUDED -----/\\----- */"
  "String used to mark end of excluded text.")
(defconst vpp-preprocessor-re
  (eval-when-compile
    (vpp-regexp-words
     `(
       "`define" "`include" "`ifdef" "`ifndef" "`if" "`endif" "`else"
       ))))

(defconst vpp-keywords
  '( "`case" "`default" "`define" "`else" "`endfor" "`endif"
     "`endprotect" "`endswitch" "`endwhile" "`for" "`format" "`if" "`ifdef"
     "`ifndef" "`include" "`let" "`protect" "`switch" "`timescale"
     "`time_scale" "`undef" "`while"

     "after" "alias" "always" "always_comb" "always_ff" "always_latch" "and"
     "assert" "assign" "assume" "automatic" "before" "begin" "bind"
     "bins" "binsof" "bit" "break" "buf" "bufif0" "bufif1" "byte"
     "case" "casex" "casez" "cell" "chandle" "class" "clocking" "cmos"
     "config" "const" "constraint" "context" "continue" "cover"
     "covergroup" "coverpoint" "cross" "deassign" "default" "defparam"
     "design" "disable" "dist" "do" "edge" "else" "end" "endcase"
     "endclass" "endclocking" "endconfig" "endfunction" "endgenerate"
     "endgroup" "endinterface" "endmodule" "endpackage" "endprimitive"
     "endprogram" "endproperty" "endspecify" "endsequence" "endtable"
     "endtask" "enum" "event" "expect" "export" "extends" "extern"
     "final" "first_match" "for" "force" "foreach" "forever" "fork"
     "forkjoin" "function" "generate" "genvar" "highz0" "highz1" "if"
     "iff" "ifnone" "ignore_bins" "illegal_bins" "import" "incdir"
     "include" "initial" "inout" "input" "inside" "instance" "int"
     "integer" "interface" "intersect" "join" "join_any" "join_none"
     "large" "liblist" "library" "local" "localparam" "logic"
     "longint" "macromodule" "mailbox" "matches" "medium" "modport" "module" "defmod"
     "nand" "negedge" "new" "nmos" "nor" "noshowcancelled" "not"
     "notif0" "notif1" "null" "or" "output" "package" "packed"
     "parameter" "pmos" "posedge" "primitive" "priority" "program"
     "property" "protected" "pull0" "pull1" "pulldown" "pullup"
     "pulsestyle_onevent" "pulsestyle_ondetect" "pure" "rand" "randc"
     "randcase" "randsequence" "rcmos" "real" "realtime" "ref" "reg"
     "release" "repeat" "return" "rnmos" "rpmos" "rtran" "rtranif0"
     "rtranif1" "scalared" "semaphore" "sequence" "shortint" "shortreal"
     "showcancelled" "signed" "small" "solve" "specify" "specparam"
     "static" "string" "strong0" "strong1" "struct" "super" "supply0"
     "supply1" "table" "tagged" "task" "this" "throughout" "time"
     "timeprecision" "timeunit" "tran" "tranif0" "tranif1" "tri"
     "tri0" "tri1" "triand" "trior" "trireg" "type" "typedef" "union"
     "unique" "unsigned" "use" "uwire" "var" "vectored" "virtual" "void"
     "wait" "wait_order" "wand" "weak0" "weak1" "while" "wildcard"
     "wire" "with" "within" "wor" "xnor" "xor"
     ;; 1800-2009
     "accept_on" "checker" "endchecker" "eventually" "global" "implies"
     "let" "nexttime" "reject_on" "restrict" "s_always" "s_eventually"
     "s_nexttime" "s_until" "s_until_with" "strong" "sync_accept_on"
     "sync_reject_on" "unique0" "until" "until_with" "untyped" "weak"
 )
 "List of Vpp keywords.")

(defconst vpp-comment-start-regexp "//\\|/\\*"
  "Dual comment value for `comment-start-regexp'.")

(defvar vpp-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Populate the syntax TABLE.
    (modify-syntax-entry ?\\ "\\" table)
    (modify-syntax-entry ?+ "." table)
    (modify-syntax-entry ?- "." table)
    (modify-syntax-entry ?= "." table)
    (modify-syntax-entry ?% "." table)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)
    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?| "." table)
    (modify-syntax-entry ?` "w" table)
    (modify-syntax-entry ?_ "w" table)
    (modify-syntax-entry ?\' "." table)

    ;; Set up TABLE to handle block and line style comments.
    (if (featurep 'xemacs)
	(progn
	  ;; XEmacs (formerly Lucid) has the best implementation
	  (modify-syntax-entry ?/  ". 1456" table)
	  (modify-syntax-entry ?*  ". 23"   table)
	  (modify-syntax-entry ?\n "> b"    table))
      ;; Emacs does things differently, but we can work with it
      (modify-syntax-entry ?/  ". 124b" table)
      (modify-syntax-entry ?*  ". 23"   table)
      (modify-syntax-entry ?\n "> b"    table))
    table)
  "Syntax table used in Vpp mode buffers.")

(defvar vpp-font-lock-keywords nil
  "Default highlighting for Vpp mode.")

(defvar vpp-font-lock-keywords-1 nil
  "Subdued level highlighting for Vpp mode.")

(defvar vpp-font-lock-keywords-2 nil
  "Medium level highlighting for Vpp mode.
See also `vpp-font-lock-extra-types'.")

(defvar vpp-font-lock-keywords-3 nil
  "Gaudy level highlighting for Vpp mode.
See also `vpp-font-lock-extra-types'.")

(defvar vpp-font-lock-translate-off-face
  'vpp-font-lock-translate-off-face
  "Font to use for translated off regions.")
(defface vpp-font-lock-translate-off-face
  '((((class color)
      (background light))
     (:background "gray90" :italic t ))
    (((class color)
      (background dark))
     (:background "gray10" :italic t ))
    (((class grayscale) (background light))
     (:foreground "DimGray" :italic t))
    (((class grayscale) (background dark))
     (:foreground "LightGray" :italic t))
    (t (:italis t)))
  "Font lock mode face used to background highlight translate-off regions."
  :group 'font-lock-highlighting-faces)

(defvar vpp-font-lock-p1800-face
  'vpp-font-lock-p1800-face
  "Font to use for p1800 keywords.")
(defface vpp-font-lock-p1800-face
  '((((class color)
      (background light))
     (:foreground "DarkOrange3" :bold t ))
    (((class color)
      (background dark))
     (:foreground "orange1" :bold t ))
    (t (:italic t)))
  "Font lock mode face used to highlight P1800 keywords."
  :group 'font-lock-highlighting-faces)

(defvar vpp-font-lock-ams-face
  'vpp-font-lock-ams-face
  "Font to use for Analog/Mixed Signal keywords.")
(defface vpp-font-lock-ams-face
  '((((class color)
      (background light))
     (:foreground "Purple" :bold t ))
    (((class color)
      (background dark))
     (:foreground "orange1" :bold t ))
    (t (:italic t)))
  "Font lock mode face used to highlight AMS keywords."
  :group 'font-lock-highlighting-faces)

(defvar vpp-font-grouping-keywords-face
  'vpp-font-lock-grouping-keywords-face
  "Font to use for Vpp Grouping Keywords (such as begin..end).")
(defface vpp-font-lock-grouping-keywords-face
  '((((class color)
      (background light))
     (:foreground "red4" :bold t ))
    (((class color)
      (background dark))
     (:foreground "red4" :bold t ))
    (t (:italic t)))
  "Font lock mode face used to highlight vpp grouping keywords."
  :group 'font-lock-highlighting-faces)

(let* ((vpp-type-font-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '(
	     "and" "bit" "buf" "bufif0" "bufif1" "cmos" "defparam"
	     "event" "genvar" "inout" "input" "integer" "localparam"
	     "logic" "mailbox" "nand" "nmos" "not" "notif0" "notif1" "or"
	     "output" "parameter" "pmos" "pull0" "pull1" "pulldown" "pullup"
	     "rcmos" "real" "realtime" "reg" "rnmos" "rpmos" "rtran"
	     "rtranif0" "rtranif1" "semaphore" "signed" "struct" "supply"
	     "supply0" "supply1" "time" "tran" "tranif0" "tranif1"
	     "tri" "tri0" "tri1" "triand" "trior" "trireg" "typedef"
	     "uwire" "vectored" "wand" "wire" "wor" "xnor" "xor"
	     ) nil  )))

       (vpp-pragma-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '("surefire" "auto" "synopsys" "rtl_synthesis" "verilint" "leda" "0in"
	     ) nil  )))

       (vpp-1800-2005-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '("alias" "assert" "assume" "automatic" "before" "bind"
	     "bins" "binsof" "break" "byte" "cell" "chandle" "class"
	     "clocking" "config" "const" "constraint" "context" "continue"
	     "cover" "covergroup" "coverpoint" "cross" "deassign" "design"
	     "dist" "do" "edge" "endclass" "endclocking" "endconfig"
	     "endgroup" "endprogram" "endproperty" "endsequence" "enum"
	     "expect" "export" "extends" "extern" "first_match" "foreach"
	     "forkjoin" "genvar" "highz0" "highz1" "ifnone" "ignore_bins"
	     "illegal_bins" "import" "incdir" "include" "inside" "instance"
	     "int" "intersect" "large" "liblist" "library" "local" "longint"
	     "matches" "medium" "modport" "new" "noshowcancelled" "null"
	     "packed" "program" "property" "protected" "pull0" "pull1"
	     "pulsestyle_onevent" "pulsestyle_ondetect" "pure" "rand" "randc"
	     "randcase" "randsequence" "ref" "release" "return" "scalared"
	     "sequence" "shortint" "shortreal" "showcancelled" "small" "solve"
	     "specparam" "static" "string" "strong0" "strong1" "struct"
	     "super" "tagged" "this" "throughout" "timeprecision" "timeunit"
	     "type" "union" "unsigned" "use" "var" "virtual" "void"
	     "wait_order" "weak0" "weak1" "wildcard" "with" "within"
	     ) nil )))

       (vpp-1800-2009-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '("accept_on" "checker" "endchecker" "eventually" "global"
	     "implies" "let" "nexttime" "reject_on" "restrict" "s_always"
	     "s_eventually" "s_nexttime" "s_until" "s_until_with" "strong"
	     "sync_accept_on" "sync_reject_on" "unique0" "until"
	     "until_with" "untyped" "weak" ) nil )))

       (vpp-ams-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '("above" "abs" "absdelay" "acos" "acosh" "ac_stim"
	     "aliasparam" "analog" "analysis" "asin" "asinh" "atan" "atan2" "atanh"
	     "branch" "ceil" "connectmodule" "connectrules" "cos" "cosh" "ddt"
	     "ddx" "discipline" "driver_update" "enddiscipline" "endconnectrules"
	     "endnature" "endparamset" "exclude" "exp" "final_step" "flicker_noise"
	     "floor" "flow" "from" "ground" "hypot" "idt" "idtmod" "inf"
	     "initial_step" "laplace_nd" "laplace_np" "laplace_zd" "laplace_zp"
	     "last_crossing" "limexp" "ln" "log" "max" "min" "nature"
	     "net_resolution" "noise_table" "paramset" "potential" "pow" "sin"
	     "sinh" "slew" "sqrt" "tan" "tanh" "timer" "transition" "white_noise"
	     "wreal" "zi_nd" "zi_np" "zi_zd" ) nil )))

       (vpp-font-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '(
	     "assign" "case" "casex" "casez" "randcase" "deassign"
	     "default" "disable" "else" "endcase" "endfunction"
	     "endgenerate" "endinterface" "endmodule" "endprimitive"
	     "endspecify" "endtable" "endtask" "final" "for" "force" "return" "break"
	     "continue" "forever" "fork" "function" "generate" "if" "iff" "initial"
	     "interface" "join" "join_any" "join_none" "macromodule" "module" "negedge" "defmod"
	     "package" "endpackage" "always" "always_comb" "always_ff"
	     "always_latch" "posedge" "primitive" "priority" "release"
	     "repeat" "specify" "table" "task" "unique" "wait" "while"
	     "class" "program" "endclass" "endprogram"
	     ) nil  )))

       (vpp-font-grouping-keywords
	(eval-when-compile
	  (vpp-regexp-opt
	   '( "begin" "end" ) nil  ))))

  (setq vpp-font-lock-keywords
	(list
	 ;; Fontify all builtin keywords
	 (concat "\\<\\(" vpp-font-keywords "\\|"
		       ;; And user/system tasks and functions
              "\\$[a-zA-Z][a-zA-Z0-9_\\$]*"
              "\\)\\>")
	 ;; Fontify all types
	 (if vpp-highlight-grouping-keywords
	     (cons (concat "\\<\\(" vpp-font-grouping-keywords "\\)\\>")
		   'vpp-font-lock-ams-face)
	   (cons (concat "\\<\\(" vpp-font-grouping-keywords "\\)\\>")
		 'font-lock-type-face))
	 (cons (concat "\\<\\(" vpp-type-font-keywords "\\)\\>")
          'font-lock-type-face)
	 ;; Fontify IEEE-1800-2005 keywords appropriately
	 (if vpp-highlight-p1800-keywords
	     (cons (concat "\\<\\(" vpp-1800-2005-keywords "\\)\\>")
		   'vpp-font-lock-p1800-face)
	   (cons (concat "\\<\\(" vpp-1800-2005-keywords "\\)\\>")
		 'font-lock-type-face))
	 ;; Fontify IEEE-1800-2009 keywords appropriately
	 (if vpp-highlight-p1800-keywords
	     (cons (concat "\\<\\(" vpp-1800-2009-keywords "\\)\\>")
		   'vpp-font-lock-p1800-face)
	   (cons (concat "\\<\\(" vpp-1800-2009-keywords "\\)\\>")
		 'font-lock-type-face))
	 ;; Fontify Vpp-AMS keywords
	 (cons (concat "\\<\\(" vpp-ams-keywords "\\)\\>")
	       'vpp-font-lock-ams-face)))

  (setq vpp-font-lock-keywords-1
	(append vpp-font-lock-keywords
		(list
		 ;; Fontify module definitions
		 (list
		  "\\<\\(\\(macro\\)?module\\|defmod\\|primitive\\|class\\|program\\|interface\\|package\\|task\\)\\>\\s-*\\(\\sw+\\)"
		  '(1 font-lock-keyword-face)
		  '(3 font-lock-function-name-face 'prepend))
		 ;; Fontify function definitions
		 (list
		  (concat "\\<function\\>\\s-+\\(integer\\|real\\(time\\)?\\|time\\)\\s-+\\(\\sw+\\)" )
		       '(1 font-lock-keyword-face)
		       '(3 font-lock-constant-face prepend))
		 '("\\<function\\>\\s-+\\(\\[[^]]+\\]\\)\\s-+\\(\\sw+\\)"
		   (1 font-lock-keyword-face)
		   (2 font-lock-constant-face append))
		 '("\\<function\\>\\s-+\\(\\sw+\\)"
		   1 'font-lock-constant-face append))))

  (setq vpp-font-lock-keywords-2
	(append vpp-font-lock-keywords-1
		(list
		 ;; Fontify pragmas
		 (concat "\\(//\\s-*\\(" vpp-pragma-keywords "\\)\\s-.*\\)")
		 ;; Fontify escaped names
		 '("\\(\\\\\\S-*\\s-\\)"  0 font-lock-function-name-face)
		 ;; Fontify macro definitions/ uses
		 '("`\\s-*[A-Za-z][A-Za-z0-9_]*" 0 (if (boundp 'font-lock-preprocessor-face)
						       'font-lock-preprocessor-face
						     'font-lock-type-face))
		 ;; Fontify delays/numbers
		 '("\\(@\\)\\|\\(#\\s-*\\(\\(\[0-9_.\]+\\('s?[hdxbo][0-9a-fA-F_xz]*\\)?\\)\\|\\(([^()]+)\\|\\sw+\\)\\)\\)"
		   0 font-lock-type-face append)
		 ;; Fontify instantiation names
		 '("\\([A-Za-z][A-Za-z0-9_]*\\)\\s-*(" 1 font-lock-function-name-face)
		 )))

  (setq vpp-font-lock-keywords-3
	(append vpp-font-lock-keywords-2
		(when vpp-highlight-translate-off
		  (list
		   ;; Fontify things in translate off regions
		   '(vpp-match-translate-off
		     (0 'vpp-font-lock-translate-off-face prepend))
		   )))))

;;
;; Buffer state preservation

(defmacro vpp-save-buffer-state (&rest body)
  "Execute BODY forms, saving state around insignificant change.
Changes in text properties like `face' or `syntax-table' are
considered insignificant.  This macro allows text properties to
be changed, even in a read-only buffer.

A change is considered significant if it affects the buffer text
in any way that isn't completely restored again.  Any
user-visible changes to the buffer must not be within a
`vpp-save-buffer-state'."
  ;; From c-save-buffer-state
  `(let* ((modified (buffer-modified-p))
	  (buffer-undo-list t)
	  (inhibit-read-only t)
	  (inhibit-point-motion-hooks t)
	  (vpp-no-change-functions t)
	  before-change-functions
	  after-change-functions
	  deactivate-mark
	  buffer-file-name ; Prevent primitives checking
	  buffer-file-truename)	; for file modification
     (unwind-protect
	 (progn ,@body)
       (and (not modified)
	    (buffer-modified-p)
	    (set-buffer-modified-p nil)))))

(defmacro vpp-save-no-change-functions (&rest body)
  "Execute BODY forms, disabling all change hooks in BODY.
For insignificant changes, see instead `vpp-save-buffer-state'."
  `(let* ((inhibit-point-motion-hooks t)
	  (vpp-no-change-functions t)
	  before-change-functions
	  after-change-functions)
     (progn ,@body)))

(defvar vpp-save-font-mod-hooked nil
  "Local variable when inside a `vpp-save-font-mods' block.")
(make-variable-buffer-local 'vpp-save-font-mod-hooked)

(defmacro vpp-save-font-mods (&rest body)
  "Execute BODY forms, disabling text modifications to allow performing BODY.
Includes temporary disabling of `font-lock' to restore the buffer
to full text form for parsing.  Additional actions may be specified with
`vpp-before-save-font-hook' and `vpp-after-save-font-hook'."
  ;; Before version 20, match-string with font-lock returns a
  ;; vector that is not equal to the string.  IE if on "input"
  ;; nil==(equal "input" (progn (looking-at "input") (match-string 0)))
  `(let* ((hooked (unless vpp-save-font-mod-hooked
		    (vpp-run-hooks 'vpp-before-save-font-hook)
		    t))
	  (vpp-save-font-mod-hooked t)
	  (fontlocked (when (and (boundp 'font-lock-mode) font-lock-mode)
			(font-lock-mode 0)
			t)))
     (unwind-protect
	   (progn ,@body)
	 ;; Unwind forms
	 (when fontlocked (font-lock-mode t))
	 (when hooked (vpp-run-hooks 'vpp-after-save-font-hook)))))

;;
;; Comment detection and caching

(defvar vpp-scan-cache-preserving nil
  "If set, the specified buffer's comment properties are static.
Buffer changes will be ignored.  See `vpp-inside-comment-or-string-p'
and `vpp-scan'.")

(defvar vpp-scan-cache-tick nil
  "Modification tick at which `vpp-scan' was last completed.")
(make-variable-buffer-local 'vpp-scan-cache-tick)

(defun vpp-scan-cache-flush ()
  "Flush the `vpp-scan' cache."
  (setq vpp-scan-cache-tick nil))

(defun vpp-scan-cache-ok-p ()
  "Return t iff the scan cache is up to date."
  (or (and vpp-scan-cache-preserving
	   (eq vpp-scan-cache-preserving (current-buffer))
	   vpp-scan-cache-tick)
      (equal vpp-scan-cache-tick (buffer-chars-modified-tick))))

(defmacro vpp-save-scan-cache (&rest body)
  "Execute the BODY forms, allowing scan cache preservation within BODY.
This requires that insertions must use `vpp-insert'."
  ;; If the buffer is out of date, trash it, as we'll not check later the tick
  ;; Note this must work properly if there's multiple layers of calls
  ;; to vpp-save-scan-cache even with differing ticks.
  `(progn
     (unless (vpp-scan-cache-ok-p)  ;; Must be before let
       (setq vpp-scan-cache-tick nil))
     (let* ((vpp-scan-cache-preserving (current-buffer)))
       (progn ,@body))))

(defun vpp-scan-region (beg end)
  "Parse between BEG and END for `vpp-inside-comment-or-string-p'.
This creates v-cmts properties where comments are in force."
  ;; Why properties and not overlays?  Overlays have much slower non O(1)
  ;; lookup times.
  ;; This function is warm - called on every vpp-insert
  (save-excursion
    (save-match-data
      (vpp-save-buffer-state
       (let (pt)
	 (goto-char beg)
	 (while (< (point) end)
	   (cond ((looking-at "//")
		  (setq pt (point))
		  (or (search-forward "\n" end t)
		      (goto-char end))
		  ;; "1+": The leading // or /* itself isn't considered as
		  ;; being "inside" the comment, so that a (search-backward)
		  ;; that lands at the start of the // won't mis-indicate
		  ;; it's inside a comment.  Also otherwise it would be
		  ;; hard to find a commented out /*AS*/ vs one that isn't
		  (put-text-property (1+ pt) (point) 'v-cmts t))
		 ((looking-at "/\\*")
		  (setq pt (point))
		  (or (search-forward "*/" end t)
		      ;; No error - let later code indicate it so we can
		      ;; use inside functions on-the-fly
		      ;;(error "%s: Unmatched /* */, at char %d"
		      ;;       (vpp-point-text) (point))
		      (goto-char end))
		  (put-text-property (1+ pt) (point) 'v-cmts t))
		 ((looking-at "\"")
		  (setq pt (point))
		  (or (re-search-forward "[^\\]\"" end t)	;; don't forward-char first, since we look for a non backslash first
		      ;; No error - let later code indicate it so we can
		      (goto-char end))
		  (put-text-property (1+ pt) (point) 'v-cmts t))
		 (t
		  (forward-char 1)
		  (if (re-search-forward "[/\"]" end t)
		      (backward-char 1)
		    (goto-char end))))))))))

(defun vpp-scan ()
  "Parse the buffer, marking all comments with properties.
Also assumes any text inserted since `vpp-scan-cache-tick'
either is ok to parse as a non-comment, or `vpp-insert' was used."
  ;; See also `vpp-scan-debug' and `vpp-scan-and-debug'
  (unless (vpp-scan-cache-ok-p)
    (save-excursion
      (vpp-save-buffer-state
	(when vpp-debug
	  (message "Scanning %s cache=%s cachetick=%S tick=%S" (current-buffer)
		   vpp-scan-cache-preserving vpp-scan-cache-tick
		   (buffer-chars-modified-tick)))
	(remove-text-properties (point-min) (point-max) '(v-cmts nil))
	(vpp-scan-region (point-min) (point-max))
	(setq vpp-scan-cache-tick (buffer-chars-modified-tick))
	(when vpp-debug (message "Scanning... done"))))))

(defun vpp-scan-debug ()
  "For debugging, show with display face results of `vpp-scan'."
  (font-lock-mode 0)
  ;;(if dbg (setq dbg (concat dbg (format "vpp-scan-debug\n"))))
  (save-excursion
    (goto-char (point-min))
    (remove-text-properties (point-min) (point-max) '(face nil))
    (while (not (eobp))
      (cond ((get-text-property (point) 'v-cmts)
	     (put-text-property (point) (1+ (point)) `face 'underline)
	     ;;(if dbg (setq dbg (concat dbg (format "  v-cmts at %S\n" (point)))))
	     (forward-char 1))
	    (t
	     (goto-char (or (next-property-change (point)) (point-max))))))))

(defun vpp-scan-and-debug ()
  "For debugging, run `vpp-scan' and `vpp-scan-debug'."
  (let (vpp-scan-cache-preserving
	vpp-scan-cache-tick)
    (goto-char (point-min))
    (vpp-scan)
    (vpp-scan-debug)))

(defun vpp-inside-comment-or-string-p (&optional pos)
  "Check if optional point POS is inside a comment.
This may require a slow pre-parse of the buffer with `vpp-scan'
to establish comment properties on all text."
  ;; This function is very hot
  (vpp-scan)
  (if pos
      (and (>= pos (point-min))
	   (get-text-property pos 'v-cmts))
    (get-text-property (point) 'v-cmts)))

(defun vpp-insert (&rest stuff)
  "Insert STUFF arguments, tracking for `vpp-inside-comment-or-string-p'.
Any insert that includes a comment must have the entire comment
inserted using a single call to `vpp-insert'."
  (let ((pt (point)))
    (while stuff
      (insert (car stuff))
      (setq stuff (cdr stuff)))
    (vpp-scan-region pt (point))))

;; More searching

(defun vpp-declaration-end ()
  (search-forward ";"))

(defun vpp-point-text (&optional pointnum)
  "Return text describing where POINTNUM or current point is (for errors).
Use filename, if current buffer being edited shorten to just buffer name."
  (concat (or (and (equal (window-buffer (selected-window)) (current-buffer))
		   (buffer-name))
	      buffer-file-name
	      (buffer-name))
	  ":" (int-to-string (1+ (count-lines (point-min) (or pointnum (point)))))))

(defun electric-vpp-backward-sexp ()
  "Move backward over one balanced expression."
  (interactive)
  ;; before that see if we are in a comment
  (vpp-backward-sexp))

(defun electric-vpp-forward-sexp ()
  "Move forward over one balanced expression."
  (interactive)
  ;; before that see if we are in a comment
  (vpp-forward-sexp))

;;;used by hs-minor-mode
(defun vpp-forward-sexp-function (arg)
  (if (< arg 0)
      (vpp-backward-sexp)
    (vpp-forward-sexp)))


(defun vpp-backward-sexp ()
  (let ((reg)
	(elsec 1)
	(found nil)
	(st (point)))
    (if (not (looking-at "\\<"))
	(forward-word -1))
    (cond
     ((vpp-skip-backward-comment-or-string))
     ((looking-at "\\<else\\>")
      (setq reg (concat
		 vpp-end-block-re
		 "\\|\\(\\<else\\>\\)"
		 "\\|\\(\\<if\\>\\)"))
      (while (and (not found)
		  (vpp-re-search-backward reg nil 'move))
	(cond
	 ((match-end 1) ; matched vpp-end-block-re
	; try to leap back to matching outward block by striding across
	; indent level changing tokens then immediately
	; previous line governs indentation.
	  (vpp-leap-to-head))
	 ((match-end 2) ; else, we're in deep
	  (setq elsec (1+ elsec)))
	 ((match-end 3) ; found it
	  (setq elsec (1- elsec))
	  (if (= 0 elsec)
	      ;; Now previous line describes syntax
	      (setq found 't))))))
     ((looking-at vpp-end-block-re)
      (vpp-leap-to-head))
     ((looking-at "\\(endmodule\\>\\)\\|\\(\\<endprimitive\\>\\)\\|\\(\\<endclass\\>\\)\\|\\(\\<endprogram\\>\\)\\|\\(\\<endinterface\\>\\)\\|\\(\\<endpackage\\>\\)")
      (cond
       ((match-end 1)
	(vpp-re-search-backward "\\<\\(macro\\)?module\\>" nil 'move))
       ((match-end 2)
	(vpp-re-search-backward "\\<primitive\\>" nil 'move))
       ((match-end 3)
	(vpp-re-search-backward "\\<class\\>" nil 'move))
       ((match-end 4)
	(vpp-re-search-backward "\\<program\\>" nil 'move))
       ((match-end 5)
	(vpp-re-search-backward "\\<interface\\>" nil 'move))
       ((match-end 6)
	(vpp-re-search-backward "\\<package\\>" nil 'move))
       (t
	(goto-char st)
	(backward-sexp 1))))
     (t
      (goto-char st)
      (backward-sexp)))))

(defun vpp-forward-sexp ()
  (let ((reg)
	(md 2)
	(st (point))
	(nest 'yes))
    (if (not (looking-at "\\<"))
	(forward-word -1))
    (cond
     ((vpp-skip-forward-comment-or-string)
      (vpp-forward-syntactic-ws))
     ((looking-at vpp-beg-block-re-ordered)
      (cond
       ((match-end 1);
	;; Search forward for matching end
	(setq reg "\\(\\<begin\\>\\)\\|\\(\\<end\\>\\)" ))
       ((match-end 2)
	;; Search forward for matching endcase
	(setq reg "\\(\\<randcase\\>\\|\\(\\<unique\\>\\s-+\\|\\<priority\\>\\s-+\\)?\\<case[xz]?\\>[^:]\\)\\|\\(\\<endcase\\>\\)" )
	(setq md 3) ;; ender is third item in regexp
	)
       ((match-end 4)
	;; might be "disable fork" or "wait fork"
	(let
	    (here)
	  (if (or
	       (looking-at vpp-disable-fork-re)
	       (and (looking-at "fork")
		    (progn
		      (setq here (point)) ;; sometimes a fork is just a fork
		      (forward-word -1)
		      (looking-at vpp-disable-fork-re))))
	      (progn ;; it is a disable fork; ignore it
		(goto-char (match-end 0))
		(forward-word 1)
		(setq reg nil))
	    (progn ;; it is a nice simple fork
	      (goto-char here)   ;; return from looking for "disable fork"
	      ;; Search forward for matching join
	      (setq reg "\\(\\<fork\\>\\)\\|\\(\\<join\\(_any\\|_none\\)?\\>\\)" )))))
       ((match-end 6)
	;; Search forward for matching endclass
	(setq reg "\\(\\<class\\>\\)\\|\\(\\<endclass\\>\\)" ))

       ((match-end 7)
	;; Search forward for matching endtable
	(setq reg "\\<endtable\\>" )
	(setq nest 'no))
      ((match-end 8)
       ;; Search forward for matching endspecify
       (setq reg "\\(\\<specify\\>\\)\\|\\(\\<endspecify\\>\\)" ))
      ((match-end 9)
       ;; Search forward for matching endfunction
       (setq reg "\\<endfunction\\>" )
       (setq nest 'no))
      ((match-end 10)
       ;; Search forward for matching endfunction
       (setq reg "\\<endfunction\\>" )
       (setq nest 'no))
      ((match-end 14)
       ;; Search forward for matching endtask
       (setq reg "\\<endtask\\>" )
       (setq nest 'no))
      ((match-end 15)
       ;; Search forward for matching endtask
       (setq reg "\\<endtask\\>" )
       (setq nest 'no))
      ((match-end 19)
       ;; Search forward for matching endgenerate
       (setq reg "\\(\\<generate\\>\\)\\|\\(\\<endgenerate\\>\\)" ))
      ((match-end 20)
       ;; Search forward for matching endgroup
       (setq reg "\\(\\<covergroup\\>\\)\\|\\(\\<endgroup\\>\\)" ))
      ((match-end 21)
       ;; Search forward for matching endproperty
       (setq reg "\\(\\<property\\>\\)\\|\\(\\<endproperty\\>\\)" ))
      ((match-end 25)
       ;; Search forward for matching endsequence
       (setq reg "\\(\\<\\(rand\\)?sequence\\>\\)\\|\\(\\<endsequence\\>\\)" )
       (setq md 3)) ; 3 to get to endsequence in the reg above
      ((match-end 27)
       ;; Search forward for matching endclocking
       (setq reg "\\(\\<clocking\\>\\)\\|\\(\\<endclocking\\>\\)" )))
      (if (and reg
	       (forward-word 1))
	  (catch 'skip
	    (if (eq nest 'yes)
		(let ((depth 1)
		      here)
		  (while (vpp-re-search-forward reg nil 'move)
		    (cond
		     ((match-end md) ; a closer in regular expression, so we are climbing out
		      (setq depth (1- depth))
		      (if (= 0 depth) ; we are out!
			  (throw 'skip 1)))
		     ((match-end 1) ; an opener in the r-e, so we are in deeper now
		      (setq here (point)) ; remember where we started
		      (goto-char (match-beginning 1))
		      (cond
		       ((if (or
			     (looking-at vpp-disable-fork-re)
			     (and (looking-at "fork")
				  (progn
				    (forward-word -1)
				    (looking-at vpp-disable-fork-re))))
			    (progn ;; it is a disable fork; another false alarm
			      (goto-char (match-end 0)))
			  (progn ;; it is a simple fork (or has nothing to do with fork)
			    (goto-char here)
			    (setq depth (1+ depth))))))))))
	      (if (vpp-re-search-forward reg nil 'move)
		  (throw 'skip 1))))))

     ((looking-at (concat
		   "\\(\\<\\(macro\\)?module\\>\\)\\|"
		   "\\(\\<defmod\\>\\)\\|"
		   "\\(\\<primitive\\>\\)\\|"
		   "\\(\\<class\\>\\)\\|"
		   "\\(\\<program\\>\\)\\|"
		   "\\(\\<interface\\>\\)\\|"
		   "\\(\\<package\\>\\)"))
      (cond
       ((match-end 1)
	(vpp-re-search-forward "\\<endmodule\\>" nil 'move))
       ((match-end 2)
	(vpp-re-search-forward "\\<endprimitive\\>" nil 'move))
       ((match-end 3)
	(vpp-re-search-forward "\\<endclass\\>" nil 'move))
       ((match-end 4)
	(vpp-re-search-forward "\\<endprogram\\>" nil 'move))
       ((match-end 5)
	(vpp-re-search-forward "\\<endinterface\\>" nil 'move))
       ((match-end 6)
	(vpp-re-search-forward "\\<endpackage\\>" nil 'move))
       (t
	(goto-char st)
	(if (= (following-char) ?\) )
	    (forward-char 1)
	  (forward-sexp 1)))))
     (t
      (goto-char st)
      (if (= (following-char) ?\) )
	  (forward-char 1)
	(forward-sexp 1))))))

(defun vpp-declaration-beg ()
  (vpp-re-search-backward vpp-declaration-re (bobp) t))

;;
;;
;;  Mode
;;
(defvar vpp-which-tool 1)
;;;###autoload
(define-derived-mode vpp-mode prog-mode "Vpp"
  "Major mode for editing Vpp code.
\\<vpp-mode-map>
See \\[describe-function] vpp-auto (\\[vpp-auto]) for details on how
AUTOs can improve coding efficiency.

Use \\[vpp-faq] for a pointer to frequently asked questions.

NEWLINE, TAB indents for Vpp code.
Delete converts tabs to spaces as it moves back.

Supports highlighting.

Turning on Vpp mode calls the value of the variable `vpp-mode-hook'
with no args, if that value is non-nil.

Variables controlling indentation/edit style:

 variable `vpp-indent-level'      (default 3)
   Indentation of Vpp statements with respect to containing block.
 `vpp-indent-level-module'        (default 3)
   Absolute indentation of Module level Vpp statements.
   Set to 0 to get initial and always statements lined up
   on the left side of your screen.
 `vpp-indent-level-declaration'   (default 3)
   Indentation of declarations with respect to containing block.
   Set to 0 to get them list right under containing block.
 `vpp-indent-level-behavioral'    (default 3)
   Indentation of first begin in a task or function block
   Set to 0 to get such code to lined up underneath the task or
   function keyword.
 `vpp-indent-level-directive'     (default 1)
   Indentation of `ifdef/`endif blocks.
 `vpp-cexp-indent'              (default 1)
   Indentation of Vpp statements broken across lines i.e.:
      if (a)
        begin
 `vpp-case-indent'              (default 2)
   Indentation for case statements.
 `vpp-auto-newline'             (default nil)
   Non-nil means automatically newline after semicolons and the punctuation
   mark after an end.
 `vpp-auto-indent-on-newline'   (default t)
   Non-nil means automatically indent line after newline.
 `vpp-tab-always-indent'        (default t)
   Non-nil means TAB in Vpp mode should always reindent the current line,
   regardless of where in the line point is when the TAB command is used.
 `vpp-indent-begin-after-if'    (default t)
   Non-nil means to indent begin statements following a preceding
   if, else, while, for and repeat statements, if any.  Otherwise,
   the begin is lined up with the preceding token.  If t, you get:
      if (a)
         begin // amount of indent based on `vpp-cexp-indent'
   otherwise you get:
      if (a)
      begin
 `vpp-auto-endcomments'         (default t)
   Non-nil means a comment /* ... */ is set after the ends which ends
   cases, tasks, functions and modules.
   The type and name of the object will be set between the braces.
 `vpp-minimum-comment-distance' (default 10)
   Minimum distance (in lines) between begin and end required before a comment
   will be inserted.  Setting this variable to zero results in every
   end acquiring a comment; the default avoids too many redundant
   comments in tight quarters.
 `vpp-auto-lineup'              (default 'declarations)
   List of contexts where auto lineup of code should be done.

Variables controlling other actions:

 `vpp-linter'                   (default surelint)
   Unix program to call to run the lint checker.  This is the default
   command for \\[compile-command] and \\[vpp-auto-save-compile].

See \\[customize] for the complete list of variables.

AUTO expansion functions are, in part:

    \\[vpp-auto]  Expand AUTO statements.
    \\[vpp-delete-auto]  Remove the AUTOs.
    \\[vpp-inject-auto]  Insert AUTOs for the first time.

Some other functions are:

    \\[vpp-complete-word]    Complete word with appropriate possibilities.
    \\[vpp-mark-defun]  Mark function.
    \\[vpp-beg-of-defun]  Move to beginning of current function.
    \\[vpp-end-of-defun]  Move to end of current function.
    \\[vpp-label-be]  Label matching begin ... end, fork ... join, etc statements.

    \\[vpp-comment-region]  Put marked area in a comment.
    \\[vpp-uncomment-region]  Uncomment an area commented with \\[vpp-comment-region].
    \\[vpp-insert-block]  Insert begin ... end.
    \\[vpp-star-comment]    Insert /* ... */.

    \\[vpp-sk-always]  Insert an always @(AS) begin .. end block.
    \\[vpp-sk-begin]  Insert a begin .. end block.
    \\[vpp-sk-case]  Insert a case block, prompting for details.
    \\[vpp-sk-for]  Insert a for (...) begin .. end block, prompting for details.
    \\[vpp-sk-generate]  Insert a generate .. endgenerate block.
    \\[vpp-sk-header]  Insert a header block at the top of file.
    \\[vpp-sk-initial]  Insert an initial begin .. end block.
    \\[vpp-sk-fork]  Insert a fork begin .. end .. join block.
    \\[vpp-sk-module]  Insert a module .. (/*AUTOARG*/);.. endmodule block.
    \\[vpp-sk-ovm-class]  Insert an OVM Class block.
    \\[vpp-sk-uvm-class]  Insert an UVM Class block.
    \\[vpp-sk-primitive]  Insert a primitive .. (.. );.. endprimitive block.
    \\[vpp-sk-repeat]  Insert a repeat (..) begin .. end block.
    \\[vpp-sk-specify]  Insert a specify .. endspecify block.
    \\[vpp-sk-task]  Insert a task .. begin .. end endtask block.
    \\[vpp-sk-while]  Insert a while (...) begin .. end block, prompting for details.
    \\[vpp-sk-casex]  Insert a casex (...) item: begin.. end endcase block, prompting for details.
    \\[vpp-sk-casez]  Insert a casez (...) item: begin.. end endcase block, prompting for details.
    \\[vpp-sk-if]  Insert an if (..) begin .. end block.
    \\[vpp-sk-else-if]  Insert an else if (..) begin .. end block.
    \\[vpp-sk-comment]  Insert a comment block.
    \\[vpp-sk-assign]  Insert an assign .. = ..; statement.
    \\[vpp-sk-function]  Insert a function .. begin .. end endfunction block.
    \\[vpp-sk-input]  Insert an input declaration, prompting for details.
    \\[vpp-sk-output]  Insert an output declaration, prompting for details.
    \\[vpp-sk-state-machine]  Insert a state machine definition, prompting for details.
    \\[vpp-sk-inout]  Insert an inout declaration, prompting for details.
    \\[vpp-sk-wire]  Insert a wire declaration, prompting for details.
    \\[vpp-sk-reg]  Insert a register declaration, prompting for details.
    \\[vpp-sk-define-signal]  Define signal under point as a register at the top of the module.

All key bindings can be seen in a Vpp-buffer with \\[describe-bindings].
Key bindings specific to `vpp-mode-map' are:

\\{vpp-mode-map}"
  :abbrev-table vpp-mode-abbrev-table
  (set (make-local-variable 'beginning-of-defun-function)
       'vpp-beg-of-defun)
  (set (make-local-variable 'end-of-defun-function)
       'vpp-end-of-defun)
  (set-syntax-table vpp-mode-syntax-table)
  (set (make-local-variable 'indent-line-function)
       #'vpp-indent-line-relative)
  (setq comment-indent-function 'vpp-comment-indent)
  (set (make-local-variable 'parse-sexp-ignore-comments) nil)
  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-start-skip) "/\\*+ *\\|// *")
  (set (make-local-variable 'comment-multi-line) nil)
  ;; Set up for compilation
  (setq vpp-which-tool 1)
  (setq vpp-tool 'vpp-linter)
  (vpp-set-compile-command)
  (when (boundp 'hack-local-variables-hook)  ;; Also modify any file-local-variables
    (add-hook 'hack-local-variables-hook 'vpp-modify-compile-command t))

  ;; Setting up menus
  (when (featurep 'xemacs)
    (easy-menu-add vpp-stmt-menu)
    (easy-menu-add vpp-menu)
    (setq mode-popup-menu (cons "Vpp Mode" vpp-stmt-menu)))

  ;; Stuff for GNU Emacs
  (set (make-local-variable 'font-lock-defaults)
       `((vpp-font-lock-keywords
	  vpp-font-lock-keywords-1
	  vpp-font-lock-keywords-2
	  vpp-font-lock-keywords-3)
         nil nil nil
	 ,(if (functionp 'syntax-ppss)
	      ;; vpp-beg-of-defun uses syntax-ppss, and syntax-ppss uses
	      ;; font-lock-beginning-of-syntax-function, so
	      ;; font-lock-beginning-of-syntax-function, can't use
              ;; vpp-beg-of-defun.
	      nil
	    'vpp-beg-of-defun)))
  ;;------------------------------------------------------------
  ;; now hook in 'vpp-highlight-include-files (eldo-mode.el&spice-mode.el)
  ;; all buffer local:
  (unless noninteractive  ;; Else can't see the result, and change hooks are slow
    (when (featurep 'xemacs)
      (make-local-hook 'font-lock-mode-hook)
      (make-local-hook 'font-lock-after-fontify-buffer-hook); doesn't exist in Emacs
      (make-local-hook 'after-change-functions))
    (add-hook 'font-lock-mode-hook 'vpp-highlight-buffer t t)
    (add-hook 'font-lock-after-fontify-buffer-hook 'vpp-highlight-buffer t t) ; not in Emacs
    (add-hook 'after-change-functions 'vpp-highlight-region t t))

  ;; Tell imenu how to handle Vpp.
  (set (make-local-variable 'imenu-generic-expression)
       vpp-imenu-generic-expression)
  ;; Tell which-func-modes that imenu knows about vpp
  (when (and (boundp 'which-func-modes) (listp which-func-modes))
    (add-to-list 'which-func-modes 'vpp-mode))
  ;; hideshow support
  (when (boundp 'hs-special-modes-alist)
    (unless (assq 'vpp-mode hs-special-modes-alist)
      (setq hs-special-modes-alist
	    (cons '(vpp-mode-mode  "\\<begin\\>" "\\<end\\>" nil
				       vpp-forward-sexp-function)
		  hs-special-modes-alist))))

  ;; Stuff for autos
  (add-hook 'write-contents-hooks 'vpp-auto-save-check nil 'local)
  ;; vpp-mode-hook call added by define-derived-mode
  )


;;
;;  Electric functions
;;
(defun electric-vpp-terminate-line (&optional arg)
  "Terminate line and indent next line.
With optional ARG, remove existing end of line comments."
  (interactive)
  ;; before that see if we are in a comment
  (let ((state (save-excursion (vpp-syntax-ppss))))
    (cond
     ((nth 7 state)			; Inside // comment
      (if (eolp)
	  (progn
	    (delete-horizontal-space)
	    (newline))
	(progn
	  (newline)
	  (insert "// ")
	  (beginning-of-line)))
      (vpp-indent-line))
     ((nth 4 state)			; Inside any comment (hence /**/)
      (newline)
      (vpp-more-comment))
     ((eolp)
       ;; First, check if current line should be indented
       (if (save-excursion
             (delete-horizontal-space)
	     (beginning-of-line)
	     (skip-chars-forward " \t")
	     (if (looking-at vpp-auto-end-comment-lines-re)
		 (let ((indent-str (vpp-indent-line)))
		   ;; Maybe we should set some endcomments
		   (if vpp-auto-endcomments
		       (vpp-set-auto-endcomments indent-str arg))
		   (end-of-line)
		   (delete-horizontal-space)
		   (if arg
		       ()
		     (newline))
		   nil)
	       (progn
		 (end-of-line)
		 (delete-horizontal-space)
		 't)))
	   ;; see if we should line up assignments
	   (progn
	     (if (or (eq 'all vpp-auto-lineup)
		     (eq 'assignments vpp-auto-lineup))
		 (vpp-pretty-expr t "\\(<\\|:\\)?=" ))
	     (newline))
	 (forward-line 1))
       ;; Indent next line
       (if vpp-auto-indent-on-newline
	   (vpp-indent-line)))
     (t
      (newline)))))

(defun electric-vpp-terminate-and-indent ()
  "Insert a newline and indent for the next statement."
  (interactive)
  (electric-vpp-terminate-line 1))

(defun electric-vpp-semi ()
  "Insert `;' character and reindent the line."
  (interactive)
  (vpp-insert-last-command-event)

  (if (or (vpp-in-comment-or-string-p)
	  (vpp-in-escaped-name-p))
      ()
    (save-excursion
      (beginning-of-line)
      (vpp-forward-ws&directives)
      (vpp-indent-line))
    (if (and vpp-auto-newline
	     (not (vpp-parenthesis-depth)))
	(electric-vpp-terminate-line))))

(defun electric-vpp-semi-with-comment ()
  "Insert `;' character, reindent the line and indent for comment."
  (interactive)
  (insert "\;")
  (save-excursion
    (beginning-of-line)
    (vpp-indent-line))
  (indent-for-comment))

(defun electric-vpp-colon ()
  "Insert `:' and do all indentations except line indent on this line."
  (interactive)
  (vpp-insert-last-command-event)
  ;; Do nothing if within string.
  (if (or
       (vpp-within-string)
       (not (vpp-in-case-region-p)))
      ()
    (save-excursion
      (let ((p (point))
	    (lim (progn (vpp-beg-of-statement) (point))))
	(goto-char p)
	(vpp-backward-case-item lim)
	(vpp-indent-line)))
;;    (let ((vpp-tab-always-indent nil))
;;      (vpp-indent-line))
    ))

;;(defun electric-vpp-equal ()
;;  "Insert `=', and do indentation if within block."
;;  (interactive)
;;  (vpp-insert-last-command-event)
;; Could auto line up expressions, but not yet
;;  (if (eq (car (vpp-calculate-indent)) 'block)
;;      (let ((vpp-tab-always-indent nil))
;;	(vpp-indent-command)))
;;  )

(defun electric-vpp-tick ()
  "Insert back-tick, and indent to column 0 if this is a CPP directive."
  (interactive)
  (vpp-insert-last-command-event)
  (save-excursion
    (if (vpp-in-directive-p)
        (vpp-indent-line))))

(defun electric-vpp-tab ()
  "Function called when TAB is pressed in Vpp mode."
  (interactive)
  ;; If vpp-tab-always-indent, indent the beginning of the line.
  (cond
   ;; The region is active, indent it.
   ((and (region-active-p)
	 (not (eq (region-beginning) (region-end))))
    (indent-region (region-beginning) (region-end) nil))
   ((or vpp-tab-always-indent
	(save-excursion
	  (skip-chars-backward " \t")
	  (bolp)))
    (let* ((oldpnt (point))
	   (boi-point
	    (save-excursion
	      (beginning-of-line)
	      (skip-chars-forward " \t")
	      (vpp-indent-line)
	      (back-to-indentation)
	      (point))))
      (if (< (point) boi-point)
	  (back-to-indentation)
	(cond ((not vpp-tab-to-comment))
	      ((not (eolp))
	       (end-of-line))
	      (t
	       (indent-for-comment)
	       (when (and (eolp) (= oldpnt (point)))
					; kill existing comment
		 (beginning-of-line)
		 (re-search-forward comment-start-skip oldpnt 'move)
		 (goto-char (match-beginning 0))
		 (skip-chars-backward " \t")
		 (kill-region (point) oldpnt)))))))
   (t (progn (insert "\t")))))



;;
;; Interactive functions
;;

(defun vpp-indent-buffer ()
  "Indent-region the entire buffer as Vpp code.
To call this from the command line, see \\[vpp-batch-indent]."
  (interactive)
  (vpp-mode)
  (indent-region (point-min) (point-max) nil))

(defun vpp-insert-block ()
  "Insert Vpp begin ... end; block in the code with right indentation."
  (interactive)
  (vpp-indent-line)
  (insert "begin")
  (electric-vpp-terminate-line)
  (save-excursion
    (electric-vpp-terminate-line)
    (insert "end")
    (beginning-of-line)
    (vpp-indent-line)))

(defun vpp-star-comment ()
  "Insert Vpp star comment at point."
  (interactive)
  (vpp-indent-line)
  (insert "/*")
  (save-excursion
    (newline)
    (insert " */"))
  (newline)
  (insert " * "))

(defun vpp-insert-1 (fmt max)
  "Use format string FMT to insert integers 0 to MAX - 1.
Inserts one integer per line, at the current column.  Stops early
if it reaches the end of the buffer."
  (let ((col (current-column))
        (n 0))
    (save-excursion
      (while (< n max)
        (insert (format fmt n))
        (forward-line 1)
        ;; Note that this function does not bother to check for lines
        ;; shorter than col.
        (if (eobp)
            (setq n max)
          (setq n (1+ n))
          (move-to-column col))))))

(defun vpp-insert-indices (max)
  "Insert a set of indices into a rectangle.
The upper left corner is defined by point.  Indices begin with 0
and extend to the MAX - 1.  If no prefix arg is given, the user
is prompted for a value.  The indices are surrounded by square
brackets \[].  For example, the following code with the point
located after the first 'a' gives:

    a = b                           a[  0] = b
    a = b                           a[  1] = b
    a = b                           a[  2] = b
    a = b                           a[  3] = b
    a = b   ==> insert-indices ==>  a[  4] = b
    a = b                           a[  5] = b
    a = b                           a[  6] = b
    a = b                           a[  7] = b
    a = b                           a[  8] = b"

  (interactive "NMAX: ")
  (vpp-insert-1 "[%3d]" max))

(defun vpp-generate-numbers (max)
  "Insert a set of generated numbers into a rectangle.
The upper left corner is defined by point.  The numbers are padded to three
digits, starting with 000 and extending to (MAX - 1).  If no prefix argument
is supplied, then the user is prompted for the MAX number.  Consider the
following code fragment:

    buf buf                             buf buf000
    buf buf                             buf buf001
    buf buf                             buf buf002
    buf buf                             buf buf003
    buf buf   ==> generate-numbers ==>  buf buf004
    buf buf                             buf buf005
    buf buf                             buf buf006
    buf buf                             buf buf007
    buf buf                             buf buf008"

  (interactive "NMAX: ")
  (vpp-insert-1 "%3.3d" max))

(defun vpp-mark-defun ()
  "Mark the current Vpp function (or procedure).
This puts the mark at the end, and point at the beginning."
  (interactive)
  (if (featurep 'xemacs)
      (progn
	(push-mark (point))
	(vpp-end-of-defun)
	(push-mark (point))
	(vpp-beg-of-defun)
	(if (fboundp 'zmacs-activate-region)
	    (zmacs-activate-region)))
    (mark-defun)))

(defun vpp-comment-region (start end)
  ; checkdoc-params: (start end)
  "Put the region into a Vpp comment.
The comments that are in this area are \"deformed\":
`*)' becomes `!(*' and `}' becomes `!{'.
These deformed comments are returned to normal if you use
\\[vpp-uncomment-region] to undo the commenting.

The commented area starts with `vpp-exclude-str-start', and ends with
`vpp-exclude-str-end'.  But if you change these variables,
\\[vpp-uncomment-region] won't recognize the comments."
  (interactive "r")
  (save-excursion
    ;; Insert start and endcomments
    (goto-char end)
    (if (and (save-excursion (skip-chars-forward " \t") (eolp))
	     (not (save-excursion (skip-chars-backward " \t") (bolp))))
	(forward-line 1)
      (beginning-of-line))
    (insert vpp-exclude-str-end)
    (setq end (point))
    (newline)
    (goto-char start)
    (beginning-of-line)
    (insert vpp-exclude-str-start)
    (newline)
    ;; Replace end-comments within commented area
    (goto-char end)
    (save-excursion
      (while (re-search-backward "\\*/" start t)
	(replace-match "*-/" t t)))
    (save-excursion
      (let ((s+1 (1+ start)))
	(while (re-search-backward "/\\*" s+1 t)
	  (replace-match "/-*" t t))))))

(defun vpp-uncomment-region ()
  "Uncomment a commented area; change deformed comments back to normal.
This command does nothing if the pointer is not in a commented
area.  See also `vpp-comment-region'."
  (interactive)
  (save-excursion
    (let ((start (point))
	  (end (point)))
      ;; Find the boundaries of the comment
      (save-excursion
	(setq start (progn (search-backward vpp-exclude-str-start nil t)
			   (point)))
	(setq end (progn (search-forward vpp-exclude-str-end nil t)
			 (point))))
      ;; Check if we're really inside a comment
      (if (or (equal start (point)) (<= end (point)))
	  (message "Not standing within commented area.")
	(progn
	  ;; Remove endcomment
	  (goto-char end)
	  (beginning-of-line)
	  (let ((pos (point)))
	    (end-of-line)
	    (delete-region pos (1+ (point))))
	  ;; Change comments back to normal
	  (save-excursion
	    (while (re-search-backward "\\*-/" start t)
	      (replace-match "*/" t t)))
	  (save-excursion
	    (while (re-search-backward "/-\\*" start t)
	      (replace-match "/*" t t)))
	  ;; Remove start comment
	  (goto-char start)
	  (beginning-of-line)
	  (let ((pos (point)))
	    (end-of-line)
	    (delete-region pos (1+ (point)))))))))

(defun vpp-beg-of-defun ()
  "Move backward to the beginning of the current function or procedure."
  (interactive)
  (vpp-re-search-backward vpp-defun-re nil 'move))

(defun vpp-beg-of-defun-quick ()
  "Move backward to the beginning of the current function or procedure.
Uses `vpp-scan' cache."
  (interactive)
  (vpp-re-search-backward-quick vpp-defun-re nil 'move))

(defun vpp-end-of-defun ()
  "Move forward to the end of the current function or procedure."
  (interactive)
  (vpp-re-search-forward vpp-end-defun-re nil 'move))

(defun vpp-get-beg-of-defun (&optional warn)
  (save-excursion
    (cond ((vpp-re-search-forward-quick vpp-defun-re nil t)
	   (point))
	  (t
	   (error "%s: Can't find module beginning" (vpp-point-text))
	   (point-max)))))
(defun vpp-get-end-of-defun (&optional warn)
  (save-excursion
    (cond ((vpp-re-search-forward-quick vpp-end-defun-re nil t)
	   (point))
	  (t
	   (error "%s: Can't find endmodule" (vpp-point-text))
	   (point-max)))))

(defun vpp-label-be (&optional arg)
  "Label matching begin ... end, fork ... join and case ... endcase statements.
With ARG, first kill any existing labels."
  (interactive)
  (let ((cnt 0)
	(oldpos (point))
	(b (progn
	     (vpp-beg-of-defun)
	     (point-marker)))
	(e (progn
	     (vpp-end-of-defun)
	     (point-marker))))
    (goto-char (marker-position b))
    (if (> (- e b) 200)
	(message  "Relabeling module..."))
    (while (and
	    (> (marker-position e) (point))
	    (vpp-re-search-forward
	     (concat
	      "\\<end\\(\\(function\\)\\|\\(task\\)\\|\\(module\\)\\|\\(defmod\\)\\|\\(primitive\\)\\|\\(interface\\)\\|\\(package\\)\\|\\(case\\)\\)?\\>"
	      "\\|\\(`endif\\)\\|\\(`else\\)")
	     nil 'move))
      (goto-char (match-beginning 0))
      (let ((indent-str (vpp-indent-line)))
	(vpp-set-auto-endcomments indent-str 't)
	(end-of-line)
	(delete-horizontal-space))
      (setq cnt (1+ cnt))
      (if (= 9 (% cnt 10))
	  (message "%d..." cnt)))
    (goto-char oldpos)
    (if (or
	 (> (- e b) 200)
	 (> cnt 20))
	(message  "%d lines auto commented" cnt))))

(defun vpp-beg-of-statement ()
  "Move backward to beginning of statement."
  (interactive)
  ;; Move back token by token until we see the end
  ;; of some earlier line.
  (let (h)
    (while
	;; If the current point does not begin a new
	;; statement, as in the character ahead of us is a ';', or SOF
	;; or the string after us unambiguously starts a statement,
	;; or the token before us unambiguously ends a statement,
	;; then move back a token and test again.
	(not (or
          ;; stop if beginning of buffer
	      (bolp)
          ;; stop if we find a ;
	      (= (preceding-char) ?\;)
          ;; stop if we see a named coverpoint
	      (looking-at "\\w+\\W*:\\W*\\(coverpoint\\|cross\\|constraint\\)")
          ;; keep going if we are in the middle of a word
	      (not (or (looking-at "\\<") (forward-word -1)))
          ;; stop if we see an assertion (perhaps labeled)
	      (and
	       (looking-at "\\(\\<\\(assert\\|assume\\|cover\\)\\>\\s-+\\<property\\>\\)\\|\\(\\<assert\\>\\)")
	       (progn
             (setq h (point))
             (save-excursion
               (vpp-backward-token)
               (if (looking-at vpp-label-re)
                   (setq h (point))))
             (goto-char h)))
          ;; stop if we see an extended complete reg, perhaps a complete one
	      (and
           (looking-at vpp-complete-reg)
           (let* ((p (point)))
             (while (and (looking-at vpp-extended-complete-re)
                         (progn (setq p (point))
                                (vpp-backward-token)
                                (/= p (point)))))
             (goto-char p)))
          ;; stop if we see a complete reg (previous found extended ones)
	      (looking-at vpp-basic-complete-re)
          ;; stop if previous token is an ender
	      (save-excursion
            (vpp-backward-token)
            (or
             (looking-at vpp-end-block-re)
             (looking-at vpp-preprocessor-re))))) ;; end of test
    (vpp-backward-syntactic-ws)
    (vpp-backward-token))
    ;; Now point is where the previous line ended.
    (vpp-forward-syntactic-ws)))

(defun vpp-beg-of-statement-1 ()
  "Move backward to beginning of statement."
  (interactive)
  (if (vpp-in-comment-p)
      (vpp-backward-syntactic-ws))
  (let ((pt (point)))
    (catch 'done
      (while (not (looking-at vpp-complete-reg))
        (setq pt (point))
        (vpp-backward-syntactic-ws)
        (if (or (bolp)
                (= (preceding-char) ?\;)
		(save-excursion
		  (vpp-backward-token)
		  (looking-at vpp-ends-re)))
            (progn
              (goto-char pt)
              (throw 'done t))
          (vpp-backward-token))))
    (vpp-forward-syntactic-ws)))
;
;    (while (and
;            (not (looking-at vpp-complete-reg))
;            (not (bolp))
;            (not (= (preceding-char) ?\;)))
;      (vpp-backward-token)
;      (vpp-backward-syntactic-ws)
;      (setq pt (point)))
;    (goto-char pt)
; ;(vpp-forward-syntactic-ws)

(defun vpp-end-of-statement ()
  "Move forward to end of current statement."
  (interactive)
  (let ((nest 0) pos)
    (cond
     ((vpp-in-directive-p)
      (forward-line 1)
      (backward-char 1))

     ((looking-at vpp-beg-block-re)
      (vpp-forward-sexp))

     ((equal (char-after) ?\})
      (forward-char))

      ;; Skip to end of statement
     ((condition-case nil
       (setq pos
             (catch 'found
               (while t
                 (forward-sexp 1)
                 (vpp-skip-forward-comment-or-string)
                 (if (eolp)
                     (forward-line 1))
                 (cond ((looking-at "[ \t]*;")
                        (skip-chars-forward "^;")
                        (forward-char 1)
                        (throw 'found (point)))
                       ((save-excursion
                          (forward-sexp -1)
                          (looking-at vpp-beg-block-re))
                        (goto-char (match-beginning 0))
                        (throw 'found nil))
                       ((looking-at "[ \t]*)")
                        (throw 'found (point)))
                       ((eobp)
                        (throw 'found (point)))
                       )))

             )
       (error nil))
      (if (not pos)
          ;; Skip a whole block
          (catch 'found
            (while t
              (vpp-re-search-forward vpp-end-statement-re nil 'move)
              (setq nest (if (match-end 1)
                             (1+ nest)
                           (1- nest)))
              (cond ((eobp)
                     (throw 'found (point)))
                    ((= 0 nest)
                     (throw 'found (vpp-end-of-statement))))))
        pos)))))

(defun vpp-in-case-region-p ()
  "Return true if in a case region.
More specifically, point @ in the line foo : @ begin"
  (interactive)
  (save-excursion
    (if (and
	 (progn (vpp-forward-syntactic-ws)
		(looking-at "\\<begin\\>"))
	 (progn (vpp-backward-syntactic-ws)
		(= (preceding-char) ?\:)))
	(catch 'found
	  (let ((nest 1))
	    (while t
	      (vpp-re-search-backward
	       (concat "\\(\\<module\\>\\)\\|\\(\\<randcase\\>\\|\\<case[xz]?\\>[^:]\\)\\|"
		       "\\(\\<endcase\\>\\)\\>")
	       nil 'move)
	      (cond
	       ((match-end 3)
		(setq nest (1+ nest)))
	       ((match-end 2)
		(if (= nest 1)
		(throw 'found 1))
		(setq nest (1- nest)))
	       (t
		(throw 'found (= nest 0)))))))
      nil)))

(defun vpp-backward-up-list (arg)
  "Call `backward-up-list' ARG, ignoring comments."
  (let ((parse-sexp-ignore-comments t))
    (backward-up-list arg)))

(defun vpp-forward-sexp-cmt (arg)
  "Call `forward-sexp' ARG, inside comments."
  (let ((parse-sexp-ignore-comments nil))
    (forward-sexp arg)))

(defun vpp-forward-sexp-ign-cmt (arg)
  "Call `forward-sexp' ARG, ignoring comments."
  (let ((parse-sexp-ignore-comments t))
    (forward-sexp arg)))

(defun vpp-in-generate-region-p ()
  "Return true if in a generate region.
More specifically, after a generate and before an endgenerate."
  (interactive)
  (let ((nest 1))
    (save-excursion
      (catch 'done
	(while (and
		(/= nest 0)
		(vpp-re-search-backward
		 "\\<\\(module\\)\\|\\(generate\\)\\|\\(endgenerate\\)\\>" nil 'move)
		(cond
		 ((match-end 1) ; module - we have crawled out
		  (throw 'done 1))
		 ((match-end 2) ; generate
		  (setq nest (1- nest)))
		 ((match-end 3) ; endgenerate
		  (setq nest (1+ nest))))))))
    (= nest 0) )) ; return nest

(defun vpp-in-fork-region-p ()
  "Return true if between a fork and join."
  (interactive)
  (let ((lim (save-excursion (vpp-beg-of-defun)  (point)))
	(nest 1))
    (save-excursion
      (while (and
	      (/= nest 0)
	      (vpp-re-search-backward "\\<\\(fork\\)\\|\\(join\\(_any\\|_none\\)?\\)\\>" lim 'move)
	      (cond
	       ((match-end 1) ; fork
		(setq nest (1- nest)))
	       ((match-end 2) ; join
		(setq nest (1+ nest)))))))
    (= nest 0) )) ; return nest

(defun vpp-backward-case-item (lim)
  "Skip backward to nearest enclosing case item.
Limit search to point LIM."
  (interactive)
  (let ((str 'nil)
	(lim1
	 (progn
	   (save-excursion
	     (vpp-re-search-backward vpp-endcomment-reason-re
					 lim 'move)
	     (point)))))
    ;; Try to find the real :
    (if (save-excursion (search-backward ":" lim1 t))
	(let ((colon 0)
	      b e )
	  (while
	      (and
	       (< colon 1)
	       (vpp-re-search-backward "\\(\\[\\)\\|\\(\\]\\)\\|\\(:\\)"
					   lim1 'move))
	    (cond
	     ((match-end 1) ;; [
	      (setq colon (1+ colon))
	      (if (>= colon 0)
		  (error "%s: unbalanced [" (vpp-point-text))))
	     ((match-end 2) ;; ]
	      (setq colon (1- colon)))

	     ((match-end 3) ;; :
	      (setq colon (1+ colon)))))
	  ;; Skip back to beginning of case item
	  (skip-chars-backward "\t ")
	  (vpp-skip-backward-comment-or-string)
	  (setq e (point))
	  (setq b
		(progn
		  (if
		      (vpp-re-search-backward
		       "\\<\\(case[zx]?\\)\\>\\|;\\|\\<end\\>" nil 'move)
		      (progn
			(cond
			 ((match-end 1)
			  (goto-char (match-end 1))
			  (vpp-forward-ws&directives)
			  (if (looking-at "(")
			      (progn
				(forward-sexp)
				(vpp-forward-ws&directives)))
			  (point))
			 (t
			  (goto-char (match-end 0))
			  (vpp-forward-ws&directives)
			  (point))))
		    (error "Malformed case item"))))
	  (setq str (buffer-substring b e))
	  (if
	      (setq e
		    (string-match
		     "[ \t]*\\(\\(\n\\)\\|\\(//\\)\\|\\(/\\*\\)\\)" str))
	      (setq str (concat (substring str 0 e) "...")))
	  str)
      'nil)))


;;
;; Other functions
;;

(defun vpp-kill-existing-comment ()
  "Kill auto comment on this line."
  (save-excursion
    (let* (
	   (e (progn
		(end-of-line)
		(point)))
	   (b (progn
		(beginning-of-line)
		(search-forward "//" e t))))
      (if b
	  (delete-region (- b 2) e)))))

(defconst vpp-directive-nest-re
  (concat "\\(`else\\>\\)\\|"
	  "\\(`endif\\>\\)\\|"
	  "\\(`if\\>\\)\\|"
	  "\\(`ifdef\\>\\)\\|"
	  "\\(`ifndef\\>\\)\\|"
	  "\\(`elsif\\>\\)"))
(defun vpp-set-auto-endcomments (indent-str kill-existing-comment)
  "Add ending comment with given INDENT-STR.
With KILL-EXISTING-COMMENT, remove what was there before.
Insert `// case: 7 ' or `// NAME ' on this line if appropriate.
Insert `// case expr ' if this line ends a case block.
Insert `// ifdef FOO ' if this line ends code conditional on FOO.
Insert `// NAME ' if this line ends a function, task, module,
primitive or interface named NAME."
  (save-excursion
    (cond
     (; Comment close preprocessor directives
      (and
       (looking-at "\\(`endif\\)\\|\\(`else\\)")
       (or  kill-existing-comment
	    (not (save-excursion
		   (end-of-line)
		   (search-backward "//" (point-at-bol) t)))))
      (let ((nest 1) b e
	    m
	    (else (if (match-end 2) "!" " ")))
	(end-of-line)
	(if kill-existing-comment
	    (vpp-kill-existing-comment))
	(delete-horizontal-space)
	(save-excursion
	  (backward-sexp 1)
	  (while (and (/= nest 0)
		      (vpp-re-search-backward vpp-directive-nest-re nil 'move))
	    (cond
	     ((match-end 1) ; `else
	      (if (= nest 1)
		  (setq else "!")))
	     ((match-end 2) ; `endif
	      (setq nest (1+ nest)))
	     ((match-end 3) ; `if
	      (setq nest (1- nest)))
	     ((match-end 4) ; `ifdef
	      (setq nest (1- nest)))
	     ((match-end 5) ; `ifndef
	      (setq nest (1- nest)))
	     ((match-end 6) ; `elsif
	      (if (= nest 1)
		  (progn
		    (setq else "!")
		    (setq nest 0))))))
	  (if (match-end 0)
	      (setq
	       m (buffer-substring
		  (match-beginning 0)
		  (match-end 0))
	       b (progn
		   (skip-chars-forward "^ \t")
		   (vpp-forward-syntactic-ws)
		   (point))
	       e (progn
		   (skip-chars-forward "a-zA-Z0-9_")
		   (point)))))
	(if b
	    (if (> (count-lines (point) b) vpp-minimum-comment-distance)
		(insert (concat " // " else m " " (buffer-substring b e))))
	  (progn
	    (insert " // unmatched `else, `elsif or `endif")
	    (ding 't)))))

     (; Comment close case/class/function/task/module and named block
      (and (looking-at "\\<end")
	   (or kill-existing-comment
	       (not (save-excursion
		      (end-of-line)
		      (search-backward "//" (point-at-bol) t)))))
      (let ((type (car indent-str)))
	(unless (eq type 'declaration)
	  (unless (looking-at (concat "\\(" vpp-end-block-ordered-re "\\)[ \t]*:")) ;; ignore named ends
	    (if (looking-at vpp-end-block-ordered-re)
	      (cond
	       (;- This is a case block; search back for the start of this case
		(match-end 1) ;; of vpp-end-block-ordered-re

		(let ((err 't)
		      (str "UNMATCHED!!"))
		  (save-excursion
		    (vpp-leap-to-head)
		    (cond
		     ((looking-at "\\<randcase\\>")
		      (setq str "randcase")
		      (setq err nil))
		     ((looking-at "\\(\\(unique\\s-+\\|priority\\s-+\\)?case[xz]?\\)")
		      (goto-char (match-end 0))
		      (setq str (concat (match-string 0) " " (vpp-get-expr)))
		      (setq err nil))
		     ))
		  (end-of-line)
		  (if kill-existing-comment
		      (vpp-kill-existing-comment))
		  (delete-horizontal-space)
		  (insert (concat " // " str ))
		  (if err (ding 't))))

	       (;- This is a begin..end block
		(match-end 2) ;; of vpp-end-block-ordered-re
		(let ((str " // UNMATCHED !!")
		      (err 't)
		      (here (point))
		      there
		      cntx)
		  (save-excursion
		    (vpp-leap-to-head)
		    (setq there (point))
		    (if (not (match-end 0))
			(progn
			  (goto-char here)
			  (end-of-line)
			  (if kill-existing-comment
			      (vpp-kill-existing-comment))
			  (delete-horizontal-space)
			  (insert str)
			  (ding 't))
		      (let ((lim
			     (save-excursion (vpp-beg-of-defun) (point)))
			    (here (point)))
			(cond
			 (;-- handle named block differently
			  (looking-at vpp-named-block-re)
			  (search-forward ":")
			  (setq there (point))
			  (setq str (vpp-get-expr))
			  (setq err nil)
			  (setq str (concat " // block: " str )))

			 ((vpp-in-case-region-p) ;-- handle case item differently
			  (goto-char here)
			  (setq str (vpp-backward-case-item lim))
			  (setq there (point))
			  (setq err nil)
			  (setq str (concat " // case: " str )))

			 (;- try to find "reason" for this begin
			  (cond
			   (;
			    (eq here (progn
				    ;;   (vpp-backward-token)
				       (vpp-beg-of-statement)
				       (point)))
			    (setq err nil)
			    (setq str ""))
			   ((looking-at vpp-endcomment-reason-re)
			    (setq there (match-end 0))
			    (setq cntx (concat (match-string 0) " "))
			    (cond
			     (;- begin
			      (match-end 1)
			      (setq err nil)
			      (save-excursion
				(if (and (vpp-continued-line)
					 (looking-at "\\<repeat\\>\\|\\<wait\\>\\|\\<always\\>"))
				    (progn
				      (goto-char (match-end 0))
				      (setq there (point))
				      (setq str
					    (concat " // " (match-string 0) " " (vpp-get-expr))))
				  (setq str ""))))

			     (;- else
			      (match-end 2)
			      (let ((nest 0)
				    ( reg "\\(\\<begin\\>\\)\\|\\(\\<end\\>\\)\\|\\(\\<if\\>\\)\\|\\(assert\\)"))
				(catch 'skip
				  (while (vpp-re-search-backward reg nil 'move)
				    (cond
				     ((match-end 1) ; begin
				      (setq nest (1- nest)))
				     ((match-end 2)                       ; end
				      (setq nest (1+ nest)))
				     ((match-end 3)
				      (if (= 0 nest)
					  (progn
					    (goto-char (match-end 0))
					    (setq there (point))
					    (setq err nil)
					    (setq str (vpp-get-expr))
					    (setq str (concat " // else: !if" str ))
					    (throw 'skip 1))))
				     ((match-end 4)
				      (if (= 0 nest)
					  (progn
					    (goto-char (match-end 0))
					    (setq there (point))
					    (setq err nil)
					    (setq str (vpp-get-expr))
					    (setq str (concat " // else: !assert " str ))
					    (throw 'skip 1)))))))))
			     (;- end else
			      (match-end 3)
			      (goto-char there)
			      (let ((nest 0)
				    (reg "\\(\\<begin\\>\\)\\|\\(\\<end\\>\\)\\|\\(\\<if\\>\\)\\|\\(assert\\)"))
				(catch 'skip
				  (while (vpp-re-search-backward reg nil 'move)
				    (cond
				     ((match-end 1) ; begin
				      (setq nest (1- nest)))
				     ((match-end 2)                       ; end
				      (setq nest (1+ nest)))
				     ((match-end 3)
				      (if (= 0 nest)
					  (progn
					    (goto-char (match-end 0))
					    (setq there (point))
					    (setq err nil)
					    (setq str (vpp-get-expr))
					    (setq str (concat " // else: !if" str ))
					    (throw 'skip 1))))
				     ((match-end 4)
				      (if (= 0 nest)
					  (progn
					    (goto-char (match-end 0))
					    (setq there (point))
					    (setq err nil)
					    (setq str (vpp-get-expr))
					    (setq str (concat " // else: !assert " str ))
					    (throw 'skip 1)))))))))

			     (; always_comb, always_ff, always_latch
			      (or (match-end 4) (match-end 5) (match-end 6))
			      (goto-char (match-end 0))
			      (setq there (point))
			      (setq err nil)
			      (setq str (concat " // " cntx )))

			     (;- task/function/initial et cetera
			      t
			      (match-end 0)
			      (goto-char (match-end 0))
			      (setq there (point))
			      (setq err nil)
			      (setq str (concat " // " cntx (vpp-get-expr))))

			     (;-- otherwise...
			      (setq str " // auto-endcomment confused "))))

			   ((and
			     (vpp-in-case-region-p) ;-- handle case item differently
			     (progn
			       (setq there (point))
			       (goto-char here)
			       (setq str (vpp-backward-case-item lim))))
			    (setq err nil)
			    (setq str (concat " // case: " str )))

			   ((vpp-in-fork-region-p)
			    (setq err nil)
			    (setq str " // fork branch" ))

			   ((looking-at "\\<end\\>")
			    ;; HERE
			    (forward-word 1)
			    (vpp-forward-syntactic-ws)
			    (setq err nil)
			    (setq str (vpp-get-expr))
			    (setq str (concat " // " cntx str )))

			   ))))
		      (goto-char here)
		      (end-of-line)
		      (if kill-existing-comment
			  (vpp-kill-existing-comment))
		      (delete-horizontal-space)
		      (if (or err
			      (> (count-lines here there) vpp-minimum-comment-distance))
			  (insert str))
		      (if err (ding 't))
		      ))))
	       (;- this is endclass, which can be nested
		(match-end 11) ;; of vpp-end-block-ordered-re
		;;(goto-char there)
		(let ((nest 0)
		      (reg "\\<\\(class\\)\\|\\(endclass\\)\\|\\(package\\|primitive\\|defmod\\|\\(macro\\)?module\\)\\>")
		      string)
		  (save-excursion
		    (catch 'skip
		      (while (vpp-re-search-backward reg nil 'move)
			(cond
			 ((match-end 3)	; endclass
			  (ding 't)
			  (setq string "unmatched endclass")
			  (throw 'skip 1))

			 ((match-end 2)	; endclass
			  (setq nest (1+ nest)))

			 ((match-end 1) ; class
			  (setq nest (1- nest))
			  (if (< nest 0)
			      (progn
				(goto-char (match-end 0))
				(let (b e)
				  (setq b (progn
					    (skip-chars-forward "^ \t")
					    (vpp-forward-ws&directives)
					    (point))
					e (progn
					    (skip-chars-forward "a-zA-Z0-9_")
					    (point)))
				  (setq string (buffer-substring b e)))
				(throw 'skip 1))))
			 ))))
		  (end-of-line)
		  (insert (concat " // " string ))))

	       (;- this is end{function,generate,task,module,primitive,table,generate}
		;- which can not be nested.
		t
		(let (string reg (name-re nil))
		  (end-of-line)
		  (if kill-existing-comment
		      (save-match-data
		       (vpp-kill-existing-comment)))
		  (delete-horizontal-space)
		  (backward-sexp)
		  (cond
		   ((match-end 5) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<function\\>\\)\\|\\(\\<\\(endfunction\\|task\\|\\(macro\\)?module\\|defmod\\|primitive\\)\\>\\)")
		    (setq name-re "\\w+\\s-*("))
		   ((match-end 6) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<task\\>\\)\\|\\(\\<\\(endtask\\|function\\|\\(macro\\)?module\\|defmod\\|primitive\\)\\>\\)")
		    (setq name-re "\\w+\\s-*("))
		   ((match-end 7) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<\\(macro\\)?module\\>\\)\\|\\<endmodule\\>|\\<defmod\\>"))
		   ((match-end 8) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<primitive\\>\\)\\|\\(\\<\\(endprimitive\\|package\\|interface\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 9) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<interface\\>\\)\\|\\(\\<\\(endinterface\\|package\\|primitive\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 10) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<package\\>\\)\\|\\(\\<\\(endpackage\\|primitive\\|interface\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 11) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<class\\>\\)\\|\\(\\<\\(endclass\\|primitive\\|interface\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 12) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<covergroup\\>\\)\\|\\(\\<\\(endcovergroup\\|primitive\\|interface\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 13) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<program\\>\\)\\|\\(\\<\\(endprogram\\|primitive\\|interface\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 14) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<\\(rand\\)?sequence\\>\\)\\|\\(\\<\\(endsequence\\|primitive\\|interface\\|\\(macro\\)?module\\|defmod\\)\\>\\)"))
		   ((match-end 15) ;; of vpp-end-block-ordered-re
		    (setq reg "\\(\\<clocking\\>\\)\\|\\<endclocking\\>"))

		   (t (error "Problem in vpp-set-auto-endcomments")))
		  (let (b e)
		    (save-excursion
		      (vpp-re-search-backward reg nil 'move)
		      (cond
		       ((match-end 1)
			(setq b (progn
				  (skip-chars-forward "^ \t")
				  (vpp-forward-ws&directives)
				  (if (looking-at "static\\|automatic")
				      (progn
					(goto-char (match-end 0))
					(vpp-forward-ws&directives)))
				  (if (and name-re (vpp-re-search-forward name-re nil 'move))
				      (progn
					(goto-char (match-beginning 0))
					(vpp-forward-ws&directives)))
				  (point))
			      e (progn
				  (skip-chars-forward "a-zA-Z0-9_")
				  (point)))
			(setq string (buffer-substring b e)))
		       (t
			(ding 't)
			(setq string "unmatched end(function|task|module|defmod|primitive|interface|package|class|clocking)")))))
		  (end-of-line)
		  (insert (concat " // " string )))
		))))))))))

(defun vpp-get-expr()
  "Grab expression at point, e.g, case ( a | b & (c ^d))."
  (let* ((b (progn
	      (vpp-forward-syntactic-ws)
	      (skip-chars-forward " \t")
	      (point)))
	 (e (let ((par 1))
	      (cond
	       ((looking-at "@")
		(forward-char 1)
		(vpp-forward-syntactic-ws)
		(if (looking-at "(")
		    (progn
		      (forward-char 1)
		      (while (and (/= par 0)
				  (vpp-re-search-forward "\\((\\)\\|\\()\\)" nil 'move))
			(cond
			 ((match-end 1)
			  (setq par (1+ par)))
			 ((match-end 2)
			  (setq par (1- par)))))))
		(point))
	       ((looking-at "(")
		(forward-char 1)
		(while (and (/= par 0)
			    (vpp-re-search-forward "\\((\\)\\|\\()\\)" nil 'move))
		  (cond
		   ((match-end 1)
		    (setq par (1+ par)))
		   ((match-end 2)
		    (setq par (1- par)))))
		(point))
	       ((looking-at "\\[")
		(forward-char 1)
		(while (and (/= par 0)
			    (vpp-re-search-forward "\\(\\[\\)\\|\\(\\]\\)" nil 'move))
		  (cond
		   ((match-end 1)
		    (setq par (1+ par)))
		   ((match-end 2)
		    (setq par (1- par)))))
		(vpp-forward-syntactic-ws)
		(skip-chars-forward "^ \t\n\f")
		(point))
	       ((looking-at "/[/\\*]")
		b)
	       ('t
		(skip-chars-forward "^: \t\n\f")
		(point)))))
	 (str (buffer-substring b e)))
    (if (setq e (string-match "[ \t]*\\(\\(\n\\)\\|\\(//\\)\\|\\(/\\*\\)\\)" str))
	(setq str (concat (substring str 0 e) "...")))
    str))

(defun vpp-expand-vector ()
  "Take a signal vector on the current line and expand it to multiple lines.
Useful for creating tri's and other expanded fields."
  (interactive)
  (vpp-expand-vector-internal "[" "]"))

(defun vpp-expand-vector-internal (bra ket)
  "Given BRA, the start brace and KET, the end brace, expand one line into many lines."
  (save-excursion
    (forward-line 0)
    (let ((signal-string (buffer-substring (point)
					   (progn
					     (end-of-line) (point)))))
      (if (string-match
	   (concat "\\(.*\\)"
		   (regexp-quote bra)
		   "\\([0-9]*\\)\\(:[0-9]*\\|\\)\\(::[0-9---]*\\|\\)"
		   (regexp-quote ket)
		   "\\(.*\\)$") signal-string)
	  (let* ((sig-head (match-string 1 signal-string))
		 (vec-start (string-to-number (match-string 2 signal-string)))
		 (vec-end (if (= (match-beginning 3) (match-end 3))
			      vec-start
			    (string-to-number
			     (substring signal-string (1+ (match-beginning 3))
					(match-end 3)))))
		 (vec-range
		  (if (= (match-beginning 4) (match-end 4))
		      1
		    (string-to-number
		     (substring signal-string (+ 2 (match-beginning 4))
				(match-end 4)))))
		 (sig-tail (match-string 5 signal-string))
		 vec)
	    ;; Decode vectors
	    (setq vec nil)
	    (if (< vec-range 0)
		(let ((tmp vec-start))
		  (setq vec-start vec-end
			vec-end tmp
			vec-range (- vec-range))))
	    (if (< vec-end vec-start)
		(while (<= vec-end vec-start)
		  (setq vec (append vec (list vec-start)))
		  (setq vec-start (- vec-start vec-range)))
	      (while (<= vec-start vec-end)
		(setq vec (append vec (list vec-start)))
		(setq vec-start (+ vec-start vec-range))))
	    ;;
	    ;; Delete current line
	    (delete-region (point) (progn (forward-line 0) (point)))
	    ;;
	    ;; Expand vector
	    (while vec
	      (insert (concat sig-head bra
			      (int-to-string (car vec)) ket sig-tail "\n"))
	      (setq vec (cdr vec)))
	    (delete-char -1)
	    ;;
	    )))))

(defun vpp-strip-comments ()
  "Strip all comments from the Vpp code."
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "//" nil t)
    (if (vpp-within-string)
	(re-search-forward "\"" nil t)
      (if (vpp-in-star-comment-p)
	  (re-search-forward "\*/" nil t)
	(let ((bpt (- (point) 2)))
	  (end-of-line)
	  (delete-region bpt (point))))))
    ;;
  (goto-char (point-min))
  (while (re-search-forward "/\\*" nil t)
    (if (vpp-within-string)
	(re-search-forward "\"" nil t)
      (let ((bpt (- (point) 2)))
	(re-search-forward "\\*/")
	(delete-region bpt (point))))))

(defun vpp-one-line ()
  "Convert structural Vpp instances to occupy one line."
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "\\([^;]\\)[ \t]*\n[ \t]*" nil t)
	(replace-match "\\1 " nil nil)))

(defun vpp-linter-name ()
  "Return name of linter, either surelint or verilint."
  (let ((compile-word1 (vpp-string-replace-matches "\\s .*$" "" nil nil
						       compile-command))
	(lint-word1    (vpp-string-replace-matches "\\s .*$" "" nil nil
						       vpp-linter)))
    (cond ((equal compile-word1 "surelint") `surelint)
	  ((equal compile-word1 "verilint") `verilint)
	  ((equal lint-word1 "surelint")    `surelint)
	  ((equal lint-word1 "verilint")    `verilint)
	  (t `surelint))))  ;; back compatibility

(defun vpp-lint-off ()
  "Convert a Vpp linter warning line into a disable statement.
For example:
	pci_bfm_null.v, line  46: Unused input: pci_rst_
becomes a comment for the appropriate tool.

The first word of the `compile-command' or `vpp-linter'
variables is used to determine which product is being used.

See \\[vpp-surelint-off] and \\[vpp-verilint-off]."
  (interactive)
  (let ((linter (vpp-linter-name)))
    (cond ((equal linter `surelint)
	   (vpp-surelint-off))
	  ((equal linter `verilint)
	   (vpp-verilint-off))
	  (t (error "Linter name not set")))))

(defvar compilation-last-buffer)
(defvar next-error-last-buffer)

(defun vpp-surelint-off ()
  "Convert a SureLint warning line into a disable statement.
Run from Vpp source window; assumes there is a *compile* buffer
with point set appropriately.

For example:
	WARNING [STD-UDDONX]: xx.v, line 8: output out is never assigned.
becomes:
	// surefire lint_line_off UDDONX"
  (interactive)
  (let ((buff (if (boundp 'next-error-last-buffer)
                  next-error-last-buffer
                compilation-last-buffer)))
    (when (buffer-live-p buff)
      (save-excursion
        (switch-to-buffer buff)
        (beginning-of-line)
        (when
            (looking-at "\\(INFO\\|WARNING\\|ERROR\\) \\[[^-]+-\\([^]]+\\)\\]: \\([^,]+\\), line \\([0-9]+\\): \\(.*\\)$")
          (let* ((code (match-string 2))
                 (file (match-string 3))
                 (line (match-string 4))
                 (buffer (get-file-buffer file))
                 dir filename)
            (unless buffer
              (progn
                (setq buffer
                      (and (file-exists-p file)
                           (find-file-noselect file)))
                (or buffer
                    (let* ((pop-up-windows t))
                      (let ((name (expand-file-name
                                   (read-file-name
                                    (format "Find this error in: (default %s) "
                                            file)
                                    dir file t))))
                        (if (file-directory-p name)
                            (setq name (expand-file-name filename name)))
                        (setq buffer
                              (and (file-exists-p name)
                                   (find-file-noselect name))))))))
            (switch-to-buffer buffer)
            (goto-char (point-min))
            (forward-line (- (string-to-number line)))
            (end-of-line)
            (catch 'already
              (cond
               ((vpp-in-slash-comment-p)
                (re-search-backward "//")
                (cond
                 ((looking-at "// surefire lint_off_line ")
                  (goto-char (match-end 0))
                  (let ((lim (point-at-eol)))
                    (if (re-search-forward code lim 'move)
                        (throw 'already t)
                      (insert (concat " " code)))))
                 (t
                  )))
               ((vpp-in-star-comment-p)
                (re-search-backward "/\*")
                (insert (format " // surefire lint_off_line %6s" code )))
               (t
                (insert (format " // surefire lint_off_line %6s" code ))
                )))))))))

(defun vpp-verilint-off ()
  "Convert a Verilint warning line into a disable statement.

For example:
	(W240)  pci_bfm_null.v, line  46: Unused input: pci_rst_
becomes:
	//Verilint 240 off // WARNING: Unused input"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (looking-at "\\(.*\\)([WE]\\([0-9A-Z]+\\)).*,\\s +line\\s +[0-9]+:\\s +\\([^:\n]+\\):?.*$")
      (replace-match (format
		      ;; %3s makes numbers 1-999 line up nicely
		      "\\1//Verilint %3s off // WARNING: \\3"
		      (match-string 2)))
      (beginning-of-line)
      (vpp-indent-line))))

(defun vpp-auto-save-compile ()
  "Update automatics with \\[vpp-auto], save the buffer, and compile."
  (interactive)
  (vpp-auto)	; Always do it for safety
  (save-buffer)
  (compile compile-command))

(defun vpp-preprocess (&optional command filename)
  "Preprocess the buffer, similar to `compile', but put output in Vpp-Mode.
Takes optional COMMAND or defaults to `vpp-preprocessor', and
FILENAME to find directory to run in, or defaults to `buffer-file-name`."
  (interactive
   (list
    (let ((default (vpp-expand-command vpp-preprocessor)))
      (set (make-local-variable `vpp-preprocessor)
	      (read-from-minibuffer "Run Preprocessor (like this): "
				     default nil nil
				      'vpp-preprocess-history default)))))
  (unless command (setq command (vpp-expand-command vpp-preprocessor)))
  (let* ((fontlocked (and (boundp 'font-lock-mode) font-lock-mode))
	  (dir (file-name-directory (or filename buffer-file-name)))
	   (cmd (concat "cd " dir "; " command)))
    (with-output-to-temp-buffer "*Vpp-Preprocessed*"
      (with-current-buffer (get-buffer "*Vpp-Preprocessed*")
	(insert (concat "// " cmd "\n"))
	(call-process shell-file-name nil t nil shell-command-switch cmd)
	(vpp-mode)
	;; Without this force, it takes a few idle seconds
	;; to get the color, which is very jarring
	(when fontlocked (font-lock-fontify-buffer))))))


;;
;; Batch
;;

(defun vpp-warn (string &rest args)
  "Print a warning with `format' using STRING and optional ARGS."
  (apply 'message (concat "%%Warning: " string) args))

(defun vpp-warn-error (string &rest args)
  "Call `error' using STRING and optional ARGS.
If `vpp-warn-fatal' is non-nil, call `vpp-warn' instead."
  (if vpp-warn-fatal
      (apply 'error string args)
    (apply 'vpp-warn string args)))

(defmacro vpp-batch-error-wrapper (&rest body)
  "Execute BODY and add error prefix to any errors found.
This lets programs calling batch mode to easily extract error messages."
  `(let ((vpp-warn-fatal nil))
     (condition-case err
	 (progn ,@body)
       (error
	(error "%%Error: %s%s" (error-message-string err)
	       (if (featurep 'xemacs) "\n" ""))))))  ;; XEmacs forgets to add a newline

(defun vpp-batch-execute-func (funref &optional no-save)
  "Internal processing of a batch command.
Runs FUNREF on all command arguments.
Save the result unless optional NO-SAVE is t."
  (vpp-batch-error-wrapper
   ;; Setting global variables like that is *VERY NASTY* !!!  --Stef
   ;; However, this function is called only when Emacs is being used as
   ;; a standalone language instead of as an editor, so we'll live.
   ;;
   ;; General globals needed
   (setq make-backup-files nil)
   (setq-default make-backup-files nil)
   (setq enable-local-variables t)
   (setq enable-local-eval t)
   ;; Make sure any sub-files we read get proper mode
   (setq-default major-mode 'vpp-mode)
   ;; Ditto files already read in
   (mapc (lambda (buf)
	   (when (buffer-file-name buf)
	     (with-current-buffer buf
	       (vpp-mode))))
	 (buffer-list))
   ;; Process the files
   (mapcar (lambda (buf)
	     (when (buffer-file-name buf)
	       (save-excursion
		 (if (not (file-exists-p (buffer-file-name buf)))
		     (error
		      (concat "File not found: " (buffer-file-name buf))))
		 (message (concat "Processing " (buffer-file-name buf)))
		 (set-buffer buf)
		 (funcall funref)
		 (unless no-save (save-buffer)))))
	   (buffer-list))))

(defun vpp-batch-auto ()
  "For use with --batch, perform automatic expansions as a stand-alone tool.
This sets up the appropriate Vpp mode environment, updates automatics
with \\[vpp-auto] on all command-line files, and saves the buffers.
For proper results, multiple filenames need to be passed on the command
line in bottom-up order."
  (unless noninteractive
    (error "Use vpp-batch-auto only with --batch"))  ;; Otherwise we'd mess up buffer modes
  (vpp-batch-execute-func `vpp-auto))

(defun vpp-batch-delete-auto ()
  "For use with --batch, perform automatic deletion as a stand-alone tool.
This sets up the appropriate Vpp mode environment, deletes automatics
with \\[vpp-delete-auto] on all command-line files, and saves the buffers."
  (unless noninteractive
    (error "Use vpp-batch-delete-auto only with --batch"))  ;; Otherwise we'd mess up buffer modes
  (vpp-batch-execute-func `vpp-delete-auto))

(defun vpp-batch-delete-trailing-whitespace ()
  "For use with --batch, perform whitespace deletion as a stand-alone tool.
This sets up the appropriate Vpp mode environment, removes
whitespace with \\[vpp-delete-trailing-whitespace] on all
command-line files, and saves the buffers."
  (unless noninteractive
    (error "Use vpp-batch-delete-trailing-whitespace only with --batch"))  ;; Otherwise we'd mess up buffer modes
  (vpp-batch-execute-func `vpp-delete-trailing-whitespace))

(defun vpp-batch-diff-auto ()
  "For use with --batch, perform automatic differences as a stand-alone tool.
This sets up the appropriate Vpp mode environment, expand automatics
with \\[vpp-diff-auto] on all command-line files, and reports an error
if any differences are observed.  This is appropriate for adding to regressions
to insure automatics are always properly maintained."
  (unless noninteractive
    (error "Use vpp-batch-diff-auto only with --batch"))  ;; Otherwise we'd mess up buffer modes
  (vpp-batch-execute-func `vpp-diff-auto t))

(defun vpp-batch-inject-auto ()
  "For use with --batch, perform automatic injection as a stand-alone tool.
This sets up the appropriate Vpp mode environment, injects new automatics
with \\[vpp-inject-auto] on all command-line files, and saves the buffers.
For proper results, multiple filenames need to be passed on the command
line in bottom-up order."
  (unless noninteractive
    (error "Use vpp-batch-inject-auto only with --batch"))  ;; Otherwise we'd mess up buffer modes
  (vpp-batch-execute-func `vpp-inject-auto))

(defun vpp-batch-indent ()
  "For use with --batch, reindent an entire file as a stand-alone tool.
This sets up the appropriate Vpp mode environment, calls
\\[vpp-indent-buffer] on all command-line files, and saves the buffers."
  (unless noninteractive
    (error "Use vpp-batch-indent only with --batch"))  ;; Otherwise we'd mess up buffer modes
  (vpp-batch-execute-func `vpp-indent-buffer))


;;
;; Indentation
;;
(defconst vpp-indent-alist
  '((block       . (+ ind vpp-indent-level))
    (case        . (+ ind vpp-case-indent))
    (cparenexp   . (+ ind vpp-indent-level))
    (cexp        . (+ ind vpp-cexp-indent))
    (defun       . vpp-indent-level-module)
    (declaration . vpp-indent-level-declaration)
    (directive   . (vpp-calculate-indent-directive))
    (tf          . vpp-indent-level)
    (behavioral  . (+ vpp-indent-level-behavioral vpp-indent-level-module))
    (statement   . ind)
    (cpp         . 0)
    (comment     . (vpp-comment-indent))
    (unknown     . 3)
    (string      . 0)))

(defun vpp-continued-line-1 (lim)
  "Return true if this is a continued line.
Set point to where line starts.  Limit search to point LIM."
  (let ((continued 't))
    (if (eq 0 (forward-line -1))
	(progn
	  (end-of-line)
	  (vpp-backward-ws&directives lim)
	  (if (bobp)
	      (setq continued nil)
	    (setq continued (vpp-backward-token))))
      (setq continued nil))
    continued))

(defun vpp-calculate-indent ()
  "Calculate the indent of the current Vpp line.
Examine previous lines.  Once a line is found that is definitive as to the
type of the current line, return that lines' indent level and its type.
Return a list of two elements: (INDENT-TYPE INDENT-LEVEL)."
  (save-excursion
    (let* ((starting_position (point))
	   (par 0)
	   (begin (looking-at "[ \t]*begin\\>"))
	   (lim (save-excursion (vpp-re-search-backward "\\(\\<begin\\>\\)\\|\\(\\<module\\>\\)" nil t)))
	   (type (catch 'nesting
		   ;; Keep working backwards until we can figure out
		   ;; what type of statement this is.
		   ;; Basically we need to figure out
		   ;; 1) if this is a continuation of the previous line;
		   ;; 2) are we in a block scope (begin..end)

		   ;; if we are in a comment, done.
		   (if (vpp-in-star-comment-p)
		       (throw 'nesting 'comment))

		   ;; if we have a directive, done.
		   (if (save-excursion (beginning-of-line)
				       (and (looking-at vpp-directive-re-1)
					    (not (or (looking-at "[ \t]*`[ou]vm_")
                                 (looking-at "[ \t]*`vmm_")))))
		       (throw 'nesting 'directive))
           ;; indent structs as if there were module level
           (if (vpp-in-struct-p)
               (throw 'nesting 'block))

	   ;; if we are in a parenthesized list, and the user likes to indent these, return.
	   ;; unless we are in the newfangled coverpoint or constraint blocks
	   (if (and
                vpp-indent-lists
                (vpp-in-paren)
                (not (vpp-in-coverage-p))
                )
	       (progn (setq par 1)
                      (throw 'nesting 'block)))

	   ;; See if we are continuing a previous line
	   (while t
	     ;; trap out if we crawl off the top of the buffer
	     (if (bobp) (throw 'nesting 'cpp))

	     (if (vpp-continued-line-1 lim)
		 (let ((sp (point)))
		   (if (and
			(not (looking-at vpp-complete-reg))
			(vpp-continued-line-1 lim))
		       (progn (goto-char sp)
			      (throw 'nesting 'cexp))

		     (goto-char sp))

		   (if (and begin
			    (not vpp-indent-begin-after-if)
			    (looking-at vpp-no-indent-begin-re))
		       (progn
			 (beginning-of-line)
			 (skip-chars-forward " \t")
			 (throw 'nesting 'statement))
		     (progn
		       (throw 'nesting 'cexp))))
	       ;; not a continued line
	       (goto-char starting_position))

	     (if (looking-at "\\<else\\>")
		 ;; search back for governing if, striding across begin..end pairs
		 ;; appropriately
		 (let ((elsec 1))
		   (while (vpp-re-search-backward vpp-ends-re nil 'move)
		     (cond
		      ((match-end 1) ; else, we're in deep
		       (setq elsec (1+ elsec)))
		      ((match-end 2) ; if
		       (setq elsec (1- elsec))
		       (if (= 0 elsec)
			   (if vpp-align-ifelse
			       (throw 'nesting 'statement)
			     (progn ;; back up to first word on this line
			       (beginning-of-line)
			       (vpp-forward-syntactic-ws)
			       (throw 'nesting 'statement)))))
		      ((match-end 3) ; assert block
		       (setq elsec (1- elsec))
		       (vpp-beg-of-statement) ;; doesn't get to beginning
		       (if (looking-at vpp-property-re)
			   (throw 'nesting 'statement) ; We don't need an endproperty for these
			 (throw 'nesting 'block)	;We still need an endproperty
			 ))
		      (t ; endblock
					; try to leap back to matching outward block by striding across
					; indent level changing tokens then immediately
					; previous line governs indentation.
		       (let (( reg) (nest 1))
			 ;;	 vpp-ends =>  else|if|end|join(_any|_none|)|endcase|endclass|endtable|endspecify|endfunction|endtask|endgenerate|endgroup
			 (cond
			  ((match-end 4) ; end
			   ;; Search back for matching begin
			   (setq reg "\\(\\<begin\\>\\)\\|\\(\\<end\\>\\)" ))
			  ((match-end 5) ; endcase
			   ;; Search back for matching case
			   (setq reg "\\(\\<randcase\\>\\|\\<case[xz]?\\>[^:]\\)\\|\\(\\<endcase\\>\\)" ))
			  ((match-end 6) ; endfunction
			   ;; Search back for matching function
			   (setq reg "\\(\\<function\\>\\)\\|\\(\\<endfunction\\>\\)" ))
			  ((match-end 7) ; endtask
			   ;; Search back for matching task
			   (setq reg "\\(\\<task\\>\\)\\|\\(\\<endtask\\>\\)" ))
			  ((match-end 8) ; endspecify
			   ;; Search back for matching specify
			   (setq reg "\\(\\<specify\\>\\)\\|\\(\\<endspecify\\>\\)" ))
			  ((match-end 9) ; endtable
			   ;; Search back for matching table
			   (setq reg "\\(\\<table\\>\\)\\|\\(\\<endtable\\>\\)" ))
			  ((match-end 10) ; endgenerate
			   ;; Search back for matching generate
			   (setq reg "\\(\\<generate\\>\\)\\|\\(\\<endgenerate\\>\\)" ))
			  ((match-end 11) ; joins
			   ;; Search back for matching fork
			   (setq reg "\\(\\<fork\\>\\)\\|\\(\\<join\\(_any\\|none\\)?\\>\\)" ))
			  ((match-end 12) ; class
			   ;; Search back for matching class
			   (setq reg "\\(\\<class\\>\\)\\|\\(\\<endclass\\>\\)" ))
			  ((match-end 13) ; covergroup
			   ;; Search back for matching covergroup
			   (setq reg "\\(\\<covergroup\\>\\)\\|\\(\\<endgroup\\>\\)" )))
			 (catch 'skip
			   (while (vpp-re-search-backward reg nil 'move)
			     (cond
			      ((match-end 1) ; begin
			       (setq nest (1- nest))
			       (if (= 0 nest)
				   (throw 'skip 1)))
			      ((match-end 2) ; end
			       (setq nest (1+ nest)))))
			   )))))))
	     (throw 'nesting (vpp-calc-1)))
	   );; catch nesting
		 );; type
	   )
      ;; Return type of block and indent level.
      (if (not type)
	  (setq type 'cpp))
      (if (> par 0)			; Unclosed Parenthesis
	  (list 'cparenexp par)
	(cond
	  ((eq type 'case)
	   (list type (vpp-case-indent-level)))
	  ((eq type 'statement)
	   (list type (current-column)))
	  ((eq type 'defun)
	   (list type 0))
	  (t
	   (list type (vpp-current-indent-level))))))))

(defun vpp-wai ()
  "Show matching nesting block for debugging."
  (interactive)
  (save-excursion
    (let* ((type (vpp-calc-1))
	   depth)
      ;; Return type of block and indent level.
      (if (not type)
	  (setq type 'cpp))
      (if (and
	   vpp-indent-lists
	   (not(or (vpp-in-coverage-p)
               (vpp-in-struct-p)))
	   (vpp-in-paren))
	  (setq depth 1)
	(cond
	  ((eq type 'case)
	   (setq depth (vpp-case-indent-level)))
	  ((eq type 'statement)
	   (setq depth (current-column)))
	  ((eq type 'defun)
	   (setq depth 0))
	  (t
	   (setq depth (vpp-current-indent-level)))))
      (message "You are at nesting %s depth %d" type depth))))
(defun vpp-calc-1 ()
  (catch 'nesting
    (let ((re (concat "\\({\\|}\\|" vpp-indent-re "\\)")))
      (while (vpp-re-search-backward re nil 'move)
	(catch 'continue
	  (cond
	   ((equal (char-after) ?\{)
	    (if (vpp-at-constraint-p)
		(throw 'nesting 'block)))

	   ((equal (char-after) ?\})
	    (let ((there (vpp-at-close-constraint-p)))
	      (if there ;; we are at the } that closes a constraint.  Find the { that opens it
		  (progn
		    (forward-char 1)
		    (backward-list 1)
		    (vpp-beg-of-statement)))))

	   ((looking-at vpp-beg-block-re-ordered)
	    (cond
	     ((match-end 2)  ; *sigh* could be "unique case" or "priority casex"
	      (let ((here (point)))
		(vpp-beg-of-statement)
		(if (looking-at vpp-extended-case-re)
		    (throw 'nesting 'case)
		  (goto-char here)))
	      (throw 'nesting 'case))

	     ((match-end 4)  ; *sigh* could be "disable fork"
	      (let ((here (point)))
		(vpp-beg-of-statement)
		(if (looking-at vpp-disable-fork-re)
		    t ; this is a normal statement
		  (progn ; or is fork, starts a new block
		    (goto-char here)
		    (throw 'nesting 'block)))))

	     ((match-end 27)  ; *sigh* might be a clocking declaration
	      (let ((here (point)))
		(if (vpp-in-paren)
		    t ; this is a normal statement
		  (progn ; or is fork, starts a new block
		    (goto-char here)
		    (throw 'nesting 'block)))))

	     ;; need to consider typedef struct here...
	     ((looking-at "\\<class\\|struct\\|function\\|task\\>")
					; *sigh* These words have an optional prefix:
					; extern {virtual|protected}? function a();
	                                ; typedef class foo;
					; and we don't want to confuse this with
					; function a();
	                                ; property
					; ...
					; endfunction
	      (vpp-beg-of-statement)
	      (if (looking-at vpp-beg-block-re-ordered)
              (throw 'nesting 'block)
            (throw 'nesting 'defun)))

         ;;
	     ((looking-at "\\<property\\>")
					; *sigh*
					;    {assert|assume|cover} property (); are complete
	                                ;   and could also be labeled: - foo: assert property
					; but
                                        ;    property ID () ... needs end_property
	      (vpp-beg-of-statement)
	      (if (looking-at vpp-property-re)
		  (throw 'continue 'statement) ; We don't need an endproperty for these
		(throw 'nesting 'block)	;We still need an endproperty
		))

	     (t              (throw 'nesting 'block))))

	   ((looking-at vpp-end-block-re)
	    (vpp-leap-to-head)
	    (if (vpp-in-case-region-p)
		(progn
		  (vpp-leap-to-case-head)
		  (if (looking-at vpp-extended-case-re)
		      (throw 'nesting 'case)))))

	   ((looking-at vpp-defun-level-re)
	    (if (looking-at vpp-defun-level-generate-only-re)
		(if (vpp-in-generate-region-p)
		    (throw 'continue 'foo)  ; always block in a generate - keep looking
		  (throw 'nesting 'defun))
	      (throw 'nesting 'defun)))

	   ((looking-at vpp-cpp-level-re)
	    (throw 'nesting 'cpp))

	   ((bobp)
	    (throw 'nesting 'cpp)))))

      (throw 'nesting 'cpp))))

(defun vpp-calculate-indent-directive ()
  "Return indentation level for directive.
For speed, the searcher looks at the last directive, not the indent
of the appropriate enclosing block."
  (let ((base -1)	;; Indent of the line that determines our indentation
	(ind 0))        ;; Relative offset caused by other directives (like `endif on same line as `else)
    ;; Start at current location, scan back for another directive

    (save-excursion
      (beginning-of-line)
      (while (and (< base 0)
		  (vpp-re-search-backward vpp-directive-re nil t))
	(cond ((save-excursion (skip-chars-backward " \t") (bolp))
	       (setq base (current-indentation))))
	(cond ((and (looking-at vpp-directive-end) (< base 0))  ;; Only matters when not at BOL
	       (setq ind (- ind vpp-indent-level-directive)))
	      ((and (looking-at vpp-directive-middle) (>= base 0))  ;; Only matters when at BOL
	       (setq ind (+ ind vpp-indent-level-directive)))
	      ((looking-at vpp-directive-begin)
	       (setq ind (+ ind vpp-indent-level-directive)))))
      ;; Adjust indent to starting indent of critical line
      (setq ind (max 0 (+ ind base))))

    (save-excursion
      (beginning-of-line)
      (skip-chars-forward " \t")
      (cond ((or (looking-at vpp-directive-middle)
		 (looking-at vpp-directive-end))
	     (setq ind (max 0 (- ind vpp-indent-level-directive))))))
   ind))

(defun vpp-leap-to-case-head ()
  (let ((nest 1))
    (while (/= 0 nest)
      (vpp-re-search-backward
       (concat
	"\\(\\<randcase\\>\\|\\(\\<unique\\s-+\\|priority\\s-+\\)?\\<case[xz]?\\>\\)"
	"\\|\\(\\<endcase\\>\\)" )
       nil 'move)
      (cond
       ((match-end 1)
	(let ((here (point)))
	  (vpp-beg-of-statement)
	  (unless (looking-at vpp-extended-case-re)
	    (goto-char here)))
	(setq nest (1- nest)))
       ((match-end 3)
	(setq nest (1+ nest)))
       ((bobp)
	(ding 't)
	(setq nest 0))))))

(defun vpp-leap-to-head ()
  "Move point to the head of this block.
Jump from end to matching begin, from endcase to matching case, and so on."
  (let ((reg nil)
	snest
	(nesting 'yes)
	(nest 1))
    (cond
     ((looking-at "\\<end\\>")
      ;; 1: Search back for matching begin
      (setq reg (concat "\\(\\<begin\\>\\)\\|\\(\\<end\\>\\)\\|"
			"\\(\\<endcase\\>\\)\\|\\(\\<join\\(_any\\|_none\\)?\\>\\)" )))
     ((looking-at "\\<endtask\\>")
      ;; 2: Search back for matching task
      (setq reg "\\(\\<task\\>\\)\\|\\(\\(\\(\\<virtual\\>\\s-+\\)\\|\\(\\<protected\\>\\s-+\\)\\)+\\<task\\>\\)")
      (setq nesting 'no))
     ((looking-at "\\<endcase\\>")
      (catch 'nesting
	(vpp-leap-to-case-head) )
      (setq reg nil) ; to force skip
      )

     ((looking-at "\\<join\\(_any\\|_none\\)?\\>")
      ;; 4: Search back for matching fork
      (setq reg "\\(\\<fork\\>\\)\\|\\(\\<join\\(_any\\|_none\\)?\\>\\)" ))
     ((looking-at "\\<endclass\\>")
      ;; 5: Search back for matching class
      (setq reg "\\(\\<class\\>\\)\\|\\(\\<endclass\\>\\)" ))
     ((looking-at "\\<endtable\\>")
      ;; 6: Search back for matching table
      (setq reg "\\(\\<table\\>\\)\\|\\(\\<endtable\\>\\)" ))
     ((looking-at "\\<endspecify\\>")
      ;; 7: Search back for matching specify
      (setq reg "\\(\\<specify\\>\\)\\|\\(\\<endspecify\\>\\)" ))
     ((looking-at "\\<endfunction\\>")
      ;; 8: Search back for matching function
      (setq reg "\\(\\<function\\>\\)\\|\\(\\(\\(\\<virtual\\>\\s-+\\)\\|\\(\\<protected\\>\\s-+\\)\\)+\\<function\\>\\)")
      (setq nesting 'no))
      ;;(setq reg "\\(\\<function\\>\\)\\|\\(\\<endfunction\\>\\)" ))
     ((looking-at "\\<endgenerate\\>")
      ;; 8: Search back for matching generate
      (setq reg "\\(\\<generate\\>\\)\\|\\(\\<endgenerate\\>\\)" ))
     ((looking-at "\\<endgroup\\>")
      ;; 10: Search back for matching covergroup
      (setq reg "\\(\\<covergroup\\>\\)\\|\\(\\<endgroup\\>\\)" ))
     ((looking-at "\\<endproperty\\>")
      ;; 11: Search back for matching property
      (setq reg "\\(\\<property\\>\\)\\|\\(\\<endproperty\\>\\)" ))
     ((looking-at vpp-uvm-end-re)
      ;; 12: Search back for matching sequence
      (setq reg (concat "\\(" vpp-uvm-begin-re "\\|" vpp-uvm-end-re "\\)")))
     ((looking-at vpp-ovm-end-re)
      ;; 12: Search back for matching sequence
      (setq reg (concat "\\(" vpp-ovm-begin-re "\\|" vpp-ovm-end-re "\\)")))
     ((looking-at vpp-vmm-end-re)
      ;; 12: Search back for matching sequence
      (setq reg (concat "\\(" vpp-vmm-begin-re "\\|" vpp-vmm-end-re "\\)")))
     ((looking-at "\\<endinterface\\>")
      ;; 12: Search back for matching interface
      (setq reg "\\(\\<interface\\>\\)\\|\\(\\<endinterface\\>\\)" ))
     ((looking-at "\\<endsequence\\>")
      ;; 12: Search back for matching sequence
      (setq reg "\\(\\<\\(rand\\)?sequence\\>\\)\\|\\(\\<endsequence\\>\\)" ))
     ((looking-at "\\<endclocking\\>")
      ;; 12: Search back for matching clocking
      (setq reg "\\(\\<clocking\\)\\|\\(\\<endclocking\\>\\)" )))
    (if reg
	(catch 'skip
	  (if (eq nesting 'yes)
	      (let (sreg)
		(while (vpp-re-search-backward reg nil 'move)
		  (cond
		   ((match-end 1) ; begin
		    (if (looking-at "fork")
			(let ((here (point)))
			  (vpp-beg-of-statement)
			  (unless (looking-at vpp-disable-fork-re)
			    (goto-char here)
			    (setq nest (1- nest))))
		      (setq nest (1- nest)))
		    (if (= 0 nest)
			;; Now previous line describes syntax
			(throw 'skip 1))
		    (if (and snest
			     (= snest nest))
			(setq reg sreg)))
		   ((match-end 2) ; end
		    (setq nest (1+ nest)))
		   ((match-end 3)
		    ;; endcase, jump to case
		    (setq snest nest)
		    (setq nest (1+ nest))
		    (setq sreg reg)
		    (setq reg "\\(\\<randcase\\>\\|\\<case[xz]?\\>[^:]\\)\\|\\(\\<endcase\\>\\)" ))
		   ((match-end 4)
		    ;; join, jump to fork
		    (setq snest nest)
		    (setq nest (1+ nest))
		    (setq sreg reg)
		    (setq reg "\\(\\<fork\\>\\)\\|\\(\\<join\\(_any\\|_none\\)?\\>\\)" ))
		   )))
	    ;no nesting
	    (if (and
		 (vpp-re-search-backward reg nil 'move)
		 (match-end 1)) ; task -> could be virtual and/or protected
		(progn
		  (vpp-beg-of-statement)
		  (throw 'skip 1))
	      (throw 'skip 1)))))))

(defun vpp-continued-line ()
  "Return true if this is a continued line.
Set point to where line starts."
  (let ((continued 't))
    (if (eq 0 (forward-line -1))
	(progn
	  (end-of-line)
	  (vpp-backward-ws&directives)
	  (if (bobp)
	      (setq continued nil)
	    (while (and continued
			(save-excursion
			  (skip-chars-backward " \t")
			  (not (bolp))))
	    (setq continued (vpp-backward-token)))))
      (setq continued nil))
    continued))

(defun vpp-backward-token ()
  "Step backward token, returning true if this is a continued line."
  (interactive)
  (vpp-backward-syntactic-ws)
  (cond
   ((bolp)
    nil)
   (;-- Anything ending in a ; is complete
    (= (preceding-char) ?\;)
    nil)
   (; If a "}" is prefixed by a ";", then this is a complete statement
    ; i.e.: constraint foo { a = b; }
    (= (preceding-char) ?\})
    (progn
      (backward-char)
      (not(vpp-at-close-constraint-p))))
   (;-- constraint foo { a = b }
    ;   is a complete statement. *sigh*
    (= (preceding-char) ?\{)
    (progn
      (backward-char)
      (not (vpp-at-constraint-p))))
   (;" string "
    (= (preceding-char) ?\")
    (backward-char)
    (vpp-skip-backward-comment-or-string)
    nil)

   (; [3:4]
    (= (preceding-char) ?\])
    (backward-char)
    (vpp-backward-open-bracket)
    t)

   (;-- Could be 'case (foo)' or 'always @(bar)' which is complete
    ;   also could be simply '@(foo)'
    ;   or foo u1 #(a=8)
    ;            (b, ... which ISN'T complete
    ;;;; Do we need this???
    (= (preceding-char) ?\))
    (progn
      (backward-char)
      (vpp-backward-up-list 1)
      (vpp-backward-syntactic-ws)
      (let ((back (point)))
	(forward-word -1)
	(cond
	 ;;XX
	 ((looking-at "\\<\\(always\\(_latch\\|_ff\\|_comb\\)?\\|case\\(\\|[xz]\\)\\|for\\(\\|each\\|ever\\)\\|i\\(f\\|nitial\\)\\|repeat\\|while\\)\\>")
	  (not (looking-at "\\<randcase\\>\\|\\<case[xz]?\\>[^:]")))
	 ((looking-at vpp-uvm-statement-re)
	  nil)
	 ((looking-at vpp-uvm-begin-re)
	  t)
	 ((looking-at vpp-uvm-end-re)
	  t)
	 ((looking-at vpp-ovm-statement-re)
	  nil)
	 ((looking-at vpp-ovm-begin-re)
	  t)
	 ((looking-at vpp-ovm-end-re)
	  t)
     ;; JBA find VMM macros
     ((looking-at vpp-vmm-statement-re)
      nil )
     ((looking-at vpp-vmm-begin-re)
      t)
     ((looking-at vpp-vmm-end-re)
      nil)
     ;; JBA trying to catch macro lines with no ; at end
     ((looking-at "\\<`")
      nil)
	 (t
	  (goto-char back)
	  (cond
	   ((= (preceding-char) ?\@)
	    (backward-char)
	    (save-excursion
	      (vpp-backward-token)
	      (not (looking-at "\\<\\(always\\(_latch\\|_ff\\|_comb\\)?\\|initial\\|while\\)\\>"))))
	   ((= (preceding-char) ?\#)
	    (backward-char))
	   (t t)))))))

   (;-- any of begin|initial|while are complete statements; 'begin : foo' is also complete
    t
    (forward-word -1)
    (while (= (preceding-char) ?\_)
      (forward-word -1))
    (cond
     ((looking-at "\\<else\\>")
      t)
     ((looking-at vpp-behavioral-block-beg-re)
      t)
     ((looking-at vpp-indent-re)
      nil)
     (t
      (let
	  ((back (point)))
	(vpp-backward-syntactic-ws)
	(cond
	 ((= (preceding-char) ?\:)
	  (backward-char)
	  (vpp-backward-syntactic-ws)
	  (backward-sexp)
	  (if (looking-at vpp-nameable-item-re )
	      nil
	    t))
	 ((= (preceding-char) ?\#)
	  (backward-char)
	  t)
	 ((= (preceding-char) ?\`)
	  (backward-char)
	  t)

	 (t
	  (goto-char back)
	  t))))))))

(defun vpp-backward-syntactic-ws ()
  "Move backwards putting point after first non-whitespace non-comment."
  (vpp-skip-backward-comments)
  (forward-comment (- (buffer-size))))

(defun vpp-backward-syntactic-ws-quick ()
  "As with `vpp-backward-syntactic-ws' but use `vpp-scan' cache."
  (while (cond ((bobp)
		nil) ; Done
	       ((> (skip-syntax-backward " ") 0)
		t)
	       ((eq (preceding-char) ?\n)  ;; \n's terminate // so aren't space syntax
		(forward-char -1)
		t)
	       ((or (vpp-inside-comment-or-string-p (1- (point)))
		    (vpp-inside-comment-or-string-p (point)))
		(re-search-backward "[/\"]" nil t) ;; Only way a comment or quote can begin
		t))))

(defun vpp-forward-syntactic-ws ()
  (vpp-skip-forward-comment-p)
  (forward-comment (buffer-size)))

(defun vpp-backward-ws&directives (&optional bound)
  "Backward skip over syntactic whitespace and compiler directives for Emacs 19.
Optional BOUND limits search."
  (save-restriction
    (let* ((bound (or bound (point-min)))
	   (here bound)
	   (p nil) )
      (if (< bound (point))
	  (progn
	    (let ((state (save-excursion (vpp-syntax-ppss))))
	      (cond
	       ((nth 7 state) ;; in // comment
		(vpp-re-search-backward "//" nil 'move)
                (skip-chars-backward "/"))
	       ((nth 4 state) ;; in /* */ comment
		(vpp-re-search-backward "/\*" nil 'move))))
	    (narrow-to-region bound (point))
	    (while (/= here (point))
	      (setq here (point))
	      (vpp-skip-backward-comments)
	      (setq p
		    (save-excursion
		      (beginning-of-line)
		      (cond
		       ((and vpp-highlight-translate-off
			     (vpp-within-translate-off))
			(vpp-back-to-start-translate-off (point-min)))
		       ((looking-at vpp-directive-re-1)
			(point))
		       (t
			nil))))
	      (if p (goto-char p))))))))

(defun vpp-forward-ws&directives (&optional bound)
  "Forward skip over syntactic whitespace and compiler directives for Emacs 19.
Optional BOUND limits search."
  (save-restriction
    (let* ((bound (or bound (point-max)))
	   (here bound)
	   jump)
      (if (> bound (point))
	  (progn
	    (let ((state (save-excursion (vpp-syntax-ppss))))
	      (cond
	       ((nth 7 state) ;; in // comment
		(end-of-line)
		(forward-char 1)
		(skip-chars-forward " \t\n\f")
		)
	       ((nth 4 state) ;; in /* */ comment
		(vpp-re-search-forward "\*\/\\s-*" nil 'move))))
	    (narrow-to-region (point) bound)
	    (while (/= here (point))
	      (setq here (point)
		    jump nil)
	      (forward-comment (buffer-size))
	      (and (looking-at "\\s-*(\\*.*\\*)\\s-*") ;; Attribute
		   (goto-char (match-end 0)))
	      (save-excursion
		(beginning-of-line)
		(if (looking-at vpp-directive-re-1)
		    (setq jump t)))
	      (if jump
		  (beginning-of-line 2))))))))

(defun vpp-in-comment-p ()
 "Return true if in a star or // comment."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (or (nth 4 state) (nth 7 state))))

(defun vpp-in-star-comment-p ()
 "Return true if in a star comment."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (and
    (nth 4 state)			; t if in a comment of style a // or b /**/
	(not
	 (nth 7 state)			; t if in a comment of style b /**/
	 ))))

(defun vpp-in-slash-comment-p ()
 "Return true if in a slash comment."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (nth 7 state)))

(defun vpp-in-comment-or-string-p ()
 "Return true if in a string or comment."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (or (nth 3 state) (nth 4 state) (nth 7 state)))) ; Inside string or comment)

(defun vpp-in-attribute-p ()
 "Return true if point is in an attribute (* [] attribute *)."
 (save-match-data
   (save-excursion
     (vpp-re-search-backward "\\((\\*\\)\\|\\(\\*)\\)" nil 'move)
     (numberp (match-beginning 1)))))

(defun vpp-in-parameter-p ()
 "Return true if point is in a parameter assignment #( p1=1, p2=5)."
 (save-match-data
   (save-excursion
     (vpp-re-search-backward "\\(#(\\)\\|\\()\\)" nil 'move)
     (numberp (match-beginning 1)))))

(defun vpp-in-escaped-name-p ()
 "Return true if in an escaped name."
 (save-excursion
   (backward-char)
   (skip-chars-backward "^ \t\n\f")
   (if (equal (char-after (point) ) ?\\ )
       t
     nil)))
(defun vpp-in-directive-p ()
 "Return true if in a directive."
 (save-excursion
   (beginning-of-line)
   (looking-at vpp-directive-re-1)))

(defun vpp-in-parenthesis-p ()
 "Return true if in a ( ) expression (but not { } or [ ])."
 (save-match-data
   (save-excursion
     (vpp-re-search-backward "\\((\\)\\|\\()\\)" nil 'move)
     (numberp (match-beginning 1)))))

(defun vpp-in-paren ()
 "Return true if in a parenthetical expression.
May cache result using `vpp-syntax-ppss'."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (> (nth 0 state) 0 )))

(defun vpp-in-paren-quick ()
 "Return true if in a parenthetical expression.
Always starts from `point-min', to allow inserts with hooks disabled."
 ;; The -quick refers to its use alongside the other -quick functions,
 ;; not that it's likely to be faster than vpp-in-paren.
 (let ((state (save-excursion (parse-partial-sexp (point-min) (point)))))
   (> (nth 0 state) 0 )))

(defun vpp-in-struct-p ()
 "Return true if in a struct declaration."
 (interactive)
 (save-excursion
   (if (vpp-in-paren)
       (progn
	 (vpp-backward-up-list 1)
	 (vpp-at-struct-p)
	 )
     nil)))

(defun vpp-in-coverage-p ()
 "Return true if in a constraint or coverpoint expression."
 (interactive)
 (save-excursion
   (if (vpp-in-paren)
       (progn
	 (vpp-backward-up-list 1)
	 (vpp-at-constraint-p)
	 )
     nil)))
(defun vpp-at-close-constraint-p ()
  "If at the } that closes a constraint or covergroup, return true."
  (if (and
       (equal (char-after) ?\})
       (vpp-in-paren))

      (save-excursion
	(vpp-backward-ws&directives)
	(if (equal (char-before) ?\;)
	    (point)
	  nil))))

(defun vpp-at-constraint-p ()
  "If at the { of a constraint or coverpoint definition, return true, moving point to constraint."
  (if (save-excursion
	(and
	 (equal (char-after) ?\{)
	 (forward-list)
	 (progn (backward-char 1)
		(vpp-backward-ws&directives)
		(equal (char-before) ?\;))))
      ;; maybe
      (vpp-re-search-backward "\\<constraint\\|coverpoint\\|cross\\>" nil 'move)
    ;; not
    nil))

(defun vpp-at-struct-p ()
  "If at the { of a struct, return true, moving point to struct."
  (save-excursion
    (if (and (equal (char-after) ?\{)
             (vpp-backward-token))
        (looking-at "\\<struct\\|union\\|packed\\|\\(un\\)?signed\\>")
      nil)))

(defun vpp-parenthesis-depth ()
 "Return non zero if in parenthetical-expression."
 (save-excursion (nth 1 (vpp-syntax-ppss))))


(defun vpp-skip-forward-comment-or-string ()
 "Return true if in a string or comment."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (cond
    ((nth 3 state)			;Inside string
     (search-forward "\"")
     t)
    ((nth 7 state)			;Inside // comment
     (forward-line 1)
     t)
    ((nth 4 state)			;Inside any comment (hence /**/)
     (search-forward "*/"))
    (t
     nil))))

(defun vpp-skip-backward-comment-or-string ()
 "Return true if in a string or comment."
 (let ((state (save-excursion (vpp-syntax-ppss))))
   (cond
    ((nth 3 state)			;Inside string
     (search-backward "\"")
     t)
    ((nth 7 state)			;Inside // comment
     (search-backward "//")
     (skip-chars-backward "/")
     t)
    ((nth 4 state)			;Inside /* */ comment
     (search-backward "/*")
     t)
    (t
     nil))))

(defun vpp-skip-backward-comments ()
 "Return true if a comment was skipped."
 (let ((more t))
   (while more
     (setq more
	   (let ((state (save-excursion (vpp-syntax-ppss))))
	     (cond
	      ((nth 7 state)			;Inside // comment
	       (search-backward "//")
	       (skip-chars-backward "/")
	       (skip-chars-backward " \t\n\f")
	       t)
	      ((nth 4 state)			;Inside /* */ comment
	       (search-backward "/*")
	       (skip-chars-backward " \t\n\f")
	       t)
	      ((and (not (bobp))
		    (= (char-before) ?\/)
		    (= (char-before (1- (point))) ?\*))
	       (goto-char (- (point) 2))
	       t) ;; Let nth 4 state handle the rest
	      ((and (not (bobp))
		    (= (char-before) ?\))
		    (= (char-before (1- (point))) ?\*))
	       (goto-char (- (point) 2))
	       (if (search-backward "(*" nil t)
		   (progn
		     (skip-chars-backward " \t\n\f")
		     t)
		 (progn
		   (goto-char (+ (point) 2))
		   nil)))
	      (t
	       (/= (skip-chars-backward " \t\n\f") 0))))))))

(defun vpp-skip-forward-comment-p ()
  "If in comment, move to end and return true."
  (let* (h
	 (state (save-excursion (vpp-syntax-ppss)))
	 (skip (cond
		((nth 3 state)		;Inside string
		 t)
		((nth 7 state)		;Inside // comment
		 (end-of-line)
		 (forward-char 1)
		 t)
		((nth 4 state)		;Inside /* comment
		 (search-forward "*/")
		 t)
		((vpp-in-attribute-p)  ;Inside (* attribute
		 (search-forward "*)" nil t)
		 t)
		(t nil))))
    (skip-chars-forward " \t\n\f")
    (while
	(cond
	 ((looking-at "\\/\\*")
	  (progn
	    (setq h (point))
	    (goto-char (match-end 0))
	    (if (search-forward "*/" nil t)
		(progn
		  (skip-chars-forward " \t\n\f")
		  (setq skip 't))
	      (progn
		(goto-char h)
		nil))))
	 ((looking-at "(\\*")
	  (progn
	    (setq h (point))
	    (goto-char (match-end 0))
	    (if (search-forward "*)" nil t)
		(progn
		  (skip-chars-forward " \t\n\f")
		  (setq skip 't))
	      (progn
		(goto-char h)
		nil))))
	 (t nil)))
    skip))

(defun vpp-indent-line-relative ()
  "Cheap version of indent line.
Only look at a few lines to determine indent level."
  (interactive)
  (let ((indent-str)
	(sp (point)))
    (if (looking-at "^[ \t]*$")
	(cond  ;- A blank line; No need to be too smart.
	 ((bobp)
	  (setq indent-str (list 'cpp 0)))
	 ((vpp-continued-line)
	  (let ((sp1 (point)))
	    (if (vpp-continued-line)
		(progn
		  (goto-char sp)
		  (setq indent-str
			(list 'statement (vpp-current-indent-level))))
	      (goto-char sp1)
	      (setq indent-str (list 'block (vpp-current-indent-level)))))
	  (goto-char sp))
	 ((goto-char sp)
	  (setq indent-str (vpp-calculate-indent))))
      (progn (skip-chars-forward " \t")
	     (setq indent-str (vpp-calculate-indent))))
    (vpp-do-indent indent-str)))

(defun vpp-indent-line ()
  "Indent for special part of code."
  (vpp-do-indent (vpp-calculate-indent)))

(defun vpp-do-indent (indent-str)
  (let ((type (car indent-str))
	(ind (car (cdr indent-str))))
    (cond
     (; handle continued exp
      (eq type 'cexp)
      (let ((here (point)))
	(vpp-backward-syntactic-ws)
	(cond
	 ((or
	   (= (preceding-char) ?\,)
	   (= (preceding-char) ?\])
	   (save-excursion
	     (vpp-beg-of-statement-1)
	     (looking-at vpp-declaration-re)))
	  (let* ( fst
		  (val
		   (save-excursion
		     (backward-char 1)
		     (vpp-beg-of-statement-1)
		     (setq fst (point))
		     (if (looking-at vpp-declaration-re)
			 (progn ;; we have multiple words
			   (goto-char (match-end 0))
			   (skip-chars-forward " \t")
			   (cond
			    ((and vpp-indent-declaration-macros
				  (= (following-char) ?\`))
			     (progn
			       (forward-char 1)
			       (forward-word 1)
			       (skip-chars-forward " \t")))
			    ((= (following-char) ?\[)
			     (progn
			       (forward-char 1)
			       (vpp-backward-up-list -1)
			       (skip-chars-forward " \t"))))
			   (current-column))
		       (progn
			 (goto-char fst)
			 (+ (current-column) vpp-cexp-indent))))))
	    (goto-char here)
	    (indent-line-to val)
	    (if (and (not vpp-indent-lists)
		     (vpp-in-paren))
		(vpp-pretty-declarations-auto))
	    ))
	 ((= (preceding-char) ?\) )
	  (goto-char here)
	  (let ((val (eval (cdr (assoc type vpp-indent-alist)))))
	    (indent-line-to val)))
	 (t
	  (goto-char here)
	  (let ((val))
	    (vpp-beg-of-statement-1)
	    (if (and (< (point) here)
		     (vpp-re-search-forward "=[ \\t]*" here 'move))
		(setq val (current-column))
	      (setq val (eval (cdr (assoc type vpp-indent-alist)))))
	    (goto-char here)
	    (indent-line-to val))))))

     (; handle inside parenthetical expressions
      (eq type 'cparenexp)
      (let* ( here
	      (val (save-excursion
		     (vpp-backward-up-list 1)
		     (forward-char 1)
             (if vpp-indent-lists
                 (skip-chars-forward " \t")
               (vpp-forward-syntactic-ws))
             (setq here (point))
             (current-column)))

	      (decl (save-excursion
		      (goto-char here)
		      (vpp-forward-syntactic-ws)
		      (setq here (point))
		      (looking-at vpp-declaration-re))))
        (indent-line-to val)
        (if decl
            (vpp-pretty-declarations-auto))))

     (;-- Handle the ends
      (or
       (looking-at vpp-end-block-re )
       (vpp-at-close-constraint-p))
      (let ((val (if (eq type 'statement)
		     (- ind vpp-indent-level)
		   ind)))
	(indent-line-to val)))

     (;-- Case -- maybe line 'em up
      (and (eq type 'case) (not (looking-at "^[ \t]*$")))
      (progn
	(cond
	 ((looking-at "\\<endcase\\>")
	  (indent-line-to ind))
	 (t
	  (let ((val (eval (cdr (assoc type vpp-indent-alist)))))
	    (indent-line-to val))))))

     (;-- defun
      (and (eq type 'defun)
	   (looking-at vpp-zero-indent-re))
      (indent-line-to 0))

     (;-- declaration
      (and (or
	    (eq type 'defun)
	    (eq type 'block))
	   (looking-at vpp-declaration-re))
      (vpp-indent-declaration ind))

     (;-- Everything else
      t
      (let ((val (eval (cdr (assoc type vpp-indent-alist)))))
	(indent-line-to val))))

    (if (looking-at "[ \t]+$")
	(skip-chars-forward " \t"))
    indent-str				; Return indent data
    ))

(defun vpp-current-indent-level ()
  "Return the indent-level of the current statement."
  (save-excursion
    (let (par-pos)
      (beginning-of-line)
      (setq par-pos (vpp-parenthesis-depth))
      (while par-pos
	(goto-char par-pos)
	(beginning-of-line)
	(setq par-pos (vpp-parenthesis-depth)))
      (skip-chars-forward " \t")
      (current-column))))

(defun vpp-case-indent-level ()
  "Return the indent-level of the current statement.
Do not count named blocks or case-statements."
  (save-excursion
    (skip-chars-forward " \t")
    (cond
     ((looking-at vpp-named-block-re)
      (current-column))
     ((and (not (looking-at vpp-extended-case-re))
	   (looking-at "^[^:;]+[ \t]*:"))
      (vpp-re-search-forward ":" nil t)
      (skip-chars-forward " \t")
      (current-column))
     (t
      (current-column)))))

(defun vpp-indent-comment ()
  "Indent current line as comment."
  (let* ((stcol
	  (cond
	   ((vpp-in-star-comment-p)
	    (save-excursion
	      (re-search-backward "/\\*" nil t)
	      (1+(current-column))))
	   (comment-column
	     comment-column )
	   (t
	    (save-excursion
	      (re-search-backward "//" nil t)
	      (current-column))))))
    (indent-line-to stcol)
    stcol))

(defun vpp-more-comment ()
  "Make more comment lines like the previous."
  (let* ((star 0)
	 (stcol
	  (cond
	   ((vpp-in-star-comment-p)
	    (save-excursion
	      (setq star 1)
	      (re-search-backward "/\\*" nil t)
	      (1+(current-column))))
	   (comment-column
	    comment-column )
	   (t
	    (save-excursion
	      (re-search-backward "//" nil t)
	      (current-column))))))
    (progn
      (indent-to stcol)
      (if (and star
	       (save-excursion
		 (forward-line -1)
		 (skip-chars-forward " \t")
		 (looking-at "\*")))
	  (insert "* ")))))

(defun vpp-comment-indent (&optional arg)
  "Return the column number the line should be indented to.
ARG is ignored, for `comment-indent-function' compatibility."
  (cond
   ((vpp-in-star-comment-p)
    (save-excursion
      (re-search-backward "/\\*" nil t)
      (1+(current-column))))
   ( comment-column
     comment-column )
   (t
    (save-excursion
      (re-search-backward "//" nil t)
      (current-column)))))

;;

(defun vpp-pretty-declarations-auto (&optional quiet)
  "Call `vpp-pretty-declarations' QUIET based on `vpp-auto-lineup'."
  (when (or (eq 'all vpp-auto-lineup)
	    (eq 'declarations vpp-auto-lineup))
    (vpp-pretty-declarations quiet)))

(defun vpp-pretty-declarations (&optional quiet)
  "Line up declarations around point.
Be verbose about progress unless optional QUIET set."
  (interactive)
  (let* ((m1 (make-marker))
         (e (point))
	 el
         r
	 (here (point))
         ind
         start
         startpos
         end
         endpos
         base-ind
         )
    (save-excursion
      (if (progn
;          (vpp-beg-of-statement-1)
          (beginning-of-line)
          (vpp-forward-syntactic-ws)
          (and (not (vpp-in-directive-p))    ;; could have `define input foo
               (looking-at vpp-declaration-re)))
	  (progn
	    (if (vpp-parenthesis-depth)
		;; in an argument list or parameter block
		(setq el (vpp-backward-up-list -1)
		      start (progn
			      (goto-char e)
			      (vpp-backward-up-list 1)
			      (forward-line) ;; ignore ( input foo,
			      (vpp-re-search-forward vpp-declaration-re el 'move)
			      (goto-char (match-beginning 0))
			      (skip-chars-backward " \t")
			      (point))
		      startpos (set-marker (make-marker) start)
		      end (progn
			    (goto-char start)
			    (vpp-backward-up-list -1)
			    (forward-char -1)
			    (vpp-backward-syntactic-ws)
			    (point))
		      endpos (set-marker (make-marker) end)
		      base-ind (progn
				 (goto-char start)
                 (forward-char 1)
                 (skip-chars-forward " \t")
                 (current-column))
		      )
	      ;; in a declaration block (not in argument list)
	      (setq
	       start (progn
		       (vpp-beg-of-statement-1)
		       (while (and (looking-at vpp-declaration-re)
				   (not (bobp)))
			 (skip-chars-backward " \t")
			 (setq e (point))
			 (beginning-of-line)
			 (vpp-backward-syntactic-ws)
			 (backward-char)
			 (vpp-beg-of-statement-1))
		       e)
	       startpos (set-marker (make-marker) start)
	       end (progn
		     (goto-char here)
		     (vpp-end-of-statement)
		     (setq e (point))	;Might be on last line
		     (vpp-forward-syntactic-ws)
		     (while (looking-at vpp-declaration-re)
		       (vpp-end-of-statement)
		       (setq e (point))
		       (vpp-forward-syntactic-ws))
		     e)
	       endpos (set-marker (make-marker) end)
	       base-ind (progn
			  (goto-char start)
			  (vpp-do-indent (vpp-calculate-indent))
			  (vpp-forward-ws&directives)
			  (current-column))))
	    ;; OK, start and end are set
	    (goto-char (marker-position startpos))
	    (if (and (not quiet)
		     (> (- end start) 100))
		(message "Lining up declarations..(please stand by)"))
	    ;; Get the beginning of line indent first
	    (while (progn (setq e (marker-position endpos))
			  (< (point) e))
	      (cond
	       ((save-excursion (skip-chars-backward " \t")
				(bolp))
		 (vpp-forward-ws&directives)
		 (indent-line-to base-ind)
		 (vpp-forward-ws&directives)
		 (if (< (point) e)
		     (vpp-re-search-forward "[ \t\n\f]" e 'move)))
	       (t
		(just-one-space)
		(vpp-re-search-forward "[ \t\n\f]" e 'move)))
	      ;;(forward-line)
	      )
	    ;; Now find biggest prefix
	    (setq ind (vpp-get-lineup-indent (marker-position startpos) endpos))
	    ;; Now indent each line.
	    (goto-char (marker-position startpos))
	    (while (progn (setq e (marker-position endpos))
			  (setq r (- e (point)))
			  (> r 0))
	      (setq e (point))
	      (unless quiet (message "%d" r))
          ;;(vpp-do-indent (vpp-calculate-indent)))
	      (vpp-forward-ws&directives)
	      (cond
	       ((or (and vpp-indent-declaration-macros
			 (looking-at vpp-declaration-re-2-macro))
		    (looking-at vpp-declaration-re-2-no-macro))
		(let ((p (match-end 0)))
		  (set-marker m1 p)
		  (if (vpp-re-search-forward "[[#`]" p 'move)
		      (progn
			(forward-char -1)
			(just-one-space)
			(goto-char (marker-position m1))
			(just-one-space)
			(indent-to ind))
		    (progn
		      (just-one-space)
		      (indent-to ind)))))
	       ((vpp-continued-line-1 (marker-position startpos))
		(goto-char e)
		(indent-line-to ind))
	       ((vpp-in-struct-p)
		;; could have a declaration of a user defined item
		(goto-char e)
		(vpp-end-of-statement))
	       (t		; Must be comment or white space
		(goto-char e)
		(vpp-forward-ws&directives)
		(forward-line -1)))
	      (forward-line 1))
	    (unless quiet (message "")))))))

(defun vpp-pretty-expr (&optional quiet myre)
  "Line up expressions around point, optionally QUIET with regexp MYRE ignored."
  (interactive)
  (if (not (vpp-in-comment-or-string-p))
      (save-excursion
        (let ( (rexp (concat "^\\s-*" vpp-complete-reg))
               (rexp1 (concat "^\\s-*" vpp-basic-complete-re)))
          (beginning-of-line)
          (if (and (not (looking-at rexp ))
                   (looking-at vpp-assignment-operation-re)
                   (save-excursion
                     (goto-char (match-end 2))
                     (and (not (vpp-in-attribute-p))
                          (not (vpp-in-parameter-p))
                          (not (vpp-in-comment-or-string-p)))))
              (let* ((here (point))
                     (e) (r)
                     (start
                      (progn
                        (beginning-of-line)
                        (setq e (point))
                        (vpp-backward-syntactic-ws)
                        (beginning-of-line)
                        (while (and (not (looking-at rexp1))
                                    (looking-at vpp-assignment-operation-re)
                                    (not (bobp))
                                    )
                          (setq e (point))
                          (vpp-backward-syntactic-ws)
                          (beginning-of-line)
                          ) ;Ack, need to grok `define
                        e))
                     (end
                      (progn
                        (goto-char here)
                        (end-of-line)
                        (setq e (point))	;Might be on last line
                        (vpp-forward-syntactic-ws)
                        (beginning-of-line)
                        (while (and
                                (not (looking-at rexp1 ))
                                (looking-at vpp-assignment-operation-re)
                                (progn
                                  (end-of-line)
                                  (not (eq e (point)))))
                          (setq e (point))
                          (vpp-forward-syntactic-ws)
                          (beginning-of-line)
                          )
                        e))
                     (endpos (set-marker (make-marker) end))
                     (ind)
                     )
                (goto-char start)
                (vpp-do-indent (vpp-calculate-indent))
                (if (and (not quiet)
                         (> (- end start) 100))
                    (message "Lining up expressions..(please stand by)"))

                ;; Set indent to minimum throughout region
                (while (< (point) (marker-position endpos))
                  (beginning-of-line)
                  (vpp-just-one-space vpp-assignment-operation-re)
                  (beginning-of-line)
                  (vpp-do-indent (vpp-calculate-indent))
                  (end-of-line)
                  (vpp-forward-syntactic-ws)
                  )

                ;; Now find biggest prefix
                (setq ind (vpp-get-lineup-indent-2 vpp-assignment-operation-re start endpos))

                ;; Now indent each line.
                (goto-char start)
                (while (progn (setq e (marker-position endpos))
                              (setq r (- e (point)))
                              (> r 0))
                  (setq e (point))
                  (if (not quiet) (message "%d" r))
                  (cond
                   ((looking-at vpp-assignment-operation-re)
                    (goto-char (match-beginning 2))
                    (if (not (or (vpp-in-parenthesis-p) ;; leave attributes and comparisons alone
                                 (vpp-in-coverage-p)))
                        (if (eq (char-after) ?=)
                            (indent-to (1+ ind))	; line up the = of the <= with surrounding =
                          (indent-to ind)
                          ))
                    )
                   ((vpp-continued-line-1 start)
                    (goto-char e)
                    (indent-line-to ind))
                   (t		; Must be comment or white space
                    (goto-char e)
                    (vpp-forward-ws&directives)
                    (forward-line -1))
                   )
                  (forward-line 1))
                (unless quiet (message ""))
                ))))))

(defun vpp-just-one-space (myre)
  "Remove extra spaces around regular expression MYRE."
  (interactive)
  (if (and (not(looking-at vpp-complete-reg))
	   (looking-at myre))
      (let ((p1 (match-end 1))
	    (p2 (match-end 2)))
	(progn
	  (goto-char p2)
	  (just-one-space)
	  (goto-char p1)
	  (just-one-space)))))

(defun vpp-indent-declaration (baseind)
  "Indent current lines as declaration.
Line up the variable names based on previous declaration's indentation.
BASEIND is the base indent to offset everything."
  (interactive)
  (let ((pos (point-marker))
	(lim (save-excursion
	       ;; (vpp-re-search-backward vpp-declaration-opener nil 'move)
	       (vpp-re-search-backward "\\(\\<begin\\>\\)\\|\\(\\<module\\>\\)\\|\\(\\<defmod\\>\\)\\|\\(\\<task\\>\\)" nil 'move)
	       (point)))
	(ind)
	(val)
	(m1 (make-marker)))
    (setq val
	  (+ baseind (eval (cdr (assoc 'declaration vpp-indent-alist)))))
    (indent-line-to val)

    ;; Use previous declaration (in this module) as template.
    (if (or (eq 'all vpp-auto-lineup)
	    (eq 'declarations vpp-auto-lineup))
	(if (vpp-re-search-backward
	     (or (and vpp-indent-declaration-macros
		      vpp-declaration-re-1-macro)
		 vpp-declaration-re-1-no-macro) lim t)
	    (progn
	      (goto-char (match-end 0))
	      (skip-chars-forward " \t")
	      (setq ind (current-column))
	      (goto-char pos)
	      (setq val
		    (+ baseind
		       (eval (cdr (assoc 'declaration vpp-indent-alist)))))
	      (indent-line-to val)
	      (if (and vpp-indent-declaration-macros
		       (looking-at vpp-declaration-re-2-macro))
		  (let ((p (match-end 0)))
		    (set-marker m1 p)
		    (if (vpp-re-search-forward "[[#`]" p 'move)
			(progn
			  (forward-char -1)
			  (just-one-space)
			  (goto-char (marker-position m1))
			  (just-one-space)
			  (indent-to ind))
		      (if (/= (current-column) ind)
			  (progn
			    (just-one-space)
			    (indent-to ind)))))
		(if (looking-at vpp-declaration-re-2-no-macro)
		    (let ((p (match-end 0)))
		      (set-marker m1 p)
		      (if (vpp-re-search-forward "[[`#]" p 'move)
			  (progn
			    (forward-char -1)
			    (just-one-space)
			    (goto-char (marker-position m1))
			    (just-one-space)
			    (indent-to ind))
			(if (/= (current-column) ind)
			    (progn
			      (just-one-space)
			      (indent-to ind))))))))))
    (goto-char pos)))

(defun vpp-get-lineup-indent (b edpos)
  "Return the indent level that will line up several lines within the region.
Region is defined by B and EDPOS."
  (save-excursion
    (let ((ind 0) e)
      (goto-char b)
      ;; Get rightmost position
      (while (progn (setq e (marker-position edpos))
		    (< (point) e))
	(if (vpp-re-search-forward
	     (or (and vpp-indent-declaration-macros
		      vpp-declaration-re-1-macro)
		 vpp-declaration-re-1-no-macro) e 'move)
	    (progn
	      (goto-char (match-end 0))
	      (vpp-backward-syntactic-ws)
	      (if (> (current-column) ind)
		  (setq ind (current-column)))
	      (goto-char (match-end 0)))))
      (if (> ind 0)
	  (1+ ind)
	;; No lineup-string found
	(goto-char b)
	(end-of-line)
	(vpp-backward-syntactic-ws)
	;;(skip-chars-backward " \t")
	(1+ (current-column))))))

(defun vpp-get-lineup-indent-2 (myre b edpos)
  "Return the indent level that will line up several lines within the region."
  (save-excursion
    (let ((ind 0) e)
      (goto-char b)
      ;; Get rightmost position
      (while (progn (setq e (marker-position edpos))
		    (< (point) e))
	(if (and (vpp-re-search-forward myre e 'move)
		 (not (vpp-in-attribute-p))) ;; skip attribute exprs
	    (progn
	      (goto-char (match-beginning 2))
	      (vpp-backward-syntactic-ws)
	      (if (> (current-column) ind)
		  (setq ind (current-column)))
	      (goto-char (match-end 0)))
	  ))
      (if (> ind 0)
	  (1+ ind)
	;; No lineup-string found
	(goto-char b)
	(end-of-line)
	(skip-chars-backward " \t")
	(1+ (current-column))))))

(defun vpp-comment-depth (type val)
  "A useful mode debugging aide.  TYPE and VAL are comments for insertion."
  (save-excursion
    (let
	((b (prog2
		(beginning-of-line)
		(point-marker)
	      (end-of-line)))
	 (e (point-marker)))
      (if (re-search-backward " /\\* \[#-\]# \[a-zA-Z\]+ \[0-9\]+ ## \\*/" b t)
	  (progn
	    (replace-match " /* -#  ## */")
	    (end-of-line))
	(progn
	  (end-of-line)
	  (insert " /* ##  ## */"))))
    (backward-char 6)
    (insert
     (format "%s %d" type val))))

;; 
;;
;; Completion
;;
(defvar vpp-str nil)
(defvar vpp-all nil)
(defvar vpp-pred nil)
(defvar vpp-buffer-to-use nil)
(defvar vpp-flag nil)
(defvar vpp-toggle-completions nil
  "True means \\<vpp-mode-map>\\[vpp-complete-word] should try all possible completions one by one.
Repeated use of \\[vpp-complete-word] will show you all of them.
Normally, when there is more than one possible completion,
it displays a list of all possible completions.")


(defvar vpp-type-keywords
  '(
    "and" "buf" "bufif0" "bufif1" "cmos" "defparam" "inout" "input"
    "integer" "localparam" "logic" "mailbox" "nand" "nmos" "nor" "not" "notif0"
    "notif1" "or" "output" "parameter" "pmos" "pull0" "pull1" "pulldown" "pullup"
    "rcmos" "real" "realtime" "reg" "rnmos" "rpmos" "rtran" "rtranif0"
    "rtranif1" "semaphore" "time" "tran" "tranif0" "tranif1" "tri" "tri0" "tri1"
    "triand" "trior" "trireg" "wand" "wire" "wor" "xnor" "xor"
    )
  "Keywords for types used when completing a word in a declaration or parmlist.
\(integer, real, reg...)")

(defvar vpp-cpp-keywords
  '("module" "defmod" "macromodule" "primitive" "timescale" "define" "ifdef" "ifndef" "else"
    "endif")
  "Keywords to complete when at first word of a line in declarative scope.
\(initial, always, begin, assign...)
The procedures and variables defined within the Vpp program
will be completed at runtime and should not be added to this list.")

(defvar vpp-defun-keywords
  (append
   '(
     "always" "always_comb" "always_ff" "always_latch" "assign"
     "begin" "end" "generate" "endgenerate" "module" "defmod" "endmodule"
     "specify" "endspecify" "function" "endfunction" "initial" "final"
     "task" "endtask" "primitive" "endprimitive"
     )
   vpp-type-keywords)
  "Keywords to complete when at first word of a line in declarative scope.
\(initial, always, begin, assign...)
The procedures and variables defined within the Vpp program
will be completed at runtime and should not be added to this list.")

(defvar vpp-block-keywords
  '(
    "begin" "break" "case" "continue" "else" "end" "endfunction"
    "endgenerate" "endinterface" "endpackage" "endspecify" "endtask"
    "for" "fork" "if" "join" "join_any" "join_none" "repeat" "return"
    "while")
  "Keywords to complete when at first word of a line in behavioral scope.
\(begin, if, then, else, for, fork...)
The procedures and variables defined within the Vpp program
will be completed at runtime and should not be added to this list.")

(defvar vpp-tf-keywords
  '("begin" "break" "fork" "join" "join_any" "join_none" "case" "end" "endtask" "endfunction" "if" "else" "for" "while" "repeat")
  "Keywords to complete when at first word of a line in a task or function.
\(begin, if, then, else, for, fork.)
The procedures and variables defined within the Vpp program
will be completed at runtime and should not be added to this list.")

(defvar vpp-case-keywords
  '("begin" "fork" "join" "join_any" "join_none" "case" "end" "endcase" "if" "else" "for" "repeat")
  "Keywords to complete when at first word of a line in case scope.
\(begin, if, then, else, for, fork...)
The procedures and variables defined within the Vpp program
will be completed at runtime and should not be added to this list.")

(defvar vpp-separator-keywords
  '("else" "then" "begin")
  "Keywords to complete when NOT standing at the first word of a statement.
\(else, then, begin...)
Variables and function names defined within the Vpp program
will be completed at runtime and should not be added to this list.")

(defvar vpp-gate-ios
  ;; All these have an implied {"input"...} at the end
  '(("and"	"output")
    ("buf"	"output")
    ("bufif0"	"output")
    ("bufif1"	"output")
    ("cmos"	"output")
    ("nand"	"output")
    ("nmos"	"output")
    ("nor"	"output")
    ("not"	"output")
    ("notif0"	"output")
    ("notif1"	"output")
    ("or"	"output")
    ("pmos"	"output")
    ("pulldown"	"output")
    ("pullup"	"output")
    ("rcmos"	"output")
    ("rnmos"	"output")
    ("rpmos"	"output")
    ("rtran"	"inout" "inout")
    ("rtranif0"	"inout" "inout")
    ("rtranif1"	"inout" "inout")
    ("tran"	"inout" "inout")
    ("tranif0"	"inout" "inout")
    ("tranif1"	"inout" "inout")
    ("xnor"	"output")
    ("xor"	"output"))
  "Map of direction for each positional argument to each gate primitive.")

(defvar vpp-gate-keywords (mapcar `car vpp-gate-ios)
  "Keywords for gate primitives.")

(defun vpp-string-diff (str1 str2)
  "Return index of first letter where STR1 and STR2 differs."
  (catch 'done
    (let ((diff 0))
      (while t
	(if (or (> (1+ diff) (length str1))
		(> (1+ diff) (length str2)))
	    (throw 'done diff))
	(or (equal (aref str1 diff) (aref str2 diff))
	    (throw 'done diff))
	(setq diff (1+ diff))))))

;; Calculate all possible completions for functions if argument is `function',
;; completions for procedures if argument is `procedure' or both functions and
;; procedures otherwise.

(defun vpp-func-completion (type)
  "Build regular expression for module/task/function names.
TYPE is 'module, 'tf for task or function, or t if unknown."
  (if (string= vpp-str "")
      (setq vpp-str "[a-zA-Z_]"))
  (let ((vpp-str (concat (cond
			     ((eq type 'module) "\\<\\(module\\|defmod\\)\\s +")
			     ((eq type 'tf) "\\<\\(task\\|function\\)\\s +")
			     (t "\\<\\(task\\|function\\|module\\|defmod\\)\\s +"))
			    "\\<\\(" vpp-str "[a-zA-Z0-9_.]*\\)\\>"))
	match)

    (if (not (looking-at vpp-defun-re))
	(vpp-re-search-backward vpp-defun-re nil t))
    (forward-char 1)

    ;; Search through all reachable functions
    (goto-char (point-min))
    (while (vpp-re-search-forward vpp-str (point-max) t)
      (progn (setq match (buffer-substring (match-beginning 2)
					   (match-end 2)))
	     (if (or (null vpp-pred)
		     (funcall vpp-pred match))
		 (setq vpp-all (cons match vpp-all)))))
    (if (match-beginning 0)
	(goto-char (match-beginning 0)))))

(defun vpp-get-completion-decl (end)
  "Macro for searching through current declaration (var, type or const)
for matches of `str' and adding the occurrence tp `all' through point END."
  (let ((re (or (and vpp-indent-declaration-macros
		     vpp-declaration-re-2-macro)
		vpp-declaration-re-2-no-macro))
	decl-end match)
    ;; Traverse lines
    (while (and (< (point) end)
		(vpp-re-search-forward re end t))
      ;; Traverse current line
      (setq decl-end (save-excursion (vpp-declaration-end)))
      (while (and (vpp-re-search-forward vpp-symbol-re decl-end t)
		  (not (match-end 1)))
	(setq match (buffer-substring (match-beginning 0) (match-end 0)))
	(if (string-match (concat "\\<" vpp-str) match)
	    (if (or (null vpp-pred)
		    (funcall vpp-pred match))
		(setq vpp-all (cons match vpp-all)))))
      (forward-line 1)))
  vpp-all)

(defun vpp-type-completion ()
  "Calculate all possible completions for types."
  (let ((start (point))
	goon)
    ;; Search for all reachable type declarations
    (while (or (vpp-beg-of-defun)
	       (setq goon (not goon)))
      (save-excursion
	(if (and (< start (prog1 (save-excursion (vpp-end-of-defun)
						 (point))
			    (forward-char 1)))
		 (vpp-re-search-forward
		  "\\<type\\>\\|\\<\\(begin\\|function\\|procedure\\)\\>"
		  start t)
		 (not (match-end 1)))
	    ;; Check current type declaration
	    (vpp-get-completion-decl start))))))

(defun vpp-var-completion ()
  "Calculate all possible completions for variables (or constants)."
  (let ((start (point)))
    ;; Search for all reachable var declarations
    (vpp-beg-of-defun)
    (save-excursion
      ;; Check var declarations
      (vpp-get-completion-decl start))))

(defun vpp-keyword-completion (keyword-list)
  "Give list of all possible completions of keywords in KEYWORD-LIST."
  (mapcar (lambda (s)
	    (if (string-match (concat "\\<" vpp-str) s)
		(if (or (null vpp-pred)
			(funcall vpp-pred s))
		    (setq vpp-all (cons s vpp-all)))))
	  keyword-list))


(defun vpp-completion (vpp-str vpp-pred vpp-flag)
  "Function passed to `completing-read', `try-completion' or `all-completions'.
Called to get completion on VPP-STR.  If VPP-PRED is non-nil, it
must be a function to be called for every match to check if this should
really be a match.  If VPP-FLAG is t, the function returns a list of
all possible completions.  If VPP-FLAG is nil it returns a string,
the longest possible completion, or t if VPP-STR is an exact match.
If VPP-FLAG is 'lambda, the function returns t if VPP-STR is an
exact match, nil otherwise."
  (save-excursion
    (let ((vpp-all nil))
      ;; Set buffer to use for searching labels. This should be set
      ;; within functions which use vpp-completions
      (set-buffer vpp-buffer-to-use)

      ;; Determine what should be completed
      (let ((state (car (vpp-calculate-indent))))
	(cond ((eq state 'defun)
	       (save-excursion (vpp-var-completion))
	       (vpp-func-completion 'module)
	       (vpp-keyword-completion vpp-defun-keywords))

	      ((eq state 'behavioral)
	       (save-excursion (vpp-var-completion))
	       (vpp-func-completion 'module)
	       (vpp-keyword-completion vpp-defun-keywords))

	      ((eq state 'block)
	       (save-excursion (vpp-var-completion))
	       (vpp-func-completion 'tf)
	       (vpp-keyword-completion vpp-block-keywords))

	      ((eq state 'case)
	       (save-excursion (vpp-var-completion))
	       (vpp-func-completion 'tf)
	       (vpp-keyword-completion vpp-case-keywords))

	      ((eq state 'tf)
	       (save-excursion (vpp-var-completion))
	       (vpp-func-completion 'tf)
	       (vpp-keyword-completion vpp-tf-keywords))

	      ((eq state 'cpp)
	       (save-excursion (vpp-var-completion))
	       (vpp-keyword-completion vpp-cpp-keywords))

	      ((eq state 'cparenexp)
	       (save-excursion (vpp-var-completion)))

	      (t;--Anywhere else
	       (save-excursion (vpp-var-completion))
	       (vpp-func-completion 'both)
	       (vpp-keyword-completion vpp-separator-keywords))))

      ;; Now we have built a list of all matches. Give response to caller
      (vpp-completion-response))))

(defun vpp-completion-response ()
  (cond ((or (equal vpp-flag 'lambda) (null vpp-flag))
	 ;; This was not called by all-completions
	 (if (null vpp-all)
	     ;; Return nil if there was no matching label
	     nil
	   ;; Get longest string common in the labels
	   (let* ((elm (cdr vpp-all))
		  (match (car vpp-all))
		  (min (length match))
		  tmp)
	     (if (string= match vpp-str)
		 ;; Return t if first match was an exact match
		 (setq match t)
	       (while (not (null elm))
		 ;; Find longest common string
		 (if (< (setq tmp (vpp-string-diff match (car elm))) min)
		     (progn
		       (setq min tmp)
		       (setq match (substring match 0 min))))
		 ;; Terminate with match=t if this is an exact match
		 (if (string= (car elm) vpp-str)
		     (progn
		       (setq match t)
		       (setq elm nil))
		   (setq elm (cdr elm)))))
	     ;; If this is a test just for exact match, return nil ot t
	     (if (and (equal vpp-flag 'lambda) (not (equal match 't)))
		 nil
	       match))))
	;; If flag is t, this was called by all-completions. Return
	;; list of all possible completions
	(vpp-flag
	 vpp-all)))

(defvar vpp-last-word-numb 0)
(defvar vpp-last-word-shown nil)
(defvar vpp-last-completions nil)

(defun vpp-complete-word ()
  "Complete word at current point.
\(See also `vpp-toggle-completions', `vpp-type-keywords',
and `vpp-separator-keywords'.)"
  (interactive)
  (let* ((b (save-excursion (skip-chars-backward "a-zA-Z0-9_") (point)))
	 (e (save-excursion (skip-chars-forward "a-zA-Z0-9_") (point)))
	 (vpp-str (buffer-substring b e))
	 ;; The following variable is used in vpp-completion
	 (vpp-buffer-to-use (current-buffer))
	 (allcomp (if (and vpp-toggle-completions
			   (string= vpp-last-word-shown vpp-str))
		      vpp-last-completions
		    (all-completions vpp-str 'vpp-completion)))
	 (match (if vpp-toggle-completions
		    "" (try-completion
			vpp-str (mapcar (lambda (elm)
					      (cons elm 0)) allcomp)))))
    ;; Delete old string
    (delete-region b e)

    ;; Toggle-completions inserts whole labels
    (if vpp-toggle-completions
	(progn
	  ;; Update entry number in list
	  (setq vpp-last-completions allcomp
		vpp-last-word-numb
		(if (>= vpp-last-word-numb (1- (length allcomp)))
		    0
		  (1+ vpp-last-word-numb)))
	  (setq vpp-last-word-shown (elt allcomp vpp-last-word-numb))
	  ;; Display next match or same string if no match was found
	  (if (not (null allcomp))
	      (insert "" vpp-last-word-shown)
	    (insert "" vpp-str)
	    (message "(No match)")))
      ;; The other form of completion does not necessarily do that.

      ;; Insert match if found, or the original string if no match
      (if (or (null match) (equal match 't))
	  (progn (insert "" vpp-str)
		 (message "(No match)"))
	(insert "" match))
      ;; Give message about current status of completion
      (cond ((equal match 't)
	     (if (not (null (cdr allcomp)))
		 (message "(Complete but not unique)")
	       (message "(Sole completion)")))
	    ;; Display buffer if the current completion didn't help
	    ;; on completing the label.
	    ((and (not (null (cdr allcomp))) (= (length vpp-str)
						(length match)))
	     (with-output-to-temp-buffer "*Completions*"
	       (display-completion-list allcomp))
	     ;; Wait for a key press. Then delete *Completion*  window
	     (momentary-string-display "" (point))
	     (delete-window (get-buffer-window (get-buffer "*Completions*")))
	     )))))

(defun vpp-show-completions ()
  "Show all possible completions at current point."
  (interactive)
  (let* ((b (save-excursion (skip-chars-backward "a-zA-Z0-9_") (point)))
	 (e (save-excursion (skip-chars-forward "a-zA-Z0-9_") (point)))
	 (vpp-str (buffer-substring b e))
	 ;; The following variable is used in vpp-completion
	 (vpp-buffer-to-use (current-buffer))
	 (allcomp (if (and vpp-toggle-completions
			   (string= vpp-last-word-shown vpp-str))
		      vpp-last-completions
		    (all-completions vpp-str 'vpp-completion))))
    ;; Show possible completions in a temporary buffer.
    (with-output-to-temp-buffer "*Completions*"
      (display-completion-list allcomp))
    ;; Wait for a key press. Then delete *Completion*  window
    (momentary-string-display "" (point))
    (delete-window (get-buffer-window (get-buffer "*Completions*")))))


(defun vpp-get-default-symbol ()
  "Return symbol around current point as a string."
  (save-excursion
    (buffer-substring (progn
			(skip-chars-backward " \t")
			(skip-chars-backward "a-zA-Z0-9_")
			(point))
		      (progn
			(skip-chars-forward "a-zA-Z0-9_")
			(point)))))

(defun vpp-build-defun-re (str &optional arg)
  "Return function/task/module starting with STR as regular expression.
With optional second ARG non-nil, STR is the complete name of the instruction."
  (if arg
      (concat "^\\(function\\|task\\|module\\|defmod\\)[ \t]+\\(" str "\\)\\>")
    (concat "^\\(function\\|task\\|module\\|defmod\\)[ \t]+\\(" str "[a-zA-Z0-9_]*\\)\\>")))

(defun vpp-comp-defun (vpp-str vpp-pred vpp-flag)
  "Function passed to `completing-read', `try-completion' or `all-completions'.
Returns a completion on any function name based on VPP-STR prefix.  If
VPP-PRED is non-nil, it must be a function to be called for every match
to check if this should really be a match.  If VPP-FLAG is t, the
function returns a list of all possible completions.  If it is nil it
returns a string, the longest possible completion, or t if VPP-STR is
an exact match.  If VPP-FLAG is 'lambda, the function returns t if
VPP-STR is an exact match, nil otherwise."
  (save-excursion
    (let ((vpp-all nil)
	  match)

      ;; Set buffer to use for searching labels. This should be set
      ;; within functions which use vpp-completions
      (set-buffer vpp-buffer-to-use)

      (let ((vpp-str vpp-str))
	;; Build regular expression for functions
	(if (string= vpp-str "")
	    (setq vpp-str (vpp-build-defun-re "[a-zA-Z_]"))
	  (setq vpp-str (vpp-build-defun-re vpp-str)))
	(goto-char (point-min))

	;; Build a list of all possible completions
	(while (vpp-re-search-forward vpp-str nil t)
	  (setq match (buffer-substring (match-beginning 2) (match-end 2)))
	  (if (or (null vpp-pred)
		  (funcall vpp-pred match))
	      (setq vpp-all (cons match vpp-all)))))

      ;; Now we have built a list of all matches. Give response to caller
      (vpp-completion-response))))

(defun vpp-goto-defun ()
  "Move to specified Vpp module/interface/task/function.
The default is a name found in the buffer around point.
If search fails, other files are checked based on
`vpp-library-flags'."
  (interactive)
  (let* ((default (vpp-get-default-symbol))
	 ;; The following variable is used in vpp-comp-function
	 (vpp-buffer-to-use (current-buffer))
	 (label (if (not (string= default ""))
		    ;; Do completion with default
		    (completing-read (concat "Goto-Label: (default "
					     default ") ")
				     'vpp-comp-defun nil nil "")
		  ;; There is no default value. Complete without it
		  (completing-read "Goto-Label: "
				   'vpp-comp-defun nil nil "")))
	 pt)
    ;; Make sure library paths are correct, in case need to resolve module
    (vpp-auto-reeval-locals)
    (vpp-getopt-flags)
    ;; If there was no response on prompt, use default value
    (if (string= label "")
	(setq label default))
    ;; Goto right place in buffer if label is not an empty string
    (or (string= label "")
	(progn
	  (save-excursion
	    (goto-char (point-min))
	    (setq pt
		  (re-search-forward (vpp-build-defun-re label t) nil t)))
	  (when pt
	    (goto-char pt)
	    (beginning-of-line))
	  pt)
	(vpp-goto-defun-file label))))

;; Eliminate compile warning
(defvar occur-pos-list)

(defun vpp-showscopes ()
  "List all scopes in this module."
  (interactive)
  (let ((buffer (current-buffer))
	(linenum 1)
	(nlines 0)
	(first 1)
	(prevpos (point-min))
        (final-context-start (make-marker))
	(regexp "\\(module\\s-+\\w+\\s-*(\\)\\|\\(\\w+\\s-+\\w+\\s-*(\\)"))
    (with-output-to-temp-buffer "*Occur*"
      (save-excursion
	(message (format "Searching for %s ..." regexp))
	;; Find next match, but give up if prev match was at end of buffer.
	(while (and (not (= prevpos (point-max)))
		    (vpp-re-search-forward regexp nil t))
	  (goto-char (match-beginning 0))
	  (beginning-of-line)
	  (save-match-data
            (setq linenum (+ linenum (count-lines prevpos (point)))))
	  (setq prevpos (point))
	  (goto-char (match-end 0))
	  (let* ((start (save-excursion
			  (goto-char (match-beginning 0))
			  (forward-line (if (< nlines 0) nlines (- nlines)))
			  (point)))
		 (end (save-excursion
			(goto-char (match-end 0))
			(if (> nlines 0)
			    (forward-line (1+ nlines))
			    (forward-line 1))
			(point)))
		 (tag (format "%3d" linenum))
		 (empty (make-string (length tag) ?\ ))
		 tem)
	    (save-excursion
	      (setq tem (make-marker))
	      (set-marker tem (point))
	      (set-buffer standard-output)
	      (setq occur-pos-list (cons tem occur-pos-list))
	      (or first (zerop nlines)
		  (insert "--------\n"))
	      (setq first nil)
	      (insert-buffer-substring buffer start end)
	      (backward-char (- end start))
	      (setq tem (if (< nlines 0) (- nlines) nlines))
	      (while (> tem 0)
		(insert empty ?:)
		(forward-line 1)
		(setq tem (1- tem)))
	      (let ((this-linenum linenum))
		(set-marker final-context-start
			    (+ (point) (- (match-end 0) (match-beginning 0))))
		(while (< (point) final-context-start)
		  (if (null tag)
		      (setq tag (format "%3d" this-linenum)))
		  (insert tag ?:)))))))
      (set-buffer-modified-p nil))))


;; Highlight helper functions
(defconst vpp-directive-regexp "\\(translate\\|coverage\\|lint\\)_")
(defun vpp-within-translate-off ()
  "Return point if within translate-off region, else nil."
  (and (save-excursion
	 (re-search-backward
	  (concat "//\\s-*.*\\s-*" vpp-directive-regexp "\\(on\\|off\\)\\>")
	  nil t))
       (equal "off" (match-string 2))
       (point)))

(defun vpp-start-translate-off (limit)
  "Return point before translate-off directive if before LIMIT, else nil."
  (when (re-search-forward
	  (concat "//\\s-*.*\\s-*" vpp-directive-regexp "off\\>")
	  limit t)
    (match-beginning 0)))

(defun vpp-back-to-start-translate-off (limit)
  "Return point before translate-off directive if before LIMIT, else nil."
  (when (re-search-backward
	  (concat "//\\s-*.*\\s-*" vpp-directive-regexp "off\\>")
	  limit t)
    (match-beginning 0)))

(defun vpp-end-translate-off (limit)
  "Return point after translate-on directive if before LIMIT, else nil."

  (re-search-forward (concat
		      "//\\s-*.*\\s-*" vpp-directive-regexp "on\\>") limit t))

(defun vpp-match-translate-off (limit)
  "Match a translate-off block, setting `match-data' and returning t, else nil.
Bound search by LIMIT."
  (when (< (point) limit)
    (let ((start (or (vpp-within-translate-off)
		     (vpp-start-translate-off limit)))
	  (case-fold-search t))
      (when start
	(let ((end (or (vpp-end-translate-off limit) limit)))
	  (set-match-data (list start end))
	  (goto-char end))))))

(defun vpp-font-lock-match-item (limit)
  "Match, and move over, any declaration item after point.
Bound search by LIMIT.  Adapted from
`font-lock-match-c-style-declaration-item-and-skip-to-next'."
  (condition-case nil
      (save-restriction
	(narrow-to-region (point-min) limit)
	;; match item
	(when (looking-at "\\s-*\\([a-zA-Z]\\w*\\)")
	  (save-match-data
	    (goto-char (match-end 1))
	    ;; move to next item
	    (if (looking-at "\\(\\s-*,\\)")
		(goto-char (match-end 1))
	      (end-of-line) t))))
    (error nil)))


;; Added by Subbu Meiyappan for Header

(defun vpp-header ()
  "Insert a standard Vpp file header.
See also `vpp-sk-header' for an alternative format."
  (interactive)
  (let ((start (point)))
  (insert "\
//-----------------------------------------------------------------------------
// Title         : <title>
// Project       : <project>
//-----------------------------------------------------------------------------
// File          : <filename>
// Author        : <author>
// Created       : <credate>
// Last modified : <moddate>
//-----------------------------------------------------------------------------
// Description :
// <description>
//-----------------------------------------------------------------------------
// Copyright (c) <copydate> by <company> This model is the confidential and
// proprietary property of <company> and the possession or use of this
// file requires a written license from <company>.
//------------------------------------------------------------------------------
// Modification history :
// <modhist>
//-----------------------------------------------------------------------------

")
    (goto-char start)
    (search-forward "<filename>")
    (replace-match (buffer-name) t t)
    (search-forward "<author>") (replace-match "" t t)
    (insert (user-full-name))
    (insert "  <" (user-login-name) "@" (system-name) ">")
    (search-forward "<credate>") (replace-match "" t t)
    (vpp-insert-date)
    (search-forward "<moddate>") (replace-match "" t t)
    (vpp-insert-date)
    (search-forward "<copydate>") (replace-match "" t t)
    (vpp-insert-year)
    (search-forward "<modhist>") (replace-match "" t t)
    (vpp-insert-date)
    (insert " : created")
    (goto-char start)
    (let (string)
      (setq string (read-string "title: "))
      (search-forward "<title>")
      (replace-match string t t)
      (setq string (read-string "project: " vpp-project))
      (setq vpp-project string)
      (search-forward "<project>")
      (replace-match string t t)
      (setq string (read-string "Company: " vpp-company))
      (setq vpp-company string)
      (search-forward "<company>")
      (replace-match string t t)
      (search-forward "<company>")
      (replace-match string t t)
      (search-forward "<company>")
      (replace-match string t t)
      (search-backward "<description>")
      (replace-match "" t t))))

;; vpp-header Uses the vpp-insert-date function

(defun vpp-insert-date ()
  "Insert date from the system."
  (interactive)
  (if vpp-date-scientific-format
      (insert (format-time-string "%Y/%m/%d"))
    (insert (format-time-string "%d.%m.%Y"))))

(defun vpp-insert-year ()
  "Insert year from the system."
  (interactive)
  (insert (format-time-string "%Y")))


;;
;; Signal list parsing
;;

;; Elements of a signal list
;; Unfortunately we use 'assoc' on this, so can't be a vector
(defsubst vpp-sig-new (name bits comment mem enum signed type multidim modport)
  (list name bits comment mem enum signed type multidim modport))
(defsubst vpp-sig-name (sig)
  (car sig))
(defsubst vpp-sig-bits (sig)
  (nth 1 sig))
(defsubst vpp-sig-comment (sig)
  (nth 2 sig))
(defsubst vpp-sig-memory (sig)
  (nth 3 sig))
(defsubst vpp-sig-enum (sig)
  (nth 4 sig))
(defsubst vpp-sig-signed (sig)
  (nth 5 sig))
(defsubst vpp-sig-type (sig)
  (nth 6 sig))
(defsubst vpp-sig-type-set (sig type)
  (setcar (nthcdr 6 sig) type))
(defsubst vpp-sig-multidim (sig)
  (nth 7 sig))
(defsubst vpp-sig-multidim-string (sig)
  (if (vpp-sig-multidim sig)
      (let ((str "") (args (vpp-sig-multidim sig)))
	(while args
	  (setq str (concat str (car args)))
	  (setq args (cdr args)))
	str)))
(defsubst vpp-sig-modport (sig)
  (nth 8 sig))
(defsubst vpp-sig-width (sig)
  (vpp-make-width-expression (vpp-sig-bits sig)))

(defsubst vpp-alw-new (outputs-del outputs-imm temps inputs)
  (vector outputs-del outputs-imm temps inputs))
(defsubst vpp-alw-get-outputs-delayed (sigs)
  (aref sigs 0))
(defsubst vpp-alw-get-outputs-immediate (sigs)
  (aref sigs 1))
(defsubst vpp-alw-get-temps (sigs)
  (aref sigs 2))
(defsubst vpp-alw-get-inputs (sigs)
  (aref sigs 3))
(defsubst vpp-alw-get-uses-delayed (sigs)
  (aref sigs 0))

(defsubst vpp-modport-new (name clockings decls)
  (list name clockings decls))
(defsubst vpp-modport-name (sig)
  (car sig))
(defsubst vpp-modport-clockings (sig)
  (nth 1 sig)) ;; Returns list of names
(defsubst vpp-modport-clockings-add (sig val)
  (setcar (nthcdr 1 sig) (cons val (nth 1 sig))))
(defsubst vpp-modport-decls (sig)
  (nth 2 sig)) ;; Returns vpp-decls-* structure
(defsubst vpp-modport-decls-set (sig val)
  (setcar (nthcdr 2 sig) val))

(defsubst vpp-modi-new (name fob pt type)
  (vector name fob pt type))
(defsubst vpp-modi-name (modi)
  (aref modi 0))
(defsubst vpp-modi-file-or-buffer (modi)
  (aref modi 1))
(defsubst vpp-modi-get-point (modi)
  (aref modi 2))
(defsubst vpp-modi-get-type (modi) ;; "module" or "interface"
  (aref modi 3))
(defsubst vpp-modi-get-decls (modi)
  (vpp-modi-cache-results modi 'vpp-read-decls))
(defsubst vpp-modi-get-sub-decls (modi)
  (vpp-modi-cache-results modi 'vpp-read-sub-decls))

;; Signal reading for given module
;; Note these all take modi's - as returned from vpp-modi-current
(defsubst vpp-decls-new (out inout in vars modports assigns consts gparams interfaces)
  (vector out inout in vars modports assigns consts gparams interfaces))
(defsubst vpp-decls-append (a b)
  (cond ((not a) b) ((not b) a)
	(t (vector (append (aref a 0) (aref b 0))   (append (aref a 1) (aref b 1))
		   (append (aref a 2) (aref b 2))   (append (aref a 3) (aref b 3))
		   (append (aref a 4) (aref b 4))   (append (aref a 5) (aref b 5))
		   (append (aref a 6) (aref b 6))   (append (aref a 7) (aref b 7))
		   (append (aref a 8) (aref b 8))))))
(defsubst vpp-decls-get-outputs (decls)
  (aref decls 0))
(defsubst vpp-decls-get-inouts (decls)
  (aref decls 1))
(defsubst vpp-decls-get-inputs (decls)
  (aref decls 2))
(defsubst vpp-decls-get-vars (decls)
  (aref decls 3))
(defsubst vpp-decls-get-modports (decls) ;; Also for clocking blocks; contains another vpp-decls struct
  (aref decls 4))  ;; Returns vpp-modport* structure
(defsubst vpp-decls-get-assigns (decls)
  (aref decls 5))
(defsubst vpp-decls-get-consts (decls)
  (aref decls 6))
(defsubst vpp-decls-get-gparams (decls)
  (aref decls 7))
(defsubst vpp-decls-get-interfaces (decls)
  (aref decls 8))


(defsubst vpp-subdecls-new (out inout in intf intfd)
  (vector out inout in intf intfd))
(defsubst vpp-subdecls-get-outputs (subdecls)
  (aref subdecls 0))
(defsubst vpp-subdecls-get-inouts (subdecls)
  (aref subdecls 1))
(defsubst vpp-subdecls-get-inputs (subdecls)
  (aref subdecls 2))
(defsubst vpp-subdecls-get-interfaces (subdecls)
  (aref subdecls 3))
(defsubst vpp-subdecls-get-interfaced (subdecls)
  (aref subdecls 4))

(defun vpp-signals-from-signame (signame-list)
  "Return signals in standard form from SIGNAME-LIST, a simple list of names."
  (mapcar (lambda (name) (vpp-sig-new name nil nil nil nil nil nil nil nil))
	  signame-list))

(defun vpp-signals-in (in-list not-list)
  "Return list of signals in IN-LIST that are also in NOT-LIST.
Also remove any duplicates in IN-LIST.
Signals must be in standard (base vector) form."
  ;; This function is hot, so implemented as O(1)
  (cond ((eval-when-compile (fboundp 'make-hash-table))
	 (let ((ht (make-hash-table :test 'equal :rehash-size 4.0))
	       (ht-not (make-hash-table :test 'equal :rehash-size 4.0))
	       out-list)
	   (while not-list
	     (puthash (car (car not-list)) t ht-not)
	     (setq not-list (cdr not-list)))
	   (while in-list
	     (when (and (gethash (vpp-sig-name (car in-list)) ht-not)
			(not (gethash (vpp-sig-name (car in-list)) ht)))
	       (setq out-list (cons (car in-list) out-list))
	       (puthash (vpp-sig-name (car in-list)) t ht))
	     (setq in-list (cdr in-list)))
	   (nreverse out-list)))
	;; Slower Fallback if no hash tables (pre Emacs 21.1/XEmacs 21.4)
	(t
	 (let (out-list)
	   (while in-list
	     (if (and (assoc (vpp-sig-name (car in-list)) not-list)
		      (not (assoc (vpp-sig-name (car in-list)) out-list)))
		 (setq out-list (cons (car in-list) out-list)))
	     (setq in-list (cdr in-list)))
	   (nreverse out-list)))))
;;(vpp-signals-in '(("A" "") ("B" "") ("DEL" "[2:3]")) '(("DEL" "") ("C" "")))

(defun vpp-signals-not-in (in-list not-list)
  "Return list of signals in IN-LIST that aren't also in NOT-LIST.
Also remove any duplicates in IN-LIST.
Signals must be in standard (base vector) form."
  ;; This function is hot, so implemented as O(1)
  (cond ((eval-when-compile (fboundp 'make-hash-table))
	 (let ((ht (make-hash-table :test 'equal :rehash-size 4.0))
	       out-list)
	   (while not-list
	     (puthash (car (car not-list)) t ht)
	     (setq not-list (cdr not-list)))
	   (while in-list
	     (when (not (gethash (vpp-sig-name (car in-list)) ht))
	       (setq out-list (cons (car in-list) out-list))
	       (puthash (vpp-sig-name (car in-list)) t ht))
	     (setq in-list (cdr in-list)))
	   (nreverse out-list)))
	;; Slower Fallback if no hash tables (pre Emacs 21.1/XEmacs 21.4)
	(t
	 (let (out-list)
	   (while in-list
	     (if (and (not (assoc (vpp-sig-name (car in-list)) not-list))
		      (not (assoc (vpp-sig-name (car in-list)) out-list)))
		 (setq out-list (cons (car in-list) out-list)))
	     (setq in-list (cdr in-list)))
	   (nreverse out-list)))))
;;(vpp-signals-not-in '(("A" "") ("B" "") ("DEL" "[2:3]")) '(("DEL" "") ("EXT" "")))

(defun vpp-signals-memory (in-list)
  "Return list of signals in IN-LIST that are memorized (multidimensional)."
  (let (out-list)
    (while in-list
      (if (nth 3 (car in-list))
	  (setq out-list (cons (car in-list) out-list)))
      (setq in-list (cdr in-list)))
    out-list))
;;(vpp-signals-memory '(("A" nil nil "[3:0]")) '(("B" nil nil nil)))

(defun vpp-signals-sort-compare (a b)
  "Compare signal A and B for sorting."
  (string< (vpp-sig-name a) (vpp-sig-name b)))

(defun vpp-signals-not-params (in-list)
  "Return list of signals in IN-LIST that aren't parameters or numeric constants."
  (let (out-list)
    (while in-list
      (unless (boundp (intern (concat "vh-" (vpp-sig-name (car in-list)))))
	(setq out-list (cons (car in-list) out-list)))
      (setq in-list (cdr in-list)))
    (nreverse out-list)))

(defun vpp-signals-with (func in-list)
  "Return IN-LIST with only signals where FUNC passed each signal is true."
  (let (out-list)
    (while in-list
      (when (funcall func (car in-list))
	(setq out-list (cons (car in-list) out-list)))
      (setq in-list (cdr in-list)))
    (nreverse out-list)))

(defun vpp-signals-combine-bus (in-list)
  "Return a list of signals in IN-LIST, with buses combined.
Duplicate signals are also removed.  For example A[2] and A[1] become A[2:1]."
  (let (combo buswarn
	out-list
	sig highbit lowbit		; Temp information about current signal
	sv-name sv-highbit sv-lowbit	; Details about signal we are forming
	sv-comment sv-memory sv-enum sv-signed sv-type sv-multidim sv-busstring
	sv-modport
	bus)
    ;; Shove signals so duplicated signals will be adjacent
    (setq in-list (sort in-list `vpp-signals-sort-compare))
    (while in-list
      (setq sig (car in-list))
      ;; No current signal; form from existing details
      (unless sv-name
	(setq sv-name    (vpp-sig-name sig)
	      sv-highbit nil
	      sv-busstring nil
	      sv-comment (vpp-sig-comment sig)
	      sv-memory  (vpp-sig-memory sig)
	      sv-enum    (vpp-sig-enum sig)
	      sv-signed  (vpp-sig-signed sig)
	      sv-type    (vpp-sig-type sig)
	      sv-multidim (vpp-sig-multidim sig)
	      sv-modport  (vpp-sig-modport sig)
	      combo ""
	      buswarn ""))
      ;; Extract bus details
      (setq bus (vpp-sig-bits sig))
      (setq bus (and bus (vpp-simplify-range-expression bus)))
      (cond ((and bus
		  (or (and (string-match "\\[\\([0-9]+\\):\\([0-9]+\\)\\]" bus)
			   (setq highbit (string-to-number (match-string 1 bus))
				 lowbit  (string-to-number
					  (match-string 2 bus))))
		      (and (string-match "\\[\\([0-9]+\\)\\]" bus)
			   (setq highbit (string-to-number (match-string 1 bus))
				 lowbit  highbit))))
	     ;; Combine bits in bus
	     (if sv-highbit
		 (setq sv-highbit (max highbit sv-highbit)
		       sv-lowbit  (min lowbit  sv-lowbit))
	       (setq sv-highbit highbit
		     sv-lowbit  lowbit)))
	    (bus
	     ;; String, probably something like `preproc:0
	     (setq sv-busstring bus)))
      ;; Peek ahead to next signal
      (setq in-list (cdr in-list))
      (setq sig (car in-list))
      (cond ((and sig (equal sv-name (vpp-sig-name sig)))
	     ;; Combine with this signal
	     (when (and sv-busstring
			(not (equal sv-busstring (vpp-sig-bits sig))))
	       (when nil  ;; Debugging
		 (message (concat "Warning, can't merge into single bus "
				  sv-name bus
				  ", the AUTOs may be wrong")))
	       (setq buswarn ", Couldn't Merge"))
	     (if (vpp-sig-comment sig) (setq combo ", ..."))
	     (setq sv-memory (or sv-memory (vpp-sig-memory sig))
		   sv-enum   (or sv-enum   (vpp-sig-enum sig))
		   sv-signed (or sv-signed (vpp-sig-signed sig))
                   sv-type   (or sv-type   (vpp-sig-type sig))
                   sv-multidim (or sv-multidim (vpp-sig-multidim sig))
                   sv-modport  (or sv-modport  (vpp-sig-modport sig))))
	    ;; Doesn't match next signal, add to queue, zero in prep for next
	    ;; Note sig may also be nil for the last signal in the list
	    (t
	     (setq out-list
		   (cons (vpp-sig-new
			  sv-name
			  (or sv-busstring
			      (if sv-highbit
				  (concat "[" (int-to-string sv-highbit) ":"
					  (int-to-string sv-lowbit) "]")))
			  (concat sv-comment combo buswarn)
			  sv-memory sv-enum sv-signed sv-type sv-multidim sv-modport)
			 out-list)
		   sv-name nil))))
    ;;
    out-list))

(defun vpp-sig-tieoff (sig)
  "Return tieoff expression for given SIG, with appropriate width.
Tieoff value uses `vpp-active-low-regexp' and
`vpp-auto-reset-widths'."
  (concat
   (if (and vpp-active-low-regexp
	    (string-match vpp-active-low-regexp (vpp-sig-name sig)))
       "~" "")
   (cond ((not vpp-auto-reset-widths)
	  "0")
	 ((equal vpp-auto-reset-widths 'unbased)
	  "'0")
	 ;; Else presume vpp-auto-reset-widths is true
	 (t
	  (let* ((width (vpp-sig-width sig)))
	    (cond ((not width)
		   "`0/*NOWIDTH*/")
		  ((string-match "^[0-9]+$" width)
		   (concat width (if (vpp-sig-signed sig) "'sh0" "'h0")))
		  (t
		   (concat "{" width "{1'b0}}"))))))))

;;
;; Dumping
;;

(defun vpp-decls-princ (decls &optional header prefix)
  "For debug, dump the `vpp-read-decls' structure DECLS."
  (when decls
    (if header (princ header))
    (setq prefix (or prefix ""))
    (vpp-signals-princ (vpp-decls-get-outputs decls)
			   (concat prefix "Outputs:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-inouts decls)
			   (concat prefix "Inout:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-inputs decls)
			   (concat prefix "Inputs:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-vars decls)
			   (concat prefix "Vars:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-assigns decls)
			   (concat prefix "Assigns:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-consts decls)
			   (concat prefix "Consts:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-gparams decls)
			   (concat prefix "Gparams:\n") (concat prefix "  "))
    (vpp-signals-princ (vpp-decls-get-interfaces decls)
			   (concat prefix "Interfaces:\n") (concat prefix "  "))
    (vpp-modport-princ (vpp-decls-get-modports decls)
			   (concat prefix "Modports:\n") (concat prefix "  "))
    (princ "\n")))

(defun vpp-signals-princ (signals &optional header prefix)
  "For debug, dump internal SIGNALS structures, with HEADER and PREFIX."
  (when signals
    (if header (princ header))
    (while signals
      (let ((sig (car signals)))
	(setq signals (cdr signals))
	(princ prefix)
	(princ "\"") (princ (vpp-sig-name sig)) (princ "\"")
	(princ "  bits=") (princ (vpp-sig-bits sig))
	(princ "  cmt=") (princ (vpp-sig-comment sig))
	(princ "  mem=") (princ (vpp-sig-memory sig))
	(princ "  enum=") (princ (vpp-sig-enum sig))
	(princ "  sign=") (princ (vpp-sig-signed sig))
	(princ "  type=") (princ (vpp-sig-type sig))
	(princ "  dim=") (princ (vpp-sig-multidim sig))
	(princ "  modp=") (princ (vpp-sig-modport sig))
	(princ "\n")))))

(defun vpp-modport-princ (modports &optional header prefix)
  "For debug, dump internal MODPORT structures, with HEADER and PREFIX."
  (when modports
    (if header (princ header))
    (while modports
      (let ((sig (car modports)))
	(setq modports (cdr modports))
	(princ prefix)
	(princ "\"") (princ (vpp-modport-name sig)) (princ "\"")
	(princ "  clockings=") (princ (vpp-modport-clockings sig))
	(princ "\n")
	(vpp-decls-princ (vpp-modport-decls sig)
			     (concat prefix "  syms:\n")
			     (concat prefix "    "))))))

;;
;; Port/Wire/Etc Reading
;;

(defun vpp-read-inst-backward-name ()
  "Internal.  Move point back to beginning of inst-name."
    (vpp-backward-open-paren)
    (let (done)
      (while (not done)
	(vpp-re-search-backward-quick "\\()\\|\\b[a-zA-Z0-9`_\$]\\|\\]\\)" nil nil)  ; ] isn't word boundary
	(cond ((looking-at ")")
	       (vpp-backward-open-paren))
	      (t (setq done t)))))
    (while (looking-at "\\]")
      (vpp-backward-open-bracket)
      (vpp-re-search-backward-quick "\\(\\b[a-zA-Z0-9`_\$]\\|\\]\\)" nil nil))
    (skip-chars-backward "a-zA-Z0-9`_$"))

(defun vpp-read-inst-module-matcher ()
  "Set match data 0 with module_name when point is inside instantiation."
  (vpp-read-inst-backward-name)
  ;; Skip over instantiation name
  (vpp-re-search-backward-quick "\\(\\b[a-zA-Z0-9`_\$]\\|)\\)" nil nil)  ; ) isn't word boundary
  ;; Check for parameterized instantiations
  (when (looking-at ")")
    (vpp-backward-open-paren)
    (vpp-re-search-backward-quick "\\b[a-zA-Z0-9`_\$]" nil nil))
  (skip-chars-backward "a-zA-Z0-9'_$")
  (looking-at "[a-zA-Z0-9`_\$]+")
  ;; Important: don't use match string, this must work with Emacs 19 font-lock on
  (buffer-substring-no-properties (match-beginning 0) (match-end 0))
  ;; Caller assumes match-beginning/match-end is still set
  )

(defun vpp-read-inst-module ()
  "Return module_name when point is inside instantiation."
  (save-excursion
    (vpp-read-inst-module-matcher)))

(defun vpp-read-inst-name ()
  "Return instance_name when point is inside instantiation."
  (save-excursion
    (vpp-read-inst-backward-name)
    (looking-at "[a-zA-Z0-9`_\$]+")
    ;; Important: don't use match string, this must work with Emacs 19 font-lock on
    (buffer-substring-no-properties (match-beginning 0) (match-end 0))))

(defun vpp-read-module-name ()
  "Return module name when after its ( or ;."
  (save-excursion
    (re-search-backward "[(;]")
    ;; Due to "module x import y (" we must search for declaration begin
    (vpp-re-search-backward-quick vpp-defun-re nil nil)
    (goto-char (match-end 0))
    (vpp-re-search-forward-quick "\\b[a-zA-Z0-9`_\$]+" nil nil)
    ;; Important: don't use match string, this must work with Emacs 19 font-lock on
    (vpp-symbol-detick
     (buffer-substring-no-properties (match-beginning 0) (match-end 0)) t)))

(defun vpp-read-inst-param-value ()
  "Return list of parameters and values when point is inside instantiation."
  (save-excursion
    (vpp-read-inst-backward-name)
    ;; Skip over instantiation name
    (vpp-re-search-backward-quick "\\(\\b[a-zA-Z0-9`_\$]\\|)\\)" nil nil)  ; ) isn't word boundary
    ;; If there are parameterized instantiations
    (when (looking-at ")")
      (let ((end-pt (point))
	    params
	    param-name paren-beg-pt param-value)
	(vpp-backward-open-paren)
	(while (vpp-re-search-forward-quick "\\." end-pt t)
	  (vpp-re-search-forward-quick "\\([a-zA-Z0-9`_\$]\\)" nil nil)
	  (skip-chars-backward "a-zA-Z0-9'_$")
	  (looking-at "[a-zA-Z0-9`_\$]+")
	  (setq param-name (buffer-substring-no-properties
			    (match-beginning 0) (match-end 0)))
	  (vpp-re-search-forward-quick "(" nil nil)
	  (setq paren-beg-pt (point))
	  (vpp-forward-close-paren)
	  (setq param-value (vpp-string-remove-spaces
			     (buffer-substring-no-properties
			      paren-beg-pt (1- (point)))))
	  (setq params (cons (list param-name param-value) params)))
	params))))

(defun vpp-read-auto-params (num-param &optional max-param)
  "Return parameter list inside auto.
Optional NUM-PARAM and MAX-PARAM check for a specific number of parameters."
  (let ((olist))
    (save-excursion
      ;; /*AUTOPUNT("parameter", "parameter")*/
      (backward-sexp 1)
      (while (looking-at "(?\\s *\"\\([^\"]*\\)\"\\s *,?")
	(setq olist (cons (match-string 1) olist))
	(goto-char (match-end 0))))
    (or (eq nil num-param)
	(<= num-param (length olist))
	(error "%s: Expected %d parameters" (vpp-point-text) num-param))
    (if (eq max-param nil) (setq max-param num-param))
    (or (eq nil max-param)
	(>= max-param (length olist))
	(error "%s: Expected <= %d parameters" (vpp-point-text) max-param))
    (nreverse olist)))

(defun vpp-read-decls ()
  "Compute signal declaration information for the current module at point.
Return an array of [outputs inouts inputs wire reg assign const]."
  (let ((end-mod-point (or (vpp-get-end-of-defun t) (point-max)))
	(functask 0) (paren 0) (sig-paren 0) (v2kargs-ok t)
	in-modport in-clocking ptype ign-prop
	sigs-in sigs-out sigs-inout sigs-var sigs-assign sigs-const
	sigs-gparam sigs-intf sigs-modports
	vec expect-signal keywd newsig rvalue enum io signed typedefed multidim
	modport
	varstack tmp)
    ;;(if dbg (setq dbg (concat dbg (format "\n\nvpp-read-decls START PT %s END %s\n" (point) end-mod-point))))
    (save-excursion
      (vpp-beg-of-defun-quick)
      (setq sigs-const (vpp-read-auto-constants (point) end-mod-point))
      (while (< (point) end-mod-point)
	;;(if dbg (setq dbg (concat dbg (format "Pt %s  Vec %s   C%c Kwd'%s'\n" (point) vec (following-char) keywd))))
	(cond
	 ((looking-at "//")
	  (if (looking-at "[^\n]*\\(auto\\|synopsys\\)\\s +enum\\s +\\([a-zA-Z0-9_]+\\)")
	      (setq enum (match-string 2)))
	  (search-forward "\n"))
	 ((looking-at "/\\*")
	  (forward-char 2)
	  (if (looking-at "[^\n]*\\(auto\\|synopsys\\)\\s +enum\\s +\\([a-zA-Z0-9_]+\\)")
	      (setq enum (match-string 2)))
	  (or (search-forward "*/")
	      (error "%s: Unmatched /* */, at char %d" (vpp-point-text) (point))))
	 ((looking-at "(\\*")
	  ;; To advance past either "(*)" or "(* ... *)" don't forward past first *
	  (forward-char 1)
	  (or (search-forward "*)")
	      (error "%s: Unmatched (* *), at char %d" (vpp-point-text) (point))))
	 ((eq ?\" (following-char))
	  (or (re-search-forward "[^\\]\"" nil t)	;; don't forward-char first, since we look for a non backslash first
	      (error "%s: Unmatched quotes, at char %d" (vpp-point-text) (point))))
	 ((eq ?\; (following-char))
	  (when (and in-modport (not (eq in-modport t))) ;; end of a modport declaration
	    (vpp-modport-decls-set
	     in-modport
	     (vpp-decls-new sigs-out sigs-inout sigs-in
				nil nil nil nil nil nil))
	    ;; Pop from varstack to restore state to pre-clocking
	    (setq tmp (car varstack)
		  varstack (cdr varstack)
		  sigs-out (aref tmp 0)
		  sigs-inout (aref tmp 1)
		  sigs-in (aref tmp 2)))
	  (setq vec nil  io nil  expect-signal nil  newsig nil  paren 0  rvalue nil
		v2kargs-ok nil  in-modport nil  ign-prop nil)
	  (forward-char 1))
	 ((eq ?= (following-char))
	  (setq rvalue t  newsig nil)
	  (forward-char 1))
	 ((and (eq ?, (following-char))
	       (eq paren sig-paren))
	  (setq rvalue nil)
	  (forward-char 1))
	 ;; ,'s can occur inside {} & funcs
	 ((looking-at "[{(]")
	  (setq paren (1+ paren))
	  (forward-char 1))
	 ((looking-at "[})]")
	  (setq paren (1- paren))
	  (forward-char 1)
	  (when (< paren sig-paren)
	    (setq expect-signal nil rvalue nil)))   ; ) that ends variables inside v2k arg list
	 ((looking-at "\\s-*\\(\\[[^]]+\\]\\)")
	  (goto-char (match-end 0))
	  (cond (newsig	; Memory, not just width.  Patch last signal added's memory (nth 3)
		 (setcar (cdr (cdr (cdr newsig)))
			 (if (vpp-sig-memory newsig)
			     (concat (vpp-sig-memory newsig) (match-string 1))
			   (match-string 1))))
		(vec ;; Multidimensional
		 (setq multidim (cons vec multidim))
		 (setq vec (vpp-string-replace-matches
			    "\\s-+" "" nil nil (match-string 1))))
		(t ;; Bit width
		 (setq vec (vpp-string-replace-matches
			    "\\s-+" "" nil nil (match-string 1))))))
	 ;; Normal or escaped identifier -- note we remember the \ if escaped
	 ((looking-at "\\s-*\\([a-zA-Z0-9`_$]+\\|\\\\[^ \t\n\f]+\\)")
	  (goto-char (match-end 0))
	  (setq keywd (match-string 1))
	  (when (string-match "^\\\\" (match-string 1))
	    (setq keywd (concat keywd " ")))  ;; Escaped ID needs space at end
	  ;; Add any :: package names to same identifier
	  (while (looking-at "\\s-*::\\s-*\\([a-zA-Z0-9`_$]+\\|\\\\[^ \t\n\f]+\\)")
	    (goto-char (match-end 0))
	    (setq keywd (concat keywd "::" (match-string 1)))
	    (when (string-match "^\\\\" (match-string 1))
	      (setq keywd (concat keywd " "))))  ;; Escaped ID needs space at end
	  (cond ((equal keywd "input")
		 (setq vec nil        enum nil      rvalue nil  newsig nil  signed nil
		       typedefed nil  multidim nil  ptype nil   modport nil
		       expect-signal 'sigs-in       io t        sig-paren paren))
		((equal keywd "output")
		 (setq vec nil        enum nil      rvalue nil  newsig nil  signed nil
		       typedefed nil  multidim nil  ptype nil   modport nil
		       expect-signal 'sigs-out      io t        sig-paren paren))
		((equal keywd "inout")
		 (setq vec nil        enum nil      rvalue nil  newsig nil  signed nil
		       typedefed nil  multidim nil  ptype nil   modport nil
		       expect-signal 'sigs-inout    io t        sig-paren paren))
		((equal keywd "parameter")
		 (setq vec nil        enum nil      rvalue nil  signed nil
		       typedefed nil  multidim nil  ptype nil   modport nil
		       expect-signal 'sigs-gparam   io t        sig-paren paren))
		((member keywd '("wire" "reg"  ; Fast
				 ;; net_type
				 "tri" "tri0" "tri1" "triand" "trior" "trireg"
				 "uwire" "wand" "wor"
				 ;; integer_atom_type
				 "byte" "shortint" "int" "longint" "integer" "time"
				 "supply0" "supply1"
				 ;; integer_vector_type - "reg" above
				 "bit" "logic"
				 ;; non_integer_type
				 "shortreal" "real" "realtime"
				 ;; data_type
				 "string" "event" "chandle"))
		 (cond (io
			(setq typedefed
			      (if typedefed (concat typedefed " " keywd) keywd)))
		       (t (setq vec nil  enum nil  rvalue nil  signed nil
				typedefed nil  multidim nil  sig-paren paren
				expect-signal 'sigs-var  modport nil))))
		((equal keywd "assign")
		 (setq vec nil        enum nil        rvalue nil  signed nil
		       typedefed nil  multidim nil    ptype nil   modport nil
		       expect-signal 'sigs-assign     sig-paren paren))
		((member keywd '("localparam" "genvar"))
		 (unless io
		   (setq vec nil        enum nil      rvalue nil  signed nil
			 typedefed nil  multidim nil  ptype nil   modport nil
			 expect-signal 'sigs-const    sig-paren paren)))
		((member keywd '("signed" "unsigned"))
		 (setq signed keywd))
		((member keywd '("assert" "assume" "cover" "expect" "restrict"))
		 (setq ign-prop t))
		((member keywd '("class" "covergroup" "function"
				 "property" "randsequence" "sequence" "task"))
		 (unless ign-prop
		   (setq functask (1+ functask))))
		((member keywd '("endclass" "endgroup" "endfunction"
				 "endproperty" "endsequence" "endtask"))
		 (setq functask (1- functask)))
		((equal keywd "modport")
		 (setq in-modport t))
		((equal keywd "clocking")
		 (setq in-clocking t))
		((equal keywd "type")
		 (setq ptype t))
		;; Ifdef?  Ignore name of define
		((member keywd '("`ifdef" "`ifndef" "`elsif"))
		 (setq rvalue t))
		;; Type?
		((unless ptype
		   (vpp-typedef-name-p keywd))
		 (setq typedefed keywd))
		;; Interface with optional modport in v2k arglist?
		;; Skip over parsing modport, and take the interface name as the type
		((and v2kargs-ok
		      (eq paren 1)
		      (not rvalue)
		      (looking-at "\\s-*\\(\\.\\(\\s-*[a-zA-Z`_$][a-zA-Z0-9`_$]*\\)\\|\\)\\s-*[a-zA-Z`_$][a-zA-Z0-9`_$]*"))
		 (when (match-end 2) (goto-char (match-end 2)))
		 (setq vec nil          enum nil       rvalue nil  signed nil
		       typedefed keywd  multidim nil   ptype nil   modport (match-string 2)
		       newsig nil    sig-paren paren
		       expect-signal 'sigs-intf  io t  ))
		;; Ignore dotted LHS assignments: "assign foo.bar = z;"
		((looking-at "\\s-*\\.")
		 (goto-char (match-end 0))
		 (when (not rvalue)
		   (setq expect-signal nil)))
		;; "modport <keywd>"
		((and (eq in-modport t)
		      (not (member keywd vpp-keywords)))
		 (setq in-modport (vpp-modport-new keywd nil nil))
		 (setq sigs-modports (cons in-modport sigs-modports))
		 ;; Push old sig values to stack and point to new signal list
		 (setq varstack (cons (vector sigs-out sigs-inout sigs-in)
				      varstack))
		 (setq sigs-in nil  sigs-inout nil  sigs-out nil))
		;; "modport x (clocking <keywd>)"
		((and in-modport in-clocking)
		 (vpp-modport-clockings-add in-modport keywd)
		 (setq in-clocking nil))
		;; endclocking
		((and in-clocking
		      (equal keywd "endclocking"))
		 (unless (eq in-clocking t)
		   (vpp-modport-decls-set
		    in-clocking
		    (vpp-decls-new sigs-out sigs-inout sigs-in
				       nil nil nil nil nil nil))
		   ;; Pop from varstack to restore state to pre-clocking
		   (setq tmp (car varstack)
			 varstack (cdr varstack)
			 sigs-out (aref tmp 0)
			 sigs-inout (aref tmp 1)
			 sigs-in (aref tmp 2)))
		 (setq in-clocking nil))
		;; "clocking <keywd>"
		((and (eq in-clocking t)
		      (not (member keywd vpp-keywords)))
		 (setq in-clocking (vpp-modport-new keywd nil nil))
		 (setq sigs-modports (cons in-clocking sigs-modports))
		 ;; Push old sig values to stack and point to new signal list
		 (setq varstack (cons (vector sigs-out sigs-inout sigs-in)
				      varstack))
		 (setq sigs-in nil  sigs-inout nil  sigs-out nil))
		;; New signal, maybe?
		((and expect-signal
		      (not rvalue)
		      (eq functask 0)
		      (not (member keywd vpp-keywords)))
		 ;; Add new signal to expect-signal's variable
		 (setq newsig (vpp-sig-new keywd vec nil nil enum signed typedefed multidim modport))
		 (set expect-signal (cons newsig
					  (symbol-value expect-signal))))))
	 (t
	  (forward-char 1)))
	(skip-syntax-forward " "))
      ;; Return arguments
      (setq tmp (vpp-decls-new (nreverse sigs-out)
				   (nreverse sigs-inout)
				   (nreverse sigs-in)
				   (nreverse sigs-var)
				   (nreverse sigs-modports)
				   (nreverse sigs-assign)
				   (nreverse sigs-const)
				   (nreverse sigs-gparam)
				   (nreverse sigs-intf)))
      ;;(if dbg (vpp-decls-princ tmp))
      tmp)))

(defvar vpp-read-sub-decls-in-interfaced nil
  "For `vpp-read-sub-decls', process next signal as under interfaced block.")

(defvar vpp-read-sub-decls-gate-ios nil
  "For `vpp-read-sub-decls', gate IO pins remaining, nil if non-primitive.")

(eval-when-compile
  ;; Prevent compile warnings; these are let's, not globals
  ;; Do not remove the eval-when-compile
  ;; - we want an error when we are debugging this code if they are refed.
  (defvar sigs-in)
  (defvar sigs-inout)
  (defvar sigs-out)
  (defvar sigs-intf)
  (defvar sigs-intfd))

(defun vpp-read-sub-decls-sig (submoddecls comment port sig vec multidim)
  "For `vpp-read-sub-decls-line', add a signal."
  ;; sig eq t to indicate .name syntax
  ;;(message "vrsds: %s(%S)" port sig)
  (let ((dotname (eq sig t))
	portdata)
    (when sig
      (setq port (vpp-symbol-detick-denumber port))
      (setq sig  (if dotname port (vpp-symbol-detick-denumber sig)))
      (if vec (setq vec  (vpp-symbol-detick-denumber vec)))
      (if multidim (setq multidim  (mapcar `vpp-symbol-detick-denumber multidim)))
      (unless (or (not sig)
		  (equal sig ""))  ;; Ignore .foo(1'b1) assignments
	(cond ((or (setq portdata (assoc port (vpp-decls-get-inouts submoddecls)))
		   (equal "inout" vpp-read-sub-decls-gate-ios))
	       (setq sigs-inout
		     (cons (vpp-sig-new
			    sig
			    (if dotname (vpp-sig-bits portdata) vec)
			    (concat "To/From " comment)
			    (vpp-sig-memory portdata)
			    nil
			    (vpp-sig-signed portdata)
			    (unless (member (vpp-sig-type portdata) '("wire" "reg"))
			      (vpp-sig-type portdata))
			    multidim nil)
			   sigs-inout)))
	      ((or (setq portdata (assoc port (vpp-decls-get-outputs submoddecls)))
		   (equal "output" vpp-read-sub-decls-gate-ios))
	       (setq sigs-out
		     (cons (vpp-sig-new
			    sig
			    (if dotname (vpp-sig-bits portdata) vec)
			    (concat "From " comment)
			    (vpp-sig-memory portdata)
			    nil
			    (vpp-sig-signed portdata)
			    ;; Though ok in SV, in V2K code, propagating the
			    ;;  "reg" in "output reg" upwards isn't legal.
			    ;; Also for backwards compatibility we don't propagate
			    ;;  "input wire" upwards.
			    ;; See also `vpp-signals-edit-wire-reg'.
			    (unless (member (vpp-sig-type portdata) '("wire" "reg"))
			      (vpp-sig-type portdata))
			    multidim nil)
			   sigs-out)))
	      ((or (setq portdata (assoc port (vpp-decls-get-inputs submoddecls)))
		   (equal "input" vpp-read-sub-decls-gate-ios))
	       (setq sigs-in
		     (cons (vpp-sig-new
			    sig
			    (if dotname (vpp-sig-bits portdata) vec)
			    (concat "To " comment)
			    (vpp-sig-memory portdata)
			    nil
			    (vpp-sig-signed portdata)
			    (unless (member (vpp-sig-type portdata) '("wire" "reg"))
			      (vpp-sig-type portdata))
			    multidim nil)
			   sigs-in)))
	      ((setq portdata (assoc port (vpp-decls-get-interfaces submoddecls)))
	       (setq sigs-intf
		     (cons (vpp-sig-new
			    sig
			    (if dotname (vpp-sig-bits portdata) vec)
			    (concat "To/From " comment)
			    (vpp-sig-memory portdata)
			    nil
			    (vpp-sig-signed portdata)
			    (vpp-sig-type portdata)
			    multidim nil)
			   sigs-intf)))
	      ((setq portdata (and vpp-read-sub-decls-in-interfaced
				   (assoc port (vpp-decls-get-vars submoddecls))))
	       (setq sigs-intfd
		     (cons (vpp-sig-new
			    sig
			    (if dotname (vpp-sig-bits portdata) vec)
			    (concat "To/From " comment)
			    (vpp-sig-memory portdata)
			    nil
			    (vpp-sig-signed portdata)
			    (vpp-sig-type portdata)
			    multidim nil)
			   sigs-intf)))
	      ;; (t  -- warning pin isn't defined.)   ; Leave for lint tool
	      )))))

(defun vpp-read-sub-decls-expr (submoddecls comment port expr)
  "For `vpp-read-sub-decls-line', parse a subexpression and add signals."
  ;;(message "vrsde: '%s'" expr)
  ;; Replace special /*[....]*/ comments inserted by vpp-auto-inst-port
  (setq expr (vpp-string-replace-matches "/\\*\\(\\[[^*]+\\]\\)\\*/" "\\1" nil nil expr))
  ;; Remove front operators
  (setq expr (vpp-string-replace-matches "^\\s-*[---+~!|&]+\\s-*" "" nil nil expr))
  ;;
  (cond
   ;; {..., a, b} requires us to recurse on a,b
   ;; To support {#{},{#{a,b}} we'll just split everything on [{},]
   ((string-match "^\\s-*{\\(.*\\)}\\s-*$" expr)
    (unless vpp-auto-ignore-concat
      (let ((mlst (split-string (match-string 1 expr) "[{},]"))
	    mstr)
	(while (setq mstr (pop mlst))
	  (vpp-read-sub-decls-expr submoddecls comment port mstr)))))
   (t
    (let (sig vec multidim)
      ;; Remove leading reduction operators, etc
      (setq expr (vpp-string-replace-matches "^\\s-*[---+~!|&]+\\s-*" "" nil nil expr))
      ;;(message "vrsde-ptop: '%s'" expr)
      (cond ;; Find \signal. Final space is part of escaped signal name
       ((string-match "^\\s-*\\(\\\\[^ \t\n\f]+\\s-\\)" expr)
	;;(message "vrsde-s: '%s'" (match-string 1 expr))
	(setq sig (match-string 1 expr)
	      expr (substring expr (match-end 0))))
       ;; Find signal
       ((string-match "^\\s-*\\([a-zA-Z_][a-zA-Z_0-9]*\\)" expr)
	;;(message "vrsde-s: '%s'" (match-string 1 expr))
	(setq sig (vpp-string-remove-spaces (match-string 1 expr))
	      expr (substring expr (match-end 0)))))
      ;; Find [vector] or [multi][multi][multi][vector]
      (while (string-match "^\\s-*\\(\\[[^]]+\\]\\)" expr)
	;;(message "vrsde-v: '%s'" (match-string 1 expr))
	(when vec (setq multidim (cons vec multidim)))
	(setq vec (match-string 1 expr)
	      expr (substring expr (match-end 0))))
      ;; If found signal, and nothing unrecognized, add the signal
      ;;(message "vrsde-rem: '%s'" expr)
      (when (and sig (string-match "^\\s-*$" expr))
	(vpp-read-sub-decls-sig submoddecls comment port sig vec multidim))))))

(defun vpp-read-sub-decls-line (submoddecls comment)
  "For `vpp-read-sub-decls', read lines of port defs until none match.
Inserts the list of signals found, using submodi to look up each port."
  (let (done port)
    (save-excursion
      (forward-line 1)
      (while (not done)
	;; Get port name
	(cond ((looking-at "\\s-*\\.\\s-*\\([a-zA-Z0-9`_$]*\\)\\s-*(\\s-*")
	       (setq port (match-string 1))
	       (goto-char (match-end 0)))
	      ;; .\escaped (
	      ((looking-at "\\s-*\\.\\s-*\\(\\\\[^ \t\n\f]*\\)\\s-*(\\s-*")
	       (setq port (concat (match-string 1) " ")) ;; escaped id's need trailing space
	       (goto-char (match-end 0)))
	      ;; .name
	      ((looking-at "\\s-*\\.\\s-*\\([a-zA-Z0-9`_$]*\\)\\s-*[,)/]")
	       (vpp-read-sub-decls-sig
		submoddecls comment (match-string 1) t ; sig==t for .name
		nil nil) ; vec multidim
	       (setq port nil))
	      ;; .\escaped_name
	      ((looking-at "\\s-*\\.\\s-*\\(\\\\[^ \t\n\f]*\\)\\s-*[,)/]")
	       (vpp-read-sub-decls-sig
		submoddecls comment (concat (match-string 1) " ") t ; sig==t for .name
		nil nil) ; vec multidim
	       (setq port nil))
	      ;; random
	      ((looking-at "\\s-*\\.[^(]*(")
	       (setq port nil) ;; skip this line
	       (goto-char (match-end 0)))
	      (t
	       (setq port nil  done t))) ;; Unknown, ignore rest of line
	;; Get signal name.  Point is at the first-non-space after (
	;; We intentionally ignore (non-escaped) signals with .s in them
	;; this prevents AUTOWIRE etc from noticing hierarchical sigs.
	(when port
	  (cond ((looking-at "\\([a-zA-Z_][a-zA-Z_0-9]*\\)\\s-*)")
		 (vpp-read-sub-decls-sig
		  submoddecls comment port
		  (vpp-string-remove-spaces (match-string 1)) ; sig
		  nil nil)) ; vec multidim
		;;
		((looking-at "\\([a-zA-Z_][a-zA-Z_0-9]*\\)\\s-*\\(\\[[^]]+\\]\\)\\s-*)")
		 (vpp-read-sub-decls-sig
		  submoddecls comment port
		  (vpp-string-remove-spaces (match-string 1)) ; sig
		  (match-string 2) nil)) ; vec multidim
		;; Fastpath was above looking-at's.
		;; For something more complicated invoke a parser
		((looking-at "[^)]+")
		 (vpp-read-sub-decls-expr
		  submoddecls comment port
		  (buffer-substring
		   (point) (1- (progn (search-backward "(") ; start at (
				      (vpp-forward-sexp-ign-cmt 1)
				      (point)))))))) ; expr
	;;
	(forward-line 1)))))

(defun vpp-read-sub-decls-gate (submoddecls comment submod end-inst-point)
  "For `vpp-read-sub-decls', read lines of UDP gate decl until none match.
Inserts the list of signals found."
  (save-excursion
    (let ((iolist (cdr (assoc submod vpp-gate-ios))))
      (while (< (point) end-inst-point)
	;; Get primitive's signal name, as will never have port, and no trailing )
	(cond ((looking-at "//")
	       (search-forward "\n"))
	      ((looking-at "/\\*")
	       (or (search-forward "*/")
		   (error "%s: Unmatched /* */, at char %d" (vpp-point-text) (point))))
	      ((looking-at "(\\*")
	       ;; To advance past either "(*)" or "(* ... *)" don't forward past first *
	       (forward-char 1)
	       (or (search-forward "*)")
		   (error "%s: Unmatched (* *), at char %d" (vpp-point-text) (point))))
	      ;; On pins, parse and advance to next pin
	      ;; Looking at pin, but *not* an // Output comment, or ) to end the inst
	      ((looking-at "\\s-*[a-zA-Z0-9`_$({}\\\\][^,]*")
	       (goto-char (match-end 0))
	       (setq vpp-read-sub-decls-gate-ios (or (car iolist) "input")
		     iolist (cdr iolist))
	       (vpp-read-sub-decls-expr
		submoddecls comment "primitive_port"
		(match-string 0)))
	      (t
	       (forward-char 1)
	       (skip-syntax-forward " ")))))))

(defun vpp-read-sub-decls ()
  "Internally parse signals going to modules under this module.
Return an array of [ outputs inouts inputs ] signals for modules that are
instantiated in this module.  For example if declare A A (.B(SIG)) and SIG
is an output, then SIG will be included in the list.

This only works on instantiations created with /*AUTOINST*/ converted by
\\[vpp-auto-inst].  Otherwise, it would have to read in the whole
component library to determine connectivity of the design.

One work around for this problem is to manually create // Inputs and //
Outputs comments above subcell signals, for example:

	module ModuleName (
	    // Outputs
	    .out (out),
	    // Inputs
	    .in  (in));"
  (save-excursion
    (let ((end-mod-point (vpp-get-end-of-defun t))
	  st-point end-inst-point
	  ;; below 3 modified by vpp-read-sub-decls-line
	  sigs-out sigs-inout sigs-in sigs-intf sigs-intfd)
      (vpp-beg-of-defun-quick)
      (while (vpp-re-search-forward-quick "\\(/\\*AUTOINST\\*/\\|\\.\\*\\)" end-mod-point t)
	(save-excursion
	  (goto-char (match-beginning 0))
	  (unless (vpp-inside-comment-or-string-p)
	    ;; Attempt to snarf a comment
	    (let* ((submod (vpp-read-inst-module))
		   (inst (vpp-read-inst-name))
		   (subprim (member submod vpp-gate-keywords))
		   (comment (concat inst " of " submod ".v"))
		   submodi submoddecls)
    	      (cond
	       (subprim
		(setq submodi `primitive
		      submoddecls (vpp-decls-new nil nil nil nil nil nil nil nil nil)
		      comment (concat inst " of " submod))
		(vpp-backward-open-paren)
		(setq end-inst-point (save-excursion (vpp-forward-sexp-ign-cmt 1)
						     (point))
		      st-point (point))
		(forward-char 1)
		(vpp-read-sub-decls-gate submoddecls comment submod end-inst-point))
	       ;; Non-primitive
	       (t
		(when (setq submodi (vpp-modi-lookup submod t))
		  (setq submoddecls (vpp-modi-get-decls submodi)
			vpp-read-sub-decls-gate-ios nil)
		  (vpp-backward-open-paren)
		  (setq end-inst-point (save-excursion (vpp-forward-sexp-ign-cmt 1)
						       (point))
			st-point (point))
		  ;; This could have used a list created by vpp-auto-inst
		  ;; However I want it to be runnable even on user's manually added signals
		  (let ((vpp-read-sub-decls-in-interfaced t))
		    (while (re-search-forward "\\s *(?\\s *// Interfaced" end-inst-point t)
		      (vpp-read-sub-decls-line submoddecls comment))) ;; Modifies sigs-ifd
		  (goto-char st-point)
		  (while (re-search-forward "\\s *(?\\s *// Interfaces" end-inst-point t)
		    (vpp-read-sub-decls-line submoddecls comment)) ;; Modifies sigs-out
		  (goto-char st-point)
		  (while (re-search-forward "\\s *(?\\s *// Outputs" end-inst-point t)
		    (vpp-read-sub-decls-line submoddecls comment)) ;; Modifies sigs-out
		  (goto-char st-point)
		  (while (re-search-forward "\\s *(?\\s *// Inouts" end-inst-point t)
		    (vpp-read-sub-decls-line submoddecls comment)) ;; Modifies sigs-inout
		  (goto-char st-point)
		  (while (re-search-forward "\\s *(?\\s *// Inputs" end-inst-point t)
		    (vpp-read-sub-decls-line submoddecls comment)) ;; Modifies sigs-in
		  )))))))
      ;; Combine duplicate bits
      ;;(setq rr (vector sigs-out sigs-inout sigs-in))
      (vpp-subdecls-new
       (vpp-signals-combine-bus (nreverse sigs-out))
       (vpp-signals-combine-bus (nreverse sigs-inout))
       (vpp-signals-combine-bus (nreverse sigs-in))
       (vpp-signals-combine-bus (nreverse sigs-intf))
       (vpp-signals-combine-bus (nreverse sigs-intfd))))))

(defun vpp-read-inst-pins ()
  "Return an array of [ pins ] for the current instantiation at point.
For example if declare A A (.B(SIG)) then B will be included in the list."
  (save-excursion
    (let ((end-mod-point (point))	;; presume at /*AUTOINST*/ point
	  pins pin)
      (vpp-backward-open-paren)
      (while (re-search-forward "\\.\\([^(,) \t\n\f]*\\)\\s-*" end-mod-point t)
	(setq pin (match-string 1))
	(unless (vpp-inside-comment-or-string-p)
	  (setq pins (cons (list pin) pins))
	  (when (looking-at "(")
	    (vpp-forward-sexp-ign-cmt 1))))
      (vector pins))))

(defun vpp-read-arg-pins ()
  "Return an array of [ pins ] for the current argument declaration at point."
  (save-excursion
    (let ((end-mod-point (point))	;; presume at /*AUTOARG*/ point
	  pins pin)
      (vpp-backward-open-paren)
      (while (re-search-forward "\\([a-zA-Z0-9$_.%`]+\\)" end-mod-point t)
	(setq pin (match-string 1))
	(unless (vpp-inside-comment-or-string-p)
	  (setq pins (cons (list pin) pins))))
      (vector pins))))

(defun vpp-read-auto-constants (beg end-mod-point)
  "Return a list of AUTO_CONSTANTs used in the region from BEG to END-MOD-POINT."
  ;; Insert new
  (save-excursion
    (let (sig-list tpl-end-pt)
      (goto-char beg)
      (while (re-search-forward "\\<AUTO_CONSTANT" end-mod-point t)
	(if (not (looking-at "\\s *("))
	    (error "%s: Missing () after AUTO_CONSTANT" (vpp-point-text)))
	(search-forward "(" end-mod-point)
	(setq tpl-end-pt (save-excursion
			   (backward-char 1)
			   (vpp-forward-sexp-cmt 1)   ;; Moves to paren that closes argdecl's
			   (backward-char 1)
			   (point)))
	(while (re-search-forward "\\s-*\\([\"a-zA-Z0-9$_.%`]+\\)\\s-*,*" tpl-end-pt t)
	  (setq sig-list (cons (list (match-string 1) nil nil) sig-list))))
      sig-list)))

(defvar vpp-cache-has-lisp nil "True if any AUTO_LISP in buffer.")
(make-variable-buffer-local 'vpp-cache-has-lisp)

(defun vpp-read-auto-lisp-present ()
  "Set `vpp-cache-has-lisp' if any AUTO_LISP in this buffer."
  (save-excursion
    (goto-char (point-min))
    (setq vpp-cache-has-lisp (re-search-forward "\\<AUTO_LISP(" nil t))))

(defun vpp-read-auto-lisp (start end)
  "Look for and evaluate an AUTO_LISP between START and END.
Must call `vpp-read-auto-lisp-present' before this function."
  ;; This function is expensive for large buffers, so we cache if any AUTO_LISP exists
  (when vpp-cache-has-lisp
    (save-excursion
      (goto-char start)
      (while (re-search-forward "\\<AUTO_LISP(" end t)
	(backward-char)
	(let* ((beg-pt (prog1 (point)
			 (vpp-forward-sexp-cmt 1)))	;; Closing paren
	       (end-pt (point))
	       (vpp-in-hooks t))
	  (eval-region beg-pt end-pt nil))))))

(eval-when-compile
  ;; Prevent compile warnings; these are let's, not globals
  ;; Do not remove the eval-when-compile
  ;; - we want an error when we are debugging this code if they are refed.
  (defvar sigs-in)
  (defvar sigs-out-d)
  (defvar sigs-out-i)
  (defvar sigs-out-unk)
  (defvar sigs-temp)
  (defvar vector-skip-list))

(defun vpp-read-always-signals-recurse
  (exit-keywd rvalue temp-next)
  "Recursive routine for parentheses/bracket matching.
EXIT-KEYWD is expression to stop at, nil if top level.
RVALUE is true if at right hand side of equal.
IGNORE-NEXT is true to ignore next token, fake from inside case statement."
  (let* ((semi-rvalue (equal "endcase" exit-keywd)) ;; true if after a ; we are looking for rvalue
	 keywd last-keywd sig-tolk sig-last-tolk gotend got-sig got-list end-else-check
	 ignore-next)
    ;;(if dbg (setq dbg (concat dbg (format "Recursion %S %S %S\n" exit-keywd rvalue temp-next))))
    (while (not (or (eobp) gotend))
      (cond
       ((looking-at "//")
	(search-forward "\n"))
       ((looking-at "/\\*")
	(or (search-forward "*/")
	    (error "%s: Unmatched /* */, at char %d" (vpp-point-text) (point))))
       ((looking-at "(\\*")
	;; To advance past either "(*)" or "(* ... *)" don't forward past first *
	(forward-char 1)
	(or (search-forward "*)")
	    (error "%s: Unmatched (* *), at char %d" (vpp-point-text) (point))))
       (t (setq keywd (buffer-substring-no-properties
		       (point)
		       (save-excursion (when (eq 0 (skip-chars-forward "a-zA-Z0-9$_.%`"))
					 (forward-char 1))
				       (point)))
		sig-last-tolk sig-tolk
		sig-tolk nil)
	  ;;(if dbg (setq dbg (concat dbg (format "\tPt=%S %S\trv=%S in=%S ee=%S gs=%S\n" (point) keywd rvalue ignore-next end-else-check got-sig))))
	  (cond
	   ((equal keywd "\"")
	    (or (re-search-forward "[^\\]\"" nil t)
		(error "%s: Unmatched quotes, at char %d" (vpp-point-text) (point))))
	   ;; else at top level loop, keep parsing
	   ((and end-else-check (equal keywd "else"))
	    ;;(if dbg (setq dbg (concat dbg (format "\tif-check-else %s\n" keywd))))
	    ;; no forward movement, want to see else in lower loop
	    (setq end-else-check nil))
	   ;; End at top level loop
	   ((and end-else-check (looking-at "[^ \t\n\f]"))
	    ;;(if dbg (setq dbg (concat dbg (format "\tif-check-else-other %s\n" keywd))))
	    (setq gotend t))
	   ;; Final statement?
	   ((and exit-keywd (equal keywd exit-keywd))
	    (setq gotend t)
	    (forward-char (length keywd)))
	   ;; Standard tokens...
	   ((equal keywd ";")
	    (setq ignore-next nil  rvalue semi-rvalue)
	    ;; Final statement at top level loop?
	    (when (not exit-keywd)
	      ;;(if dbg (setq dbg (concat dbg (format "\ttop-end-check %s\n" keywd))))
	      (setq end-else-check t))
	    (forward-char 1))
	   ((equal keywd "'")
	    (if (looking-at "'[sS]?[hdxboHDXBO]?[ \t]*[0-9a-fA-F_xzXZ?]+")
		(goto-char (match-end 0))
	      (forward-char 1)))
	   ((equal keywd ":")	;; Case statement, begin/end label, x?y:z
	    (cond ((equal "endcase" exit-keywd)  ;; case x: y=z; statement next
		   (setq ignore-next nil rvalue nil))
		  ((equal "?" exit-keywd)  ;; x?y:z rvalue
		   ) ;; NOP
		  ((equal "]" exit-keywd)  ;; [x:y] rvalue
		   ) ;; NOP
		  (got-sig	;; label: statement
		   (setq ignore-next nil rvalue semi-rvalue got-sig nil))
		  ((not rvalue)	;; begin label
		   (setq ignore-next t rvalue nil)))
	    (forward-char 1))
	   ((equal keywd "=")
	    (when got-sig
	      ;;(if dbg (setq dbg (concat dbg (format "\t\tequal got-sig=%S got-list=%s\n" got-sig got-list))))
	      (set got-list (cons got-sig (symbol-value got-list)))
	      (setq got-sig nil))
	    (when (not rvalue)
	      (if (eq (char-before) ?< )
		  (setq sigs-out-d (append sigs-out-d sigs-out-unk)
			sigs-out-unk nil)
		(setq sigs-out-i (append sigs-out-i sigs-out-unk)
		      sigs-out-unk nil)))
	    (setq ignore-next nil rvalue t)
	    (forward-char 1))
	   ((equal keywd "?")
	    (forward-char 1)
	    (vpp-read-always-signals-recurse ":" rvalue nil))
	   ((equal keywd "[")
	    (forward-char 1)
	    (vpp-read-always-signals-recurse "]" t nil))
	   ((equal keywd "(")
	    (forward-char 1)
	    (cond (sig-last-tolk	;; Function call; zap last signal
		   (setq got-sig nil)))
	    (cond ((equal last-keywd "for")
		   ;; temp-next: Variables on LHS are lvalues, but generally we want
		   ;; to ignore them, assuming they are loop increments
		   (vpp-read-always-signals-recurse ";" nil t)
		   (vpp-read-always-signals-recurse ";" t nil)
		   (vpp-read-always-signals-recurse ")" nil nil))
		  (t (vpp-read-always-signals-recurse ")" t nil))))
	   ((equal keywd "begin")
	    (skip-syntax-forward "w_")
	    (vpp-read-always-signals-recurse "end" nil nil)
	    ;;(if dbg (setq dbg (concat dbg (format "\tgot-end %s\n" exit-keywd))))
	    (setq ignore-next nil  rvalue semi-rvalue)
	    (if (not exit-keywd) (setq end-else-check t)))
	   ((member keywd '("case" "casex" "casez"))
	    (skip-syntax-forward "w_")
	    (vpp-read-always-signals-recurse "endcase" t nil)
	    (setq ignore-next nil  rvalue semi-rvalue)
	    (if (not exit-keywd) (setq gotend t)))	;; top level begin/end
	   ((string-match "^[$`a-zA-Z_]" keywd)	;; not exactly word constituent
	    (cond ((member keywd '("`ifdef" "`ifndef" "`elsif"))
		   (setq ignore-next t))
		  ((or ignore-next
		       (member keywd vpp-keywords)
		       (string-match "^\\$" keywd))	;; PLI task
		   (setq ignore-next nil))
		  (t
		   (setq keywd (vpp-symbol-detick-denumber keywd))
		   (when got-sig
		     (set got-list (cons got-sig (symbol-value got-list)))
		     ;;(if dbg (setq dbg (concat dbg (format "\t\tgot-sig=%S got-list=%S\n" got-sig got-list))))
		     )
		   (setq got-list (cond (temp-next 'sigs-temp)
					(rvalue 'sigs-in)
					(t 'sigs-out-unk))
			 got-sig (if (or (not keywd)
					 (assoc keywd (symbol-value got-list)))
				     nil (list keywd nil nil))
			 temp-next nil
			 sig-tolk t)))
	    (skip-chars-forward "a-zA-Z0-9$_.%`"))
	   (t
	    (forward-char 1)))
	  ;; End of non-comment token
	  (setq last-keywd keywd)))
      (skip-syntax-forward " "))
    ;; Append the final pending signal
    (when got-sig
      ;;(if dbg (setq dbg (concat dbg (format "\t\tfinal got-sig=%S got-list=%s\n" got-sig got-list))))
      (set got-list (cons got-sig (symbol-value got-list)))
      (setq got-sig nil))
    ;;(if dbg (setq dbg (concat dbg (format "ENDRecursion %s\n" exit-keywd))))
    ))

(defun vpp-read-always-signals ()
  "Parse always block at point and return list of (outputs inout inputs)."
  (save-excursion
    (let* (;;(dbg "")
	   sigs-out-d sigs-out-i sigs-out-unk sigs-temp sigs-in)
      (search-forward ")")
      (vpp-read-always-signals-recurse nil nil nil)
      (setq sigs-out-i (append sigs-out-i sigs-out-unk)
	    sigs-out-unk nil)
      ;;(if dbg (with-current-buffer (get-buffer-create "*vl-dbg*")) (delete-region (point-min) (point-max)) (insert dbg) (setq dbg ""))
      ;; Return what was found
      (vpp-alw-new sigs-out-d sigs-out-i sigs-temp sigs-in))))

(defun vpp-read-instants ()
  "Parse module at point and return list of ( ( file instance ) ... )."
  (vpp-beg-of-defun-quick)
  (let* ((end-mod-point (vpp-get-end-of-defun t))
	 (state nil)
	 (instants-list nil))
    (save-excursion
      (while (< (point) end-mod-point)
	;; Stay at level 0, no comments
	(while (progn
		 (setq state (parse-partial-sexp (point) end-mod-point 0 t nil))
		 (or (> (car state) 0)	; in parens
		     (nth 5 state)		; comment
		     ))
	  (forward-line 1))
	(beginning-of-line)
	(if (looking-at "^\\s-*\\([a-zA-Z0-9`_$]+\\)\\s-+\\([a-zA-Z0-9`_$]+\\)\\s-*(")
	    ;;(if (looking-at "^\\(.+\\)$")
	    (let ((module (match-string 1))
		  (instant (match-string 2)))
	      (if (not (member module vpp-keywords))
		  (setq instants-list (cons (list module instant) instants-list)))))
	(forward-line 1)))
    instants-list))


(defun vpp-read-auto-template-middle ()
  "With point in middle of an AUTO_TEMPLATE, parse it.
Returns REGEXP and list of ( (signal_name connection_name)... )."
  (save-excursion
    ;; Find beginning
    (let ((tpl-regexp "\\([0-9]+\\)")
	  (lineno -1)  ; -1 to offset for the AUTO_TEMPLATE's newline
	  (templateno 0)
	  tpl-sig-list tpl-wild-list tpl-end-pt rep)
      ;; Parse "REGEXP"
      ;; We reserve @"..." for future lisp expressions that evaluate
      ;; once-per-AUTOINST
      (when (looking-at "\\s-*\"\\([^\"]*\\)\"")
	(setq tpl-regexp (match-string 1))
	(goto-char (match-end 0)))
      (search-forward "(")
      ;; Parse lines in the template
      (when (or vpp-auto-inst-template-numbers
		vpp-auto-template-warn-unused)
	(save-excursion
	  (let ((pre-pt (point)))
	    (goto-char (point-min))
	    (while (search-forward "AUTO_TEMPLATE" pre-pt t)
	      (setq templateno (1+ templateno)))
	    (while (< (point) pre-pt)
	      (forward-line 1)
	      (setq lineno (1+ lineno))))))
      (setq tpl-end-pt (save-excursion
			 (backward-char 1)
			 (vpp-forward-sexp-cmt 1)   ;; Moves to paren that closes argdecl's
			 (backward-char 1)
			 (point)))
      ;;
      (while (< (point) tpl-end-pt)
	(cond ((looking-at "\\s-*\\.\\([a-zA-Z0-9`_$]+\\)\\s-*(\\(.*\\))\\s-*\\(,\\|)\\s-*;\\)")
	       (setq tpl-sig-list
		     (cons (list
			    (match-string-no-properties 1)
			    (match-string-no-properties 2)
			    templateno lineno)
			   tpl-sig-list))
	       (goto-char (match-end 0)))
	      ;; Regexp form??
	      ((looking-at
		;; Regexp bug in XEmacs disallows ][ inside [], and wants + last
		"\\s-*\\.\\(\\([a-zA-Z0-9`_$+@^.*?|---]+\\|[][]\\|\\\\[()|]\\)+\\)\\s-*(\\(.*\\))\\s-*\\(,\\|)\\s-*;\\)")
	       (setq rep (match-string-no-properties 3))
	       (goto-char (match-end 0))
	       (setq tpl-wild-list
		     (cons (list
			    (concat "^"
				    (vpp-string-replace-matches "@" "\\\\([0-9]+\\\\)" nil nil
								    (match-string 1))
				    "$")
			    rep
			    templateno lineno)
			   tpl-wild-list)))
	      ((looking-at "[ \t\f]+")
	       (goto-char (match-end 0)))
	      ((looking-at "\n")
	       (setq lineno (1+ lineno))
	       (goto-char (match-end 0)))
	      ((looking-at "//")
	       (search-forward "\n")
	       (setq lineno (1+ lineno)))
	      ((looking-at "/\\*")
	       (forward-char 2)
	       (or (search-forward "*/")
		   (error "%s: Unmatched /* */, at char %d" (vpp-point-text) (point))))
	      (t
	       (error "%s: AUTO_TEMPLATE parsing error: %s"
		      (vpp-point-text)
		      (progn (looking-at ".*$") (match-string 0))))))
      ;; Return
      (vector tpl-regexp
	      (list tpl-sig-list tpl-wild-list)))))

(defun vpp-read-auto-template (module)
  "Look for an auto_template for the instantiation of the given MODULE.
If found returns `vpp-read-auto-template-inside' structure."
  (save-excursion
    ;; Find beginning
    (let ((pt (point)))
      ;; Note this search is expensive, as we hunt from mod-begin to point
      ;; for every instantiation.  Likewise in vpp-read-auto-lisp.
      ;; So, we look first for an exact string rather than a slow regexp.
      ;; Someday we may keep a cache of every template, but this would also
      ;; need to record the relative position of each AUTOINST, as multiple
      ;; templates exist for each module, and we're inserting lines.
      (cond ((or
	      ;; See also regexp in `vpp-auto-template-lint'
	      (vpp-re-search-backward-substr
	       "AUTO_TEMPLATE"
	       (concat "^\\s-*/?\\*?\\s-*" module "\\s-+AUTO_TEMPLATE") nil t)
	      ;; Also try forward of this AUTOINST
	      ;; This is for historical support; this isn't speced as working
	      (progn
		(goto-char pt)
		(vpp-re-search-forward-substr
		 "AUTO_TEMPLATE"
		 (concat "^\\s-*/?\\*?\\s-*" module "\\s-+AUTO_TEMPLATE") nil t)))
	     (goto-char (match-end 0))
	     (vpp-read-auto-template-middle))
	    ;; If no template found
	    (t (vector "" nil))))))
;;(progn (find-file "auto-template.v") (vpp-read-auto-template "ptl_entry"))

(defvar vpp-auto-template-hits nil "Successful lookups with `vpp-read-auto-template-hit'.")
(make-variable-buffer-local 'vpp-auto-template-hits)

(defun vpp-read-auto-template-hit (tpl-ass)
  "Record that TPL-ASS template from `vpp-read-auto-template' was used."
  (when (eval-when-compile (fboundp 'make-hash-table)) ;; else feature not allowed
    (when vpp-auto-template-warn-unused
      (unless vpp-auto-template-hits
	(setq vpp-auto-template-hits
	      (make-hash-table :test 'equal :rehash-size 4.0)))
      (puthash (vector (nth 2 tpl-ass) (nth 3 tpl-ass)) t
	       vpp-auto-template-hits))))

(defun vpp-set-define (defname defvalue &optional buffer enumname)
  "Set the definition DEFNAME to the DEFVALUE in the given BUFFER.
Optionally associate it with the specified enumeration ENUMNAME."
  (with-current-buffer (or buffer (current-buffer))
    (let ((mac (intern (concat "vh-" defname))))
      ;;(message "Define %s=%s" defname defvalue) (sleep-for 1)
      ;; Need to define to a constant if no value given
      (set (make-local-variable mac)
	   (if (equal defvalue "") "1" defvalue)))
    (if enumname
	(let ((enumvar (intern (concat "venum-" enumname))))
	  ;;(message "Define %s=%s" defname defvalue) (sleep-for 1)
	  (unless (boundp enumvar) (set enumvar nil))
          (add-to-list (make-local-variable enumvar) defname)))))

(defun vpp-read-defines (&optional filename recurse subcall)
  "Read `defines and parameters for the current file, or optional FILENAME.
If the filename is provided, `vpp-library-flags' will be used to
resolve it.  If optional RECURSE is non-nil, recurse through `includes.

Parameters must be simple assignments to constants, or have their own
\"parameter\" label rather than a list of parameters.  Thus:

    parameter X = 5, Y = 10;	// Ok
    parameter X = {1'b1, 2'h2};	// Ok
    parameter X = {1'b1, 2'h2}, Y = 10;	// Bad, make into 2 parameter lines

Defines must be simple text substitutions, one on a line, starting
at the beginning of the line.  Any ifdefs or multiline comments around the
define are ignored.

Defines are stored inside Emacs variables using the name vh-{definename}.

This function is useful for setting vh-* variables.  The file variables
feature can be used to set defines that `vpp-mode' can see; put at the
*END* of your file something like:

    // Local Variables:
    // vh-macro:\"macro_definition\"
    // End:

If macros are defined earlier in the same file and you want their values,
you can read them automatically (provided `enable-local-eval' is on):

    // Local Variables:
    // eval:(vpp-read-defines)
    // eval:(vpp-read-defines \"group_standard_includes.v\")
    // End:

Note these are only read when the file is first visited, you must use
\\[find-alternate-file] RET  to have these take effect after editing them!

If you want to disable the \"Process `eval' or hook local variables\"
warning message, you need to add to your init file:

    (setq enable-local-eval t)"
  (let ((origbuf (current-buffer)))
    (save-excursion
      (unless subcall (vpp-getopt-flags))
      (when filename
	(let ((fns (vpp-library-filenames filename (buffer-file-name))))
	  (if fns
	      (set-buffer (find-file-noselect (car fns)))
	    (error (concat (vpp-point-text)
			   ": Can't find vpp-read-defines file: " filename)))))
      (when recurse
	(goto-char (point-min))
	(while (re-search-forward "^\\s-*`include\\s-+\\([^ \t\n\f]+\\)" nil t)
	  (let ((inc (vpp-string-replace-matches
		      "\"" "" nil nil (match-string-no-properties 1))))
	    (unless (vpp-inside-comment-or-string-p)
	      (vpp-read-defines inc recurse t)))))
      ;; Read `defines
      ;; note we don't use vpp-re... it's faster this way, and that
      ;; function has problems when comments are at the end of the define
      (goto-char (point-min))
      (while (re-search-forward "^\\s-*`define\\s-+\\([a-zA-Z0-9_$]+\\)\\s-+\\(.*\\)$" nil t)
	(let ((defname (match-string-no-properties 1))
	      (defvalue (match-string-no-properties 2)))
	  (setq defvalue (vpp-string-replace-matches "\\s-*/[/*].*$" "" nil nil defvalue))
	  (vpp-set-define defname defvalue origbuf)))
      ;; Hack: Read parameters
      (goto-char (point-min))
      (while (re-search-forward
	      "^\\s-*\\(parameter\\|localparam\\)\\(\\s-*\\[[^]]*\\]\\)?\\s-*" nil t)
	(let (enumname)
	  ;; The primary way of getting defines is vpp-read-decls
	  ;; However, that isn't called yet for included files, so we'll add another scheme
	  (if (looking-at "[^\n]*\\(auto\\|synopsys\\)\\s +enum\\s +\\([a-zA-Z0-9_]+\\)")
	      (setq enumname (match-string-no-properties 2)))
	  (forward-comment 99999)
	  (while (looking-at (concat "\\s-*,?\\s-*\\(?:/[/*].*?$\\)?\\s-*\\([a-zA-Z0-9_$]+\\)"
				     "\\s-*=\\s-*\\([^;,]*\\),?\\s-*\\(/[/*].*?$\\)?\\s-*"))
	    (vpp-set-define (match-string-no-properties 1)
				(match-string-no-properties 2) origbuf enumname)
	    (goto-char (match-end 0))
	    (forward-comment 99999)))))))

(defun vpp-read-includes ()
  "Read `includes for the current file.
This will find all of the `includes which are at the beginning of lines,
ignoring any ifdefs or multiline comments around them.
`vpp-read-defines' is then performed on the current and each included
file.

It is often useful put at the *END* of your file something like:

    // Local Variables:
    // eval:(vpp-read-defines)
    // eval:(vpp-read-includes)
    // End:

Note includes are only read when the file is first visited, you must use
\\[find-alternate-file] RET  to have these take effect after editing them!

It is good to get in the habit of including all needed files in each .v
file that needs it, rather than waiting for compile time.  This will aid
this process, Verilint, and readability.  To prevent defining the same
variable over and over when many modules are compiled together, put a test
around the inside each include file:

foo.v (an include file):
	`ifdef _FOO_V	// include if not already included
	`else
	`define _FOO_V
	... contents of file
	`endif // _FOO_V"
;;slow:  (vpp-read-defines nil t))
  (save-excursion
    (vpp-getopt-flags)
    (goto-char (point-min))
    (while (re-search-forward "^\\s-*`include\\s-+\\([^ \t\n\f]+\\)" nil t)
      (let ((inc (vpp-string-replace-matches "\"" "" nil nil (match-string 1))))
	(vpp-read-defines inc nil t)))))

(defun vpp-read-signals (&optional start end)
  "Return a simple list of all possible signals in the file.
Bounded by optional region from START to END.  Overly aggressive but fast.
Some macros and such are also found and included.  For dinotrace.el."
  (let (sigs-all keywd)
    (progn;save-excursion
      (goto-char (or start (point-min)))
      (setq end (or end (point-max)))
      (while (re-search-forward "[\"/a-zA-Z_.%`]" end t)
	(forward-char -1)
	(cond
	 ((looking-at "//")
	  (search-forward "\n"))
	 ((looking-at "/\\*")
	  (search-forward "*/"))
	 ((looking-at "(\\*")
	  (or (looking-at "(\\*\\s-*)")   ; It's a "always @ (*)"
	      (search-forward "*)")))
	 ((eq ?\" (following-char))
	  (re-search-forward "[^\\]\""))	;; don't forward-char first, since we look for a non backslash first
	 ((looking-at "\\s-*\\([a-zA-Z0-9$_.%`]+\\)")
	  (goto-char (match-end 0))
	  (setq keywd (match-string-no-properties 1))
	  (or (member keywd vpp-keywords)
	      (member keywd sigs-all)
	      (setq sigs-all (cons keywd sigs-all))))
	 (t (forward-char 1))))
      ;; Return list
      sigs-all)))

;;
;; Argument file parsing
;;

(defun vpp-getopt (arglist)
  "Parse -f, -v etc arguments in ARGLIST list or string."
  (unless (listp arglist) (setq arglist (list arglist)))
  (let ((space-args '())
	arg next-param)
    ;; Split on spaces, so users can pass whole command lines
    (while arglist
      (setq arg (car arglist)
	    arglist (cdr arglist))
      (while (string-match "^\\([^ \t\n\f]+\\)[ \t\n\f]*\\(.*$\\)" arg)
	(setq space-args (append space-args
				 (list (match-string-no-properties 1 arg))))
	(setq arg (match-string 2 arg))))
    ;; Parse arguments
    (while space-args
      (setq arg (car space-args)
	    space-args (cdr space-args))
      (cond
       ;; Need another arg
       ((equal arg "-f")
	(setq next-param arg))
       ((equal arg "-v")
	(setq next-param arg))
       ((equal arg "-y")
	(setq next-param arg))
       ;; +libext+(ext1)+(ext2)...
       ((string-match "^\\+libext\\+\\(.*\\)" arg)
	(setq arg (match-string 1 arg))
	(while (string-match "\\([^+]+\\)\\+?\\(.*\\)" arg)
	  (vpp-add-list-unique `vpp-library-extensions
				   (match-string 1 arg))
	  (setq arg (match-string 2 arg))))
       ;;
       ((or (string-match "^-D\\([^+=]*\\)[+=]\\(.*\\)" arg)	;; -Ddefine=val
	    (string-match "^-D\\([^+=]*\\)\\(\\)" arg)	;; -Ddefine
	    (string-match "^\\+define\\([^+=]*\\)[+=]\\(.*\\)" arg)	;; +define+val
	    (string-match "^\\+define\\([^+=]*\\)\\(\\)" arg))		;; +define+define
	(vpp-set-define (match-string 1 arg) (match-string 2 arg)))
       ;;
       ((or (string-match "^\\+incdir\\+\\(.*\\)" arg)	;; +incdir+dir
	    (string-match "^-I\\(.*\\)" arg))	;; -Idir
	(vpp-add-list-unique `vpp-library-directories
				 (match-string 1 (substitute-in-file-name arg))))
       ;; Ignore
       ((equal "+librescan" arg))
       ((string-match "^-U\\(.*\\)" arg))	;; -Udefine
       ;; Second parameters
       ((equal next-param "-f")
	(setq next-param nil)
	(vpp-getopt-file (substitute-in-file-name arg)))
       ((equal next-param "-v")
	(setq next-param nil)
	(vpp-add-list-unique `vpp-library-files
				 (substitute-in-file-name arg)))
       ((equal next-param "-y")
	(setq next-param nil)
	(vpp-add-list-unique `vpp-library-directories
				 (substitute-in-file-name arg)))
       ;; Filename
       ((string-match "^[^-+]" arg)
	(vpp-add-list-unique `vpp-library-files
				 (substitute-in-file-name arg)))
       ;; Default - ignore; no warning
       ))))
;;(vpp-getopt (list "+libext+.a+.b" "+incdir+foodir" "+define+a+aval" "-f" "otherf" "-v" "library" "-y" "dir"))

(defun vpp-getopt-file (filename)
  "Read Vpp options from the specified FILENAME."
  (save-excursion
    (let ((fns (vpp-library-filenames filename (buffer-file-name)))
	  (orig-buffer (current-buffer))
	  line)
      (if fns
	  (set-buffer (find-file-noselect (car fns)))
	(error (concat (vpp-point-text)
		       ": Can't find vpp-getopt-file -f file: " filename)))
      (goto-char (point-min))
      (while (not (eobp))
	(setq line (buffer-substring (point) (point-at-eol)))
	(forward-line 1)
	(when (string-match "//" line)
	  (setq line (substring line 0 (match-beginning 0))))
	(with-current-buffer orig-buffer  ; Variables are buffer-local, so need right context.
	  (vpp-getopt line))))))

(defun vpp-getopt-flags ()
  "Convert `vpp-library-flags' into standard library variables."
  ;; If the flags are local, then all the outputs should be local also
  (when (local-variable-p `vpp-library-flags (current-buffer))
    (mapc 'make-local-variable '(vpp-library-extensions
                                 vpp-library-directories
                                 vpp-library-files
                                 vpp-library-flags)))
  ;; Allow user to customize
  (vpp-run-hooks 'vpp-before-getopt-flags-hook)
  ;; Process arguments
  (vpp-getopt vpp-library-flags)
  ;; Allow user to customize
  (vpp-run-hooks 'vpp-getopt-flags-hook))

(defun vpp-add-list-unique (varref object)
  "Append to VARREF list the given OBJECT,
unless it is already a member of the variable's list."
  (unless (member object (symbol-value varref))
    (set varref (append (symbol-value varref) (list object))))
  varref)
;;(progn (setq l '()) (vpp-add-list-unique `l "a") (vpp-add-list-unique `l "a") l)

(defun vpp-current-flags ()
  "Convert `vpp-library-flags' and similar variables to command line.
Used for __FLAGS__ in `vpp-expand-command'."
  (let ((cmd (mapconcat `concat vpp-library-flags " ")))
    (when (equal cmd "")
      (setq cmd (concat
		 "+libext+" (mapconcat `concat vpp-library-extensions "+")
		 (mapconcat (lambda (i) (concat " -y " i " +incdir+" i))
			    vpp-library-directories "")
		 (mapconcat (lambda (i) (concat " -v " i))
			    vpp-library-files ""))))
    cmd))
;;(vpp-current-flags)


;;
;; Cached directory support
;;

(defvar vpp-dir-cache-preserving nil
  "If set, the directory cache is enabled, and file system changes are ignored.
See `vpp-dir-exists-p' and `vpp-dir-files'.")

;; If adding new cached variable, add also to vpp-preserve-dir-cache
(defvar vpp-dir-cache-list nil
  "Alist of (((Cwd Dirname) Results)...) for caching `vpp-dir-files'.")
(defvar vpp-dir-cache-lib-filenames nil
  "Cached data for `vpp-library-filenames'.")

(defmacro vpp-preserve-dir-cache (&rest body)
  "Execute the BODY forms, allowing directory cache preservation within BODY.
This means that changes inside BODY made to the file system will not be
seen by the `vpp-dir-files' and related functions."
  `(let ((vpp-dir-cache-preserving (current-buffer))
	 vpp-dir-cache-list
	 vpp-dir-cache-lib-filenames)
     (progn ,@body)))

(defun vpp-dir-files (dirname)
  "Return all filenames in the DIRNAME directory.
Relative paths depend on the `default-directory'.
Results are cached if inside `vpp-preserve-dir-cache'."
  (unless vpp-dir-cache-preserving
    (setq vpp-dir-cache-list nil)) ;; Cache disabled
  ;; We don't use expand-file-name on the dirname to make key, as it's slow
  (let* ((cache-key (list dirname default-directory))
	 (fass (assoc cache-key vpp-dir-cache-list))
	 exp-dirname data)
    (cond (fass  ;; Return data from cache hit
	   (nth 1 fass))
	  (t
	   (setq exp-dirname (expand-file-name dirname)
		 data (and (file-directory-p exp-dirname)
			   (directory-files exp-dirname nil nil nil)))
	   ;; Note we also encache nil for non-existing dirs.
	   (setq vpp-dir-cache-list (cons (list cache-key data)
					      vpp-dir-cache-list))
	   data))))
;; Miss-and-hit test:
;;(vpp-preserve-dir-cache (prin1 (vpp-dir-files "."))
;; (prin1 (vpp-dir-files ".")) nil)

(defun vpp-dir-file-exists-p (filename)
  "Return true if FILENAME exists.
Like `file-exists-p' but results are cached if inside
`vpp-preserve-dir-cache'."
  (let* ((dirname (file-name-directory filename))
	 ;; Correct for file-name-nondirectory returning same if no slash.
	 (dirnamed (if (or (not dirname) (equal dirname filename))
		       default-directory dirname))
	 (flist (vpp-dir-files dirnamed)))
    (and flist
	 (member (file-name-nondirectory filename) flist)
	 t)))
;;(vpp-dir-file-exists-p "vpp-mode.el")
;;(vpp-dir-file-exists-p "../vpp-mode/vpp-mode.el")


;;
;; Module name lookup
;;

(defun vpp-module-inside-filename-p (module filename)
  "Return modi if MODULE is specified inside FILENAME, else nil.
Allows version control to check out the file if need be."
  (and (or (file-exists-p filename)
	   (and (fboundp 'vc-backend)
		(vc-backend filename)))
       (let (modi type)
	 (with-current-buffer (find-file-noselect filename)
	   (save-excursion
	     (goto-char (point-min))
	     (while (and
		     ;; It may be tempting to look for vpp-defun-re,
		     ;; don't, it slows things down a lot!
		     (vpp-re-search-forward-quick "\\<\\(module\\|defmod\\|interface\\|program\\)\\>" nil t)
		     (setq type (match-string-no-properties 0))
		     (vpp-re-search-forward-quick "[(;]" nil t))
	       (if (equal module (vpp-read-module-name))
		   (setq modi (vpp-modi-new module filename (point) type))))
	     modi)))))

(defun vpp-is-number (symbol)
  "Return true if SYMBOL is number-like."
  (or (string-match "^[0-9 \t:]+$" symbol)
      (string-match "^[---]*[0-9]+$" symbol)
      (string-match "^[0-9 \t]+'s?[hdxbo][0-9a-fA-F_xz? \t]*$" symbol)))

(defun vpp-symbol-detick (symbol wing-it)
  "Return an expanded SYMBOL name without any defines.
If the variable vh-{symbol} is defined, return that value.
If undefined, and WING-IT, return just SYMBOL without the tick, else nil."
  (while (and symbol (string-match "^`" symbol))
    (setq symbol (substring symbol 1))
    (setq symbol
	  (if (boundp (intern (concat "vh-" symbol)))
	      ;; Emacs has a bug where boundp on a buffer-local
	      ;; variable in only one buffer returns t in another.
	      ;; This can confuse, so check for nil.
	      (let ((val (eval (intern (concat "vh-" symbol)))))
		(if (eq val nil)
		    (if wing-it symbol nil)
		  val))
	    (if wing-it symbol nil))))
  symbol)
;;(vpp-symbol-detick "`mod" nil)

(defun vpp-symbol-detick-denumber (symbol)
  "Return SYMBOL with defines converted and any numbers dropped to nil."
  (when (string-match "^`" symbol)
    ;; This only will work if the define is a simple signal, not
    ;; something like a[b].  Sorry, it should be substituted into the parser
    (setq symbol
	  (vpp-string-replace-matches
	   "\[[^0-9: \t]+\]" "" nil nil
	   (or (vpp-symbol-detick symbol nil)
	       (if vpp-auto-sense-defines-constant
		   "0"
		 symbol)))))
  (if (vpp-is-number symbol)
      nil
    symbol))

(defun vpp-symbol-detick-text (text)
  "Return TEXT without any known defines.
If the variable vh-{symbol} is defined, substitute that value."
  (let ((ok t) symbol val)
    (while (and ok (string-match "`\\([a-zA-Z0-9_]+\\)" text))
      (setq symbol (match-string 1 text))
      ;;(message symbol)
      (cond ((and
	      (boundp (intern (concat "vh-" symbol)))
	      ;; Emacs has a bug where boundp on a buffer-local
	      ;; variable in only one buffer returns t in another.
	      ;; This can confuse, so check for nil.
	      (setq val (eval (intern (concat "vh-" symbol)))))
	     (setq text (replace-match val nil nil text)))
	    (t (setq ok nil)))))
  text)
;;(progn (setq vh-mod "`foo" vh-foo "bar") (vpp-symbol-detick-text "bar `mod `undefed"))

(defun vpp-expand-dirnames (&optional dirnames)
  "Return a list of existing directories given a list of wildcarded DIRNAMES.
Or, just the existing dirnames themselves if there are no wildcards."
  ;; Note this function is performance critical.
  ;; Do not call anything that requires disk access that cannot be cached.
  (interactive)
  (unless dirnames (error "`vpp-library-directories' should include at least '.'"))
  (setq dirnames (reverse dirnames))	; not nreverse
  (let ((dirlist nil)
	pattern dirfile dirfiles dirname root filename rest basefile)
    (while dirnames
      (setq dirname (substitute-in-file-name (car dirnames))
	    dirnames (cdr dirnames))
      (cond ((string-match (concat "^\\(\\|[/\\]*[^*?]*[/\\]\\)"  ;; root
				   "\\([^/\\]*[*?][^/\\]*\\)"	  ;; filename with *?
				   "\\(.*\\)")			  ;; rest
			   dirname)
	     (setq root (match-string 1 dirname)
		   filename (match-string 2 dirname)
		   rest (match-string 3 dirname)
		   pattern filename)
	     ;; now replace those * and ? with .+ and .
	     ;; use ^ and /> to get only whole file names
	     (setq pattern (vpp-string-replace-matches "[*]" ".+" nil nil pattern)
		   pattern (vpp-string-replace-matches "[?]" "." nil nil pattern)
		   pattern (concat "^" pattern "$")
		   dirfiles (vpp-dir-files root))
	     (while dirfiles
	       (setq basefile (car dirfiles)
		     dirfile (expand-file-name (concat root basefile rest))
		     dirfiles (cdr dirfiles))
	       (if (and (string-match pattern basefile)
			;; Don't allow abc/*/rtl to match abc/rtl via ..
			(not (equal basefile "."))
			(not (equal basefile ".."))
			(file-directory-p dirfile))
		   (setq dirlist (cons dirfile dirlist)))))
	    ;; Defaults
	    (t
	     (if (file-directory-p dirname)
		 (setq dirlist (cons dirname dirlist))))))
    dirlist))
;;(vpp-expand-dirnames (list "." ".." "nonexist" "../*" "/home/wsnyder/*/v"))

(defun vpp-library-filenames (filename &optional current check-ext)
  "Return a search path to find the given FILENAME or module name.
Uses the optional CURRENT filename or variable `buffer-file-name', plus
`vpp-library-directories' and `vpp-library-extensions'
variables to build the path.  With optional CHECK-EXT also check
`vpp-library-extensions'."
  (unless current (setq current (buffer-file-name)))
  (unless vpp-dir-cache-preserving
    (setq vpp-dir-cache-lib-filenames nil))
  (let* ((cache-key (list filename current check-ext))
	 (fass (assoc cache-key vpp-dir-cache-lib-filenames))
	 chkdirs chkdir chkexts fn outlist)
    (cond (fass  ;; Return data from cache hit
	   (nth 1 fass))
	  (t
	   ;; Note this expand can't be easily cached, as we need to
	   ;; pick up buffer-local variables for newly read sub-module files
	   (setq chkdirs (vpp-expand-dirnames vpp-library-directories))
	   (while chkdirs
	     (setq chkdir (expand-file-name (car chkdirs)
					    (file-name-directory current))
		   chkexts (if check-ext vpp-library-extensions `("")))
	     (while chkexts
	       (setq fn (expand-file-name (concat filename (car chkexts))
					  chkdir))
	       ;;(message "Check for %s" fn)
	       (if (vpp-dir-file-exists-p fn)
		   (setq outlist (cons (expand-file-name
					fn (file-name-directory current))
				       outlist)))
		 (setq chkexts (cdr chkexts)))
	     (setq chkdirs (cdr chkdirs)))
	   (setq outlist (nreverse outlist))
	   (setq vpp-dir-cache-lib-filenames
		 (cons (list cache-key outlist)
		       vpp-dir-cache-lib-filenames))
	   outlist))))

(defun vpp-module-filenames (module current)
  "Return a search path to find the given MODULE name.
Uses the CURRENT filename, `vpp-library-extensions',
`vpp-library-directories' and `vpp-library-files'
variables to build the path."
  ;; Return search locations for it
  (append (list current)		; first, current buffer
	  (vpp-library-filenames module current t)
	  vpp-library-files))	; finally, any libraries

;;
;; Module Information
;;
;; Many of these functions work on "modi" a module information structure
;; A modi is:  [module-name-string file-name begin-point]

(defvar vpp-cache-enabled t
  "Non-nil enables caching of signals, etc.  Set to nil for debugging to make things SLOW!")

(defvar vpp-modi-cache-list nil
  "Cache of ((Module Function) Buf-Tick Buf-Modtime Func-Returns)...
For speeding up vpp-modi-get-* commands.
Buffer-local.")
(make-variable-buffer-local 'vpp-modi-cache-list)

(defvar vpp-modi-cache-preserve-tick nil
  "Modification tick after which the cache is still considered valid.
Use `vpp-preserve-modi-cache' to set it.")
(defvar vpp-modi-cache-preserve-buffer nil
  "Modification tick after which the cache is still considered valid.
Use `vpp-preserve-modi-cache' to set it.")
(defvar vpp-modi-cache-current-enable nil
  "Non-nil means allow caching `vpp-modi-current', set by let().")
(defvar vpp-modi-cache-current nil
  "Currently active `vpp-modi-current', if any, set by let().")
(defvar vpp-modi-cache-current-max nil
  "Current endmodule point for `vpp-modi-cache-current', if any.")

(defun vpp-modi-current ()
  "Return the modi structure for the module currently at point, possibly cached."
  (cond ((and vpp-modi-cache-current
	      (>= (point) (vpp-modi-get-point vpp-modi-cache-current))
	      (<= (point) vpp-modi-cache-current-max))
	 ;; Slow assertion, for debugging the cache:
	 ;;(or (equal vpp-modi-cache-current (vpp-modi-current-get)) (debug))
	 vpp-modi-cache-current)
	(vpp-modi-cache-current-enable
	 (setq vpp-modi-cache-current (vpp-modi-current-get)
	       vpp-modi-cache-current-max
	       ;; The cache expires when we pass "endmodule" as then the
	       ;; current modi may change to the next module
	       ;; This relies on the AUTOs generally inserting, not deleting text
	       (save-excursion
		 (vpp-re-search-forward-quick vpp-end-defun-re nil nil)))
	 vpp-modi-cache-current)
	(t
	 (vpp-modi-current-get))))

(defun vpp-modi-current-get ()
  "Return the modi structure for the module currently at point."
  (let* (name type pt)
    ;; read current module's name
    (save-excursion
      (vpp-re-search-backward-quick vpp-defun-re nil nil)
      (setq type (match-string-no-properties 0))
      (vpp-re-search-forward-quick "(" nil nil)
      (setq name (vpp-read-module-name))
      (setq pt (point)))
    ;; return modi - note this vector built two places
    (vpp-modi-new name (or (buffer-file-name) (current-buffer)) pt type)))

(defvar vpp-modi-lookup-cache nil "Hash of (modulename modi).")
(make-variable-buffer-local 'vpp-modi-lookup-cache)
(defvar vpp-modi-lookup-last-current nil "Cache of `current-buffer' at last lookup.")
(defvar vpp-modi-lookup-last-tick nil "Cache of `buffer-chars-modified-tick' at last lookup.")

(defun vpp-modi-lookup (module allow-cache &optional ignore-error)
  "Find the file and point at which MODULE is defined.
If ALLOW-CACHE is set, check and remember cache of previous lookups.
Return modi if successful, else print message unless IGNORE-ERROR is true."
  (let* ((current (or (buffer-file-name) (current-buffer)))
	 modi)
    ;; Check cache
    ;;(message "vpp-modi-lookup: %s" module)
    (cond ((and vpp-modi-lookup-cache
		vpp-cache-enabled
		allow-cache
		(setq modi (gethash module vpp-modi-lookup-cache))
		(equal vpp-modi-lookup-last-current current)
		;; Iff hit is in current buffer, then tick must match
		(or (equal vpp-modi-lookup-last-tick (buffer-chars-modified-tick))
		    (not (equal current (vpp-modi-file-or-buffer modi)))))
	   ;;(message "vpp-modi-lookup: HIT %S" modi)
	   modi)
	  ;; Miss
	  (t (let* ((realname (vpp-symbol-detick module t))
		    (orig-filenames (vpp-module-filenames realname current))
		    (filenames orig-filenames)
		    mif)
	       (while (and filenames (not mif))
		 (if (not (setq mif (vpp-module-inside-filename-p realname (car filenames))))
		     (setq filenames (cdr filenames))))
	       ;; mif has correct form to become later elements of modi
	       (cond (mif (setq modi mif))
		     (t (setq modi nil)
			(or ignore-error
			    (error (concat (vpp-point-text)
					   ": Can't locate " module " module definition"
					   (if (not (equal module realname))
					       (concat " (Expanded macro to " realname ")")
					     "")
					   "\n    Check the vpp-library-directories variable."
					   "\n    I looked in (if not listed, doesn't exist):\n\t"
					   (mapconcat 'concat orig-filenames "\n\t"))))))
	       (when (eval-when-compile (fboundp 'make-hash-table))
		 (unless vpp-modi-lookup-cache
		   (setq vpp-modi-lookup-cache
			 (make-hash-table :test 'equal :rehash-size 4.0)))
		 (puthash module modi vpp-modi-lookup-cache))
	       (setq vpp-modi-lookup-last-current current
		     vpp-modi-lookup-last-tick (buffer-chars-modified-tick)))))
    modi))

(defun vpp-modi-filename (modi)
  "Filename of MODI, or name of buffer if it's never been saved."
  (if (bufferp (vpp-modi-file-or-buffer modi))
      (or (buffer-file-name (vpp-modi-file-or-buffer modi))
	  (buffer-name (vpp-modi-file-or-buffer modi)))
    (vpp-modi-file-or-buffer modi)))

(defun vpp-modi-goto (modi)
  "Move point/buffer to specified MODI."
  (or modi (error "Passed unfound modi to goto, check earlier"))
  (set-buffer (if (bufferp (vpp-modi-file-or-buffer modi))
		  (vpp-modi-file-or-buffer modi)
		(find-file-noselect (vpp-modi-file-or-buffer modi))))
  (or (equal major-mode `vpp-mode)	;; Put into Vpp mode to get syntax
      (vpp-mode))
  (goto-char (vpp-modi-get-point modi)))

(defun vpp-goto-defun-file (module)
  "Move point to the file at which a given MODULE is defined."
  (interactive "sGoto File for Module: ")
  (let* ((modi (vpp-modi-lookup module nil)))
    (when modi
      (vpp-modi-goto modi)
      (switch-to-buffer (current-buffer)))))

(defun vpp-modi-cache-results (modi function)
  "Run on MODI the given FUNCTION.  Locate the module in a file.
Cache the output of function so next call may have faster access."
  (let (fass)
    (save-excursion  ;; Cache is buffer-local so can't avoid this.
      (vpp-modi-goto modi)
      (if (and (setq fass (assoc (list modi function)
				 vpp-modi-cache-list))
	       ;; Destroy caching when incorrect; Modified or file changed
	       (not (and vpp-cache-enabled
			 (or (equal (buffer-chars-modified-tick) (nth 1 fass))
			     (and vpp-modi-cache-preserve-tick
				  (<= vpp-modi-cache-preserve-tick  (nth 1 fass))
				  (equal  vpp-modi-cache-preserve-buffer (current-buffer))))
			 (equal (visited-file-modtime) (nth 2 fass)))))
	  (setq vpp-modi-cache-list nil
		fass nil))
      (cond (fass
	     ;; Return data from cache hit
	     (nth 3 fass))
	    (t
	     ;; Read from file
	     ;; Clear then restore any highlighting to make emacs19 happy
	     (let (func-returns)
	       (vpp-save-font-mods
		(setq func-returns (funcall function)))
	       ;; Cache for next time
	       (setq vpp-modi-cache-list
		     (cons (list (list modi function)
				 (buffer-chars-modified-tick)
				 (visited-file-modtime)
				 func-returns)
			   vpp-modi-cache-list))
	       func-returns))))))

(defun vpp-modi-cache-add (modi function element sig-list)
  "Add function return results to the module cache.
Update MODI's cache for given FUNCTION so that the return ELEMENT of that
function now contains the additional SIG-LIST parameters."
  (let (fass)
    (save-excursion
      (vpp-modi-goto modi)
      (if (setq fass (assoc (list modi function)
			    vpp-modi-cache-list))
	  (let ((func-returns (nth 3 fass)))
	    (aset func-returns element
		  (append sig-list (aref func-returns element))))))))

(defmacro vpp-preserve-modi-cache (&rest body)
  "Execute the BODY forms, allowing cache preservation within BODY.
This means that changes to the buffer will not result in the cache being
flushed.  If the changes affect the modsig state, they must call the
modsig-cache-add-* function, else the results of later calls may be
incorrect.  Without this, changes are assumed to be adding/removing signals
and invalidating the cache."
  `(let ((vpp-modi-cache-preserve-tick (buffer-chars-modified-tick))
	 (vpp-modi-cache-preserve-buffer (current-buffer)))
     (progn ,@body)))


(defun vpp-modi-modport-lookup-one (modi name &optional ignore-error)
  "Given a MODI, return the declarations related to the given modport NAME."
  ;; Recursive routine - see below
  (let* ((realname (vpp-symbol-detick name t))
	 (modport (assoc name (vpp-decls-get-modports (vpp-modi-get-decls modi)))))
    (or modport ignore-error
	(error (concat (vpp-point-text)
		       ": Can't locate " name " modport definition"
		       (if (not (equal name realname))
			   (concat " (Expanded macro to " realname ")")
			 ""))))
    (let* ((decls (vpp-modport-decls modport))
	   (clks (vpp-modport-clockings modport)))
      ;; Now expand any clocking's
      (while clks
	(setq decls (vpp-decls-append
		     decls
		     (vpp-modi-modport-lookup-one modi (car clks) ignore-error)))
	(setq clks (cdr clks)))
      decls)))

(defun vpp-modi-modport-lookup (modi name-re &optional ignore-error)
  "Given a MODI, return the declarations related to the given modport NAME-RE.
If the modport points to any clocking blocks, expand the signals to include
those clocking block's signals."
  ;; Recursive routine - see below
  (let* ((mod-decls (vpp-modi-get-decls modi))
	 (clks (vpp-decls-get-modports mod-decls))
	 (name-re (concat "^" name-re "$"))
	 (decls (vpp-decls-new nil nil nil nil nil nil nil nil nil)))
    ;; Pull in all modports
    (while clks
      (when (string-match name-re (vpp-modport-name (car clks)))
	(setq decls (vpp-decls-append
		     decls
		     (vpp-modi-modport-lookup-one modi (vpp-modport-name (car clks)) ignore-error))))
      (setq clks (cdr clks)))
    decls))

(defun vpp-signals-matching-enum (in-list enum)
  "Return all signals in IN-LIST matching the given ENUM."
  (let (out-list)
    (while in-list
      (if (equal (vpp-sig-enum (car in-list)) enum)
	  (setq out-list (cons (car in-list) out-list)))
      (setq in-list (cdr in-list)))
    ;; New scheme
    (let* ((enumvar (intern (concat "venum-" enum)))
	   (enumlist (and (boundp enumvar) (eval enumvar))))
      (while enumlist
	(add-to-list 'out-list (list (car enumlist)))
	(setq enumlist (cdr enumlist))))
    (nreverse out-list)))

(defun vpp-signals-matching-regexp (in-list regexp)
  "Return all signals in IN-LIST matching the given REGEXP, if non-nil."
  (if (or (not regexp) (equal regexp ""))
      in-list
    (let (out-list)
      (while in-list
	(if (string-match regexp (vpp-sig-name (car in-list)))
	    (setq out-list (cons (car in-list) out-list)))
	(setq in-list (cdr in-list)))
      (nreverse out-list))))

(defun vpp-signals-not-matching-regexp (in-list regexp)
  "Return all signals in IN-LIST not matching the given REGEXP, if non-nil."
  (if (or (not regexp) (equal regexp ""))
      in-list
    (let (out-list)
      (while in-list
	(if (not (string-match regexp (vpp-sig-name (car in-list))))
	    (setq out-list (cons (car in-list) out-list)))
	(setq in-list (cdr in-list)))
      (nreverse out-list))))

(defun vpp-signals-matching-dir-re (in-list decl-type regexp)
  "Return all signals in IN-LIST matching the given DECL-TYPE and REGEXP,
if non-nil."
  (if (or (not regexp) (equal regexp ""))
      in-list
    (let (out-list to-match)
      (while in-list
	;; Note vpp-insert-one-definition matches on this order
	(setq to-match (concat
			decl-type
			" " (vpp-sig-signed (car in-list))
			" " (vpp-sig-multidim (car in-list))
			(vpp-sig-bits (car in-list))))
	(if (string-match regexp to-match)
	    (setq out-list (cons (car in-list) out-list)))
	(setq in-list (cdr in-list)))
      (nreverse out-list))))

(defun vpp-signals-edit-wire-reg (in-list)
  "Return all signals in IN-LIST with wire/reg data types made blank."
  (mapcar (lambda (sig)
	    (when (member (vpp-sig-type sig) '("wire" "reg"))
	      (vpp-sig-type-set sig nil))
	    sig) in-list))

;; Combined
(defun vpp-decls-get-signals (decls)
  "Return all declared signals in DECLS, excluding 'assign' statements."
  (append
   (vpp-decls-get-outputs decls)
   (vpp-decls-get-inouts decls)
   (vpp-decls-get-inputs decls)
   (vpp-decls-get-vars decls)
   (vpp-decls-get-consts decls)
   (vpp-decls-get-gparams decls)))

(defun vpp-decls-get-ports (decls)
  (append
   (vpp-decls-get-outputs decls)
   (vpp-decls-get-inouts decls)
   (vpp-decls-get-inputs decls)))

(defun vpp-decls-get-iovars (decls)
  (append
   (vpp-decls-get-vars decls)
   (vpp-decls-get-outputs decls)
   (vpp-decls-get-inouts decls)
   (vpp-decls-get-inputs decls)))

(defsubst vpp-modi-cache-add-outputs (modi sig-list)
  (vpp-modi-cache-add modi 'vpp-read-decls 0 sig-list))
(defsubst vpp-modi-cache-add-inouts (modi sig-list)
  (vpp-modi-cache-add modi 'vpp-read-decls 1 sig-list))
(defsubst vpp-modi-cache-add-inputs (modi sig-list)
  (vpp-modi-cache-add modi 'vpp-read-decls 2 sig-list))
(defsubst vpp-modi-cache-add-vars (modi sig-list)
  (vpp-modi-cache-add modi 'vpp-read-decls 3 sig-list))
(defsubst vpp-modi-cache-add-gparams (modi sig-list)
  (vpp-modi-cache-add modi 'vpp-read-decls 7 sig-list))


;;
;; Auto creation utilities
;;

(defun vpp-auto-re-search-do (search-for func)
  "Search for the given auto text regexp SEARCH-FOR, and perform FUNC where it occurs."
  (goto-char (point-min))
  (while (vpp-re-search-forward-quick search-for nil t)
    (funcall func)))

(defun vpp-insert-one-definition (sig type indent-pt)
  "Print out a definition for SIG of the given TYPE,
with appropriate INDENT-PT indentation."
  (indent-to indent-pt)
  ;; Note vpp-signals-matching-dir-re matches on this order
  (insert type)
  (when (vpp-sig-modport sig)
    (insert "." (vpp-sig-modport sig)))
  (when (vpp-sig-signed sig)
    (insert " " (vpp-sig-signed sig)))
  (when (vpp-sig-multidim sig)
    (insert " " (vpp-sig-multidim-string sig)))
  (when (vpp-sig-bits sig)
    (insert " " (vpp-sig-bits sig)))
  (indent-to (max 24 (+ indent-pt 16)))
  (unless (= (char-syntax (preceding-char)) ?\  )
    (insert " "))  ; Need space between "]name" if indent-to did nothing
  (insert (vpp-sig-name sig))
  (when (vpp-sig-memory sig)
    (insert " " (vpp-sig-memory sig))))

(defun vpp-insert-definition (modi sigs direction indent-pt v2k &optional dont-sort)
  "Print out a definition for MODI's list of SIGS of the given DIRECTION,
with appropriate INDENT-PT indentation.  If V2K, use Vpp 2001 I/O
format.  Sort unless DONT-SORT.  DIRECTION is normally wire/reg/output.
When MODI is non-null, also add to modi-cache, for tracking."
  (when modi
    (cond ((equal direction "wire")
	   (vpp-modi-cache-add-vars modi sigs))
	  ((equal direction "reg")
	   (vpp-modi-cache-add-vars modi sigs))
	  ((equal direction "output")
	   (vpp-modi-cache-add-outputs modi sigs)
	   (when vpp-auto-declare-nettype
	     (vpp-modi-cache-add-vars modi sigs)))
	  ((equal direction "input")
	   (vpp-modi-cache-add-inputs modi sigs)
	   (when vpp-auto-declare-nettype
	     (vpp-modi-cache-add-vars modi sigs)))
	  ((equal direction "inout")
	   (vpp-modi-cache-add-inouts modi sigs)
	   (when vpp-auto-declare-nettype
	     (vpp-modi-cache-add-vars modi sigs)))
	  ((equal direction "interface"))
	  ((equal direction "parameter")
	   (vpp-modi-cache-add-gparams modi sigs))
	  (t
	   (error "Unsupported vpp-insert-definition direction: %s" direction))))
  (or dont-sort
      (setq sigs (sort (copy-alist sigs) `vpp-signals-sort-compare)))
  (while sigs
    (let ((sig (car sigs)))
      (vpp-insert-one-definition
       sig
       ;; Want "type x" or "output type x", not "wire type x"
       (cond ((or (vpp-sig-type sig)
		  vpp-auto-wire-type)
	      (concat
	       (when (member direction '("input" "output" "inout"))
		 (concat direction " "))
	       (or (vpp-sig-type sig)
		  vpp-auto-wire-type)))
	     ((and vpp-auto-declare-nettype
		   (member direction '("input" "output" "inout")))
	      (concat direction " " vpp-auto-declare-nettype))
	     (t
	      direction))
       indent-pt)
      (insert (if v2k "," ";"))
      (if (or (not (vpp-sig-comment sig))
	      (equal "" (vpp-sig-comment sig)))
	  (insert "\n")
	(indent-to (max 48 (+ indent-pt 40)))
	(vpp-insert "// " (vpp-sig-comment sig) "\n"))
      (setq sigs (cdr sigs)))))

(eval-when-compile
  (if (not (boundp 'indent-pt))
      (defvar indent-pt nil "Local used by insert-indent")))

(defun vpp-insert-indent (&rest stuff)
  "Indent to position stored in local `indent-pt' variable, then insert STUFF.
Presumes that any newlines end a list element."
  (let ((need-indent t))
    (while stuff
      (if need-indent (indent-to indent-pt))
      (setq need-indent nil)
      (vpp-insert (car stuff))
      (setq need-indent (string-match "\n$" (car stuff))
	    stuff (cdr stuff)))))
;;(let ((indent-pt 10)) (vpp-insert-indent "hello\n" "addon" "there\n"))

(defun vpp-forward-or-insert-line ()
  "Move forward a line, unless at EOB, then insert a newline."
  (if (eobp) (insert "\n")
    (forward-line)))

(defun vpp-repair-open-comma ()
  "Insert comma if previous argument is other than an open parenthesis or endif."
  ;; We can't just search backward for ) as it might be inside another expression.
  ;; Also want "`ifdef X   input foo   `endif" to just leave things to the human to deal with
  (save-excursion
    (vpp-backward-syntactic-ws-quick)
    (when (and (not (save-excursion ;; Not beginning (, or existing ,
		      (backward-char 1)
		      (looking-at "[(,]")))
	       (not (save-excursion ;; Not `endif, or user define
		      (backward-char 1)
		      (skip-chars-backward "[a-zA-Z0-9_`]")
		      (looking-at "`"))))
      (insert ","))))

(defun vpp-repair-close-comma ()
  "If point is at a comma followed by a close parenthesis, fix it.
This repairs those mis-inserted by an AUTOARG."
  ;; It would be much nicer if Vpp allowed extra commas like Perl does!
  (save-excursion
    (vpp-forward-close-paren)
    (backward-char 1)
    (vpp-backward-syntactic-ws-quick)
    (backward-char 1)
    (when (looking-at ",")
      (delete-char 1))))

(defun vpp-get-list (start end)
  "Return the elements of a comma separated list between START and END."
  (interactive)
  (let ((my-list (list))
	my-string)
    (save-excursion
      (while (< (point) end)
	(when (re-search-forward "\\([^,{]+\\)" end t)
	  (setq my-string (vpp-string-remove-spaces (match-string 1)))
	  (setq my-list (nconc my-list (list my-string) ))
	  (goto-char (match-end 0))))
      my-list)))

(defun vpp-make-width-expression (range-exp)
  "Return an expression calculating the length of a range [x:y] in RANGE-EXP."
  ;; strip off the []
  (cond ((not range-exp)
	 "1")
	(t
	 (if (string-match "^\\[\\(.*\\)\\]$" range-exp)
	     (setq range-exp (match-string 1 range-exp)))
	 (cond ((not range-exp)
		"1")
	       ;; [#:#] We can compute a numeric result
	       ((string-match "^\\s *\\([0-9]+\\)\\s *:\\s *\\([0-9]+\\)\\s *$"
			      range-exp)
		(int-to-string
		 (1+ (abs (- (string-to-number (match-string 1 range-exp))
			     (string-to-number (match-string 2 range-exp)))))))
	       ;; [PARAM-1:0] can just return PARAM
	       ((string-match "^\\s *\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s *-\\s *1\\s *:\\s *0\\s *$" range-exp)
		(match-string 1 range-exp))
	       ;; [arbitrary] need math
	       ((string-match "^\\(.*\\)\\s *:\\s *\\(.*\\)\\s *$" range-exp)
		(concat "(1+(" (match-string 1 range-exp) ")"
			(if (equal "0" (match-string 2 range-exp))
			    ""  ;; Don't bother with -(0)
			  (concat "-(" (match-string 2 range-exp) ")"))
			")"))
	       (t nil)))))
;;(vpp-make-width-expression "`A:`B")

(defun vpp-simplify-range-expression (expr)
  "Return a simplified range expression with constants eliminated from EXPR."
  ;; Note this is always called with brackets; ie [z] or [z:z]
  (if (not (string-match "[---+*()]" expr))
      expr ;; short-circuit
    (let ((out expr)
	  (last-pass ""))
      (while (not (equal last-pass out))
	(setq last-pass out)
	;; Prefix regexp needs beginning of match, or some symbol of
	;; lesser or equal precedence.  We assume the [:]'s exist in expr.
	;; Ditto the end.
	(while (string-match
		(concat "\\([[({:*+-]\\)"  ; - must be last
			"(\\<\\([0-9A-Za-z_]+\\))"
			"\\([])}:*+-]\\)")
		out)
	  (setq out (replace-match "\\1\\2\\3" nil nil out)))
	(while (string-match
		(concat "\\([[({:*+-]\\)"  ; - must be last
			"\\$clog2\\s *(\\<\\([0-9]+\\))"
			"\\([])}:*+-]\\)")
		out)
	  (setq out (replace-match
		     (concat
		      (match-string 1 out)
		      (int-to-string (vpp-clog2 (string-to-number (match-string 2 out))))
		      (match-string 3 out))
		     nil nil out)))
	;; For precedence do * before +/-
	(while (string-match
		(concat "\\([[({:*+-]\\)"
			"\\([0-9]+\\)\\s *\\([*]\\)\\s *\\([0-9]+\\)"
			"\\([])}:*+-]\\)")
		out)
	  (setq out (replace-match
		     (concat (match-string 1 out)
			     (int-to-string (* (string-to-number (match-string 2 out))
					       (string-to-number (match-string 4 out))))
			     (match-string 5 out))
		     nil nil out)))
	(while (string-match
		(concat "\\([[({:+-]\\)" ; No * here as higher prec
			"\\([0-9]+\\)\\s *\\([---+]\\)\\s *\\([0-9]+\\)"
			"\\([])}:+-]\\)")
		out)
	  (let ((pre (match-string 1 out))
		(lhs (string-to-number (match-string 2 out)))
		(rhs (string-to-number (match-string 4 out)))
		(post (match-string 5 out))
		val)
	    (when (equal pre "-")
	      (setq lhs (- lhs)))
	    (setq val (if (equal (match-string 3 out) "-")
			  (- lhs rhs)
			(+ lhs rhs))
		  out (replace-match
		       (concat (if (and (equal pre "-")
					(< val 0))
				   "" ;; Not "--20" but just "-20"
				 pre)
			       (int-to-string val)
			       post)
		       nil nil out)) )))
      out)))

;;(vpp-simplify-range-expression "[1:3]") ;; 1
;;(vpp-simplify-range-expression "[(1):3]") ;; 1
;;(vpp-simplify-range-expression "[(((16)+1)+1+(1+1))]")  ;;20
;;(vpp-simplify-range-expression "[(2*3+6*7)]") ;; 48
;;(vpp-simplify-range-expression "[(FOO*4-1*2)]") ;; FOO*4-2
;;(vpp-simplify-range-expression "[(FOO*4+1-1)]") ;; FOO*4+0
;;(vpp-simplify-range-expression "[(func(BAR))]") ;; func(BAR)
;;(vpp-simplify-range-expression "[FOO-1+1-1+1]") ;; FOO-0
;;(vpp-simplify-range-expression "[$clog2(2)]") ;; 1
;;(vpp-simplify-range-expression "[$clog2(7)]") ;; 3

(defun vpp-clog2 (value)
  "Compute $clog2 - ceiling log2 of VALUE."
  (if (< value 1)
      0
    (ceiling (/ (log value) (log 2)))))

(defun vpp-typedef-name-p (variable-name)
  "Return true if the VARIABLE-NAME is a type definition."
  (when vpp-typedef-regexp
    (string-match vpp-typedef-regexp variable-name)))

;;
;; Auto deletion
;;

(defun vpp-delete-autos-lined ()
  "Delete autos that occupy multiple lines, between begin and end comments."
  ;; The newline must not have a comment property, so we must
  ;; delete the end auto's newline, not the first newline
  (forward-line 1)
  (let ((pt (point)))
    (when (and
	   (looking-at "\\s-*// Beginning")
	   (search-forward "// End of automatic" nil t))
      ;; End exists
      (end-of-line)
      (forward-line 1)
      (delete-region pt (point)))))

(defun vpp-delete-empty-auto-pair ()
  "Delete begin/end auto pair at point, if empty."
  (forward-line 0)
  (when (looking-at (concat "\\s-*// Beginning of automatic.*\n"
			    "\\s-*// End of automatics\n"))
    (delete-region (point) (save-excursion (forward-line 2) (point)))))

(defun vpp-forward-close-paren ()
  "Find the close parenthesis that match the current point.
Ignore other close parenthesis with matching open parens."
  (let ((parens 1))
    (while (> parens 0)
      (unless (vpp-re-search-forward-quick "[()]" nil t)
	(error "%s: Mismatching ()" (vpp-point-text)))
      (cond ((= (preceding-char) ?\( )
	     (setq parens (1+ parens)))
	    ((= (preceding-char) ?\) )
	     (setq parens (1- parens)))))))

(defun vpp-backward-open-paren ()
  "Find the open parenthesis that match the current point.
Ignore other open parenthesis with matching close parens."
  (let ((parens 1))
    (while (> parens 0)
      (unless (vpp-re-search-backward-quick "[()]" nil t)
	(error "%s: Mismatching ()" (vpp-point-text)))
      (cond ((= (following-char) ?\) )
	     (setq parens (1+ parens)))
	    ((= (following-char) ?\( )
	     (setq parens (1- parens)))))))

(defun vpp-backward-open-bracket ()
  "Find the open bracket that match the current point.
Ignore other open bracket with matching close bracket."
  (let ((parens 1))
    (while (> parens 0)
      (unless (vpp-re-search-backward-quick "[][]" nil t)
	(error "%s: Mismatching []" (vpp-point-text)))
      (cond ((= (following-char) ?\] )
	     (setq parens (1+ parens)))
	    ((= (following-char) ?\[ )
	     (setq parens (1- parens)))))))

(defun vpp-delete-to-paren ()
  "Delete the automatic inst/sense/arg created by autos.
Deletion stops at the matching end parenthesis, outside comments."
  (delete-region (point)
		 (save-excursion
		   (vpp-backward-open-paren)
		   (vpp-forward-sexp-ign-cmt 1)   ;; Moves to paren that closes argdecl's
		   (backward-char 1)
		   (point))))

(defun vpp-auto-star-safe ()
  "Return if a .* AUTOINST is safe to delete or expand.
It was created by the AUTOS themselves, or by the user."
  (and vpp-auto-star-expand
       (looking-at
	(concat "[ \t\n\f,]*\\([)]\\|// " vpp-inst-comment-re "\\)"))))

(defun vpp-delete-auto-star-all ()
  "Delete a .* AUTOINST, if it is safe."
  (when (vpp-auto-star-safe)
    (vpp-delete-to-paren)))

(defun vpp-delete-auto-star-implicit ()
  "Delete all .* implicit connections created by `vpp-auto-star'.
This function will be called automatically at save unless
`vpp-auto-star-save' is set, any non-templated expanded pins will be
removed."
  (interactive)
  (let (paren-pt indent have-close-paren)
    (save-excursion
      (goto-char (point-min))
      ;; We need to match these even outside of comments.
      ;; For reasonable performance, we don't check if inside comments, sorry.
      (while (re-search-forward "// Implicit \\.\\*" nil t)
	(setq paren-pt (point))
	(beginning-of-line)
	(setq have-close-paren
	      (save-excursion
		(when (search-forward ");" paren-pt t)
		  (setq indent (current-indentation))
		  t)))
	(delete-region (point) (+ 1 paren-pt))  ; Nuke line incl CR
	(when have-close-paren
	  ;; Delete extra commentary
	  (save-excursion
	    (while (progn
		     (forward-line -1)
		     (looking-at (concat "\\s *//\\s *" vpp-inst-comment-re "\n")))
	      (delete-region (match-beginning 0) (match-end 0))))
	  ;; If it is simple, we can put the ); on the same line as the last text
	  (let ((rtn-pt (point)))
	    (save-excursion
	      (while (progn (backward-char 1)
			    (looking-at "[ \t\n\f]")))
	      (when (looking-at ",")
		(delete-region (+ 1 (point)) rtn-pt))))
	  (when (bolp)
	    (indent-to indent))
	  (insert ");\n")
	  ;; Still need to kill final comma - always is one as we put one after the .*
	  (re-search-backward ",")
	  (delete-char 1))))))

(defun vpp-delete-auto ()
  "Delete the automatic outputs, regs, and wires created by \\[vpp-auto].
Use \\[vpp-auto] to re-insert the updated AUTOs.

The hooks `vpp-before-delete-auto-hook' and `vpp-delete-auto-hook' are
called before and after this function, respectively."
  (interactive)
  (save-excursion
    (if (buffer-file-name)
	(find-file-noselect (buffer-file-name)))	;; To check we have latest version
    (vpp-save-no-change-functions
     (vpp-save-scan-cache
      ;; Allow user to customize
      (vpp-run-hooks 'vpp-before-delete-auto-hook)

      ;; Remove those that have multi-line insertions, possibly with parameters
      ;; We allow anything beginning with AUTO, so that users can add their own
      ;; patterns
      (vpp-auto-re-search-do
       (concat "/\\*AUTO[A-Za-z0-9_]+"
	       ;; Optional parens or quoted parameter or .* for (((...)))
	       "\\(\\|([^)]*)\\|(\"[^\"]*\")\\).*?"
	       "\\*/")
       'vpp-delete-autos-lined)
      ;; Remove those that are in parenthesis
      (vpp-auto-re-search-do
       (concat "/\\*"
	       (eval-when-compile
		 (vpp-regexp-words
		  `("AS" "AUTOARG" "AUTOCONCATWIDTH" "AUTOINST" "AUTOINSTPARAM"
		    "AUTOSENSE")))
	       "\\*/")
       'vpp-delete-to-paren)
      ;; Do .* instantiations, but avoid removing any user pins by looking for our magic comments
      (vpp-auto-re-search-do "\\.\\*"
				 'vpp-delete-auto-star-all)
      ;; Remove template comments ... anywhere in case was pasted after AUTOINST removed
      (goto-char (point-min))
      (while (re-search-forward "\\s-*// \\(Templated\\|Implicit \\.\\*\\)\\([ \tLT0-9]*\\| LHS: .*\\)?$" nil t)
	(replace-match ""))

      ;; Final customize
      (vpp-run-hooks 'vpp-delete-auto-hook)))))

;;
;; Auto inject
;;

(defun vpp-inject-auto ()
  "Examine legacy non-AUTO code and insert AUTOs in appropriate places.

Any always @ blocks with sensitivity lists that match computed lists will
be replaced with /*AS*/ comments.

Any cells will get /*AUTOINST*/ added to the end of the pin list.
Pins with have identical names will be deleted.

Argument lists will not be deleted, /*AUTOARG*/ will only be inserted to
support adding new ports.  You may wish to delete older ports yourself.

For example:

	module ExampInject (i, o);
	  input i;
	  input j;
	  output o;
	  always @ (i or j)
	     o = i | j;
	  InstModule instName
            (.foobar(baz),
	     j(j));
	endmodule

Typing \\[vpp-inject-auto] will make this into:

	module ExampInject (i, o/*AUTOARG*/
	  // Inputs
	  j);
	  input i;
	  output o;
	  always @ (/*AS*/i or j)
	     o = i | j;
	  InstModule instName
            (.foobar(baz),
	     /*AUTOINST*/
	     // Outputs
	     j(j));
	endmodule"
  (interactive)
  (vpp-auto t))

(defun vpp-inject-arg ()
  "Inject AUTOARG into new code.  See `vpp-inject-auto'."
  ;; Presume one module per file.
  (save-excursion
    (goto-char (point-min))
    (while (vpp-re-search-forward-quick "\\<module\\>" nil t)
      (let ((endmodp (save-excursion
		       (vpp-re-search-forward-quick "\\<endmodule\\>" nil t)
		       (point))))
	;; See if there's already a comment .. inside a comment so not vpp-re-search
	(when (not (re-search-forward "/\\*AUTOARG\\*/" endmodp t))
	  (vpp-re-search-forward-quick ";" nil t)
	  (backward-char 1)
	  (vpp-backward-syntactic-ws-quick)
	  (backward-char 1) ; Moves to paren that closes argdecl's
	  (when (looking-at ")")
	    (vpp-insert "/*AUTOARG*/")))))))

(defun vpp-inject-sense ()
  "Inject AUTOSENSE into new code.  See `vpp-inject-auto'."
  (save-excursion
    (goto-char (point-min))
    (while (vpp-re-search-forward-quick "\\<always\\s *@\\s *(" nil t)
      (let* ((start-pt (point))
	     (modi (vpp-modi-current))
	     (moddecls (vpp-modi-get-decls modi))
	     pre-sigs
	     got-sigs)
	(backward-char 1)
	(vpp-forward-sexp-ign-cmt 1)
	(backward-char 1) ;; End )
	(when (not (vpp-re-search-backward-quick "/\\*\\(AUTOSENSE\\|AS\\)\\*/" start-pt t))
	  (setq pre-sigs (vpp-signals-from-signame
			  (vpp-read-signals start-pt (point)))
		got-sigs (vpp-auto-sense-sigs moddecls nil))
	  (when (not (or (vpp-signals-not-in pre-sigs got-sigs)  ; Both are equal?
			 (vpp-signals-not-in got-sigs pre-sigs)))
	    (delete-region start-pt (point))
	    (vpp-insert "/*AS*/")))))))

(defun vpp-inject-inst ()
  "Inject AUTOINST into new code.  See `vpp-inject-auto'."
  (save-excursion
    (goto-char (point-min))
    ;; It's hard to distinguish modules; we'll instead search for pins.
    (while (vpp-re-search-forward-quick "\\.\\s *[a-zA-Z0-9`_\$]+\\s *(\\s *[a-zA-Z0-9`_\$]+\\s *)" nil t)
      (vpp-backward-open-paren) ;; Inst start
      (cond
       ((= (preceding-char) ?\#)  ;; #(...) parameter section, not pin.  Skip.
	(forward-char 1)
	(vpp-forward-close-paren)) ;; Parameters done
       (t
	(forward-char 1)
	(let ((indent-pt (+ (current-column)))
	      (end-pt (save-excursion (vpp-forward-close-paren) (point))))
	  (cond ((vpp-re-search-forward-quick "\\(/\\*AUTOINST\\*/\\|\\.\\*\\)" end-pt t)
		 (goto-char end-pt)) ;; Already there, continue search with next instance
		(t
		 ;; Delete identical interconnect
		 (let ((case-fold-search nil))  ;; So we don't convert upper-to-lower, etc
		   (while (vpp-re-search-forward-quick "\\.\\s *\\([a-zA-Z0-9`_\$]+\\)*\\s *(\\s *\\1\\s *)\\s *" end-pt t)
		     (delete-region (match-beginning 0) (match-end 0))
		     (setq end-pt (- end-pt (- (match-end 0) (match-beginning 0)))) ;; Keep it correct
		     (while (or (looking-at "[ \t\n\f,]+")
				(looking-at "//[^\n]*"))
		       (delete-region (match-beginning 0) (match-end 0))
		       (setq end-pt (- end-pt (- (match-end 0) (match-beginning 0)))))))
		 (vpp-forward-close-paren)
		 (backward-char 1)
		 ;; Not vpp-re-search, as we don't want to strip comments
		 (while (re-search-backward "[ \t\n\f]+" (- (point) 1) t)
		   (delete-region (match-beginning 0) (match-end 0)))
		 (vpp-insert "\n")
		 (vpp-insert-indent "/*AUTOINST*/")))))))))

;;
;; Auto diff
;;

(defun vpp-diff-buffers-p (b1 b2 &optional whitespace)
  "Return nil if buffers B1 and B2 have same contents.
Else, return point in B1 that first mismatches.
If optional WHITESPACE true, ignore whitespace."
  (save-excursion
    (let* ((case-fold-search nil)  ;; compare-buffer-substrings cares
	   (p1 (with-current-buffer b1 (goto-char (point-min))))
	   (p2 (with-current-buffer b2 (goto-char (point-min))))
	   (maxp1 (with-current-buffer b1 (point-max)))
	   (maxp2 (with-current-buffer b2 (point-max)))
	   (op1 -1) (op2 -1)
	   progress size)
      (while (not (and (eq p1 op1) (eq p2 op2)))
	;; If both windows have whitespace optionally skip over it.
	(when whitespace
	  ;; skip-syntax-* doesn't count \n
	  (with-current-buffer b1
	    (goto-char p1)
	    (skip-chars-forward " \t\n\r\f\v")
	    (setq p1 (point)))
	  (with-current-buffer b2
	    (goto-char p2)
	    (skip-chars-forward " \t\n\r\f\v")
	    (setq p2 (point))))
	(setq size (min (- maxp1 p1) (- maxp2 p2)))
	(setq progress (compare-buffer-substrings b2 p2 (+ size p2)
						  b1 p1 (+ size p1)))
	(setq progress (if (zerop progress) size (1- (abs progress))))
	(setq op1 p1  op2 p2
	      p1 (+ p1 progress)
	      p2 (+ p2 progress)))
      ;; Return value
      (if (and (eq p1 maxp1) (eq p2 maxp2))
	  nil p1))))

(defun vpp-diff-file-with-buffer (f1 b2 &optional whitespace show)
  "View the differences between file F1 and buffer B2.
This requires the external program `diff-command' to be in your `exec-path',
and uses `diff-switches' in which you may want to have \"-u\" flag.
Ignores WHITESPACE if t, and writes output to stdout if SHOW."
  ;; Similar to `diff-buffer-with-file' but works on XEmacs, and doesn't
  ;; call `diff' as `diff' has different calling semantics on different
  ;; versions of Emacs.
  (if (not (file-exists-p f1))
      (message "Buffer %s has no associated file on disc" (buffer-name b2))
    (with-temp-buffer "*Vpp-Diff*"
      (let ((outbuf (current-buffer))
	    (f2 (make-temp-file "vm-diff-auto-")))
	(unwind-protect
	    (progn
	      (with-current-buffer b2
		(save-restriction
		  (widen)
		  (write-region (point-min) (point-max) f2 nil 'nomessage)))
	      (call-process diff-command nil outbuf t
			    diff-switches ;; User may want -u in diff-switches
			    (if whitespace "-b" "")
			    f1 f2)
	      ;; Print out results.  Alternatively we could have call-processed
	      ;; ourself, but this way we can reuse diff switches
	      (when show
		(with-current-buffer outbuf (message "%s" (buffer-string))))))
	(sit-for 0)
	(when (file-exists-p f2)
	  (delete-file f2))))))

(defun vpp-diff-report (b1 b2 diffpt)
  "Report differences detected with `vpp-diff-auto'.
Differences are between buffers B1 and B2, starting at point
DIFFPT.  This function is called via `vpp-diff-function'."
  (let ((name1 (with-current-buffer b1 (buffer-file-name))))
    (vpp-warn "%s:%d: Difference in AUTO expansion found"
		  name1 (with-current-buffer b1
			  (1+ (count-lines (point-min) (point)))))
    (cond (noninteractive
	   (vpp-diff-file-with-buffer name1 b2 t t))
	  (t
	   (ediff-buffers b1 b2)))))

(defun vpp-diff-auto ()
  "Expand AUTOs in a temporary buffer and indicate any change.
Whitespace differences are ignored to determine identicalness, but
once a difference is detected, whitespace differences may be shown.

To call this from the command line, see \\[vpp-batch-diff-auto].

The action on differences is selected with
`vpp-diff-function'.  The default is `vpp-diff-report'
which will report an error and run `ediff' in interactive mode,
or `diff' in batch mode."
  (interactive)
  (let ((b1 (current-buffer)) b2 diffpt
	(name1 (buffer-file-name))
	(newname "*Vpp-Diff*"))
    (save-excursion
      (when (get-buffer newname)
	(kill-buffer newname))
      (setq b2 (let (buffer-file-name)  ;; Else clone is upset
		 (clone-buffer newname)))
      (with-current-buffer b2
	;; auto requires the filename, but can't have same filename in two
	;; buffers; so override both b1 and b2's names
	(let ((buffer-file-name name1))
	  (unwind-protect
	      (progn
		(with-current-buffer b1 (setq buffer-file-name nil))
		(vpp-auto)
		(when (not vpp-auto-star-save)
		  (vpp-delete-auto-star-implicit)))
	    ;; Restore name if unwind
	    (with-current-buffer b1 (setq buffer-file-name name1)))))
      ;;
      (setq diffpt (vpp-diff-buffers-p b1 b2 t))
      (cond ((not diffpt)
	     (unless noninteractive (message "AUTO expansion identical"))
	     (kill-buffer newname)) ;; Nice to cleanup after oneself
	    (t
	     (funcall vpp-diff-function b1 b2 diffpt)))
      ;; Return result of compare
      diffpt)))


;;
;; Auto save
;;

(defun vpp-auto-save-check ()
  "On saving see if we need auto update."
  (cond ((not vpp-auto-save-policy)) ; disabled
	((not (save-excursion
		(save-match-data
		  (let ((case-fold-search nil))
		    (goto-char (point-min))
		    (re-search-forward "AUTO" nil t))))))
	((eq vpp-auto-save-policy 'force)
	 (vpp-auto))
	((not (buffer-modified-p)))
	((eq vpp-auto-update-tick (buffer-chars-modified-tick))) ; up-to-date
	((eq vpp-auto-save-policy 'detect)
	 (vpp-auto))
	(t
	 (when (yes-or-no-p "AUTO statements not recomputed, do it now? ")
	   (vpp-auto))
	 ;; Don't ask again if didn't update
	 (set (make-local-variable 'vpp-auto-update-tick) (buffer-chars-modified-tick))))
  (when (not vpp-auto-star-save)
    (vpp-delete-auto-star-implicit))
  nil)	;; Always return nil -- we don't write the file ourselves

(defun vpp-auto-read-locals ()
  "Return file local variable segment at bottom of file."
  (save-excursion
    (goto-char (point-max))
    (if (re-search-backward "Local Variables:" nil t)
	(buffer-substring-no-properties (point) (point-max))
      "")))

(defun vpp-auto-reeval-locals (&optional force)
  "Read file local variable segment at bottom of file if it has changed.
If FORCE, always reread it."
  (let ((curlocal (vpp-auto-read-locals)))
    (when (or force (not (equal vpp-auto-last-file-locals curlocal)))
      (set (make-local-variable 'vpp-auto-last-file-locals) curlocal)
      ;; Note this may cause this function to be recursively invoked,
      ;; because hack-local-variables may call (vpp-mode)
      ;; The above when statement will prevent it from recursing forever.
      (hack-local-variables)
      t)))

;;
;; Auto creation
;;

(defun vpp-auto-arg-ports (sigs message indent-pt)
  "Print a list of ports for an AUTOINST.
Takes SIGS list, adds MESSAGE to front and inserts each at INDENT-PT."
  (when sigs
    (when vpp-auto-arg-sort
      (setq sigs (sort (copy-alist sigs) `vpp-signals-sort-compare)))
    (insert "\n")
    (indent-to indent-pt)
    (insert message)
    (insert "\n")
    (let ((space ""))
      (indent-to indent-pt)
      (while sigs
	(cond ((> (+ 2 (current-column) (length (vpp-sig-name (car sigs)))) fill-column)
	       (insert "\n")
	       (indent-to indent-pt))
	      (t (insert space)))
	(insert (vpp-sig-name (car sigs)) ",")
	(setq sigs (cdr sigs)
	      space " ")))))

(defun vpp-auto-arg ()
  "Expand AUTOARG statements.
Replace the argument declarations at the beginning of the
module with ones automatically derived from input and output
statements.  This can be dangerous if the module is instantiated
using position-based connections, so use only name-based when
instantiating the resulting module.  Long lines are split based
on the `fill-column', see \\[set-fill-column].

Limitations:
  Concatenation and outputting partial buses is not supported.

  Typedefs must match `vpp-typedef-regexp', which is disabled by default.

For example:

	module ExampArg (/*AUTOARG*/);
	  input i;
	  output o;
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampArg (/*AUTOARG*/
	  // Outputs
	  o,
	  // Inputs
	  i
	);
	  input i;
	  output o;
	endmodule

The argument declarations may be printed in declaration order to best suit
order based instantiations, or alphabetically, based on the
`vpp-auto-arg-sort' variable.

Any ports declared between the ( and /*AUTOARG*/ are presumed to be
predeclared and are not redeclared by AUTOARG.  AUTOARG will make a
conservative guess on adding a comma for the first signal, if you have
any ifdefs or complicated expressions before the AUTOARG you will need
to choose the comma yourself.

Avoid declaring ports manually, as it makes code harder to maintain."
  (save-excursion
    (let* ((modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (skip-pins (aref (vpp-read-arg-pins) 0)))
      (vpp-repair-open-comma)
      (vpp-auto-arg-ports (vpp-signals-not-in
			       (vpp-decls-get-outputs moddecls)
			       skip-pins)
			      "// Outputs"
			      vpp-indent-level-declaration)
      (vpp-auto-arg-ports (vpp-signals-not-in
			       (vpp-decls-get-inouts moddecls)
			       skip-pins)
			      "// Inouts"
			      vpp-indent-level-declaration)
      (vpp-auto-arg-ports (vpp-signals-not-in
			       (vpp-decls-get-inputs moddecls)
			       skip-pins)
			      "// Inputs"
			      vpp-indent-level-declaration)
      (vpp-repair-close-comma)
      (unless (eq (char-before) ?/ )
	(insert "\n"))
      (indent-to vpp-indent-level-declaration))))

(defun vpp-auto-assign-modport ()
  "Expand AUTOASSIGNMODPORT statements, as part of \\[vpp-auto].
Take input/output/inout statements from the specified interface
and modport and use to build assignments into the modport, for
making verification modules that connect to UVM interfaces.

  The first parameter is the name of an interface.

  The second parameter is a regexp of modports to read from in
  that interface.

  The third parameter is the instance name to use to dot reference into.

  The optional fourth parameter is a regular expression, and only
  signals matching the regular expression will be included.

Limitations:

  Interface names must be resolvable to filenames.  See `vpp-auto-inst'.

  Inouts are not supported, as assignments must be unidirectional.

  If a signal is part of the interface header and in both a
  modport and the interface itself, it will not be listed.  (As
  this would result in a syntax error when the connections are
  made.)

See the example in `vpp-auto-inout-modport'."
  (save-excursion
    (let* ((params (vpp-read-auto-params 3 4))
	   (submod (nth 0 params))
	   (modport-re (nth 1 params))
	   (inst-name (nth 2 params))
	   (regexp (nth 3 params))
	   direction-re submodi) ;; direction argument not supported until requested
      ;; Lookup position, etc of co-module
      ;; Note this may raise an error
      (when (setq submodi (vpp-modi-lookup submod t))
	(let* ((indent-pt (current-indentation))
	       (modi (vpp-modi-current))
	       (submoddecls (vpp-modi-get-decls submodi))
	       (submodportdecls (vpp-modi-modport-lookup submodi modport-re))
	       (sig-list-i (vpp-signals-in ;; Decls doesn't have data types, must resolve
			    (vpp-decls-get-vars submoddecls)
			    (vpp-signals-not-in
			     (vpp-decls-get-inputs submodportdecls)
			     (vpp-decls-get-ports submoddecls))))
	       (sig-list-o (vpp-signals-in ;; Decls doesn't have data types, must resolve
			    (vpp-decls-get-vars submoddecls)
			    (vpp-signals-not-in
			     (vpp-decls-get-outputs submodportdecls)
			     (vpp-decls-get-ports submoddecls)))))
	  (forward-line 1)
	  (setq sig-list-i  (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-i regexp)
			      "input" direction-re))
		sig-list-o  (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-o regexp)
			      "output" direction-re)))
	  (setq sig-list-i (sort (copy-alist sig-list-i) `vpp-signals-sort-compare))
	  (setq sig-list-o (sort (copy-alist sig-list-o) `vpp-signals-sort-compare))
	  (when (or sig-list-i sig-list-o)
	    (vpp-insert-indent "// Beginning of automatic assignments from modport\n")
	    ;; Don't sort them so an upper AUTOINST will match the main module
	    (let ((sigs sig-list-o))
	      (while sigs
		(vpp-insert-indent "assign " (vpp-sig-name (car sigs))
				       " = " inst-name
				       "." (vpp-sig-name (car sigs)) ";\n")
		(setq sigs (cdr sigs))))
	    (let ((sigs sig-list-i))
	      (while sigs
		(vpp-insert-indent "assign " inst-name
				       "." (vpp-sig-name (car sigs))
				       " = " (vpp-sig-name (car sigs)) ";\n")
		(setq sigs (cdr sigs))))
	    (vpp-insert-indent "// End of automatics\n")))))))

(defun vpp-auto-inst-port-map (port-st)
  nil)

(defvar vl-cell-type nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-cell-name nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-modport   nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-name  nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-width nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-dir   nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-bits  nil "See `vpp-auto-inst'.") ; Prevent compile warning
(defvar vl-mbits nil "See `vpp-auto-inst'.") ; Prevent compile warning

(defun vpp-auto-inst-port (port-st indent-pt tpl-list tpl-num for-star par-values)
  "Print out an instantiation connection for this PORT-ST.
Insert to INDENT-PT, use template TPL-LIST.
@ are instantiation numbers, replaced with TPL-NUM.
@\"(expression @)\" are evaluated, with @ as a variable.
If FOR-STAR add comment it is a .* expansion.
If PAR-VALUES replace final strings with these parameter values."
  (let* ((port (vpp-sig-name port-st))
	 (tpl-ass (or (assoc port (car tpl-list))
		      (vpp-auto-inst-port-map port-st)))
	 ;; vl-* are documented for user use
	 (vl-name (vpp-sig-name port-st))
	 (vl-width (vpp-sig-width port-st))
	 (vl-modport (vpp-sig-modport port-st))
	 (vl-mbits (if (vpp-sig-multidim port-st)
                       (vpp-sig-multidim-string port-st) ""))
	 (vl-bits (if (or vpp-auto-inst-vector
			  (not (assoc port vector-skip-list))
			  (not (equal (vpp-sig-bits port-st)
				      (vpp-sig-bits (assoc port vector-skip-list)))))
		      (or (vpp-sig-bits port-st) "")
		    ""))
	 (case-fold-search nil)
	 (check-values par-values)
	 tpl-net)
    ;; Replace parameters in bit-width
    (when (and check-values
	       (not (equal vl-bits "")))
      (while check-values
	(setq vl-bits (vpp-string-replace-matches
		       (concat "\\<" (nth 0 (car check-values)) "\\>")
		       (concat "(" (nth 1 (car check-values)) ")")
		       t t vl-bits)
	      vl-mbits (vpp-string-replace-matches
			(concat "\\<" (nth 0 (car check-values)) "\\>")
			(concat "(" (nth 1 (car check-values)) ")")
			t t vl-mbits)
	      check-values (cdr check-values)))
      (setq vl-bits (vpp-simplify-range-expression vl-bits)
	    vl-mbits (vpp-simplify-range-expression vl-mbits)
	    vl-width (vpp-make-width-expression vl-bits))) ; Not in the loop for speed
    ;; Default net value if not found
    (setq tpl-net (concat port
			  (if vl-modport (concat "." vl-modport) "")
			  (if (vpp-sig-multidim port-st)
			      (concat "/*" vl-mbits vl-bits "*/")
			    (concat vl-bits))))
    ;; Find template
    (cond (tpl-ass	    ; Template of exact port name
	   (setq tpl-net (nth 1 tpl-ass)))
	  ((nth 1 tpl-list) ; Wildcards in template, search them
	   (let ((wildcards (nth 1 tpl-list)))
	     (while wildcards
	       (when (string-match (nth 0 (car wildcards)) port)
		 (setq tpl-ass (car wildcards)  ; so allow @ parsing
		       tpl-net (replace-match (nth 1 (car wildcards))
					      t nil port)))
	       (setq wildcards (cdr wildcards))))))
    ;; Parse Templated variable
    (when tpl-ass
      ;; Evaluate @"(lispcode)"
      (when (string-match "@\".*[^\\]\"" tpl-net)
	(while (string-match "@\"\\(\\([^\\\"]*\\(\\\\.\\)*\\)*\\)\"" tpl-net)
	  (setq tpl-net
		(concat
		 (substring tpl-net 0 (match-beginning 0))
		 (save-match-data
		   (let* ((expr (match-string 1 tpl-net))
			  (value
			   (progn
			     (setq expr (vpp-string-replace-matches "\\\\\"" "\"" nil nil expr))
			     (setq expr (vpp-string-replace-matches "@" tpl-num nil nil expr))
			     (prin1 (eval (car (read-from-string expr)))
				    (lambda (ch) ())))))
		     (if (numberp value) (setq value (number-to-string value)))
		     value))
		 (substring tpl-net (match-end 0))))))
      ;; Replace @ and [] magic variables in final output
      (setq tpl-net (vpp-string-replace-matches "@" tpl-num nil nil tpl-net))
      (setq tpl-net (vpp-string-replace-matches "\\[\\]" vl-bits nil nil tpl-net)))
    ;; Insert it
    (indent-to indent-pt)
    (insert "." port)
    (unless (and vpp-auto-inst-dot-name
		 (equal port tpl-net))
      (indent-to vpp-auto-inst-column)
      (insert "(" tpl-net ")"))
    (insert ",")
    (cond (tpl-ass
	   (vpp-read-auto-template-hit tpl-ass)
	   (indent-to (+ (if (< vpp-auto-inst-column 48) 24 16)
			 vpp-auto-inst-column))
	   ;; vpp-insert requires the complete comment in one call - including the newline
	   (cond ((equal vpp-auto-inst-template-numbers `lhs)
		  (vpp-insert " // Templated"
				  " LHS: " (nth 0 tpl-ass)
				  "\n"))
		 (vpp-auto-inst-template-numbers
		  (vpp-insert " // Templated"
				  " T" (int-to-string (nth 2 tpl-ass))
				  " L" (int-to-string (nth 3 tpl-ass))
				  "\n"))
		 (t
		  (vpp-insert " // Templated\n"))))
	  (for-star
	   (indent-to (+ (if (< vpp-auto-inst-column 48) 24 16)
			 vpp-auto-inst-column))
	   (vpp-insert " // Implicit .\*\n")) ;For some reason the . or * must be escaped...
	  (t
	   (insert "\n")))))
;;(vpp-auto-inst-port (list "foo" "[5:0]") 10 (list (list "foo" "a@\"(% (+ @ 1) 4)\"a")) "3")
;;(x "incom[@\"(+ (* 8 @) 7)\":@\"(* 8 @)\"]")
;;(x ".out (outgo[@\"(concat (+ (* 8 @) 7) \\\":\\\" ( * 8 @))\"]));")

(defun vpp-auto-inst-port-list (sig-list indent-pt tpl-list tpl-num for-star par-values)
  "For `vpp-auto-inst' print a list of ports using `vpp-auto-inst-port'."
  (when vpp-auto-inst-sort
    (setq sig-list (sort (copy-alist sig-list) `vpp-signals-sort-compare)))
  (mapc (lambda (port)
	  (vpp-auto-inst-port port indent-pt
				  tpl-list tpl-num for-star par-values))
	sig-list))

(defun vpp-auto-inst-first ()
  "Insert , etc before first ever port in this instant, as part of \\[vpp-auto-inst]."
  ;; Do we need a trailing comma?
  ;; There maybe an ifdef or something similar before us.  What a mess.  Thus
  ;; to avoid trouble we only insert on preceding ) or *.
  ;; Insert first port on new line
  (insert "\n")  ;; Must insert before search, so point will move forward if insert comma
  (save-excursion
    (vpp-re-search-backward-quick "[^ \t\n\f]" nil nil)
    (when (looking-at ")\\|\\*")  ;; Generally don't insert, unless we are fairly sure
      (forward-char 1)
      (insert ","))))

(defun vpp-auto-star ()
  "Expand SystemVpp .* pins, as part of \\[vpp-auto].

If `vpp-auto-star-expand' is set, .* pins are treated if they were
AUTOINST statements, otherwise they are ignored.  For safety, Vpp mode
will also ignore any .* that are not last in your pin list (this prevents
it from deleting pins following the .* when it expands the AUTOINST.)

On writing your file, unless `vpp-auto-star-save' is set, any
non-templated expanded pins will be removed.  You may do this at any time
with \\[vpp-delete-auto-star-implicit].

If you are converting a module to use .* for the first time, you may wish
to use \\[vpp-inject-auto] and then replace the created AUTOINST with .*.

See `vpp-auto-inst' for examples, templates, and more information."
  (when (vpp-auto-star-safe)
    (vpp-auto-inst)))

(defun vpp-auto-inst ()
  "Expand AUTOINST statements, as part of \\[vpp-auto].
Replace the pin connections to an instantiation or interface
declaration with ones automatically derived from the module or
interface header of the instantiated item.

If `vpp-auto-star-expand' is set, also expand SystemVpp .* ports,
and delete them before saving unless `vpp-auto-star-save' is set.
See `vpp-auto-star' for more information.

The pins are printed in declaration order or alphabetically,
based on the `vpp-auto-inst-sort' variable.

Limitations:
  Module names must be resolvable to filenames by adding a
  `vpp-library-extensions', and being found in the same directory, or
  by changing the variable `vpp-library-flags' or
  `vpp-library-directories'.  Macros `modname are translated through the
  vh-{name} Emacs variable, if that is not found, it just ignores the `.

  In templates you must have one signal per line, ending in a ), or ));,
  and have proper () nesting, including a final ); to end the template.

  Typedefs must match `vpp-typedef-regexp', which is disabled by default.

  SystemVpp multidimensional input/output has only experimental support.

  SystemVpp .name syntax is used if `vpp-auto-inst-dot-name' is set.

  Parameters referenced by the instantiation will remain symbolic, unless
  `vpp-auto-inst-param-value' is set.

  Gate primitives (and/or) may have AUTOINST for the purpose of
  AUTOWIRE declarations, etc.  Gates are the only case when
  position based connections are passed.

For example, first take the submodule InstModule.v:

	module InstModule (o,i);
	   output [31:0] o;
	   input i;
	   wire [31:0] o = {32{i}};
	endmodule

This is then used in an upper level module:

	module ExampInst (o,i);
	   output o;
	   input i;
	   InstModule instName
	     (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampInst (o,i);
	   output o;
	   input i;
	   InstModule instName
	     (/*AUTOINST*/
	      // Outputs
	      .ov	(ov[31:0]),
	      // Inputs
	      .i	(i));
	endmodule

Where the list of inputs and outputs came from the inst module.

Exceptions:

  Unless you are instantiating a module multiple times, or the module is
  something trivial like an adder, DO NOT CHANGE SIGNAL NAMES ACROSS HIERARCHY.
  It just makes for unmaintainable code.  To sanitize signal names, try
  vrename from URL `http://www.veripool.org'.

  When you need to violate this suggestion there are two ways to list
  exceptions, placing them before the AUTOINST, or using templates.

  Any ports defined before the /*AUTOINST*/ are not included in the list of
  automatics.  This is similar to making a template as described below, but
  is restricted to simple connections just like you normally make.  Also note
  that any signals before the AUTOINST will only be picked up by AUTOWIRE if
  you have the appropriate // Input or // Output comment, and exactly the
  same line formatting as AUTOINST itself uses.

	InstModule instName
          (// Inputs
	   .i		(my_i_dont_mess_with_it),
	   /*AUTOINST*/
	   // Outputs
	   .ov		(ov[31:0]));


Templates:

  For multiple instantiations based upon a single template, create a
  commented out template:

	/* InstModule AUTO_TEMPLATE (
		.sig3	(sigz[]),
		);
	*/

  Templates go ABOVE the instantiation(s).  When an instantiation is
  expanded `vpp-mode' simply searches up for the closest template.
  Thus you can have multiple templates for the same module, just alternate
  between the template for an instantiation and the instantiation itself.
  (For backward compatibility if no template is found above, it
  will also look below, but do not use this behavior in new designs.)

  The module name must be the same as the name of the module in the
  instantiation name, and the code \"AUTO_TEMPLATE\" must be in these exact
  words and capitalized.  Only signals that must be different for each
  instantiation need to be listed.

  Inside a template, a [] in a connection name (with nothing else inside
  the brackets) will be replaced by the same bus subscript as it is being
  connected to, or the [] will be removed if it is a single bit signal.
  Generally it is a good idea to do this for all connections in a template,
  as then they will work for any width signal, and with AUTOWIRE.  See
  PTL_BUS becoming PTL_BUSNEW below.

  If you have a complicated template, set `vpp-auto-inst-template-numbers'
  to see which regexps are matching.  Don't leave that mode set after
  debugging is completed though, it will result in lots of extra differences
  and merge conflicts.

  Setting `vpp-auto-template-warn-unused' will report errors
  if any template lines are unused.

  For example:

	/* InstModule AUTO_TEMPLATE (
		.ptl_bus	(ptl_busnew[]),
		);
	*/
	InstModule ms2m (/*AUTOINST*/);

  Typing \\[vpp-auto] will make this into:

	InstModule ms2m (/*AUTOINST*/
	    // Outputs
	    .NotInTemplate	(NotInTemplate),
	    .ptl_bus		(ptl_busnew[3:0]),  // Templated
	    ....


Multiple Module Templates:

  The same template lines can be applied to multiple modules with
  the syntax as follows:

	/* InstModuleA AUTO_TEMPLATE
	   InstModuleB AUTO_TEMPLATE
	   InstModuleC AUTO_TEMPLATE
	   InstModuleD AUTO_TEMPLATE (
		.ptl_bus	(ptl_busnew[]),
		);
	*/

  Note there is only one AUTO_TEMPLATE opening parenthesis.

@ Templates:

  It is common to instantiate a cell multiple times, so templates make it
  trivial to substitute part of the cell name into the connection name.

	/* InstName AUTO_TEMPLATE <optional \"REGEXP\"> (
		.sig1	(sigx[@]),
		.sig2	(sigy[@\"(% (+ 1 @) 4)\"]),
		);
	*/

  If no regular expression is provided immediately after the AUTO_TEMPLATE
  keyword, then the @ character in any connection names will be replaced
  with the instantiation number; the first digits found in the cell's
  instantiation name.

  If a regular expression is provided, the @ character will be replaced
  with the first \(\) grouping that matches against the cell name.  Using a
  regexp of \"\\([0-9]+\\)\" provides identical values for @ as when no
  regexp is provided.  If you use multiple layers of parenthesis,
  \"test\\([^0-9]+\\)_\\([0-9]+\\)\" would replace @ with non-number
  characters after test and before _, whereas
  \"\\(test\\([a-z]+\\)_\\([0-9]+\\)\\)\" would replace @ with the entire
  match.

  For example:

	/* InstModule AUTO_TEMPLATE (
		.ptl_mapvalidx		(ptl_mapvalid[@]),
		.ptl_mapvalidp1x	(ptl_mapvalid[@\"(% (+ 1 @) 4)\"]),
		);
	*/
	InstModule ms2m (/*AUTOINST*/);

  Typing \\[vpp-auto] will make this into:

	InstModule ms2m (/*AUTOINST*/
	    // Outputs
	    .ptl_mapvalidx		(ptl_mapvalid[2]),
	    .ptl_mapvalidp1x		(ptl_mapvalid[3]));

  Note the @ character was replaced with the 2 from \"ms2m\".

  Alternatively, using a regular expression for @:

	/* InstModule AUTO_TEMPLATE \"_\\([a-z]+\\)\" (
		.ptl_mapvalidx		(@_ptl_mapvalid),
		.ptl_mapvalidp1x	(ptl_mapvalid_@),
		);
	*/
	InstModule ms2_FOO (/*AUTOINST*/);
	InstModule ms2_BAR (/*AUTOINST*/);

  Typing \\[vpp-auto] will make this into:

	InstModule ms2_FOO (/*AUTOINST*/
	    // Outputs
	    .ptl_mapvalidx		(FOO_ptl_mapvalid),
	    .ptl_mapvalidp1x		(ptl_mapvalid_FOO));
	InstModule ms2_BAR (/*AUTOINST*/
	    // Outputs
	    .ptl_mapvalidx		(BAR_ptl_mapvalid),
	    .ptl_mapvalidp1x		(ptl_mapvalid_BAR));


Regexp Templates:

  A template entry of the form

	    .pci_req\\([0-9]+\\)_l	(pci_req_jtag_[\\1]),

  will apply an Emacs style regular expression search for any port beginning
  in pci_req followed by numbers and ending in _l and connecting that to
  the pci_req_jtag_[] net, with the bus subscript coming from what matches
  inside the first set of \\( \\).  Thus pci_req2_l becomes pci_req_jtag_[2].

  Since \\([0-9]+\\) is so common and ugly to read, a @ in the port name
  does the same thing.  (Note a @ in the connection/replacement text is
  completely different -- still use \\1 there!)  Thus this is the same as
  the above template:

	    .pci_req@_l		(pci_req_jtag_[\\1]),

  Here's another example to remove the _l, useful when naming conventions
  specify _ alone to mean active low.  Note the use of [] to keep the bus
  subscript:

	    .\\(.*\\)_l		(\\1_[]),

Lisp Templates:

  First any regular expression template is expanded.

  If the syntax @\"( ... )\" is found in a connection, the expression in
  quotes will be evaluated as a Lisp expression, with @ replaced by the
  instantiation number.  The MAPVALIDP1X example above would put @+1 modulo
  4 into the brackets.  Quote all double-quotes inside the expression with
  a leading backslash (\\\"...\\\"); or if the Lisp template is also a
  regexp template backslash the backslash quote (\\\\\"...\\\\\").

  There are special variables defined that are useful in these
  Lisp functions:

	vl-name        Name portion of the input/output port.
	vl-bits        Bus bits portion of the input/output port ('[2:0]').
	vl-mbits       Multidimensional array bits for port ('[2:0][3:0]').
	vl-width       Width of the input/output port ('3' for [2:0]).
                       May be a (...) expression if bits isn't a constant.
	vl-dir         Direction of the pin input/output/inout/interface.
	vl-modport     The modport, if an interface with a modport.
	vl-cell-type   Module name/type of the cell ('InstModule').
	vl-cell-name   Instance name of the cell ('instName').

  Normal Lisp variables may be used in expressions.  See
  `vpp-read-defines' which can set vh-{definename} variables for use
  here.  Also, any comments of the form:

	/*AUTO_LISP(setq foo 1)*/

  will evaluate any Lisp expression inside the parenthesis between the
  beginning of the buffer and the point of the AUTOINST.  This allows
  functions to be defined or variables to be changed between instantiations.
  (See also `vpp-auto-insert-lisp' if you want the output from your
  lisp function to be inserted.)

  Note that when using lisp expressions errors may occur when @ is not a
  number; you may need to use the standard Emacs Lisp functions
  `number-to-string' and `string-to-number'.

  After the evaluation is completed, @ substitution and [] substitution
  occur.

For more information see the \\[vpp-faq] and forums at URL
`http://www.veripool.org'."
  (save-excursion
    ;; Find beginning
    (let* ((pt (point))
	   (for-star (save-excursion (backward-char 2) (looking-at "\\.\\*")))
	   (indent-pt (save-excursion (vpp-backward-open-paren)
				      (1+ (current-column))))
	   (vpp-auto-inst-column (max vpp-auto-inst-column
					  (+ 16 (* 8 (/ (+ indent-pt 7) 8)))))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (vector-skip-list (unless vpp-auto-inst-vector
			       (vpp-decls-get-signals moddecls)))
	   submod submodi submoddecls
	   inst skip-pins tpl-list tpl-num did-first par-values)

      ;; Find module name that is instantiated
      (setq submod  (vpp-read-inst-module)
	    inst (vpp-read-inst-name)
	    vl-cell-type submod
	    vl-cell-name inst
	    skip-pins (aref (vpp-read-inst-pins) 0))

      ;; Parse any AUTO_LISP() before here
      (vpp-read-auto-lisp (point-min) pt)

      ;; Read parameters (after AUTO_LISP)
      (setq par-values (and vpp-auto-inst-param-value
			    (vpp-read-inst-param-value)))

      ;; Lookup position, etc of submodule
      ;; Note this may raise an error
      (when (and (not (member submod vpp-gate-keywords))
		 (setq submodi (vpp-modi-lookup submod t)))
	(setq submoddecls (vpp-modi-get-decls submodi))
	;; If there's a number in the instantiation, it may be an argument to the
	;; automatic variable instantiation program.
	(let* ((tpl-info (vpp-read-auto-template submod))
	       (tpl-regexp (aref tpl-info 0)))
	  (setq tpl-num (if (string-match tpl-regexp inst)
			    (match-string 1 inst)
			  "")
		tpl-list (aref tpl-info 1)))
	;; Find submodule's signals and dump
	(let ((sig-list (and (equal (vpp-modi-get-type submodi) "interface")
			     (vpp-signals-not-in
			      (vpp-decls-get-vars submoddecls)
			      skip-pins)))
	      (vl-dir "interfaced"))
	  (when (and sig-list
		     vpp-auto-inst-interfaced-ports)
	    (when (not did-first) (vpp-auto-inst-first) (setq did-first t))
            ;; Note these are searched for in vpp-read-sub-decls.
	    (vpp-insert-indent "// Interfaced\n")
	    (vpp-auto-inst-port-list sig-list indent-pt
					 tpl-list tpl-num for-star par-values)))
	(let ((sig-list (vpp-signals-not-in
			 (vpp-decls-get-interfaces submoddecls)
			 skip-pins))
	      (vl-dir "interface"))
	  (when sig-list
	    (when (not did-first) (vpp-auto-inst-first) (setq did-first t))
            ;; Note these are searched for in vpp-read-sub-decls.
	    (vpp-insert-indent "// Interfaces\n")
	    (vpp-auto-inst-port-list sig-list indent-pt
					 tpl-list tpl-num for-star par-values)))
	(let ((sig-list (vpp-signals-not-in
			 (vpp-decls-get-outputs submoddecls)
			 skip-pins))
	      (vl-dir "output"))
	  (when sig-list
	    (when (not did-first) (vpp-auto-inst-first) (setq did-first t))
	    (vpp-insert-indent "// Outputs\n")
	    (vpp-auto-inst-port-list sig-list indent-pt
					 tpl-list tpl-num for-star par-values)))
	(let ((sig-list (vpp-signals-not-in
			 (vpp-decls-get-inouts submoddecls)
			 skip-pins))
	      (vl-dir "inout"))
	  (when sig-list
	    (when (not did-first) (vpp-auto-inst-first) (setq did-first t))
	    (vpp-insert-indent "// Inouts\n")
	    (vpp-auto-inst-port-list sig-list indent-pt
					 tpl-list tpl-num for-star par-values)))
	(let ((sig-list (vpp-signals-not-in
			 (vpp-decls-get-inputs submoddecls)
			 skip-pins))
	      (vl-dir "input"))
	  (when sig-list
	    (when (not did-first) (vpp-auto-inst-first) (setq did-first t))
	    (vpp-insert-indent "// Inputs\n")
	    (vpp-auto-inst-port-list sig-list indent-pt
					 tpl-list tpl-num for-star par-values)))
	;; Kill extra semi
	(save-excursion
	  (cond (did-first
		 (re-search-backward "," pt t)
		 (delete-char 1)
		 (insert ");")
		 (search-forward "\n")	;; Added by inst-port
		 (delete-char -1)
		 (if (search-forward ")" nil t) ;; From user, moved up a line
		     (delete-char -1))
		 (if (search-forward ";" nil t) ;; Don't error if user had syntax error and forgot it
		     (delete-char -1)))))))))

(defun vpp-auto-inst-param ()
  "Expand AUTOINSTPARAM statements, as part of \\[vpp-auto].
Replace the parameter connections to an instantiation with ones
automatically derived from the module header of the instantiated netlist.

See \\[vpp-auto-inst] for limitations, and templates to customize the
output.

For example, first take the submodule InstModule.v:

	module InstModule (o,i);
	   parameter PAR;
	endmodule

This is then used in an upper level module:

	module ExampInst (o,i);
	   parameter PAR;
	   InstModule #(/*AUTOINSTPARAM*/)
		instName (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampInst (o,i);
	   output o;
	   input i;
	   InstModule #(/*AUTOINSTPARAM*/
		        // Parameters
		        .PAR	(PAR));
		instName (/*AUTOINST*/);
	endmodule

Where the list of parameter connections come from the inst module.

Templates:

  You can customize the parameter connections using AUTO_TEMPLATEs,
  just as you would with \\[vpp-auto-inst]."
  (save-excursion
    ;; Find beginning
    (let* ((pt (point))
	   (indent-pt (save-excursion (vpp-backward-open-paren)
				      (1+ (current-column))))
	   (vpp-auto-inst-column (max vpp-auto-inst-column
					  (+ 16 (* 8 (/ (+ indent-pt 7) 8)))))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (vector-skip-list (unless vpp-auto-inst-vector
			       (vpp-decls-get-signals moddecls)))
	   submod submodi submoddecls
	   inst skip-pins tpl-list tpl-num did-first)
      ;; Find module name that is instantiated
      (setq submod (save-excursion
		     ;; Get to the point where AUTOINST normally is to read the module
		     (vpp-re-search-forward-quick "[(;]" nil nil)
		     (vpp-read-inst-module))
	    inst   (save-excursion
		     ;; Get to the point where AUTOINST normally is to read the module
		     (vpp-re-search-forward-quick "[(;]" nil nil)
		     (vpp-read-inst-name))
	    vl-cell-type submod
	    vl-cell-name inst
	    skip-pins (aref (vpp-read-inst-pins) 0))

      ;; Parse any AUTO_LISP() before here
      (vpp-read-auto-lisp (point-min) pt)

      ;; Lookup position, etc of submodule
      ;; Note this may raise an error
      (when (setq submodi (vpp-modi-lookup submod t))
	(setq submoddecls (vpp-modi-get-decls submodi))
	;; If there's a number in the instantiation, it may be an argument to the
	;; automatic variable instantiation program.
	(let* ((tpl-info (vpp-read-auto-template submod))
	       (tpl-regexp (aref tpl-info 0)))
	  (setq tpl-num (if (string-match tpl-regexp inst)
			    (match-string 1 inst)
			  "")
		tpl-list (aref tpl-info 1)))
	;; Find submodule's signals and dump
	(let ((sig-list (vpp-signals-not-in
			 (vpp-decls-get-gparams submoddecls)
			 skip-pins))
	      (vl-dir "parameter"))
	  (when sig-list
	    (when (not did-first) (vpp-auto-inst-first) (setq did-first t))
            ;; Note these are searched for in vpp-read-sub-decls.
	    (vpp-insert-indent "// Parameters\n")
	    (vpp-auto-inst-port-list sig-list indent-pt
					 tpl-list tpl-num nil nil)))
	;; Kill extra semi
	(save-excursion
	  (cond (did-first
		 (re-search-backward "," pt t)
		 (delete-char 1)
		 (insert ")")
		 (search-forward "\n")	;; Added by inst-port
		 (delete-char -1)
		 (if (search-forward ")" nil t) ;; From user, moved up a line
		     (delete-char -1)))))))))

(defun vpp-auto-reg ()
  "Expand AUTOREG statements, as part of \\[vpp-auto].
Make reg statements for any output that isn't already declared,
and isn't a wire output from a block.  `vpp-auto-wire-type'
may be used to change the datatype of the declarations.

Limitations:
  This ONLY detects outputs of AUTOINSTants (see `vpp-read-sub-decls').

  This does NOT work on memories, declare those yourself.

An example:

	module ExampReg (o,i);
	   output o;
	   input i;
	   /*AUTOREG*/
	   always o = i;
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampReg (o,i);
	   output o;
	   input i;
	   /*AUTOREG*/
	   // Beginning of automatic regs (for this module's undeclared outputs)
	   reg		o;
	   // End of automatics
	   always o = i;
	endmodule"
  (save-excursion
    ;; Point must be at insertion point.
    (let* ((indent-pt (current-indentation))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-not-in
		      (vpp-decls-get-outputs moddecls)
		      (append (vpp-signals-with ;; ignore typed signals
			       'vpp-sig-type
			       (vpp-decls-get-outputs moddecls))
			      (vpp-decls-get-vars moddecls)
			      (vpp-decls-get-assigns moddecls)
			      (vpp-decls-get-consts moddecls)
			      (vpp-decls-get-gparams moddecls)
			      (vpp-subdecls-get-interfaced modsubdecls)
			      (vpp-subdecls-get-outputs modsubdecls)
			      (vpp-subdecls-get-inouts modsubdecls)))))
      (when sig-list
	(vpp-forward-or-insert-line)
	(vpp-insert-indent "// Beginning of automatic regs (for this module's undeclared outputs)\n")
	(vpp-insert-definition modi sig-list "reg" indent-pt nil)
	(vpp-insert-indent "// End of automatics\n")))))

(defun vpp-auto-reg-input ()
  "Expand AUTOREGINPUT statements, as part of \\[vpp-auto].
Make reg statements instantiation inputs that aren't already declared.
This is useful for making a top level shell for testing the module that is
to be instantiated.

Limitations:
  This ONLY detects inputs of AUTOINSTants (see `vpp-read-sub-decls').

  This does NOT work on memories, declare those yourself.

An example (see `vpp-auto-inst' for what else is going on here):

	module ExampRegInput (o,i);
	   output o;
	   input i;
	   /*AUTOREGINPUT*/
           InstModule instName
             (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampRegInput (o,i);
	   output o;
	   input i;
	   /*AUTOREGINPUT*/
	   // Beginning of automatic reg inputs (for undeclared ...
	   reg [31:0]		iv;	// From inst of inst.v
	   // End of automatics
	   InstModule instName
             (/*AUTOINST*/
	      // Outputs
	      .o		(o[31:0]),
	      // Inputs
	      .iv		(iv));
	endmodule"
  (save-excursion
    ;; Point must be at insertion point.
    (let* ((indent-pt (current-indentation))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-combine-bus
		      (vpp-signals-not-in
		       (append (vpp-subdecls-get-inputs modsubdecls)
			       (vpp-subdecls-get-inouts modsubdecls))
		       (append (vpp-decls-get-signals moddecls)
			       (vpp-decls-get-assigns moddecls))))))
      (when sig-list
	(vpp-forward-or-insert-line)
	(vpp-insert-indent "// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)\n")
	(vpp-insert-definition modi sig-list "reg" indent-pt nil)
	(vpp-insert-indent "// End of automatics\n")))))

(defun vpp-auto-logic-setup ()
  "Prepare variables due to AUTOLOGIC."
  (unless vpp-auto-wire-type
    (set (make-local-variable 'vpp-auto-wire-type)
	 "logic")))

(defun vpp-auto-logic ()
  "Expand AUTOLOGIC statements, as part of \\[vpp-auto].
Make wire statements using the SystemVpp logic keyword.
This is currently equivalent to:

    /*AUTOWIRE*/

with the below at the bottom of the file

    // Local Variables:
    // vpp-auto-logic-type:\"logic\"
    // End:

In the future AUTOLOGIC may declare additional identifiers,
while AUTOWIRE will not."
  (save-excursion
    (vpp-auto-logic-setup)
    (vpp-auto-wire)))

(defun vpp-auto-wire ()
  "Expand AUTOWIRE statements, as part of \\[vpp-auto].
Make wire statements for instantiations outputs that aren't
already declared.  `vpp-auto-wire-type' may be used to change
the datatype of the declarations.

Limitations:
  This ONLY detects outputs of AUTOINSTants (see `vpp-read-sub-decls'),
  and all buses must have widths, such as those from AUTOINST, or using []
  in AUTO_TEMPLATEs.

  This does NOT work on memories or SystemVpp .name connections,
  declare those yourself.

  Vpp mode will add \"Couldn't Merge\" comments to signals it cannot
  determine how to bus together.  This occurs when you have ports with
  non-numeric or non-sequential bus subscripts.  If Vpp mode
  mis-guessed, you'll have to declare them yourself.

An example (see `vpp-auto-inst' for what else is going on here):

	module ExampWire (o,i);
	   output o;
	   input i;
	   /*AUTOWIRE*/
           InstModule instName
	     (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampWire (o,i);
	   output o;
	   input i;
	   /*AUTOWIRE*/
	   // Beginning of automatic wires
	   wire [31:0]		ov;	// From inst of inst.v
	   // End of automatics
	   InstModule instName
	     (/*AUTOINST*/
	      // Outputs
	      .ov	(ov[31:0]),
	      // Inputs
	      .i	(i));
	   wire o = | ov;
	endmodule"
  (save-excursion
    ;; Point must be at insertion point.
    (let* ((indent-pt (current-indentation))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-combine-bus
		      (vpp-signals-not-in
		       (append (vpp-subdecls-get-outputs modsubdecls)
			       (vpp-subdecls-get-inouts modsubdecls))
		       (vpp-decls-get-signals moddecls)))))
      (when sig-list
	(vpp-forward-or-insert-line)
	(vpp-insert-indent "// Beginning of automatic wires (for undeclared instantiated-module outputs)\n")
	(vpp-insert-definition modi sig-list "wire" indent-pt nil)
	(vpp-insert-indent "// End of automatics\n")
	;; We used to optionally call vpp-pretty-declarations and
	;; vpp-pretty-expr here, but it's too slow on huge modules,
	;; plus makes everyone's module change. Finally those call
	;; syntax-ppss which is broken when change hooks are disabled.
	))))

(defun vpp-auto-output ()
  "Expand AUTOOUTPUT statements, as part of \\[vpp-auto].
Make output statements for any output signal from an /*AUTOINST*/ that
isn't an input to another AUTOINST.  This is useful for modules which
only instantiate other modules.

Limitations:
  This ONLY detects outputs of AUTOINSTants (see `vpp-read-sub-decls').

  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  If any concatenation, or bit-subscripts are missing in the AUTOINSTant's
  instantiation, all bets are off.  (For example due to an AUTO_TEMPLATE).

  Typedefs must match `vpp-typedef-regexp', which is disabled by default.

  Signals matching `vpp-auto-output-ignore-regexp' are not included.

An example (see `vpp-auto-inst' for what else is going on here):

	module ExampOutput (ov,i);
	   input i;
	   /*AUTOOUTPUT*/
	   InstModule instName
	     (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampOutput (ov,i);
	   input i;
	   /*AUTOOUTPUT*/
	   // Beginning of automatic outputs (from unused autoinst outputs)
	   output [31:0]	ov;	// From inst of inst.v
	   // End of automatics
	   InstModule instName
	     (/*AUTOINST*/
	      // Outputs
	      .ov	(ov[31:0]),
	      // Inputs
	      .i	(i));
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting outputs starting with ov:

	   /*AUTOOUTPUT(\"^ov\")*/"
  (save-excursion
    ;; Point must be at insertion point.
    (let* ((indent-pt (current-indentation))
	   (params (vpp-read-auto-params 0 1))
	   (regexp (nth 0 params))
	   (v2k  (vpp-in-paren-quick))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-not-in
		      (vpp-subdecls-get-outputs modsubdecls)
		      (append (vpp-decls-get-outputs moddecls)
			      (vpp-decls-get-inouts moddecls)
			      (vpp-subdecls-get-inputs modsubdecls)
			      (vpp-subdecls-get-inouts modsubdecls)))))
      (when regexp
	(setq sig-list (vpp-signals-matching-regexp
			sig-list regexp)))
      (setq sig-list (vpp-signals-not-matching-regexp
		      sig-list vpp-auto-output-ignore-regexp))
      (vpp-forward-or-insert-line)
      (when v2k (vpp-repair-open-comma))
      (when sig-list
	(vpp-insert-indent "// Beginning of automatic outputs (from unused autoinst outputs)\n")
	(vpp-insert-definition modi sig-list "output" indent-pt v2k)
	(vpp-insert-indent "// End of automatics\n"))
      (when v2k (vpp-repair-close-comma)))))

(defun vpp-auto-output-every ()
  "Expand AUTOOUTPUTEVERY statements, as part of \\[vpp-auto].
Make output statements for any signals that aren't primary inputs or
outputs already.  This makes every signal in the design an output.  This is
useful to get Synopsys to preserve every signal in the design, since it
won't optimize away the outputs.

An example:

	module ExampOutputEvery (o,i,tempa,tempb);
	   output o;
	   input i;
	   /*AUTOOUTPUTEVERY*/
	   wire tempa = i;
	   wire tempb = tempa;
	   wire o = tempb;
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampOutputEvery (o,i,tempa,tempb);
	   output o;
	   input i;
	   /*AUTOOUTPUTEVERY*/
	   // Beginning of automatic outputs (every signal)
	   output	tempb;
	   output	tempa;
	   // End of automatics
	   wire tempa = i;
	   wire tempb = tempa;
	   wire o = tempb;
	endmodule"
  (save-excursion
    ;;Point must be at insertion point
    (let* ((indent-pt (current-indentation))
	   (v2k  (vpp-in-paren-quick))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (sig-list (vpp-signals-combine-bus
		      (vpp-signals-not-in
		       (vpp-decls-get-signals moddecls)
		       (vpp-decls-get-ports moddecls)))))
      (vpp-forward-or-insert-line)
      (when v2k (vpp-repair-open-comma))
      (when sig-list
	(vpp-insert-indent "// Beginning of automatic outputs (every signal)\n")
	(vpp-insert-definition modi sig-list "output" indent-pt v2k)
	(vpp-insert-indent "// End of automatics\n"))
      (when v2k (vpp-repair-close-comma)))))

(defun vpp-auto-input ()
  "Expand AUTOINPUT statements, as part of \\[vpp-auto].
Make input statements for any input signal into an /*AUTOINST*/ that
isn't declared elsewhere inside the module.  This is useful for modules which
only instantiate other modules.

Limitations:
  This ONLY detects outputs of AUTOINSTants (see `vpp-read-sub-decls').

  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  If any concatenation, or bit-subscripts are missing in the AUTOINSTant's
  instantiation, all bets are off.  (For example due to an AUTO_TEMPLATE).

  Typedefs must match `vpp-typedef-regexp', which is disabled by default.

  Signals matching `vpp-auto-input-ignore-regexp' are not included.

An example (see `vpp-auto-inst' for what else is going on here):

	module ExampInput (ov,i);
	   output [31:0] ov;
	   /*AUTOINPUT*/
	   InstModule instName
	     (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampInput (ov,i);
	   output [31:0] ov;
	   /*AUTOINPUT*/
	   // Beginning of automatic inputs (from unused autoinst inputs)
	   input	i;	// From inst of inst.v
	   // End of automatics
	   InstModule instName
	     (/*AUTOINST*/
	      // Outputs
	      .ov	(ov[31:0]),
	      // Inputs
	      .i	(i));
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting inputs starting with i:

	   /*AUTOINPUT(\"^i\")*/"
  (save-excursion
    (let* ((indent-pt (current-indentation))
	   (params (vpp-read-auto-params 0 1))
	   (regexp (nth 0 params))
	   (v2k  (vpp-in-paren-quick))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-not-in
		      (vpp-subdecls-get-inputs modsubdecls)
		      (append (vpp-decls-get-inputs moddecls)
			      (vpp-decls-get-inouts moddecls)
			      (vpp-decls-get-vars moddecls)
			      (vpp-decls-get-consts moddecls)
			      (vpp-decls-get-gparams moddecls)
			      (vpp-subdecls-get-interfaced modsubdecls)
			      (vpp-subdecls-get-outputs modsubdecls)
			      (vpp-subdecls-get-inouts modsubdecls)))))
      (when regexp
	(setq sig-list (vpp-signals-matching-regexp
			sig-list regexp)))
      (setq sig-list (vpp-signals-not-matching-regexp
		      sig-list vpp-auto-input-ignore-regexp))
      (vpp-forward-or-insert-line)
      (when v2k (vpp-repair-open-comma))
      (when sig-list
	(vpp-insert-indent "// Beginning of automatic inputs (from unused autoinst inputs)\n")
	(vpp-insert-definition modi sig-list "input" indent-pt v2k)
	(vpp-insert-indent "// End of automatics\n"))
      (when v2k (vpp-repair-close-comma)))))

(defun vpp-auto-inout ()
  "Expand AUTOINOUT statements, as part of \\[vpp-auto].
Make inout statements for any inout signal in an /*AUTOINST*/ that
isn't declared elsewhere inside the module.

Limitations:
  This ONLY detects outputs of AUTOINSTants (see `vpp-read-sub-decls').

  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  If any concatenation, or bit-subscripts are missing in the AUTOINSTant's
  instantiation, all bets are off.  (For example due to an AUTO_TEMPLATE).

  Typedefs must match `vpp-typedef-regexp', which is disabled by default.

  Signals matching `vpp-auto-inout-ignore-regexp' are not included.

An example (see `vpp-auto-inst' for what else is going on here):

	module ExampInout (ov,i);
	   input i;
	   /*AUTOINOUT*/
	   InstModule instName
	     (/*AUTOINST*/);
	endmodule

Typing \\[vpp-auto] will make this into:

	module ExampInout (ov,i);
	   input i;
	   /*AUTOINOUT*/
	   // Beginning of automatic inouts (from unused autoinst inouts)
	   inout [31:0]	ov;	// From inst of inst.v
	   // End of automatics
	   InstModule instName
	     (/*AUTOINST*/
	      // Inouts
	      .ov	(ov[31:0]),
	      // Inputs
	      .i	(i));
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting inouts starting with i:

	   /*AUTOINOUT(\"^i\")*/"
  (save-excursion
    ;; Point must be at insertion point.
    (let* ((indent-pt (current-indentation))
	   (params (vpp-read-auto-params 0 1))
	   (regexp (nth 0 params))
	   (v2k  (vpp-in-paren-quick))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-not-in
		      (vpp-subdecls-get-inouts modsubdecls)
		      (append (vpp-decls-get-outputs moddecls)
			      (vpp-decls-get-inouts moddecls)
			      (vpp-decls-get-inputs moddecls)
			      (vpp-subdecls-get-inputs modsubdecls)
			      (vpp-subdecls-get-outputs modsubdecls)))))
      (when regexp
	(setq sig-list (vpp-signals-matching-regexp
			sig-list regexp)))
      (setq sig-list (vpp-signals-not-matching-regexp
		      sig-list vpp-auto-inout-ignore-regexp))
      (vpp-forward-or-insert-line)
      (when v2k (vpp-repair-open-comma))
      (when sig-list
	(vpp-insert-indent "// Beginning of automatic inouts (from unused autoinst inouts)\n")
	(vpp-insert-definition modi sig-list "inout" indent-pt v2k)
	(vpp-insert-indent "// End of automatics\n"))
      (when v2k (vpp-repair-close-comma)))))

(defun vpp-auto-inout-module (&optional complement all-in)
  "Expand AUTOINOUTMODULE statements, as part of \\[vpp-auto].
Take input/output/inout statements from the specified module and insert
into the current module.  This is useful for making null templates and
shell modules which need to have identical I/O with another module.
Any I/O which are already defined in this module will not be redefined.
For the complement of this function, see `vpp-auto-inout-comp',
and to make monitors with all inputs, see `vpp-auto-inout-in'.

Limitations:
  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  Concatenation and outputting partial buses is not supported.

  Module names must be resolvable to filenames.  See `vpp-auto-inst'.

  Signals are not inserted in the same order as in the original module,
  though they will appear to be in the same order to an AUTOINST
  instantiating either module.

  Signals declared as \"output reg\" or \"output wire\" etc will
  lose the wire/reg declaration so that shell modules may
  generate those outputs differently.  However, \"output logic\"
  is propagated.

An example:

	module ExampShell (/*AUTOARG*/);
	   /*AUTOINOUTMODULE(\"ExampMain\")*/
	endmodule

	module ExampMain (i,o,io);
          input i;
          output o;
          inout io;
        endmodule

Typing \\[vpp-auto] will make this into:

	module ExampShell (/*AUTOARG*/i,o,io);
	   /*AUTOINOUTMODULE(\"ExampMain\")*/
           // Beginning of automatic in/out/inouts (from specific module)
           output o;
           inout io;
           input i;
	   // End of automatics
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting signals starting with i:

	   /*AUTOINOUTMODULE(\"ExampMain\",\"^i\")*/

You may also provide an optional second regular expression, in
which case only signals which have that pin direction and data
type will be included.  This matches against everything before
the signal name in the declaration, for example against
\"input\" (single bit), \"output logic\" (direction and type) or
\"output [1:0]\" (direction and implicit type).  You also
probably want to skip spaces in your regexp.

For example, the below will result in matching the output \"o\"
against the previous example's module:

	   /*AUTOINOUTMODULE(\"ExampMain\",\"\",\"^output.*\")*/"
  (save-excursion
    (let* ((params (vpp-read-auto-params 1 3))
	   (submod (nth 0 params))
	   (regexp (nth 1 params))
	   (direction-re (nth 2 params))
	   submodi)
      ;; Lookup position, etc of co-module
      ;; Note this may raise an error
      (when (setq submodi (vpp-modi-lookup submod t))
	(let* ((indent-pt (current-indentation))
	       (v2k  (vpp-in-paren-quick))
	       (modi (vpp-modi-current))
	       (moddecls (vpp-modi-get-decls modi))
	       (submoddecls (vpp-modi-get-decls submodi))
	       (sig-list-i  (vpp-signals-not-in
			     (cond (all-in
				    (append
				     (vpp-decls-get-inputs submoddecls)
				     (vpp-decls-get-inouts submoddecls)
				     (vpp-decls-get-outputs submoddecls)))
				   (complement
				    (vpp-decls-get-outputs submoddecls))
				   (t (vpp-decls-get-inputs submoddecls)))
			     (append (vpp-decls-get-inputs moddecls))))
	       (sig-list-o  (vpp-signals-not-in
			     (cond (all-in nil)
				   (complement
				    (vpp-decls-get-inputs submoddecls))
				   (t (vpp-decls-get-outputs submoddecls)))
			     (append (vpp-decls-get-outputs moddecls))))
	       (sig-list-io (vpp-signals-not-in
			     (cond (all-in nil)
				   (t (vpp-decls-get-inouts submoddecls)))
			     (append (vpp-decls-get-inouts moddecls))))
	       (sig-list-if (vpp-signals-not-in
			     (vpp-decls-get-interfaces submoddecls)
			     (append (vpp-decls-get-interfaces moddecls)))))
	  (forward-line 1)
	  (setq sig-list-i  (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-i regexp)
			      "input" direction-re))
		sig-list-o  (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-o regexp)
			      "output" direction-re))
		sig-list-io (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-io regexp)
			      "inout" direction-re))
		sig-list-if (vpp-signals-matching-dir-re
			     (vpp-signals-matching-regexp sig-list-if regexp)
			     "interface" direction-re))
	  (when v2k (vpp-repair-open-comma))
	  (when (or sig-list-i sig-list-o sig-list-io)
	    (vpp-insert-indent "// Beginning of automatic in/out/inouts (from specific module)\n")
	    ;; Don't sort them so an upper AUTOINST will match the main module
	    (vpp-insert-definition modi sig-list-o  "output" indent-pt v2k t)
	    (vpp-insert-definition modi sig-list-io "inout" indent-pt v2k t)
	    (vpp-insert-definition modi sig-list-i  "input" indent-pt v2k t)
	    (vpp-insert-definition modi sig-list-if "interface" indent-pt v2k t)
	    (vpp-insert-indent "// End of automatics\n"))
	  (when v2k (vpp-repair-close-comma)))))))

(defun vpp-auto-inout-comp ()
  "Expand AUTOINOUTCOMP statements, as part of \\[vpp-auto].
Take input/output/inout statements from the specified module and
insert the inverse into the current module (inputs become outputs
and vice-versa.)  This is useful for making test and stimulus
modules which need to have complementing I/O with another module.
Any I/O which are already defined in this module will not be
redefined.  For the complement of this function, see
`vpp-auto-inout-module'.

Limitations:
  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  Concatenation and outputting partial buses is not supported.

  Module names must be resolvable to filenames.  See `vpp-auto-inst'.

  Signals are not inserted in the same order as in the original module,
  though they will appear to be in the same order to an AUTOINST
  instantiating either module.

An example:

	module ExampShell (/*AUTOARG*/);
	   /*AUTOINOUTCOMP(\"ExampMain\")*/
	endmodule

	module ExampMain (i,o,io);
          input i;
          output o;
          inout io;
        endmodule

Typing \\[vpp-auto] will make this into:

	module ExampShell (/*AUTOARG*/i,o,io);
	   /*AUTOINOUTCOMP(\"ExampMain\")*/
           // Beginning of automatic in/out/inouts (from specific module)
           output i;
           inout io;
           input o;
	   // End of automatics
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting signals starting with i:

	   /*AUTOINOUTCOMP(\"ExampMain\",\"^i\")*/"
  (vpp-auto-inout-module t nil))

(defun vpp-auto-inout-in ()
  "Expand AUTOINOUTIN statements, as part of \\[vpp-auto].
Take input/output/inout statements from the specified module and
insert them as all inputs into the current module.  This is
useful for making monitor modules which need to see all signals
as inputs based on another module.  Any I/O which are already
defined in this module will not be redefined.  See also
`vpp-auto-inout-module'.

Limitations:
  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  Concatenation and outputting partial buses is not supported.

  Module names must be resolvable to filenames.  See `vpp-auto-inst'.

  Signals are not inserted in the same order as in the original module,
  though they will appear to be in the same order to an AUTOINST
  instantiating either module.

An example:

	module ExampShell (/*AUTOARG*/);
	   /*AUTOINOUTIN(\"ExampMain\")*/
	endmodule

	module ExampMain (i,o,io);
          input i;
          output o;
          inout io;
        endmodule

Typing \\[vpp-auto] will make this into:

	module ExampShell (/*AUTOARG*/i,o,io);
	   /*AUTOINOUTIN(\"ExampMain\")*/
           // Beginning of automatic in/out/inouts (from specific module)
           input i;
           input io;
           input o;
	   // End of automatics
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting signals starting with i:

	   /*AUTOINOUTCOMP(\"ExampMain\",\"^i\")*/"
  (vpp-auto-inout-module nil t))

(defun vpp-auto-inout-param ()
  "Expand AUTOINOUTPARAM statements, as part of \\[vpp-auto].
Take input/output/inout statements from the specified module and insert
into the current module.  This is useful for making null templates and
shell modules which need to have identical I/O with another module.
Any I/O which are already defined in this module will not be redefined.
For the complement of this function, see `vpp-auto-inout-comp',
and to make monitors with all inputs, see `vpp-auto-inout-in'.

Limitations:
  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  Concatenation and outputting partial buses is not supported.

  Module names must be resolvable to filenames.  See `vpp-auto-inst'.

  Signals are not inserted in the same order as in the original module,
  though they will appear to be in the same order to an AUTOINST
  instantiating either module.

  Signals declared as \"output reg\" or \"output wire\" etc will
  lose the wire/reg declaration so that shell modules may
  generate those outputs differently.  However, \"output logic\"
  is propagated.

An example:

	module ExampShell (/*AUTOARG*/);
	   /*AUTOINOUTMODULE(\"ExampMain\")*/
	endmodule

	module ExampMain (i,o,io);
          input i;
          output o;
          inout io;
        endmodule

Typing \\[vpp-auto] will make this into:

	module ExampShell (/*AUTOARG*/i,o,io);
	   /*AUTOINOUTMODULE(\"ExampMain\")*/
           // Beginning of automatic in/out/inouts (from specific module)
           output o;
           inout io;
           input i;
	   // End of automatics
	endmodule

You may also provide an optional regular expression, in which case only
signals matching the regular expression will be included.  For example the
same expansion will result from only extracting signals starting with i:

	   /*AUTOINOUTMODULE(\"ExampMain\",\"^i\")*/

You may also provide an optional second regular expression, in
which case only signals which have that pin direction and data
type will be included.  This matches against everything before
the signal name in the declaration, for example against
\"input\" (single bit), \"output logic\" (direction and type) or
\"output [1:0]\" (direction and implicit type).  You also
probably want to skip spaces in your regexp.

For example, the below will result in matching the output \"o\"
against the previous example's module:

	   /*AUTOINOUTMODULE(\"ExampMain\",\"\",\"^output.*\")*/

You may also provide an optional third regular expression, in
which case any parameter names that match the given regexp will
be included.  Including parameters is off by default.  To include
all signals and parameters, use:

	   /*AUTOINOUTMODULE(\"ExampMain\",\".*\",\".*\",\".*\")*/"
  (save-excursion
    (let* ((params (vpp-read-auto-params 1 2))
	   (submod (nth 0 params))
	   (regexp (nth 1 params))
	   submodi)
      ;; Lookup position, etc of co-module
      ;; Note this may raise an error
      (when (setq submodi (vpp-modi-lookup submod t))
	(let* ((indent-pt (current-indentation))
	       (v2k  (vpp-in-paren-quick))
	       (modi (vpp-modi-current))
	       (moddecls (vpp-modi-get-decls modi))
	       (submoddecls (vpp-modi-get-decls submodi))
	       (sig-list-p  (vpp-signals-not-in
			     (vpp-decls-get-gparams submoddecls)
			     (append (vpp-decls-get-gparams moddecls)))))
	  (forward-line 1)
	  (setq sig-list-p  (vpp-signals-matching-regexp sig-list-p regexp))
	  (when v2k (vpp-repair-open-comma))
	  (when sig-list-p
	    (vpp-insert-indent "// Beginning of automatic parameters (from specific module)\n")
	    ;; Don't sort them so an upper AUTOINST will match the main module
	    (vpp-insert-definition modi sig-list-p  "parameter" indent-pt v2k t)
	    (vpp-insert-indent "// End of automatics\n"))
	  (when v2k (vpp-repair-close-comma)))))))

(defun vpp-auto-inout-modport ()
  "Expand AUTOINOUTMODPORT statements, as part of \\[vpp-auto].
Take input/output/inout statements from the specified interface
and modport and insert into the current module.  This is useful
for making verification modules that connect to UVM interfaces.

  The first parameter is the name of an interface.

  The second parameter is a regexp of modports to read from in
  that interface.

  The optional third parameter is a regular expression, and only
  signals matching the regular expression will be included.

Limitations:
  If placed inside the parenthesis of a module declaration, it creates
  Vpp 2001 style, else uses Vpp 1995 style.

  Interface names must be resolvable to filenames.  See `vpp-auto-inst'.

As with other autos, any inputs/outputs declared in the module
will suppress the AUTO from redeclaring an inputs/outputs by
the same name.

An example:

	interface ExampIf
	  ( input logic clk );
	   logic        req_val;
	   logic [7:0]  req_dat;
	   clocking mon_clkblk @(posedge clk);
	      input     req_val;
	      input     req_dat;
	   endclocking
	   modport mp(clocking mon_clkblk);
	endinterface

	module ExampMain
	( input clk,
	  /*AUTOINOUTMODPORT(\"ExampIf\" \"mp\")*/
	  // Beginning of automatic in/out/inouts (from modport)
	  input	[7:0] req_dat,
	  input       req_val
	  // End of automatics
	);
	/*AUTOASSIGNMODPORT(\"ExampIf\" \"mp\")*/
	endmodule

Typing \\[vpp-auto] will make this into:

	...
	module ExampMain
	( input clk,
	  /*AUTOINOUTMODPORT(\"ExampIf\" \"mp\")*/
	  // Beginning of automatic in/out/inouts (from modport)
	  input			req_dat,
	  input			req_val
	  // End of automatics
	);

If the modport is part of a UVM monitor/driver class, this
creates a wrapper module that may be used to instantiate the
driver/monitor using AUTOINST in the testbench."
  (save-excursion
    (let* ((params (vpp-read-auto-params 2 3))
	   (submod (nth 0 params))
	   (modport-re (nth 1 params))
	   (regexp (nth 2 params))
	   direction-re submodi) ;; direction argument not supported until requested
      ;; Lookup position, etc of co-module
      ;; Note this may raise an error
      (when (setq submodi (vpp-modi-lookup submod t))
	(let* ((indent-pt (current-indentation))
	       (v2k  (vpp-in-paren-quick))
	       (modi (vpp-modi-current))
	       (moddecls (vpp-modi-get-decls modi))
	       (submoddecls (vpp-modi-get-decls submodi))
	       (submodportdecls (vpp-modi-modport-lookup submodi modport-re))
	       (sig-list-i (vpp-signals-in ;; Decls doesn't have data types, must resolve
			    (vpp-decls-get-vars submoddecls)
			    (vpp-signals-not-in
			     (vpp-decls-get-inputs submodportdecls)
			     (append (vpp-decls-get-ports submoddecls)
				     (vpp-decls-get-ports moddecls)))))
	       (sig-list-o (vpp-signals-in ;; Decls doesn't have data types, must resolve
			    (vpp-decls-get-vars submoddecls)
			    (vpp-signals-not-in
			     (vpp-decls-get-outputs submodportdecls)
			     (append (vpp-decls-get-ports submoddecls)
				     (vpp-decls-get-ports moddecls)))))
	       (sig-list-io (vpp-signals-in ;; Decls doesn't have data types, must resolve
			     (vpp-decls-get-vars submoddecls)
			     (vpp-signals-not-in
			      (vpp-decls-get-inouts submodportdecls)
			      (append (vpp-decls-get-ports submoddecls)
				      (vpp-decls-get-ports moddecls))))))
	  (forward-line 1)
	  (setq sig-list-i  (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-i regexp)
			      "input" direction-re))
		sig-list-o  (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-o regexp)
			      "output" direction-re))
		sig-list-io (vpp-signals-edit-wire-reg
			     (vpp-signals-matching-dir-re
			      (vpp-signals-matching-regexp sig-list-io regexp)
			      "inout" direction-re)))
	  (when v2k (vpp-repair-open-comma))
	  (when (or sig-list-i sig-list-o sig-list-io)
	    (vpp-insert-indent "// Beginning of automatic in/out/inouts (from modport)\n")
	    ;; Don't sort them so an upper AUTOINST will match the main module
	    (vpp-insert-definition modi sig-list-o  "output" indent-pt v2k t)
	    (vpp-insert-definition modi sig-list-io "inout" indent-pt v2k t)
	    (vpp-insert-definition modi sig-list-i  "input" indent-pt v2k t)
	    (vpp-insert-indent "// End of automatics\n"))
	  (when v2k (vpp-repair-close-comma)))))))

(defun vpp-auto-insert-lisp ()
  "Expand AUTOINSERTLISP statements, as part of \\[vpp-auto].
The Lisp code provided is called, and the Lisp code calls
`insert` to insert text into the current file beginning on the
line after the AUTOINSERTLISP.

See also AUTO_LISP, which takes a Lisp expression and evaluates
it during `vpp-auto-inst' but does not insert any text.

An example:

	module ExampInsertLisp;
	   /*AUTOINSERTLISP(my-vpp-insert-hello \"world\")*/
	endmodule

	// For this example we declare the function in the
	// module's file itself.  Often you'd define it instead
	// in a site-start.el or init file.
	/*
	 Local Variables:
	 eval:
	   (defun my-vpp-insert-hello (who)
	     (insert (concat \"initial $write(\\\"hello \" who \"\\\");\\n\")))
	 End:
	*/

Typing \\[vpp-auto] will call my-vpp-insert-hello and
expand the above into:

	// Beginning of automatic insert lisp
	initial $write(\"hello world\");
	// End of automatics

You can also call an external program and insert the returned
text:

	/*AUTOINSERTLISP(insert (shell-command-to-string \"echo //hello\"))*/
	// Beginning of automatic insert lisp
	//hello
	// End of automatics"
  (save-excursion
    ;; Point is at end of /*AUTO...*/
    (let* ((indent-pt (current-indentation))
	   (cmd-end-pt (save-excursion (search-backward ")")
				       (forward-char)
				       (point)))	;; Closing paren
	   (cmd-beg-pt (save-excursion (goto-char cmd-end-pt)
				       (backward-sexp 1)  ;; Inside comment
				       (point))) ;; Beginning paren
	   (cmd (buffer-substring-no-properties cmd-beg-pt cmd-end-pt)))
      (vpp-forward-or-insert-line)
      ;; Some commands don't move point (like insert-file) so we always
      ;; add the begin/end comments, then delete it if not needed
      (vpp-insert-indent "// Beginning of automatic insert lisp\n")
      (vpp-insert-indent "// End of automatics\n")
      (forward-line -1)
      (eval (read cmd))
      (forward-line -1)
      (setq vpp-scan-cache-tick nil) ;; Clear cache; inserted unknown text
      (vpp-delete-empty-auto-pair))))

(defun vpp-auto-sense-sigs (moddecls presense-sigs)
  "Return list of signals for current AUTOSENSE block."
  (let* ((sigss (vpp-read-always-signals))
	 (sig-list (vpp-signals-not-params
		    (vpp-signals-not-in (vpp-alw-get-inputs sigss)
					    (append (and (not vpp-auto-sense-include-inputs)
							 (vpp-alw-get-outputs-delayed sigss))
						    (and (not vpp-auto-sense-include-inputs)
							 (vpp-alw-get-outputs-immediate sigss))
						    (vpp-alw-get-temps sigss)
						    (vpp-decls-get-consts moddecls)
						    (vpp-decls-get-gparams moddecls)
						    presense-sigs)))))
    sig-list))

(defun vpp-auto-sense ()
  "Expand AUTOSENSE statements, as part of \\[vpp-auto].
Replace the always (/*AUTOSENSE*/) sensitivity list (/*AS*/ for short)
with one automatically derived from all inputs declared in the always
statement.  Signals that are generated within the same always block are NOT
placed into the sensitivity list (see `vpp-auto-sense-include-inputs').
Long lines are split based on the `fill-column', see \\[set-fill-column].

Limitations:
  Vpp does not allow memories (multidimensional arrays) in sensitivity
  lists.  AUTOSENSE will thus exclude them, and add a /*memory or*/ comment.

Constant signals:
  AUTOSENSE cannot always determine if a `define is a constant or a signal
  (it could be in an include file for example).  If a `define or other signal
  is put into the AUTOSENSE list and is not desired, use the AUTO_CONSTANT
  declaration anywhere in the module (parenthesis are required):

	/* AUTO_CONSTANT ( `this_is_really_constant_dont_autosense_it ) */

  Better yet, use a parameter, which will be understood to be constant
  automatically.

OOps!
  If AUTOSENSE makes a mistake, please report it.  (First try putting
  a begin/end after your always!) As a workaround, if a signal that
  shouldn't be in the sensitivity list was, use the AUTO_CONSTANT above.
  If a signal should be in the sensitivity list wasn't, placing it before
  the /*AUTOSENSE*/ comment will prevent it from being deleted when the
  autos are updated (or added if it occurs there already).

An example:

	   always @ (/*AS*/) begin
	      /* AUTO_CONSTANT (`constant) */
	      outin = ina | inb | `constant;
	      out = outin;
	   end

Typing \\[vpp-auto] will make this into:

	   always @ (/*AS*/ina or inb) begin
	      /* AUTO_CONSTANT (`constant) */
	      outin = ina | inb | `constant;
	      out = outin;
	   end

Note in Vpp 2001, you can often get the same result from the new @*
operator.  (This was added to the language in part due to AUTOSENSE!)

	   always @* begin
	      outin = ina | inb | `constant;
	      out = outin;
	   end"
  (save-excursion
    ;; Find beginning
    (let* ((start-pt (save-excursion
		       (vpp-re-search-backward-quick "(" nil t)
		       (point)))
	   (indent-pt (save-excursion
			(or (and (goto-char start-pt) (1+ (current-column)))
			    (current-indentation))))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (sig-memories (vpp-signals-memory
			  (vpp-decls-get-vars moddecls)))
	   sig-list not-first presense-sigs)
      ;; Read signals in always, eliminate outputs from sense list
      (setq presense-sigs (vpp-signals-from-signame
			   (save-excursion
			     (vpp-read-signals start-pt (point)))))
      (setq sig-list (vpp-auto-sense-sigs moddecls presense-sigs))
      (when sig-memories
	(let ((tlen (length sig-list)))
	  (setq sig-list (vpp-signals-not-in sig-list sig-memories))
	  (if (not (eq tlen (length sig-list))) (vpp-insert " /*memory or*/ "))))
      (if (and presense-sigs  ;; Add a "or" if not "(.... or /*AUTOSENSE*/"
	       (save-excursion (goto-char (point))
			       (vpp-re-search-backward-quick "[a-zA-Z0-9$_.%`]+" start-pt t)
			       (vpp-re-search-backward-quick "\\s-" start-pt t)
			       (while (looking-at "\\s-`endif")
				 (vpp-re-search-backward-quick "[a-zA-Z0-9$_.%`]+" start-pt t)
				 (vpp-re-search-backward-quick "\\s-" start-pt t))
			       (not (looking-at "\\s-or\\b"))))
	  (setq not-first t))
      (setq sig-list (sort sig-list `vpp-signals-sort-compare))
      (while sig-list
	(cond ((> (+ 4 (current-column) (length (vpp-sig-name (car sig-list)))) fill-column) ;+4 for width of or
	       (insert "\n")
	       (indent-to indent-pt)
	       (if not-first (insert "or ")))
	      (not-first (insert " or ")))
	(insert (vpp-sig-name (car sig-list)))
	(setq sig-list (cdr sig-list)
	      not-first t)))))

(defun vpp-auto-reset ()
  "Expand AUTORESET statements, as part of \\[vpp-auto].
Replace the /*AUTORESET*/ comment with code to initialize all
registers set elsewhere in the always block.

Limitations:
  AUTORESET will not clear memories.

  AUTORESET uses <= if the signal has a <= assignment in the block,
  else it uses =.

  If <= is used, all = assigned variables are ignored if
  `vpp-auto-reset-blocking-in-non' is nil; they are presumed
  to be temporaries.

/*AUTORESET*/ presumes that any signals mentioned between the previous
begin/case/if statement and the AUTORESET comment are being reset manually
and should not be automatically reset.  This includes omitting any signals
used on the right hand side of assignments.

By default, AUTORESET will include the width of the signal in the
autos, SystemVpp designs may want to change this.  To control
this behavior, see `vpp-auto-reset-widths'.  In some cases
AUTORESET must use a '0 assignment and it will print NOWIDTH; use
`vpp-auto-reset-widths' unbased to prevent this.

AUTORESET ties signals to deasserted, which is presumed to be zero.
Signals that match `vpp-active-low-regexp' will be deasserted by tying
them to a one.

AUTORESET may try to reset arrays or structures that cannot be
reset by a simple assignment, resulting in compile errors.  This
is a feature to be taken as a hint that you need to reset these
signals manually (or put them into a \"`ifdef NEVER signal<=`0;
`endif\" so Vpp-Mode ignores them.)

An example:

    always @(posedge clk or negedge reset_l) begin
        if (!reset_l) begin
            c <= 1;
            /*AUTORESET*/
        end
        else begin
            a <= in_a;
            b <= in_b;
            c <= in_c;
        end
    end

Typing \\[vpp-auto] will make this into:

    always @(posedge core_clk or negedge reset_l) begin
        if (!reset_l) begin
            c <= 1;
            /*AUTORESET*/
            // Beginning of autoreset for uninitialized flops
            a <= 0;
            b = 0;   // if `vpp-auto-reset-blocking-in-non' true
            // End of automatics
        end
        else begin
            a <= in_a;
            b  = in_b;
            c <= in_c;
        end
    end"

  (interactive)
  (save-excursion
    ;; Find beginning
    (let* ((indent-pt (current-indentation))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (all-list (vpp-decls-get-signals moddecls))
	   sigss sig-list dly-list prereset-sigs)
      ;; Read signals in always, eliminate outputs from reset list
      (setq prereset-sigs (vpp-signals-from-signame
			   (save-excursion
			     (vpp-read-signals
			      (save-excursion
				(vpp-re-search-backward-quick "\\(@\\|\\<begin\\>\\|\\<if\\>\\|\\<case\\>\\)" nil t)
				(point))
			      (point)))))
      (save-excursion
	(vpp-re-search-backward-quick "@" nil t)
        (setq sigss (vpp-read-always-signals)))
      (setq dly-list (vpp-alw-get-outputs-delayed sigss))
      (setq sig-list (vpp-signals-not-in (append
					      (vpp-alw-get-outputs-delayed sigss)
					      (when (or (not (vpp-alw-get-uses-delayed sigss))
							vpp-auto-reset-blocking-in-non)
						(vpp-alw-get-outputs-immediate sigss)))
					     (append
					      (vpp-alw-get-temps sigss)
					      prereset-sigs)))
      (setq sig-list (sort sig-list `vpp-signals-sort-compare))
      (when sig-list
	(insert "\n");
	(vpp-insert-indent "// Beginning of autoreset for uninitialized flops\n");
	(while sig-list
	  (let ((sig (or (assoc (vpp-sig-name (car sig-list)) all-list) ;; As sig-list has no widths
			 (car sig-list))))
	    (indent-to indent-pt)
	    (insert (vpp-sig-name sig)
		    (if (assoc (vpp-sig-name sig) dly-list)
			(concat " <= " vpp-assignment-delay)
		      " = ")
		    (vpp-sig-tieoff sig)
		    ";\n")
	    (setq sig-list (cdr sig-list))))
	(vpp-insert-indent "// End of automatics")))))

(defun vpp-auto-tieoff ()
  "Expand AUTOTIEOFF statements, as part of \\[vpp-auto].
Replace the /*AUTOTIEOFF*/ comment with code to wire-tie all unused output
signals to deasserted.

/*AUTOTIEOFF*/ is used to make stub modules; modules that have the same
input/output list as another module, but no internals.  Specifically, it
finds all outputs in the module, and if that input is not otherwise declared
as a register or wire, creates a tieoff.

AUTORESET ties signals to deasserted, which is presumed to be zero.
Signals that match `vpp-active-low-regexp' will be deasserted by tying
them to a one.

You can add signals you do not want included in AUTOTIEOFF with
`vpp-auto-tieoff-ignore-regexp'.

`vpp-auto-wire-type' may be used to change the datatype of
the declarations.

`vpp-auto-reset-widths' may be used to change how the tieoff
value's width is generated.

An example of making a stub for another module:

    module ExampStub (/*AUTOINST*/);
	/*AUTOINOUTPARAM(\"Foo\")*/
	/*AUTOINOUTMODULE(\"Foo\")*/
        /*AUTOTIEOFF*/
        // verilator lint_off UNUSED
        wire _unused_ok = &{1'b0,
                            /*AUTOUNUSED*/
                            1'b0};
        // verilator lint_on  UNUSED
    endmodule

Typing \\[vpp-auto] will make this into:

    module ExampStub (/*AUTOINST*/...);
	/*AUTOINOUTPARAM(\"Foo\")*/
	/*AUTOINOUTMODULE(\"Foo\")*/
        // Beginning of autotieoff
        output [2:0] foo;
        // End of automatics

        /*AUTOTIEOFF*/
        // Beginning of autotieoff
        wire [2:0] foo = 3'b0;
        // End of automatics
        ...
    endmodule"
  (interactive)
  (save-excursion
    ;; Find beginning
    (let* ((indent-pt (current-indentation))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-not-in
		      (vpp-decls-get-outputs moddecls)
		      (append (vpp-decls-get-vars moddecls)
			      (vpp-decls-get-assigns moddecls)
			      (vpp-decls-get-consts moddecls)
			      (vpp-decls-get-gparams moddecls)
			      (vpp-subdecls-get-interfaced modsubdecls)
			      (vpp-subdecls-get-outputs modsubdecls)
			      (vpp-subdecls-get-inouts modsubdecls)))))
      (setq sig-list (vpp-signals-not-matching-regexp
		      sig-list vpp-auto-tieoff-ignore-regexp))
      (when sig-list
	(vpp-forward-or-insert-line)
	(vpp-insert-indent "// Beginning of automatic tieoffs (for this module's unterminated outputs)\n")
	(setq sig-list (sort (copy-alist sig-list) `vpp-signals-sort-compare))
	(vpp-modi-cache-add-vars modi sig-list)  ; Before we trash list
	(while sig-list
	  (let ((sig (car sig-list)))
	    (cond ((equal vpp-auto-tieoff-declaration "assign")
		   (indent-to indent-pt)
		   (insert "assign " (vpp-sig-name sig)))
		  (t
		   (vpp-insert-one-definition sig vpp-auto-tieoff-declaration indent-pt)))
	    (indent-to (max 48 (+ indent-pt 40)))
	    (insert "= " (vpp-sig-tieoff sig)
		    ";\n")
	    (setq sig-list (cdr sig-list))))
	(vpp-insert-indent "// End of automatics\n")))))

(defun vpp-auto-undef ()
  "Expand AUTOUNDEF statements, as part of \\[vpp-auto].
Take any `defines since the last AUTOUNDEF in the current file
and create `undefs for them.  This is used to insure that
file-local defines do not pollute the global `define name space.

Limitations:
  AUTOUNDEF presumes any identifier following `define is the
  name of a define.  Any `ifdefs are ignored.

  AUTOUNDEF suppresses creating an `undef for any define that was
  `undefed before the AUTOUNDEF.  This may be used to work around
  the ignoring of `ifdefs as shown below.

An example:

	`define XX_FOO
	`define M_BAR(x)
	`define M_BAZ
	...
	`ifdef NEVER
	  `undef M_BAZ	// Emacs will see this and not `undef M_BAZ
	`endif
	...
	/*AUTOUNDEF*/

Typing \\[vpp-auto] will make this into:

	...
	/*AUTOUNDEF*/
	// Beginning of automatic undefs
	`undef XX_FOO
	`undef M_BAR
	// End of automatics

You may also provide an optional regular expression, in which case only
defines the regular expression will be undefed."
  (save-excursion
    (let* ((params (vpp-read-auto-params 0 1))
	   (regexp (nth 0 params))
	   (indent-pt (current-indentation))
	   (end-pt (point))
	   defs def)
      (save-excursion
	;; Scan from start of file, or last AUTOUNDEF
	(or (vpp-re-search-backward-quick "/\\*AUTOUNDEF\\>" end-pt t)
	    (goto-char (point-min)))
	(while (vpp-re-search-forward-quick
		"`\\(define\\|undef\\)\\s-*\\([a-zA-Z_][a-zA-Z_0-9]*\\)" end-pt t)
	  (cond ((equal (match-string-no-properties 1) "define")
		 (setq def (match-string-no-properties 2))
		 (when (and (or (not regexp)
				(string-match regexp def))
			    (not (member def defs))) ;; delete-dups not in 21.1
		   (setq defs (cons def defs))))
		(t
		 (setq defs (delete (match-string-no-properties 2) defs))))))
      ;; Insert
      (setq defs (sort defs 'string<))
      (when defs
	(vpp-forward-or-insert-line)
	(vpp-insert-indent "// Beginning of automatic undefs\n")
	(while defs
	  (vpp-insert-indent "`undef " (car defs) "\n")
	  (setq defs (cdr defs)))
	(vpp-insert-indent "// End of automatics\n")))))

(defun vpp-auto-unused ()
  "Expand AUTOUNUSED statements, as part of \\[vpp-auto].
Replace the /*AUTOUNUSED*/ comment with a comma separated list of all unused
input and inout signals.

/*AUTOUNUSED*/ is used to make stub modules; modules that have the same
input/output list as another module, but no internals.  Specifically, it
finds all inputs and inouts in the module, and if that input is not otherwise
used, adds it to a comma separated list.

The comma separated list is intended to be used to create a _unused_ok
signal.  Using the exact name \"_unused_ok\" for name of the temporary
signal is recommended as it will insure maximum forward compatibility, it
also makes lint warnings easy to understand; ignore any unused warnings
with \"unused\" in the signal name.

To reduce simulation time, the _unused_ok signal should be forced to a
constant to prevent wiggling.  The easiest thing to do is use a
reduction-and with 1'b0 as shown.

This way all unused signals are in one place, making it convenient to add
your tool's specific pragmas around the assignment to disable any unused
warnings.

You can add signals you do not want included in AUTOUNUSED with
`vpp-auto-unused-ignore-regexp'.

An example of making a stub for another module:

    module ExampStub (/*AUTOINST*/);
	/*AUTOINOUTPARAM(\"Examp\")*/
	/*AUTOINOUTMODULE(\"Examp\")*/
        /*AUTOTIEOFF*/
        // verilator lint_off UNUSED
        wire _unused_ok = &{1'b0,
                            /*AUTOUNUSED*/
                            1'b0};
        // verilator lint_on  UNUSED
    endmodule

Typing \\[vpp-auto] will make this into:

        ...
        // verilator lint_off UNUSED
        wire _unused_ok = &{1'b0,
                            /*AUTOUNUSED*/
			    // Beginning of automatics
			    unused_input_a,
			    unused_input_b,
			    unused_input_c,
			    // End of automatics
                            1'b0};
        // verilator lint_on  UNUSED
    endmodule"
  (interactive)
  (save-excursion
    ;; Find beginning
    (let* ((indent-pt (progn (search-backward "/*") (current-column)))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   (modsubdecls (vpp-modi-get-sub-decls modi))
	   (sig-list (vpp-signals-not-in
		      (append (vpp-decls-get-inputs moddecls)
			      (vpp-decls-get-inouts moddecls))
		      (append (vpp-subdecls-get-inputs modsubdecls)
			      (vpp-subdecls-get-inouts modsubdecls)))))
      (setq sig-list (vpp-signals-not-matching-regexp
		      sig-list vpp-auto-unused-ignore-regexp))
      (when sig-list
	(vpp-forward-or-insert-line)
	(vpp-insert-indent "// Beginning of automatic unused inputs\n")
	(setq sig-list (sort (copy-alist sig-list) `vpp-signals-sort-compare))
	(while sig-list
	  (let ((sig (car sig-list)))
	    (indent-to indent-pt)
	    (insert (vpp-sig-name sig) ",\n")
	    (setq sig-list (cdr sig-list))))
	(vpp-insert-indent "// End of automatics\n")))))

(defun vpp-enum-ascii (signm elim-regexp)
  "Convert an enum name SIGNM to an ascii string for insertion.
Remove user provided prefix ELIM-REGEXP."
  (or elim-regexp (setq elim-regexp "_ DONT MATCH IT_"))
  (let ((case-fold-search t))
    ;; All upper becomes all lower for readability
    (downcase (vpp-string-replace-matches elim-regexp "" nil nil signm))))

(defun vpp-auto-ascii-enum ()
  "Expand AUTOASCIIENUM statements, as part of \\[vpp-auto].
Create a register to contain the ASCII decode of an enumerated signal type.
This will allow trace viewers to show the ASCII name of states.

First, parameters are built into an enumeration using the synopsys enum
comment.  The comment must be between the keyword and the symbol.
\(Annoying, but that's what Synopsys's dc_shell FSM reader requires.)

Next, registers which that enum applies to are also tagged with the same
enum.

Finally, an AUTOASCIIENUM command is used.

  The first parameter is the name of the signal to be decoded.

  The second parameter is the name to store the ASCII code into.  For the
  signal foo, I suggest the name _foo__ascii, where the leading _ indicates
  a signal that is just for simulation, and the magic characters _ascii
  tell viewers like Dinotrace to display in ASCII format.

  The third optional parameter is a string which will be removed
  from the state names.  It defaults to \"\" which removes nothing.

  The fourth optional parameter is \"onehot\" to force one-hot
  decoding.  If unspecified, if and only if the first parameter
  width is 2^(number of states in enum) and does NOT match the
  width of the enum, the signal is assumed to be a one-hot
  decode.  Otherwise, it's a normal encoded state vector.

  `vpp-auto-wire-type' may be used to change the datatype of
  the declarations.

  \"auto enum\" may be used in place of \"synopsys enum\".

An example:

	//== State enumeration
	parameter [2:0] // synopsys enum state_info
			   SM_IDLE =  3'b000,
			   SM_SEND =  3'b001,
			   SM_WAIT1 = 3'b010;
	//== State variables
	reg [2:0]  /* synopsys enum state_info */
		   state_r;  /* synopsys state_vector state_r */
	reg [2:0]  /* synopsys enum state_info */
		   state_e1;

	/*AUTOASCIIENUM(\"state_r\", \"state_ascii_r\", \"SM_\")*/

Typing \\[vpp-auto] will make this into:

	... same front matter ...

	/*AUTOASCIIENUM(\"state_r\", \"state_ascii_r\", \"SM_\")*/
	// Beginning of automatic ASCII enum decoding
	reg [39:0]		state_ascii_r;		// Decode of state_r
	always @(state_r) begin
	   case ({state_r})
		SM_IDLE:  state_ascii_r = \"idle \";
		SM_SEND:  state_ascii_r = \"send \";
		SM_WAIT1: state_ascii_r = \"wait1\";
		default:  state_ascii_r = \"%Erro\";
	   endcase
	end
	// End of automatics"
  (save-excursion
    (let* ((params (vpp-read-auto-params 2 4))
	   (undecode-name (nth 0 params))
	   (ascii-name (nth 1 params))
	   (elim-regexp (and (nth 2 params)
			     (not (equal (nth 2 params) ""))
			     (nth 2 params)))
	   (one-hot-flag (nth 3 params))
	   ;;
	   (indent-pt (current-indentation))
	   (modi (vpp-modi-current))
	   (moddecls (vpp-modi-get-decls modi))
	   ;;
	   (sig-list-consts (append (vpp-decls-get-consts moddecls)
				    (vpp-decls-get-gparams moddecls)))
	   (sig-list-all  (vpp-decls-get-iovars moddecls))
	   ;;
	   (undecode-sig (or (assoc undecode-name sig-list-all)
			     (error "%s: Signal %s not found in design" (vpp-point-text) undecode-name)))
	   (undecode-enum (or (vpp-sig-enum undecode-sig)
			      (error "%s: Signal %s does not have an enum tag" (vpp-point-text) undecode-name)))
	   ;;
	   (enum-sigs (vpp-signals-not-in
		       (or (vpp-signals-matching-enum sig-list-consts undecode-enum)
			   (error "%s: No state definitions for %s" (vpp-point-text) undecode-enum))
		       nil))
	   ;;
	   (one-hot (or
		     (string-match "onehot" (or one-hot-flag ""))
		     (and ;; width(enum) != width(sig)
		      (or (not (vpp-sig-bits (car enum-sigs)))
			  (not (equal (vpp-sig-width (car enum-sigs))
				      (vpp-sig-width undecode-sig))))
		      ;; count(enums) == width(sig)
		      (equal (number-to-string (length enum-sigs))
			     (vpp-sig-width undecode-sig)))))
  	   (enum-chars 0)
	   (ascii-chars 0))
      ;;
      ;; Find number of ascii chars needed
      (let ((tmp-sigs enum-sigs))
	(while tmp-sigs
	  (setq enum-chars (max enum-chars (length (vpp-sig-name (car tmp-sigs))))
		ascii-chars (max ascii-chars (length (vpp-enum-ascii
						      (vpp-sig-name (car tmp-sigs))
						      elim-regexp)))
		tmp-sigs (cdr tmp-sigs))))
      ;;
      (vpp-forward-or-insert-line)
      (vpp-insert-indent "// Beginning of automatic ASCII enum decoding\n")
      (let ((decode-sig-list (list (list ascii-name (format "[%d:0]" (- (* ascii-chars 8) 1))
					 (concat "Decode of " undecode-name) nil nil))))
	(vpp-insert-definition modi decode-sig-list "reg" indent-pt nil))
      ;;
      (vpp-insert-indent "always @(" undecode-name ") begin\n")
      (setq indent-pt (+ indent-pt vpp-indent-level))
      (vpp-insert-indent "case ({" undecode-name "})\n")
      (setq indent-pt (+ indent-pt vpp-case-indent))
      ;;
      (let ((tmp-sigs enum-sigs)
	    (chrfmt (format "%%-%ds %s = \"%%-%ds\";\n"
			    (+ (if one-hot 9 1) (max 8 enum-chars))
			    ascii-name ascii-chars))
	    (errname (substring "%Error" 0 (min 6 ascii-chars))))
	(while tmp-sigs
	  (vpp-insert-indent
	   (concat
	    (format chrfmt
		    (concat (if one-hot "(")
			    ;; Use enum-sigs length as that's numeric
			    ;; vpp-sig-width undecode-sig might not be.
			    (if one-hot (number-to-string (length enum-sigs)))
			    ;; We use a shift instead of var[index]
			    ;; so that a non-one hot value will show as error.
			    (if one-hot "'b1<<")
			    (vpp-sig-name (car tmp-sigs))
			    (if one-hot ")") ":")
		    (vpp-enum-ascii (vpp-sig-name (car tmp-sigs))
					elim-regexp))))
	  (setq tmp-sigs (cdr tmp-sigs)))
	(vpp-insert-indent (format chrfmt "default:" errname)))
      ;;
      (setq indent-pt (- indent-pt vpp-case-indent))
      (vpp-insert-indent "endcase\n")
      (setq indent-pt (- indent-pt vpp-indent-level))
      (vpp-insert-indent "end\n"
			     "// End of automatics\n"))))

(defun vpp-auto-templated-rel ()
  "Replace Templated relative line numbers with absolute line numbers.
Internal use only.  This hacks around the line numbers in AUTOINST Templates
being different from the final output's line numbering."
  (let ((templateno 0) (template-line (list 0)) (buf-line 1))
    ;; Find line number each template is on
    ;; Count lines as we go, as otherwise it's O(n^2) to use count-lines
    (goto-char (point-min))
    (while (not (eobp))
      (when (looking-at ".*AUTO_TEMPLATE")
	(setq templateno (1+ templateno))
	(setq template-line (cons buf-line template-line)))
      (setq buf-line (1+ buf-line))
      (forward-line 1))
    (setq template-line (nreverse template-line))
    ;; Replace T# L# with absolute line number
    (goto-char (point-min))
    (while (re-search-forward " Templated T\\([0-9]+\\) L\\([0-9]+\\)" nil t)
      (replace-match
       (concat " Templated "
	       (int-to-string (+ (nth (string-to-number (match-string 1))
				      template-line)
				 (string-to-number (match-string 2)))))
       t t))))

(defun vpp-auto-template-lint ()
  "Check AUTO_TEMPLATEs for unused lines.
Enable with `vpp-auto-template-warn-unused'."
  (let ((name1 (or (buffer-file-name) (buffer-name))))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
	      "^\\s-*/?\\*?\\s-*[a-zA-Z0-9`_$]+\\s-+AUTO_TEMPLATE" nil t)
	(let* ((tpl-info (vpp-read-auto-template-middle))
	       (tpl-list (aref tpl-info 1))
	       (tlines (append (nth 0 tpl-list) (nth 1 tpl-list)))
	       tpl-ass)
	  (while tlines
	    (setq tpl-ass (car tlines)
		  tlines (cdr tlines))
	    ;;;
	    (unless (or (not (eval-when-compile (fboundp 'make-hash-table))) ;; Not supported, no warning
			(not vpp-auto-template-hits)
			(gethash (vector (nth 2 tpl-ass) (nth 3 tpl-ass))
				 vpp-auto-template-hits))
	      (vpp-warn-error "%s:%d: AUTO_TEMPLATE line unused: \".%s (%s)\""
				  name1
				  (+ (elt tpl-ass 3)  ;; Template line number
				     (count-lines (point-min) (point)))
				  (elt tpl-ass 0) (elt tpl-ass 1))
	      )))))))


;;
;; Auto top level
;;

(defun vpp-auto (&optional inject)  ; Use vpp-inject-auto instead of passing an arg
  "Expand AUTO statements.
Look for any /*AUTO...*/ commands in the code, as used in
instantiations or argument headers.  Update the list of signals
following the /*AUTO...*/ command.

Use \\[vpp-delete-auto] to remove the AUTOs.

Use \\[vpp-diff-auto] to see differences in AUTO expansion.

Use \\[vpp-inject-auto] to insert AUTOs for the first time.

Use \\[vpp-faq] for a pointer to frequently asked questions.

The hooks `vpp-before-auto-hook' and `vpp-auto-hook' are
called before and after this function, respectively.

For example:
	module ModuleName (/*AUTOARG*/);
	/*AUTOINPUT*/
	/*AUTOOUTPUT*/
	/*AUTOWIRE*/
	/*AUTOREG*/
	InstMod instName #(/*AUTOINSTPARAM*/) (/*AUTOINST*/);

You can also update the AUTOs from the shell using:
	emacs --batch  <filenames.v>  -f vpp-batch-auto
Or fix indentation with:
	emacs --batch  <filenames.v>  -f vpp-batch-indent
Likewise, you can delete or inject AUTOs with:
	emacs --batch  <filenames.v>  -f vpp-batch-delete-auto
	emacs --batch  <filenames.v>  -f vpp-batch-inject-auto
Or check if AUTOs have the same expansion
	emacs --batch  <filenames.v>  -f vpp-batch-diff-auto

Using \\[describe-function], see also:
    `vpp-auto-arg'          for AUTOARG module instantiations
    `vpp-auto-ascii-enum'   for AUTOASCIIENUM enumeration decoding
    `vpp-auto-assign-modport' for AUTOASSIGNMODPORT assignment to/from modport
    `vpp-auto-inout-comp'   for AUTOINOUTCOMP copy complemented i/o
    `vpp-auto-inout-in'     for AUTOINOUTIN inputs for all i/o
    `vpp-auto-inout-modport'  for AUTOINOUTMODPORT i/o from an interface modport
    `vpp-auto-inout-module' for AUTOINOUTMODULE copying i/o from elsewhere
    `vpp-auto-inout-param'  for AUTOINOUTPARAM copying params from elsewhere
    `vpp-auto-inout'        for AUTOINOUT making hierarchy inouts
    `vpp-auto-input'        for AUTOINPUT making hierarchy inputs
    `vpp-auto-insert-lisp'  for AUTOINSERTLISP insert code from lisp function
    `vpp-auto-inst'         for AUTOINST instantiation pins
    `vpp-auto-star'         for AUTOINST .* SystemVpp pins
    `vpp-auto-inst-param'   for AUTOINSTPARAM instantiation params
    `vpp-auto-logic'        for AUTOLOGIC declaring logic signals
    `vpp-auto-output'       for AUTOOUTPUT making hierarchy outputs
    `vpp-auto-output-every' for AUTOOUTPUTEVERY making all outputs
    `vpp-auto-reg'          for AUTOREG registers
    `vpp-auto-reg-input'    for AUTOREGINPUT instantiation registers
    `vpp-auto-reset'        for AUTORESET flop resets
    `vpp-auto-sense'        for AUTOSENSE always sensitivity lists
    `vpp-auto-tieoff'       for AUTOTIEOFF output tieoffs
    `vpp-auto-undef'        for AUTOUNDEF `undef of local `defines
    `vpp-auto-unused'       for AUTOUNUSED unused inputs/inouts
    `vpp-auto-wire'         for AUTOWIRE instantiation wires

    `vpp-read-defines'      for reading `define values
    `vpp-read-includes'     for reading `includes

If you have bugs with these autos, please file an issue at
URL `http://www.veripool.org/vpp-mode' or contact the AUTOAUTHOR
Wilson Snyder (wsnyder@wsnyder.org)."
  (interactive)
  (unless noninteractive (message "Updating AUTOs..."))
  (if (fboundp 'dinotrace-unannotate-all)
      (dinotrace-unannotate-all))
  (vpp-save-font-mods
   (let ((oldbuf (if (not (buffer-modified-p))
		     (buffer-string)))
	 ;; Cache directories; we don't write new files, so can't change
	 (vpp-dir-cache-preserving t)
	 ;; Cache current module
	 (vpp-modi-cache-current-enable t)
	 (vpp-modi-cache-current-max (point-min)) ; IE it's invalid
	 vpp-modi-cache-current)
     (unwind-protect
	 ;; Disable change hooks for speed
	 ;; This let can't be part of above let; must restore
	 ;; after-change-functions before font-lock resumes
	 (vpp-save-no-change-functions
	  (vpp-save-scan-cache
	   (save-excursion
	     ;; Wipe cache; otherwise if we AUTOed a block above this one,
	     ;; we'll misremember we have generated IOs, confusing AUTOOUTPUT
	     (setq vpp-modi-cache-list nil)
	     ;; Local state
	     (setq vpp-auto-template-hits nil)
	     ;; If we're not in vpp-mode, change syntax table so parsing works right
	     (unless (eq major-mode `vpp-mode) (vpp-mode))
	     ;; Allow user to customize
	     (vpp-run-hooks 'vpp-before-auto-hook)
	     ;; Try to save the user from needing to revert-file to reread file local-variables
	     (vpp-auto-reeval-locals)
	     (vpp-read-auto-lisp-present)
	     (vpp-read-auto-lisp (point-min) (point-max))
	     (vpp-getopt-flags)
	     ;; From here on out, we can cache anything we read from disk
	     (vpp-preserve-dir-cache
	      ;; These two may seem obvious to do always, but on large includes it can be way too slow
	      (when vpp-auto-read-includes
		(vpp-read-includes)
		(vpp-read-defines nil nil t))
	      ;; Setup variables due to SystemVpp expansion
	      (vpp-auto-re-search-do "/\\*AUTOLOGIC\\*/" 'vpp-auto-logic-setup)
	      ;; This particular ordering is important
	      ;; INST: Lower modules correct, no internal dependencies, FIRST
	      (vpp-preserve-modi-cache
	       ;; Clear existing autos else we'll be screwed by existing ones
	       (vpp-delete-auto)
	       ;; Injection if appropriate
	       (when inject
		 (vpp-inject-inst)
		 (vpp-inject-sense)
		 (vpp-inject-arg))
	       ;;
	       ;; Do user inserts first, so their code can insert AUTOs
	       ;; We may provide an AUTOINSERTLISPLAST if another cleanup pass is needed
	       (vpp-auto-re-search-do "/\\*AUTOINSERTLISP(.*?)\\*/"
					  'vpp-auto-insert-lisp)
	       ;; Expand instances before need the signals the instances input/output
	       (vpp-auto-re-search-do "/\\*AUTOINSTPARAM\\*/" 'vpp-auto-inst-param)
	       (vpp-auto-re-search-do "/\\*AUTOINST\\*/" 'vpp-auto-inst)
	       (vpp-auto-re-search-do "\\.\\*" 'vpp-auto-star)
	       ;; Doesn't matter when done, but combine it with a common changer
	       (vpp-auto-re-search-do "/\\*\\(AUTOSENSE\\|AS\\)\\*/" 'vpp-auto-sense)
	       (vpp-auto-re-search-do "/\\*AUTORESET\\*/" 'vpp-auto-reset)
	       ;; Must be done before autoin/out as creates a reg
	       (vpp-auto-re-search-do "/\\*AUTOASCIIENUM(.*?)\\*/" 'vpp-auto-ascii-enum)
	       ;;
	       ;; first in/outs from other files
	       (vpp-auto-re-search-do "/\\*AUTOINOUTMODPORT(.*?)\\*/" 'vpp-auto-inout-modport)
	       (vpp-auto-re-search-do "/\\*AUTOINOUTMODULE(.*?)\\*/" 'vpp-auto-inout-module)
	       (vpp-auto-re-search-do "/\\*AUTOINOUTCOMP(.*?)\\*/" 'vpp-auto-inout-comp)
	       (vpp-auto-re-search-do "/\\*AUTOINOUTIN(.*?)\\*/" 'vpp-auto-inout-in)
	       (vpp-auto-re-search-do "/\\*AUTOINOUTPARAM(.*?)\\*/" 'vpp-auto-inout-param)
	       ;; next in/outs which need previous sucked inputs first
	       (vpp-auto-re-search-do "/\\*AUTOOUTPUT\\((.*?)\\)?\\*/" 'vpp-auto-output)
	       (vpp-auto-re-search-do "/\\*AUTOINPUT\\((.*?)\\)?\\*/" 'vpp-auto-input)
	       (vpp-auto-re-search-do "/\\*AUTOINOUT\\((.*?)\\)?\\*/" 'vpp-auto-inout)
	       ;; Then tie off those in/outs
	       (vpp-auto-re-search-do "/\\*AUTOTIEOFF\\*/" 'vpp-auto-tieoff)
	       ;; These can be anywhere after AUTOINSERTLISP
	       (vpp-auto-re-search-do "/\\*AUTOUNDEF\\((.*?)\\)?\\*/" 'vpp-auto-undef)
	       ;; Wires/regs must be after inputs/outputs
	       (vpp-auto-re-search-do "/\\*AUTOASSIGNMODPORT(.*?)\\*/" 'vpp-auto-assign-modport)
	       (vpp-auto-re-search-do "/\\*AUTOLOGIC\\*/" 'vpp-auto-logic)
	       (vpp-auto-re-search-do "/\\*AUTOWIRE\\*/" 'vpp-auto-wire)
	       (vpp-auto-re-search-do "/\\*AUTOREG\\*/" 'vpp-auto-reg)
	       (vpp-auto-re-search-do "/\\*AUTOREGINPUT\\*/" 'vpp-auto-reg-input)
	       ;; outputevery needs AUTOOUTPUTs done first
	       (vpp-auto-re-search-do "/\\*AUTOOUTPUTEVERY\\*/" 'vpp-auto-output-every)
	       ;; After we've created all new variables
	       (vpp-auto-re-search-do "/\\*AUTOUNUSED\\*/" 'vpp-auto-unused)
	       ;; Must be after all inputs outputs are generated
	       (vpp-auto-re-search-do "/\\*AUTOARG\\*/" 'vpp-auto-arg)
	       ;; Fix line numbers (comments only)
	       (when vpp-auto-inst-template-numbers
		 (vpp-auto-templated-rel))
	       (when vpp-auto-template-warn-unused
		 (vpp-auto-template-lint))))
	     ;;
	     (vpp-run-hooks 'vpp-auto-hook)
	     ;;
	     (when vpp-auto-delete-trailing-whitespace
	       (vpp-delete-trailing-whitespace))
	     ;;
	     (set (make-local-variable 'vpp-auto-update-tick) (buffer-chars-modified-tick))
	     ;;
	     ;; If end result is same as when started, clear modified flag
	     (cond ((and oldbuf (equal oldbuf (buffer-string)))
		    (set-buffer-modified-p nil)
		    (unless noninteractive (message "Updating AUTOs...done (no changes)")))
		   (t (unless noninteractive (message "Updating AUTOs...done"))))
	     ;; End of after-change protection
	     )))
       ;; Unwind forms
       ;; Currently handled in vpp-save-font-mods
       ))))


;;
;; Skeleton based code insertion
;;
(defvar vpp-template-map
  (let ((map (make-sparse-keymap)))
    (define-key map "a" 'vpp-sk-always)
    (define-key map "b" 'vpp-sk-begin)
    (define-key map "c" 'vpp-sk-case)
    (define-key map "f" 'vpp-sk-for)
    (define-key map "g" 'vpp-sk-generate)
    (define-key map "h" 'vpp-sk-header)
    (define-key map "i" 'vpp-sk-initial)
    (define-key map "j" 'vpp-sk-fork)
    (define-key map "m" 'vpp-sk-module)
    (define-key map "o" 'vpp-sk-ovm-class)
    (define-key map "p" 'vpp-sk-primitive)
    (define-key map "r" 'vpp-sk-repeat)
    (define-key map "s" 'vpp-sk-specify)
    (define-key map "t" 'vpp-sk-task)
    (define-key map "u" 'vpp-sk-uvm-class)
    (define-key map "w" 'vpp-sk-while)
    (define-key map "x" 'vpp-sk-casex)
    (define-key map "z" 'vpp-sk-casez)
    (define-key map "?" 'vpp-sk-if)
    (define-key map ":" 'vpp-sk-else-if)
    (define-key map "/" 'vpp-sk-comment)
    (define-key map "A" 'vpp-sk-assign)
    (define-key map "F" 'vpp-sk-function)
    (define-key map "I" 'vpp-sk-input)
    (define-key map "O" 'vpp-sk-output)
    (define-key map "S" 'vpp-sk-state-machine)
    (define-key map "=" 'vpp-sk-inout)
    (define-key map "W" 'vpp-sk-wire)
    (define-key map "R" 'vpp-sk-reg)
    (define-key map "D" 'vpp-sk-define-signal)
    map)
  "Keymap used in Vpp mode for smart template operations.")


;;
;; Place the templates into Vpp Mode.  They may be inserted under any key.
;; C-c C-t will be the default.  If you use templates a lot, you
;; may want to consider moving the binding to another key in your init
;; file.
;;
;; Note \C-c and letter are reserved for users
(define-key vpp-mode-map "\C-c\C-t" vpp-template-map)

;;; ---- statement skeletons ------------------------------------------

(define-skeleton vpp-sk-prompt-condition
  "Prompt for the loop condition."
  "[condition]: " str )

(define-skeleton vpp-sk-prompt-init
  "Prompt for the loop init statement."
  "[initial statement]: " str )

(define-skeleton vpp-sk-prompt-inc
  "Prompt for the loop increment statement."
  "[increment statement]: " str )

(define-skeleton vpp-sk-prompt-name
  "Prompt for the name of something."
  "[name]: " str)

(define-skeleton vpp-sk-prompt-clock
  "Prompt for the name of something."
  "name and edge of clock(s): " str)

(defvar vpp-sk-reset nil)
(defun vpp-sk-prompt-reset ()
  "Prompt for the name of a state machine reset."
  (setq vpp-sk-reset (read-string "name of reset: " "rst")))


(define-skeleton vpp-sk-prompt-state-selector
  "Prompt for the name of a state machine selector."
  "name of selector (eg {a,b,c,d}): " str )

(define-skeleton vpp-sk-prompt-output
  "Prompt for the name of something."
  "output: " str)

(define-skeleton vpp-sk-prompt-msb
  "Prompt for most significant bit specification."
  "msb:" str & ?: & '(vpp-sk-prompt-lsb) | -1 )

(define-skeleton vpp-sk-prompt-lsb
  "Prompt for least significant bit specification."
  "lsb:" str )

(defvar vpp-sk-p nil)
(define-skeleton vpp-sk-prompt-width
  "Prompt for a width specification."
  ()
  (progn
    (setq vpp-sk-p (point))
    (vpp-sk-prompt-msb)
    (if (> (point) vpp-sk-p) "] " " ")))

(defun vpp-sk-header ()
  "Insert a descriptive header at the top of the file.
See also `vpp-header' for an alternative format."
  (interactive "*")
  (save-excursion
    (goto-char (point-min))
    (vpp-sk-header-tmpl)))

(define-skeleton vpp-sk-header-tmpl
  "Insert a comment block containing the module title, author, etc."
  "[Description]: "
  "//                              -*- Mode: Vpp -*-"
  "\n// Filename        : " (buffer-name)
  "\n// Description     : " str
  "\n// Author          : " (user-full-name)
  "\n// Created On      : " (current-time-string)
  "\n// Last Modified By: " (user-full-name)
  "\n// Last Modified On: " (current-time-string)
  "\n// Update Count    : 0"
  "\n// Status          : Unknown, Use with caution!"
  "\n")

(define-skeleton vpp-sk-module
  "Insert a module definition."
  ()
  > "module " '(vpp-sk-prompt-name) " (/*AUTOARG*/ ) ;" \n
  > _ \n
  > (- vpp-indent-level-behavioral) "endmodule" (progn (electric-vpp-terminate-line) nil))

;;; ------------------------------------------------------------------------
;;; Define a default OVM class, with macros and new()
;;; ------------------------------------------------------------------------

(define-skeleton vpp-sk-ovm-class
  "Insert a class definition"
  ()
  > "class " (setq name (skeleton-read "Name: ")) " extends " (skeleton-read "Extends: ") ";" \n
  > _ \n
  > "`ovm_object_utils_begin(" name ")" \n
  > (- vpp-indent-level) " `ovm_object_utils_end" \n
  > _ \n
  > "function new(name=\"" name "\");" \n
  > "super.new(name);" \n
  > (- vpp-indent-level) "endfunction" \n
  > _ \n
  > "endclass" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-uvm-class
  "Insert a class definition"
  ()
  > "class " (setq name (skeleton-read "Name: ")) " extends " (skeleton-read "Extends: ") ";" \n
  > _ \n
  > "`uvm_object_utils_begin(" name ")" \n
  > (- vpp-indent-level) " `uvm_object_utils_end" \n
  > _ \n
  > "function new(name=\"" name "\");" \n
  > "super.new(name);" \n
  > (- vpp-indent-level) "endfunction" \n
  > _ \n
  > "endclass" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-primitive
  "Insert a task definition."
  ()
  > "primitive " '(vpp-sk-prompt-name) " ( " '(vpp-sk-prompt-output) ("input:" ", " str ) " );"\n
  > _ \n
  > (- vpp-indent-level-behavioral) "endprimitive" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-task
  "Insert a task definition."
  ()
  > "task " '(vpp-sk-prompt-name) & ?; \n
  > _ \n
  > "begin" \n
  > \n
  > (- vpp-indent-level-behavioral) "end" \n
  > (- vpp-indent-level-behavioral) "endtask" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-function
  "Insert a function definition."
  ()
  > "function [" '(vpp-sk-prompt-width) | -1 '(vpp-sk-prompt-name) ?; \n
  > _ \n
  > "begin" \n
  > \n
  > (- vpp-indent-level-behavioral) "end" \n
  > (- vpp-indent-level-behavioral) "endfunction" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-always
  "Insert always block.  Uses the minibuffer to prompt
for sensitivity list."
  ()
  > "always @ ( /*AUTOSENSE*/ ) begin\n"
  > _ \n
  > (- vpp-indent-level-behavioral) "end" \n >
  )

(define-skeleton vpp-sk-initial
  "Insert an initial block."
  ()
  > "initial begin\n"
  > _ \n
  > (- vpp-indent-level-behavioral) "end" \n > )

(define-skeleton vpp-sk-specify
  "Insert specify block.  "
  ()
  > "specify\n"
  > _ \n
  > (- vpp-indent-level-behavioral) "endspecify" \n > )

(define-skeleton vpp-sk-generate
  "Insert generate block.  "
  ()
  > "generate\n"
  > _ \n
  > (- vpp-indent-level-behavioral) "endgenerate" \n > )

(define-skeleton vpp-sk-begin
  "Insert begin end block.  Uses the minibuffer to prompt for name."
  ()
  > "begin" '(vpp-sk-prompt-name) \n
  > _ \n
  > (- vpp-indent-level-behavioral) "end"
)

(define-skeleton vpp-sk-fork
  "Insert a fork join block."
  ()
  > "fork\n"
  > "begin" \n
  > _ \n
  > (- vpp-indent-level-behavioral) "end" \n
  > "begin" \n
  > \n
  > (- vpp-indent-level-behavioral) "end" \n
  > (- vpp-indent-level-behavioral) "join" \n
  > )


(define-skeleton vpp-sk-case
  "Build skeleton case statement, prompting for the selector expression,
and the case items."
  "[selector expression]: "
  > "case (" str ") " \n
  > ("case selector: " str ": begin" \n > _ \n > (- vpp-indent-level-behavioral) "end" \n > )
  resume: >  (- vpp-case-indent) "endcase" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-casex
  "Build skeleton casex statement, prompting for the selector expression,
and the case items."
  "[selector expression]: "
  > "casex (" str ") " \n
  > ("case selector: " str ": begin" \n > _ \n > (- vpp-indent-level-behavioral) "end" \n > )
  resume: >  (- vpp-case-indent) "endcase" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-casez
  "Build skeleton casez statement, prompting for the selector expression,
and the case items."
  "[selector expression]: "
  > "casez (" str ") " \n
  > ("case selector: " str ": begin" \n > _ \n > (- vpp-indent-level-behavioral) "end" \n > )
  resume: >  (- vpp-case-indent) "endcase" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-if
  "Insert a skeleton if statement."
  > "if (" '(vpp-sk-prompt-condition) & ")" " begin" \n
  > _ \n
  > (- vpp-indent-level-behavioral) "end " \n )

(define-skeleton vpp-sk-else-if
  "Insert a skeleton else if statement."
  > (vpp-indent-line) "else if ("
  (progn (setq vpp-sk-p (point)) nil) '(vpp-sk-prompt-condition) (if (> (point) vpp-sk-p) ") " -1 ) & " begin" \n
  > _ \n
  > "end" (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-datadef
  "Common routine to get data definition."
  ()
  '(vpp-sk-prompt-width) | -1 ("name (RET to end):" str ", ") -2 ";" \n)

(define-skeleton vpp-sk-input
  "Insert an input definition."
  ()
  > "input  [" '(vpp-sk-datadef))

(define-skeleton vpp-sk-output
  "Insert an output definition."
  ()
  > "output [" '(vpp-sk-datadef))

(define-skeleton vpp-sk-inout
  "Insert an inout definition."
  ()
  > "inout  [" '(vpp-sk-datadef))

(defvar vpp-sk-signal nil)
(define-skeleton vpp-sk-def-reg
  "Insert a reg definition."
  ()
  > "reg    [" '(vpp-sk-prompt-width) | -1 vpp-sk-signal ";" \n (vpp-pretty-declarations-auto) )

(defun vpp-sk-define-signal ()
  "Insert a definition of signal under point at top of module."
  (interactive "*")
  (let* ((sig-re "[a-zA-Z0-9_]*")
	 (v1 (buffer-substring
	       (save-excursion
		 (skip-chars-backward sig-re)
		 (point))
	       (save-excursion
		 (skip-chars-forward sig-re)
		 (point)))))
    (if (not (member v1 vpp-keywords))
	(save-excursion
	  (setq vpp-sk-signal v1)
	  (vpp-beg-of-defun)
	  (vpp-end-of-statement)
	  (vpp-forward-syntactic-ws)
	  (vpp-sk-def-reg)
	  (message "signal at point is %s" v1))
      (message "object at point (%s) is a keyword" v1))))

(define-skeleton vpp-sk-wire
  "Insert a wire definition."
  ()
  > "wire   [" '(vpp-sk-datadef))

(define-skeleton vpp-sk-reg
  "Insert a reg definition."
  ()
  > "reg   [" '(vpp-sk-datadef))

(define-skeleton vpp-sk-assign
  "Insert a skeleton assign statement."
  ()
  > "assign " '(vpp-sk-prompt-name) " = " _ ";" \n)

(define-skeleton vpp-sk-while
  "Insert a skeleton while loop statement."
  ()
  > "while ("  '(vpp-sk-prompt-condition)  ") begin" \n
  > _ \n
  > (- vpp-indent-level-behavioral) "end " (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-repeat
  "Insert a skeleton repeat loop statement."
  ()
  > "repeat ("  '(vpp-sk-prompt-condition)  ") begin" \n
  > _ \n
  > (- vpp-indent-level-behavioral) "end " (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-for
  "Insert a skeleton while loop statement."
  ()
  > "for ("
  '(vpp-sk-prompt-init) "; "
  '(vpp-sk-prompt-condition) "; "
  '(vpp-sk-prompt-inc)
  ") begin" \n
  > _ \n
  > (- vpp-indent-level-behavioral) "end " (progn (electric-vpp-terminate-line) nil))

(define-skeleton vpp-sk-comment
  "Inserts three comment lines, making a display comment."
  ()
  > "/*\n"
  > "* " _ \n
  > "*/")

(define-skeleton vpp-sk-state-machine
  "Insert a state machine definition."
  "Name of state variable: "
  '(setq input "state")
  > "// State registers for " str | -23 \n
  '(setq vpp-sk-state str)
  > "reg [" '(vpp-sk-prompt-width) | -1 vpp-sk-state ", next_" vpp-sk-state ?; \n
  '(setq input nil)
  > \n
  > "// State FF for " vpp-sk-state \n
  > "always @ ( " (read-string "clock:" "posedge clk") " or " (vpp-sk-prompt-reset) " ) begin" \n
  > "if ( " vpp-sk-reset " ) " vpp-sk-state " = 0; else" \n
  > vpp-sk-state " = next_" vpp-sk-state ?; \n
  > (- vpp-indent-level-behavioral) "end" (progn (electric-vpp-terminate-line) nil)
  > \n
  > "// Next State Logic for " vpp-sk-state \n
  > "always @ ( /*AUTOSENSE*/ ) begin\n"
  > "case (" '(vpp-sk-prompt-state-selector) ") " \n
  > ("case selector: " str ": begin" \n > "next_" vpp-sk-state " = " _ ";" \n > (- vpp-indent-level-behavioral) "end" \n )
  resume: >  (- vpp-case-indent) "endcase" (progn (electric-vpp-terminate-line) nil)
  > (- vpp-indent-level-behavioral) "end" (progn (electric-vpp-terminate-line) nil))


;;
;; Include file loading with mouse/return event
;;
;; idea & first impl.: M. Rouat (eldo-mode.el)
;; second (emacs/xemacs) impl.: G. Van der Plas (spice-mode.el)

(if (featurep 'xemacs)
    (require 'overlay))

(defconst vpp-include-file-regexp
  "^`include\\s-+\"\\([^\n\"]*\\)\""
  "Regexp that matches the include file.")

(defvar vpp-mode-mouse-map
  (let ((map (make-sparse-keymap))) ; as described in info pages, make a map
    (set-keymap-parent map vpp-mode-map)
    ;; mouse button bindings
    (define-key map "\r"            'vpp-load-file-at-point)
    (if (featurep 'xemacs)
	(define-key map 'button2    'vpp-load-file-at-mouse);ffap-at-mouse ?
      (define-key map [mouse-2]     'vpp-load-file-at-mouse))
    (if (featurep 'xemacs)
	(define-key map 'Sh-button2 'mouse-yank) ; you wanna paste don't you ?
      (define-key map [S-mouse-2]   'mouse-yank-at-click))
    map)
  "Map containing mouse bindings for `vpp-mode'.")


(defun vpp-highlight-region (beg end old-len)
  "Colorize included files and modules in the (changed?) region.
Clicking on the middle-mouse button loads them in a buffer (as in dired)."
  (when (or vpp-highlight-includes
	    vpp-highlight-modules)
    (save-excursion
      (save-match-data  ;; A query-replace may call this function - do not disturb
	(vpp-save-buffer-state
	 (vpp-save-scan-cache
	  (let (end-point)
	    (goto-char end)
	    (setq end-point (point-at-eol))
	    (goto-char beg)
	    (beginning-of-line)  ; scan entire line
	    ;; delete overlays existing on this line
	    (let ((overlays (overlays-in (point) end-point)))
	      (while overlays
		(if (and
		     (overlay-get (car overlays) 'detachable)
		     (or (overlay-get (car overlays) 'vpp-include-file)
			 (overlay-get (car overlays) 'vpp-inst-module)))
		    (delete-overlay (car overlays)))
		(setq overlays (cdr overlays))))
	    ;;
	    ;; make new include overlays
	    (when vpp-highlight-includes
	      (while (search-forward-regexp vpp-include-file-regexp end-point t)
		(goto-char (match-beginning 1))
		(let ((ov (make-overlay (match-beginning 1) (match-end 1))))
		  (overlay-put ov 'start-closed 't)
		  (overlay-put ov 'end-closed 't)
		  (overlay-put ov 'evaporate 't)
		  (overlay-put ov 'vpp-include-file 't)
		  (overlay-put ov 'mouse-face 'highlight)
		  (overlay-put ov 'local-map vpp-mode-mouse-map))))
	    ;;
	    ;; make new module overlays
	    (goto-char beg)
	    ;; This scanner is syntax-fragile, so don't get bent
	    (when vpp-highlight-modules
	      (condition-case nil
		  (while (vpp-re-search-forward-quick "\\(/\\*AUTOINST\\*/\\|\\.\\*\\)" end-point t)
		    (save-excursion
		      (goto-char (match-beginning 0))
		      (unless (vpp-inside-comment-or-string-p)
			(vpp-read-inst-module-matcher)   ;; sets match 0
			(let* ((ov (make-overlay (match-beginning 0) (match-end 0))))
			  (overlay-put ov 'start-closed 't)
			  (overlay-put ov 'end-closed 't)
			  (overlay-put ov 'evaporate 't)
			  (overlay-put ov 'vpp-inst-module 't)
			  (overlay-put ov 'mouse-face 'highlight)
			  (overlay-put ov 'local-map vpp-mode-mouse-map)))))
		(error nil)))
	    ;;
	    ;; Future highlights:
	    ;;  variables - make an Occur buffer of where referenced
	    ;;  pins - make an Occur buffer of the sig in the declaration module
	    )))))))

(defun vpp-highlight-buffer ()
  "Colorize included files and modules across the whole buffer."
  ;; Invoked via vpp-mode calling font-lock then `font-lock-mode-hook'
  (interactive)
  ;; delete and remake overlays
  (vpp-highlight-region (point-min) (point-max) nil))

;; Deprecated, but was interactive, so we'll keep it around
(defalias 'vpp-colorize-include-files-buffer 'vpp-highlight-buffer)

;; ffap-at-mouse isn't useful for Vpp mode. It uses library paths.
;; so define this function to do more or less the same as ffap-at-mouse
;; but first resolve filename...
(defun vpp-load-file-at-mouse (event)
  "Load file under button 2 click's EVENT.
Files are checked based on `vpp-library-flags'."
  (interactive "@e")
  (save-excursion ;; implement a Vpp specific ffap-at-mouse
    (mouse-set-point event)
    (vpp-load-file-at-point t)))

;; ffap isn't usable for Vpp mode. It uses library paths.
;; so define this function to do more or less the same as ffap
;; but first resolve filename...
(defun vpp-load-file-at-point (&optional warn)
  "Load file under point.
If WARN, throw warning if not found.
Files are checked based on `vpp-library-flags'."
  (interactive)
  (save-excursion ;; implement a Vpp specific ffap
    (let ((overlays (overlays-in (point) (point)))
	  hit)
      (while (and overlays (not hit))
	(when (overlay-get (car overlays) 'vpp-inst-module)
	  (vpp-goto-defun-file (buffer-substring
				    (overlay-start (car overlays))
				    (overlay-end (car overlays))))
	  (setq hit t))
	(setq overlays (cdr overlays)))
      ;; Include?
      (beginning-of-line)
      (when (and (not hit)
		 (looking-at vpp-include-file-regexp))
	(if (and (car (vpp-library-filenames
		       (match-string 1) (buffer-file-name)))
		 (file-readable-p (car (vpp-library-filenames
					(match-string 1) (buffer-file-name)))))
	    (find-file (car (vpp-library-filenames
			     (match-string 1) (buffer-file-name))))
	  (when warn
	    (message
	     "File '%s' isn't readable, use shift-mouse2 to paste in this field"
	     (match-string 1))))))))

;;
;; Bug reporting
;;

(defun vpp-faq ()
  "Tell the user their current version, and where to get the FAQ etc."
  (interactive)
  (with-output-to-temp-buffer "*vpp-mode help*"
    (princ (format "You are using vpp-mode %s\n" vpp-mode-version))
    (princ "\n")
    (princ "For new releases, see http://www.vpp.com\n")
    (princ "\n")
    (princ "For frequently asked questions, see http://www.veripool.org/vpp-mode-faq.html\n")
    (princ "\n")
    (princ "To submit a bug, use M-x vpp-submit-bug-report\n")
    (princ "\n")))

(autoload 'reporter-submit-bug-report "reporter")
(defvar reporter-prompt-for-summary-p)

(defun vpp-submit-bug-report ()
  "Submit via mail a bug report on vpp-mode.el."
  (interactive)
  (let ((reporter-prompt-for-summary-p t))
    (reporter-submit-bug-report
     "mac@vpp.com, wsnyder@wsnyder.org"
     (concat "vpp-mode v" vpp-mode-version)
     '(
       vpp-active-low-regexp
       vpp-after-save-font-hook
       vpp-align-ifelse
       vpp-assignment-delay
       vpp-auto-arg-sort
       vpp-auto-declare-nettype
       vpp-auto-delete-trailing-whitespace
       vpp-auto-endcomments
       vpp-auto-hook
       vpp-auto-ignore-concat
       vpp-auto-indent-on-newline
       vpp-auto-inout-ignore-regexp
       vpp-auto-input-ignore-regexp
       vpp-auto-inst-column
       vpp-auto-inst-dot-name
       vpp-auto-inst-interfaced-ports
       vpp-auto-inst-param-value
       vpp-auto-inst-sort
       vpp-auto-inst-template-numbers
       vpp-auto-inst-vector
       vpp-auto-lineup
       vpp-auto-newline
       vpp-auto-output-ignore-regexp
       vpp-auto-read-includes
       vpp-auto-reset-blocking-in-non
       vpp-auto-reset-widths
       vpp-auto-save-policy
       vpp-auto-sense-defines-constant
       vpp-auto-sense-include-inputs
       vpp-auto-star-expand
       vpp-auto-star-save
       vpp-auto-template-warn-unused
       vpp-auto-tieoff-declaration
       vpp-auto-tieoff-ignore-regexp
       vpp-auto-unused-ignore-regexp
       vpp-auto-wire-type
       vpp-before-auto-hook
       vpp-before-delete-auto-hook
       vpp-before-getopt-flags-hook
       vpp-before-save-font-hook
       vpp-cache-enabled
       vpp-case-indent
       vpp-cexp-indent
       vpp-compiler
       vpp-coverage
       vpp-delete-auto-hook
       vpp-getopt-flags-hook
       vpp-highlight-grouping-keywords
       vpp-highlight-includes
       vpp-highlight-modules
       vpp-highlight-p1800-keywords
       vpp-highlight-translate-off
       vpp-indent-begin-after-if
       vpp-indent-declaration-macros
       vpp-indent-level
       vpp-indent-level-behavioral
       vpp-indent-level-declaration
       vpp-indent-level-directive
       vpp-indent-level-module
       vpp-indent-lists
       vpp-library-directories
       vpp-library-extensions
       vpp-library-files
       vpp-library-flags
       vpp-linter
       vpp-minimum-comment-distance
       vpp-mode-hook
       vpp-mode-release-date
       vpp-mode-release-emacs
       vpp-mode-version
       vpp-preprocessor
       vpp-simulator
       vpp-tab-always-indent
       vpp-tab-to-comment
       vpp-typedef-regexp
       vpp-warn-fatal
       )
     nil nil
     (concat "Hi Mac,

I want to report a bug.

Before I go further, I want to say that Vpp mode has changed my life.
I save so much time, my files are colored nicely, my co workers respect
my coding ability... until now.  I'd really appreciate anything you
could do to help me out with this minor deficiency in the product.

I've taken a look at the Vpp-Mode FAQ at
http://www.veripool.org/vpp-mode-faq.html.

And, I've considered filing the bug on the issue tracker at
http://www.veripool.org/vpp-mode-bugs
since I realize that public bugs are easier for you to track,
and for others to search, but would prefer to email.

So, to reproduce the bug, start a fresh Emacs via " invocation-name "
-no-init-file -no-site-file'.  In a new buffer, in Vpp mode, type
the code included below.

Given those lines, I expected [[Fill in here]] to happen;
but instead, [[Fill in here]] happens!.

== The code: =="))))

(provide 'vpp-mode)

;; Local Variables:
;; checkdoc-permit-comma-termination-flag:t
;; checkdoc-force-docstrings-flag:nil
;; End:

;;; vpp-mode.el ends here
