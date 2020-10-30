(defun configure-c-mode()
  (c-set-offset 'case-label 2)
)

(defun insert-pdb ()
  (interactive)
  (insert "import pdb; pdb.set_trace()\n")
  (indent-for-tab-command)
)

(defun setup-tab-completion()
  ;(setq hippie-expand-dabbrev-as-symbol 1)
  (setq hippie-expand-verbose nil)

  ;(require 'thingatpt)

  (defun indent-or-complete ()
    "Complete if point is at end of a word, otherwise indent line."
    (interactive)
    (if (and (looking-at "\\>") (not (looking-at "^")))
        (dabbrev-expand nil)
  ;      (hippie-expand nil)
      (indent-for-tab-command)
      )
  )

  ;(global-set-key (kbd "TAB") 'indent-or-complete)

  (add-hook 'find-file-hooks
            (function (lambda ()
                        (local-set-key (kbd "TAB") 'indent-or-complete)
                        (light-symbol-mode)
                        ))
            )

  (add-hook 'python-mode-hook
            (function (lambda ()
                        (local-set-key (kbd "M-p") 'insert-pdb)
                        (modify-syntax-entry ?_ "_")
                        )
                      )
            )

;  (defun org-or-complete ()
;    "Complete if point is at end of a word, otherwise indent line."
;    (interactive)
;    (if (and (looking-at "\\>") (not (looking-at "^")))
;        (org-cycle)
;  ;      (hippie-expand nil)
;      (indent-for-tab-command)
;      )
;  )

  ;(add-hook 'org-mode-hook
  ;          (lambda () (local-set-key (kbd "TAB") 'org-or-complete)
  ;            )
  ;          )
  (add-hook 'c-mode-hook
            (lambda ()
              (define-key c-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
              ;(define-key c-mode-map (kbd "M-`") 'ff-find-other-file)
              )
            )

  (add-hook 'c++-mode-hook
            (lambda ()
              (define-key c++-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
              ;(define-key c++-mode-map (kbd "M-`") 'ff-find-other-file)
              )
            )

  (add-hook 'c-mode-hook 'configure-c-mode)
  (add-hook 'c++-mode-hook 'configure-c-mode)


  (add-hook 'emacs-lisp-mode-hook
            (lambda ()
              (define-key emacs-lisp-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
              ;(define-key emacs-lisp-mode-map (kbd "tab") 'dabbrev-expand)
              )
            )

  (add-hook 'verilog-mode-hook
            (function (lambda ()
                        (local-set-key (kbd ";") 'self-insert-command)
                        ;(define-key verilog-mode-map (kbd "RET") 'newline-and-indent)
                      )
            )
  )

  (add-hook 'vpp-mode-hook
            (function (lambda ()
                        (local-set-key (kbd ";") 'self-insert-command)
                        ;(define-key vpp-mode-map (kbd "RET") 'newline-and-indent)
                      )
            )
  )

  (global-set-key (kbd "M-`") 'ff-find-other-file)
  (global-set-key (kbd "S-TAB") 'dabbrev-completion)

;  (setq ff-search-directories (append '(".")
;                                      (list
;                                       (concat env-root "/../../common/*/include")
;                                       (concat env-root "/*/tb")
;                                       (concat env-root "/*/rtl")
;                                       (concat env-root "/*/tests/lib")
;                                       (concat env-root "/build/*")
;                                       )
;                              )
;  )

  (require 'find-file)

  (setq cc-other-file-alist
        (quote (
                ("\\.v$" (".vi" ".vh"))
                ("\\.v[ih]" (".v"))

                ("\\.vr[hi]$" (".vr"))
                ("\\.vr$" (".vrh"))

                ("\\.sv$" (".svh"))
                ("\\.sv[hi]$" (".sv"))

                ("\\.cc$" (".hh" ".h"))
                ("\\.hh$" (".cc" ".C"))
                ("\\.c$" (".h"))
                ("\\.h$" (".c" ".cc" ".C" ".CC" ".cxx" ".cpp"))
                ("\\.C$" (".H" ".hh" ".h"))
                ("\\.H$" (".C" ".CC"))
                ("\\.CC$" (".HH" ".H" ".hh" ".h"))
                ("\\.HH$" (".CC"))
                ("\\.cxx$" (".h" ".hh"))
                ("\\.cpp$" (".h" ".hh" ".hpp"))
                ("\\.hpp$" (".cpp"))

                )
         )
   )

   (setq ff-special-constructs (append
                               '(
                                 ("^ *\[#`]\\s *\\(include\\|import\\)\\s +[<\"]\\(.*\\)[>\"]" .
                                  (lambda ()
                                    (setq fname (buffer-substring (match-beginning 2) (match-end 2))))))
                               ff-special-constructs
                               )
   )

)

;(setq build-command "build")
;(defun setup-model-compilation()
;  (setq verilog-set-compile-command build-command)
;  (setq compilation-scroll-output 1)
;
;  ; Find file at point
;  (require 'find-this-file)
;
;  ; Read-only build/default hook
;  (add-hook 'find-file-hooks
;            (lambda ()
;              (if (and
;                   (string-match "/build/" buffer-file-name)
;                   (not (string-match "/src/build/" buffer-file-name)) ; tools/src/build is OK
;                   (not (file-symlink-p buffer-file-name))
;                   )
;                       (toggle-read-only 1))
;              )
;  )
;
;  ;; Some code that will make it so the background color of the lines
;  ;; that gcc found errors on, should be in another color.
;
;  (require 'custom)
;
;  (defvar all-overlays ())
;
;  (defun delete-this-overlay(overlay is-after begin end &optional len)
;    (delete-overlay overlay)
;    )
;
;  (defun highlight-current-line()
;    (interactive)
;    (setq current-point (point))
;    (beginning-of-line)
;    (setq beg (point))
;    (forward-line 1)
;    (setq end (point))
;    ;; Create and place the overlay
;    (setq error-line-overlay (make-overlay 1 1))
;
;    ;; Append to list of all overlays
;    (setq all-overlays (cons error-line-overlay all-overlays))
;
;    (overlay-put error-line-overlay
;                 'face '(background-color . "firebrick"))
;    (overlay-put error-line-overlay
;                 'modification-hooks (list 'delete-this-overlay))
;    (move-overlay error-line-overlay beg end)
;    (goto-char current-point)
;    )
;
;  (defun delete-all-overlays()
;    (while all-overlays
;      (delete-overlay (car all-overlays))
;      (setq all-overlays (cdr all-overlays))
;      )
;    )
;
;  (defun highlight-error-lines(compilation-buffer, process-result)
;    (interactive)
;    (delete-all-overlays)
;    (if (string-match "finished" process-result)
;
;        (let ((buf (get-buffer "*compilation*")))
;          (when buf
;            (delete-window (get-buffer-window buf))
;            (kill-buffer buf)
;            )
;
;          (message "Success")
;
;          )
;
;      (progn
;        (condition-case nil
;            (while t
;              (next-error)
;              (highlight-current-line)
;              )
;          (error nil))
;        ; Select the first error
;        (first-error)
;        )
;      )
;    )
;
;  (setq compilation-finish-function 'highlight-error-lines)
;)
;
(defun match-paren (arg)
  "Go to the matching paren"
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))

        (t (error "%s" "Not on a paren, brace, or bracket"))

        )
)

(defun switch-to-other-buffer ()
  "Switch to other-buffer in current window"
  (interactive)
  (switch-to-buffer (other-buffer)))

(defun backward-kill-line ()
  "Kill from the beginning of current line to point."
  (interactive)
  (kill-line 0))

;(defun strip (s)
;  "Return a new string derived by stripping whitespace surrounding string
;S."
;  (interactive "sString: ")
;  (let ((r s))
;    (when (string-match "^[ \t\n]+" r)
;      (setq r (substring r (match-end 0))))
;    (when (string-match "[ \t\n]+$" r)
;      (setq r (substring r 0 (match-beginning 0))))
;    r))
;
;(defun compile-model ()
;  (interactive)
;  (setq local-env-root (strip (shell-command-to-string "env_root")))
;  ; TODO: exit if model root not found
;  (if (string-match "ERROR" local-env-root)
;      (error local-env-root)
;    (progn
;      (setq compile-command build-command)
;      (setq compilation-search-path (list local-env-root))
;      )
;    )
;  ;    (progn
;;  (setq compilation-finish-function 'highlight-error-lines)
;
;  (recompile)
;)
;
;(defun lint ()
;  "Run the linter (duh!)"
;  (interactive)
;  (if (null buffer-file-name)
;      (error "Null buffer")
;    (progn
;      (setq compile-command
;            (concat "lint " buffer-file-name)
;            )
;      (recompile)
;
;      )
;    )
;  )
;
(defun load-defaults ()

  ; Disable auto-saving
  (setq auto-save-default nil)
  
  (setq load-path (cons "~/emacs/org/lisp" load-path))
  
  ; Make "yes or no" => "y or n"
  (fset 'yes-or-no-p 'y-or-n-p)

   ; Redo support
   (require 'redo)
   (global-set-key "\M-?" 'redo)
   
   (global-set-key (kbd "C-x p") 'bury-buffer)
   (global-set-key (kbd "C-x C-k") 'kill-this-buffer)
   
   ; Fix retarded page-up/down in emacs
   (require 'pager)
   (global-set-key "\C-v"     'pager-page-down)
   (global-set-key [next]     'pager-page-down)
   (global-set-key "\ev"      'pager-page-up)
   (global-set-key [prior]    'pager-page-up)
   (global-set-key '[M-up]    'pager-row-up)
   (global-set-key '[M-kp-8]  'pager-row-up)
   (global-set-key '[M-down]  'pager-row-down)
   (global-set-key '[M-kp-2]  'pager-row-down)
   
   (global-set-key "\M-n" 'backward-kill-line)

;   (custom-set-faces
;     ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
;     ;; Your init file should contain only one such instance.
;    '(font-lock-warning-face ((t (:foreground "red2" :weight bold)))))
;   
   (global-set-key "\M-=" 'match-paren)
   (setq auto-revert-verbose nil)
;   (setq tags-revert-without-query t)
   
   (global-set-key (kbd "<C-tab>") 'switch-to-other-buffer)
   
;   ; ASM configuration
;   ;(setq asm-comment-char ?\#)
;   ;(setq tab-stop-list '(4 8 12 16 20 24 28 32))
;   (setq-default tab-width 2)
   
   (setq c-mode-hook
       (function (lambda ()
                   (setq indent-tabs-mode nil)
                   (setq c-indent-level 2))))
   (setq c++-mode-hook
       (function (lambda ()
                   (setq indent-tabs-mode nil)
                   (setq c-indent-level 2))))
   
   (setq c-basic-offset 2)
   
   (setq c-default-style "bsd"
         c-basic-offset 2)
   
   (setq auto-mode-alist (cons '("\\.B$" . asm-mode) auto-mode-alist))
   (setq auto-mode-alist (cons '("\\.h$" . c++-mode) auto-mode-alist))
   
   ; Set the window title bar to the current buffer's name (ie. the filename)
   (setq initial-frame-alist '((name . nil) (minibuffer . t))
         frame-title-format '("%b"))
   (setq frame-title-format "Emacs: %b")
   (setq icon-title-format "%b")
   
   (setq default-frame-alist
         '(
           (width . 166)
           (height . 60)
           (background-color . "black")
           (foreground-color . "white")
           )
         )
   
   (global-set-key "\M-;" 'replace-regexp)
   (global-set-key "\M-g" 'goto-line)
   ;(global-set-key "\C-h" 'delete-backward-char)
   ;(global-set-key (kbd "DEL") 'delete-char)
   
   ; Fix the Putty home/end mappings
   (global-set-key "\e[h" 'beginning-of-line)
   (global-set-key "\e[1~" 'beginning-of-line)
   (global-set-key [kp-7] 'end-of-line)
   (global-set-key "\eOw" 'end-of-line)
   (global-set-key [select] 'end-of-line)
   
   ; Turn on auto-reverting
   (global-auto-revert-mode 1)
   
   ; Turn on column numbers
   (column-number-mode 1)
   
   ; Set the foreground and background colors (hacker-style baby!)
   ;(require 'font-lock)
;   (set-foreground-color "LightYellow2")
;   (set-background-color "black")
   
   ;(fast-lock-mode t)
   (global-font-lock-mode t)
   
   ; Highlight changes mode
   (global-set-key "\M-'" 'highlight-changes-mode)

   ; Kill other windows with meta -
   (global-set-key [(meta -)] 'delete-other-windows)
   
;   ;(setq printer-name "//big_brother/binary_p1")
;   (fset 'detab
;      [?\C-x ?h ?\M-x ?u ?n ?t ?a ?b ?i ?f ?y return])
   
   (put 'narrow-to-region 'disabled nil)
   
;   ; Log files
;   (autoload 'log-mode "log-mode" "Log Mode" t)
;   (setq auto-mode-alist (cons '("\\.log\\'" . log-mode) auto-mode-alist))

   ;; From verilog-mode.el install - EricS
   ;; Load verilog mode only when needed 
   (autoload 'verilog-mode "verilog-mode" "Verilog mode" t ) 
   ;; Any files that end in .v, .dv or .sv should be in verilog mode 
   (add-to-list 'auto-mode-alist '("\\.[ds]?v\\'" . verilog-mode)) 
   (add-to-list 'auto-mode-alist '("\\.[ds]?vh\\'" . verilog-mode)) 
   ;; Any files in verilog mode should have their keywords colorized 
   (add-hook 'verilog-mode-hook '(lambda () (font-lock-mode 1)))

   ;; From vpp-mode.el install - EricS
   ;; Load vpp mode only when needed 
   (autoload 'vpp-mode "vpp-mode" "Vpp mode" t ) 
   ;; Any files that end in .v, .dv or .sv should be in vpp mode 
   (add-to-list 'auto-mode-alist '("\\.[f]?v\\'" . vpp-mode)) 
   (add-to-list 'auto-mode-alist '("\\.[f]?vh\\'" . vpp-mode)) 
   ;; Any files in vpp mode should have their keywords colorized 
   (add-hook 'vpp-mode-hook '(lambda () (font-lock-mode 1)))

   (custom-set-variables
     ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
     ;; Your init file should contain only one such instance.
    '(indent-tabs-mode nil)
    '(make-backup-files nil)
    '(show-paren-mode t nil (paren))
    '(transient-mark-mode t)
    '(case-fold-search t)
;    '(tags-case-fold-search nil)
;    '(nxml-child-indent 4)
;    '(nxml-outline-child-indent 4)
;    '(nxml-slash-auto-complete-flag t)
   )
   
;   (global-set-key (kbd "M-<return>") 'complete-tag)
   
   (setup-tab-completion)

   (load "light-symbol")
   
;   (require 'ido)
;   (ido-mode t)
   (setq ido-enable-flex-matching t)
   (setq ido-everywhere t)
   (ido-mode 1)
   
   (require 'browse-kill-ring)
   (browse-kill-ring-default-keybindings)
   
)   ; end of load-defaults()
