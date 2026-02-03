;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun start/org-babel-tangle-config ()
  "Automatically tangle our Emacs.org config file when we save it. Credit to Emacs From Scratch for this one!"
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name "~/Git/new.emacs.d/"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'start/org-babel-tangle-config)))

(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t) ;; Always ensures that a package is installed
(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

;;(use-package quelpa)
;;(use-package quelpa-use-package)

(defvar bootstrap-version)
(let ((bootstrap-file
      (expand-file-name
       "straight/repos/straight.el/bootstrap.el"
       (or (bound-and-true-p straight-base-dir)
           user-emacs-directory)))
     (bootstrap-version 7))
 (unless (file-exists-p bootstrap-file)
   (with-current-buffer
       (url-retrieve-synchronously
        "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
        'silent 'inhibit-cookies)
     (goto-char (point-max))
     (eval-print-last-sexp)))
 (load bootstrap-file nil 'nomessage))

(use-package evil
  :init ;; Execute code Before a package is loaded
  (evil-mode)
  :config ;; Execute code After a package is loaded
  (evil-set-initial-state 'eat-mode 'insert) ;; Set initial state in eat terminal to insert mode
  (evil-set-initial-state 'org-agenda-mode 'normal)  ;; Use normal mode (not emacs) in agenda
  :custom ;; Customization of package custom variables
  (evil-want-keybinding nil)    ;; Disable evil bindings in other modes (It's not consistent and not good)
  (evil-want-C-u-scroll nil)    ;; Do not set C-u to scroll up
  (evil-want-C-i-jump nil)      ;; Disables C-i jump
  (evil-undo-system 'undo-redo) ;; C-r to redo
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links

  ;; Unmap keys in 'evil-maps. If not done, org-return-follows-link will not work
  :bind (:map evil-motion-state-map
              ("SPC" . nil)
              ("RET" . nil)
              ("TAB" . nil)))

(use-package evil-collection
  :after evil
  :custom
  (evil-collection-mode-list '(dired ibuffer magit forge corfu vertico consult dashboard org ediff ement))
  :config
  (evil-collection-init)
  )

(use-package general
  :config
  (general-evil-setup)
  ;; Global keys
  (general-define-key
   :states '(normal visual motion emacs)
   "K" 'scroll-down-command
   "J" 'scroll-up-command
   ;; "<escape>" 'keyboard-quit
   )

  ;; Mode Specific Keybinds
  ;; Shell
  (general-define-key
   :states 'insert
   :keymaps 'comint-mode-map

   "<up>" 'comint-previous-input
   "<down>" 'comint-next-input
   )

  (general-define-key
   :keymaps 'compilation-mode-map
   :states 'motion

   "<escape>" 'quit-window
   )

  (general-define-key
   :keymaps 'minibuffer-mode-map

   "<C-up>" 'previous-history-element
   "<C-down>" 'next-history-element
   )

  ;; Set up a local-leader used for language mode specific functionality
  (general-create-definer my-local-leader
    :prefix ","
    )

  ;; Add some eglot related things to , because my muscle memory demands it
  (my-local-leader
    :states '(normal visual)
    ;; If I only enable this in eglot-mode-map then setting major-mode specific binds override this one
    ;;:keymaps 'eglot-mode-map
    "g" '(:ignore t :wk "Eglot goto")
    "g g" '(xref-find-definitions :wk "Goto Definition")
    "g D" '(xref-find-definitions-other-window :wk "Goto Definition (other window)")
    "g r" '(xref-find-references :wk "Find references")
    "d" '('eldoc-doc-buffer :wk "Documentation")
    "z" '(zeal-at-point :wk "Zeal (at point)")
    )

  ;; Set up 'SPC' as primary leader key
  (general-create-definer start/leader-keys
    :states '(normal insert visual motion emacs)
    :keymaps 'override
    :prefix "SPC"           ;; Set leader key
    :global-prefix "C-SPC") ;; Set global leader key

  (start/leader-keys
    "SPC" '(execute-extended-command :wk "M-x")
    "." '(find-file :wk "Find file")
    "TAB" '(evil-switch-to-windows-last-buffer :wk "Last buffer")
    "/" '(consult-git-grep :wk "Search Project")
    )

  (start/leader-keys
    "a" '(:ignore t :wk "Applications")
    "a r" '(ranger :wk "Ranger")
    "a e" '(cadair/ement-connect :wk "Matrix")
    )

  (start/leader-keys
    "b" '(:ignore t :wk "Buffer Bookmarks")
    "b b" '(consult-buffer :wk "Switch buffer")
    "b c" '(clone-indirect-buffer :wk "Clone buffer")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone buffer other window")
    "b d" '(kill-current-buffer :wk "Kill buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b j" '(consult-bookmark :wk "Bookmark jump")
    "b l" '(evil-switch-to-windows-last-buffer :wk "Switch to last buffer")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b M" '(bookmark-delete :wk "Delete bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b N" '(evil-buffer-new :wk "New empty buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(cadair/python-scratch :wk "Python Scratch Buffer")
    "b S" '(scratch-buffer :wk "Scratch Buffer")
    "b -" '(view-echo-area-messages :wk "Messages Buffer")
    )

  (start/leader-keys
    "c" '(:ignore t :wk "Code")
    "c a"   '(eglot-code-actions :wk "Code actions")
    "c b"   '(eval-buffer :wk "Evaluate elisp in buffer")
    "c d"   '(eldoc-doc-buffer :wk "Documentation")
    "c e"   '(eglot-reconnect :wk "Eglot Reconnect")
    "c f"   '(eglot-format :wk "Eglot Format")
    "c g d" '(xref-find-definitions :wk "Goto Definition")
    "c g D" '(xref-find-definitions-other-window :wk "Goto Definition (other window)")
    "c g r" '(xref-find-references :wk "Find references")
    "c i"   '(indent-region :wk "Indent Region")
    "c l"   '(evilnc-comment-or-uncomment-lines :wk "Toggle Comments")
    "c L"   '(evilnc-toggle-comment-empty-lines :wk "Toggle commenting empty lines")
    "c o"   '(symbols-outline-show :wk "Show symbols outline")
    "c r"   '(eglot-rename :wk "Rename symbol at point")
    "c s"   '(consult-eglot-symbols :wk "Find Symbols in Workspace")
    )

  (start/leader-keys
    "d" '(:ignore t :wk "Dired")
    "j v" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    )

  (start/leader-keys
    "e"   '(:ignore t :wk "Evals and Errors")
    "e l" '(consult-flymake :wk "Consult Flymake")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    )

  (start/leader-keys
    "f" '(:ignore t :wk "Find / Files")
    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "f C" '(doom/copy-this-file :wk "Copy this file")
    "f f" '(find-file :wk "Find file")
    "f g" '(consult-ripgrep :wk "Ripgrep search in files")
    "f i" '(consult-imenu :wk "Imenu buffer locations")
    "f l" '(consult-line :wk "Find line")
    "f L" '(locate :wk "Locate file")
    "f r" '(consult-recent-file :wk "Recent files")
    "f R" '(doom/move-this-file :wk "Rename/Move file")
    "f s" '(save-buffer :wk "Save Buffer")
    "f S" '(evil-write-all :wk "Save all files")
    )

  (start/leader-keys
    "g" '(:ignore t :wk "Git")
    "g s"   '(magit                              :wk "Magit")
    "g R"   '(vc-revert                          :wk "Revert file")
    "g y"   '(git-link-homepage                  :wk "Copy link to remote")
    "g t"   '(git-timemachine-toggle             :wk "Git time machine")
    "g /"   '(magit-dispatch                     :wk "Magit dispatch")
    "g ."   '(magit-file-dispatch                :wk "Magit file dispatch")
    "g '"   '(forge-dispatch                     :wk "Forge dispatch")
    "g -"   '(blamer-mode                        :wk "Toggle blamer")
    "g b"   '(magit-branch-checkout              :wk "Magit switch branch")
    "g b"   '(magit-blame-addition               :wk "Magit blame")
    "g g"   '(magit-status                       :wk "Magit status")
    "g G"   '(magit-status-here                  :wk "Magit status here")
    "g D"   '(magit-file-delete                  :wk "Magit file delete")
    "g C"   '(magit-clone                        :wk "Magit clone")
    "g F"   '(magit-fetch                        :wk "Magit fetch")
    "g L"   '(git-link                           :wk "Link to selection")
    "g S"   '(magit-stage-buffer-file            :wk "Git stage this file")
    "g U"   '(magit-unstage-buffer-file          :wk "Git unstage this file")
    "g f"   '(:ignore t :wk "find")
    "g f f" '(magit-find-file                    :wk "Find file")
    "g f g" '(magit-find-git-config-file         :wk "Find gitconfig file")
    "g f c" '(magit-show-commit                  :wk "Find commit")
    "g f i" '(forge-visit-issue                  :wk "Find issue")
    "g f p" '(forge-visit-pullreq                :wk "Find pull request")
    "g o"   '(:ignore t :wk "open in browser")
    "g o r" '(forge-browse-remote                :wk "Browse remote")
    "g o c" '(forge-browse-commit                :wk "Browse commit")
    "g o i" '(forge-browse-issue                 :wk "Browse an issue")
    "g o p" '(forge-browse-pullreq               :wk "Browse a pull request")
    "g o I" '(forge-browse-issues                :wk "Browse issues")
    "g o P" '(forge-browse-pullreqs              :wk "Browse pull requests")
    "g l"   '(:ignore t :wk "list")
    ;;"g l g" '(+gist:list                         :wk "List gists")
    "g l r" '(magit-list-repositories            :wk "List repositories")
    "g l s" '(magit-list-submodules              :wk "List submodules")
    "g l i" '(forge-list-issues                  :wk "List issues")
    "g l p" '(forge-list-pullreqs                :wk "List pull requests")
    "g l n" '(forge-list-notifications           :wk "List notifications")
    "g c"   '(:ignore t :wk "create")
    "g c r" '(magit-init                         :wk "Initialize repo")
    "g c R" '(magit-clone                        :wk "Clone repo")
    "g c c" '(magit-commit-create                :wk "Commit")
    "g c f" '(magit-commit-fixup                 :wk "Fixup")
    "g c b" '(magit-branch-and-checkout          :wk "Branch")
    "g c i" '(forge-create-issue                 :wk "Issue")
    "g c p" '(forge-create-pullreq               :wk "Pull request")
    )

  ;; TODO: It would be nice if I could just rebind C-h to SPC h
  (start/leader-keys
    "h" '(:ignore t :wk "Help") ;; To get more help use C-h commands (describe variable, function, etc.)
    "h k" '(describe-key :wk "Describe Key")
    "h s" '(describe-symbol :wk "Describe Symbol")
    "h v" '(describe-variable :wk "Describe Variable")
    "h f" '(describe-function :wk "Describe Function")
    "h b" '(describe-bindings :wk "Describe Bindings")
    )

  (start/leader-keys
    "l" '(:ignore t :wk "Tabspaces")
    "l C" '(tabspaces-clear-buffers :wk "Clear all Buffers")
    "l b" '(tabspaces-switch-to-buffer :wk "Switch to Buffer")
    "l d" '(tabspaces-close-workspace :wk "Close Workspace")
    "l k" '(tabspaces-kill-buffers-close-workspace :wk "Kill Buffers and Close Workspace")
    "l o" '(tabspaces-open-or-create-project-and-workspace :wk "Open Project and Workspace")
    "l r" '(tabspaces-remove-current-buffer :wk "Remove current buffer")
    "l R" '(tabspaces-restore-session :wk "Restore previous session")
    "l l" '(tabspaces-switch-or-create-workspace :wk "Switch or Create Workspace")
    "l t" '(tabspaces-switch-buffer-and-tab :wk "Switch Buffer and tab")
    ;; General Tab Control
    "l TAB" '(tab-bar-switch-to-recent-tab :wk "Previous Tab")
    "l L" '(tab-move :wk "Move Tab Right")
    "l H" '((lambda () (interactive) (tab-move -1)) :wk "Move Tab Left")
    )

  (start/leader-keys
    "o" '(:ignore t :wk "Org Mode")
    "o a" '(org-agenda :wk "Agenda")
    "o c" '(org-capture :wk "Capture")
    "o d" '(cadair/org-open-year-and-jump-to-today-plan :wk "Jump to today's plan")
    "o f" '(consult-org-agenda :wk "Find Agenda Item")
    "o h" '(org-insert-todo-heading :wk "Insert TODO heading")
    "o s" '(org-insert-todo-subheading :wk "Insert TODO subheading")
    "o t" '(lambda() (interactive)(find-file "~/Notebooks/ToDo.org") :wk "Open ToDo.org")
    )

  (start/leader-keys
    "p" '(:ignore t :wk "Projects")
    "p t" '(treemacs :wk "Treemacs")
    ;; Copied from project.el
    "p !" '(project-shell-command :wk "Run command")
    "p &" '(project-async-shell-command :wk "Run command (async)")
    "p f" '(project-find-file :wk "Find file")
    "p F" '(project-or-external-find-file :wk "Find file in project or external roots")
    "p b" '(project-switch-to-buffer :wk "Switch to project buffer")
    "p s" '(eat-project-other-window :wk "Run shell in project")
    "p d" '(project-find-dir :wk "Find directory")
    "p D" '(project-dired :Wk "Dired")
    "p v" '(project-vc-dir :Wk "Run Vc-Dir")
    "p c" '(project-compile :wk "Compile Project")
    "p e" '(project-eshell :wk "Run Shell")
    "p k" '(project-kill-buffers :wk "Kill all buffers")
    "p p" '(tabspaces-open-or-create-project-and-workspace :wk "Switch Tabspaces")
    "p P" '(project-switch-project :wk "Switch Project")
    "p g" '(project-find-regexp :wk "Find matches for regexp")
    "p G" '(project-or-external-find-regexp :wk "Find matches for regexp in project or external")
    "p r" '(project-query-replace-regexp :wk "Replace regexp")
    "p x" '(project-execute-extended-command :wk "Execute extended command")
    "p o" '(project-any-command :wk "Execute any command")
    )

  (start/leader-keys
    "q" '(:ignore t :wk "Quit / Session")
    "q q" '(save-buffers-kill-terminal :wk "Quit Emacs")
    "q f" '(delete-frame :wk "Close Frame")
    "q r" '((lambda () (interactive)
              (load-file user-init-file))
            :wk "Reload Emacs config")
    "q u" '(package-upgrade-all :wk "Upgrade all packages")
    )

  (start/leader-keys
    "s" '(:ignore t :wk "Show / Spell")
    "s e" '(eat-other-window :wk "Eat terminal")
    "s k" '(browse-kill-ring :wk "Show kill-ring")
    "s c" '(flyspell-correct-word-before-point :wk "Correct word at point")
    "s s" '(flyspell-toggle :wk "Toggle flyspell")
    "s n" '(evil-next-flyspell-error :wk "Next spelling error")
    )

  (start/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t t" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t l" '(toggle-truncate-lines :wk "Toggle truncate lines")
    "t L" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t w" '(whitespace-mode :wk "Toggle whitespace highlighting")
    )

  (start/leader-keys
    "w" '(:ignore t :wk "Windows and Workspaces")
    "w h" '(evil-window-left :wk "Window left")
    "w l" '(evil-window-right :wk "Window right")
    "w j" '(evil-window-down :wk "Window Down")
    "w k" '(evil-window-up :wk "Window Up")
    "w /" '(evil-window-vsplit :wk "Vertical Split")
    "w -" '(evil-window-split :wk "Vertical Split")
    "w d" '(evil-window-delete :wk "Close window")
    "w D" '(toggle-window-dedicated :wk "Dedicate window to buffer")
    )

  (start/leader-keys
    "x" '(:ignore t :wk "Cleanup")
    "x d w" '(delete-trailing-whitespace :wk "Delete trailing whitespace")
    )
  )

(use-package emacs
  :custom
  (menu-bar-mode nil)                   ;; Disable the menu bar
  (scroll-bar-mode nil)                 ;; Disable the scroll bar
  (tool-bar-mode nil)                   ;; Disable the tool bar
  (inhibit-startup-screen t)            ;; Disable welcome screen

  (delete-selection-mode t)             ;; Select text and delete it by typing.
  (electric-indent-mode t)              ;; Turn off the weird indenting that Emacs does by default.
  (electric-pair-mode nil)              ;; Turns off automatic parens pairing
  (blink-cursor-mode nil)               ;; Don't blink cursor
  (global-auto-revert-mode t)           ;; Automatically reload file and show changes if the file has changed
  (global-display-line-numbers-mode t)  ;; Display line numbers

  (mouse-wheel-progressive-speed nil)   ;; Disable progressive speed when scrolling
  (scroll-conservatively 10)            ;; Smooth scrolling
  ;;(scroll-margin 8)

  (use-short-answers t)

  (tab-width 4)
  (setq-default 'truncate-lines t)

  (make-backup-files nil) ;; Stop creating ~ backup files
  (auto-save-default nil) ;; Stop creating # auto save files
  :hook
  (prog-mode . editorconfig-mode)
  ;; replaced by treesit-fold for now
  ;; (prog-mode . (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally
  :config
  ;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)
  :bind (
         ([escape] . keyboard-escape-quit) ;; Makes Escape quit prompts (Minibuffer Escape)
         )
  ;; Fix general.el leader key not working instantly in messages buffer with evil mode
  :ghook ('after-init-hook
          (lambda (&rest _)
            (when-let ((messages-buffer (get-buffer "*Messages*")))
              (with-current-buffer messages-buffer
                (evil-normalize-keymaps))))
          nil nil t)
  )

;; No tabs by default
(setq-default indent-tabs-mode nil)

;; Detect if a file has more lines which start with a tab vs a space and set indent-tabs-mode appropriately
;; from: https://www.emacswiki.org/emacs/NoTabs
(defun infer-indentation-style ()
  "Set indent-tabs-mode by looking at the source"
  (interactive)
  (let ((space-count (how-many "^  " (point-min) (point-max)))
        (tab-count (how-many "^\t" (point-min) (point-max))))
    (if (> space-count tab-count) (setq indent-tabs-mode nil))
    (if (> tab-count space-count) (setq indent-tabs-mode t))))

;; Run this function on all buffers
(add-hook 'prog-mode-hook #'infer-indentation-style)
(add-hook 'text-mode-hook #'infer-indentation-style)

;; Configure the whitespace built-in package to highlight indentation which doesn't match the default for a file
(use-package whitespace
  :ensure nil
  :custom
  ;; Highlight inconsistent indentation and trailing whitespace via colours (faces) and also tabs as a symbol
  (whitespace-style '(face trailing indentation tab-mark)))
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'text-mode-hook #'whitespace-mode)

(setq
 ediff-diff-options "-w" ; turn off whitespace checking
 ediff-split-window-function #'split-window-horizontally
 ediff-window-setup-function #'ediff-setup-windows-plain
 )

(setenv "LD_LIBRARY_PATH" (concat (getenv "LD_LIBRARY_PATH") (concat ":" (getenv "NIX_LD_LIBRARY_PATH"))))
;;(setenv "PATH" (concat (getenv "PATH") ":/run/current-system/sw/bin/:/home/stuart/.nix-profile/bin/"))
;;(setq exec-path (append exec-path '("/run/current-system/sw/bin/")))
;;(setq exec-path (append exec-path '("/home/stuart/.nix-profile/bin/")))

;; Make manual buffer commands obey the rules
(setq switch-to-buffer-obey-display-actions t)

;; If you try and open a new buffer in a dediated window put it somewhere else
(setq switch-to-buffer-in-dedicated-window "pop")

;; an interactive function for setting a buffer as dediated
(defun toggle-window-dedication ()
  "Toggles window dedication in the selected window."
  (interactive)
  (set-window-dedicated-p (selected-window)
     (not (window-dedicated-p (selected-window)))))

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(setq compilation-scroll-output t)
(setq compile-command "tox -e py313")

;;  (use-package gruvbox-theme
;;    :config
;;    (load-theme 'gruvbox-dark-medium t)) ;; We need to add t to trust this package

(add-to-list 'default-frame-alist '(alpha-background . 90)) ;; For all new frames henceforth

;;(set-face-attribute 'default nil
;;                    :font "JetBrains Mono"
;;                    :height 120
;;                    :weight 'medium)
;;;; This sets the default font on all graphical frames created after restarting Emacs.
;;;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;;;; are not right unless I also add this method of setting the default font.

;;(add-to-list 'default-frame-alist '(font . "JetBrains Mono")) ;; Set your favorite font
(setq-default line-spacing 0.01)

(use-package mixed-pitch
  :defer t
  :hook ((org-mode   . mixed-pitch-mode)
         (LaTeX-mode . mixed-pitch-mode)))

(use-package nerd-icons
  :if (display-graphic-p)
  :demand t
  )

(use-package nerd-icons-dired
  :hook (dired-mode . (lambda () (nerd-icons-dired-mode t))))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package emacs
  :bind
  ("C-+" . text-scale-increase)
  ("C--" . text-scale-decrease)
  ("<C-wheel-up>" . text-scale-increase)
  ("<C-wheel-down>" . text-scale-decrease))

(use-package doom-modeline
  :hook
  (after-init . doom-modeline-mode)
  (after-init . column-number-mode)
  :custom
  (doom-modeline-height 25)     ;; Sets modeline height
  (doom-modeline-bar-width 5)   ;; Sets right bar width
  )

(use-package breadcrumb
  :hook
  (prog-mode . breadcrumb-local-mode)
  (org-mode . breadcrumb-local-mode)

  :custom-face
  (breadcrumb-face ((t (:inherit mode-line))))

  :custom
  ;; This doesn't work as breadcrumb get's prepended
  ;; (header-line-format `("" header-line-indent))

  ;; Add nerd-icons to breadcrumb
  (breadcrumb-imenu-crumb-separator
   (concat " "(nerd-icons-faicon "nf-fa-chevron_right") " "))
  (breadcrumb-project-crumb-separator
   (concat " "(nerd-icons-faicon "nf-fa-chevron_right") " "))
  (breadcrumb-imenu-max-length 0.5)
  (breadcrumb-project-max-length 0.5)

  :preface
  ;; Add icons to breadcrumb
  (advice-add #'breadcrumb--format-project-node :around
              (lambda (og p more &rest r)
                "Icon For File"
                (let ((string (apply og p more r)))
                  (if (not more)
                      (concat (nerd-icons-icon-for-file string)
                              " " string)
                    (concat (nerd-icons-faicon
                             "nf-fa-folder_open"
                             :face 'breadcrumb-project-crumbs-face)
                            " "
                            string)))))

  (advice-add #'breadcrumb--format-ipath-node :around
              (lambda (og p more &rest r)
                "Icon for items"
                (let ((string (apply og p more r)))
                  (if (not more)
                      (concat (nerd-icons-codicon
                               "nf-cod-symbol_field"
                               :face 'breadcrumb-imenu-leaf-face)
                              " " string)
                    (cond ((string= string "Packages")
                           (concat (nerd-icons-codicon "nf-cod-package" :face 'breadcrumb-imenu-crumbs-face) " " string))
                          ((string= string "Requires")
                           (concat (nerd-icons-codicon "nf-cod-file_submodule" :face 'breadcrumb-imenu-crumbs-face) " " string))
                          ((or (string= string "Variable") (string= string "Variables"))
                           (concat (nerd-icons-codicon "nf-cod-symbol_variable" :face 'breadcrumb-imenu-crumbs-face) " " string))
                          ((string= string "Function")
                           (concat (nerd-icons-codicon "nf-cod-symbol_field" :face 'breadcrumb-imenu-crumbs-face) " " string))
                          (t string)))))))

(defun doom-files--update-refs (&rest files)
  "Ensure FILES are updated in `recentf', `magit' and `save-place'."
  (let (toplevels)
    (dolist (file files)
      (when (featurep 'vc)
        (vc-file-clearprops file)
        (when-let (buffer (get-file-buffer file))
          (with-current-buffer buffer
            (vc-refresh-state))))
      (when (featurep 'magit)
        (when-let (default-directory (magit-toplevel (file-name-directory file)))
          (cl-pushnew default-directory toplevels)))
      (unless (file-readable-p file)
        (when (bound-and-true-p recentf-mode)
          (recentf-remove-if-non-kept file))))
    (dolist (default-directory toplevels)
      (magit-refresh))
    (when (bound-and-true-p save-place-mode)
      (save-place-forget-unreadable-files))))

(defun doom/copy-this-file (new-path &optional force-p)
  "Copy current buffer's file to NEW-PATH then open NEW-PATH.

If FORCE-P, overwrite the destination file if it exists, without confirmation."
  (interactive
   (list (read-file-name "Copy file to: ")
         current-prefix-arg))
  (unless (and buffer-file-name (file-exists-p buffer-file-name))
    (user-error "Buffer is not visiting any file"))
  (let ((old-path (buffer-file-name (buffer-base-buffer)))
        (new-path (expand-file-name new-path)))
    (make-directory (file-name-directory new-path) 't)
    (copy-file old-path new-path (or force-p 1))
    (find-file new-path)
    (doom-files--update-refs old-path new-path)
    (message "File copied to %S" (abbreviate-file-name new-path))))

(defun doom/move-this-file (new-path &optional force-p)
  "Move current buffer's file to NEW-PATH.

If FORCE-P, overwrite the destination file if it exists, without confirmation."
  (interactive
   (list (read-file-name "Move file to: ")
         current-prefix-arg))
  (unless (and buffer-file-name (file-exists-p buffer-file-name))
    (user-error "Buffer is not visiting any file"))
  (let ((old-path (buffer-file-name (buffer-base-buffer)))
        (new-path (expand-file-name new-path)))
    (when (directory-name-p new-path)
      (setq new-path (concat new-path (file-name-nondirectory old-path))))
    (make-directory (file-name-directory new-path) 't)
    (rename-file old-path new-path (or force-p 1))
    (set-visited-file-name new-path t t)
    (doom-files--update-refs old-path new-path)
    (message "File moved to %S" (abbreviate-file-name new-path))))

(use-package hl-todo
  :config
  (global-hl-todo-mode)
  )

(use-package flymake :ensure nil
  :init
  (add-hook 'flymake-diagnostic-functions #'flymake-hl-todo nil 'local)
  :config ; (Optional) For fix bad icon display (Only for left margin)
  (advice-add #'flymake--indicator-overlay-spec
              :filter-return
              (lambda (indicator)
                (concat indicator
                        (propertize " "
                                    'face 'default
                                    'display `((margin left-margin)
                                               (space :width 5))))))
  :custom
  (flymake-indicator-type 'margins)
  (flymake-margin-indicators-string
   `((error ,(nerd-icons-faicon "nf-fa-remove_sign") compilation-error)
     (warning ,(nerd-icons-faicon "nf-fa-warning") compilation-warning)
     (note ,(nerd-icons-faicon "nf-fa-circle_info") compilation-info))))

(use-package project
  :custom
  (project-switch-commands 'project-find-file)  ;; Always open find file after switching project
  )

(use-package tab-bar
  :hook (after-init . tab-bar-mode)
  )

(use-package tabspaces
  :hook (after-init . tabspaces-mode)
  :custom
  (tabspaces-use-filtered-buffers-as-default t)
  (tabspaces-default-tab "Default")
  (tabspaces-remove-to-default t)
  (tabspaces-include-buffers '("*scratch*"))
  (tabspaces-initialize-project-with-todo nil)
  ;; sessions
  (tabspaces-session t)
  (tabspaces-session-auto-restore nil)
  (tab-bar-new-tab-choice "*scratch*")
  )

;; Filter Buffers for Consult-Buffer

;; (with-eval-after-load 'consult
;; ;; hide full buffer list (still available with "b" prefix)
;; (consult-customize consult-source-buffer :hidden t :default nil)
;; ;; set consult-workspace buffer list
;; (defvar consult--source-workspace
;;   (list :name     "Workspace Buffers"
;;         :narrow   ?w
;;         :history  'buffer-name-history
;;         :category 'buffer
;;         :state    #'consult--buffer-state
;;         :default  t
;;         :items    (lambda () (consult--buffer-query
;;                          :predicate #'tabspaces--local-buffer-p
;;                          :sort 'visibility
;;                          :as #'buffer-name)))

;;   "Set workspace buffer list for consult-buffer.")
;; (add-to-list 'consult-buffer-sources 'consult--source-workspace))

(defun get-python-env-root ()
  "Return the value of `python-shell-virtualenv-root` if defined, otherwise nil."
  ;; This should work for micromamba and venvs
  (if (bound-and-true-p python-shell-virtualenv-root)
      python-shell-virtualenv-root
    nil))

(use-package eglot
  :ensure nil ;; Don't install eglot because it's now built-in
  :hook ((python-mode python-ts-mode nix-mode nix-ts-mode scad-mode markdown-mode rst-mode yaml-ts-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nil")))
  (add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
  (add-to-list 'eglot-server-programs '(scad-mode . ("openscad-lsp")))
  (add-to-list 'eglot-server-programs '(text-mode . ("harper-ls" "--stdio")))
  (add-to-list 'eglot-server-programs '(rst-mode . ("harper-ls" "--stdio")))
  (add-to-list 'eglot-server-programs '(markdown-mode . ("harper-ls" "--stdio")))
  (add-to-list 'eglot-server-programs '(yaml-ts-mode . ("yaml-language-server" "--stdio")))
  :custom
  ;; (eglot-events-buffer-size 0) ;; No event buffers (Lsp server logs)
  (eglot-autoshutdown t);; Shutdown unused servers.
  ;; (eglot-report-progress nil) ;; Disable lsp server logs (Don't show lsp messages at the bottom, java)

  ;; Dynamically load the workspace configuration so that we set jedi to use the active workspace
  (eglot-workspace-configuration
   (lambda (&rest args)
     (let ((venv-directory (get-python-env-root)))
       (message "Located venv: %s" venv-directory)
       `((:pylsp .
                 (:plugins
                  (:jedi_completion (:fuzzy t)
                                    :jedi (:environment ,venv-directory)
                                    :pydocstyle (:enabled nil)
                                    :pycodestyle (:enabled nil)
                                    :mccabe (:enabled nil)
                                    :pyflakes (:enabled nil)
                                    :flake8 (:enabled nil)
                                    :black (:enabled nil))))))))
  )

(defun restart-eglot ()
  (interactive)
  ;; Check if there's an active Eglot server
  (let ((current-server (eglot-current-server)))
    ;; If a server exists, prompt the user to continue
    (if current-server
        ;; Shut down the server if user confirms
        (eglot-shutdown current-server)))
  ;; Restart Eglot for the current buffer
  (eglot-ensure))

(use-package dape
  :preface
  ;; By default dape shares the same keybinding prefix as `gud'
  ;; If you do not want to use any prefix, set it to nil.
  (setq dape-key-prefix nil)

  :config
  ;; Turn on global bindings for setting breakpoints with mouse
  (dape-breakpoint-global-mode)

  ;; Info buffers to the right
  (setq dape-buffer-window-arrangement 'right)

  ;; Info buffers like gud (gdb-mi)
  ;; (setq dape-buffer-window-arrangement 'gud)
  ;; (setq dape-info-hide-mode-line nil)

  ;; Pulse source line (performance hit)
  ;; (add-hook 'dape-display-source-hook 'pulse-momentary-highlight-one-line)

  ;; Showing inlay hints
  ;; (setq dape-inlay-hints t)

  ;; Save buffers on startup, useful for interpreted languages
  (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))

  ;; Kill compile buffer on build success
  ;; (add-hook 'dape-compile-hook 'kill-buffer)

  ;; Projectile users
  ;; (setq dape-cwd-function 'projectile-project-root)
  )

(use-package yasnippet-snippets
  :hook
  (prog-mode . yas-minor-mode)
  (rst-mode . yas-minor-mode)
  (markdown-mode . yas-minor-mode)
  (org-mode . yas-minor-mode)
  :custom
  (yas-snippet-dirs
   '("~/.emacs.d/snippets"                 ;; writeable snippets dir
         "~/.emacs.d/hm-snippets"              ;; snippets managed by home-manager
     )
   )
  )

(use-package treesit-fold
   :straight (treesit-fold :type git :host github :repo "emacs-tree-sitter/treesit-fold")
   :custom
   (global-treesit-fold-mode t)
   (global-treesit-fold-indicators-mode nil)
   (treesit-fold-summary-show t)
   (treesit-fold-summary-max-length 100)
)

(use-package combobulate
  :vc (:url "https://github.com/mickeynp/combobulate.git"
       :rev "master")
  :hook ((prog-mode . combobulate-mode)))

(my-local-leader
  :states 'normal
  :keymaps 'combobulate-key-map
  "o" 'evil-combobulate-state
  )

(evil-define-state combobulate
  "Combobulate state"
  :tag " <C> "
  :enable (normal)
  (message (if (evil-combobulate-state-p)
               "Enabling combobulate state."
             "Disabling combobulate state.")))

;; Define the bindings for combobulate state
(evil-define-key 'combobulate 'combobulate-key-map
  ;; Combobulate
  "o" 'combobulate

  ;; Linear navigation
  "w" 'combobulate-navigate-logical-next
  "b" 'combobulate-navigate-logical-previous

  ;; Tree Navigation (hjkl)
  "h" 'combobulate-navigate-up
  "j" 'combobulate-navigate-next
  "k" 'combobulate-navigate-previous
  "l" 'combobulate-navigate-down

  )

(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)))

(use-package pyvenv
  :ensure t
  :hook (pyvenv-post-activate-hooks . restart-eglot)
  )

(setenv "MAMBA_ROOT_PREFIX" (expand-file-name "~/.local/share/mamba"))
(use-package micromamba
  :ensure t
  :hook (micromamba-postactivate-hook . restart-eglot)
  )

(use-package python-pytest
  :config
  (transient-append-suffix 'python-pytest-dispatch
    '(-2)
    ["Extra Options"
     ("-r" "Remote data (any)" "--remote-data=any")
     ("-c" "Coverage" "--cov --cov-report=term-missing")
         ]
    )
  )

(use-package flymake-ruff
  :vc (:url "https://github.com/erickgnavar/flymake-ruff"
                        :rev :newest)
  :ensure t
  :hook (eglot-managed-mode . flymake-ruff-load)
  :config
  (setq flymake-ruff--severity-map '(
                                    ("SyntaxError" . :error)     ; Syntax Errors
                                    ("E"           . :error)     ; Critical style errors
                                    ("W"           . :warning)   ; Style warnings
                                    ("F"           . :error)     ; Logical errors (pyflakes)
                                    ("B"           . :warning)   ; Bugbears (best practices)
                                    ("C90"         . :warning)   ; Complexity (mccabe)
                                    ("N"           . :note)      ; Naming conventions
                                    ("I"           . :note)      ; Import sorting
                                    ("UP"          . :note)      ; Python upgrades (pyupgrade)
                                    ("SIM"         . :note)      ; Simplification
                                    ("PERF"        . :warning)   ; Performance issues
                                    )
        )
  )

(use-package python-isort)
(use-package ruff-format)
(use-package python-black)
(use-package reformatter)

;; Define a formatter which runs ruff check --fix
(reformatter-define ruff-check
  :program ruff-format-command
  :args (list "check" "--fix" "--unsafe-fixes" "--stdin-filename" (or (buffer-file-name) input-file))
  :lighter " RuffCheck")

(defun cadair/python-scratch ()
  "Launch a scratch buffer in Python Mode"
  (interactive)
  (switch-to-buffer (get-buffer-create "*python-scratch*"))
  (with-current-buffer "*python-scratch*" (python-ts-mode)))

;; Add to __all__
(defsubst python-in-string/comment ()
  "Return non-nil if point is in a Python literal (a comment or string)."
  ;; We don't need to save the match data.
  (nth 8 (syntax-ppss)))

(defun python-add-to-all ()
  "Take the symbol under the point and add it to the __all__ list, if it's not already there."
  (interactive)
  (save-excursion
    (let ((thing (thing-at-point 'symbol)))
      (if (progn (goto-char (point-min))
                 (let (found)
                   (while (and (not found)
                               (re-search-forward (rx symbol-start "__all__" symbol-end
                                                      (0+ space) "=" (0+ space)
                                                      (syntax open-parenthesis))
                                                  nil t))
                     (setq found (not (python-in-string/comment))))
                   found))
          (when (not (looking-at (rx-to-string
                                  `(and (0+ (not (syntax close-parenthesis)))
                                        (syntax string-quote) ,thing (syntax string-quote)))))
            (insert (format "\"%s\", " thing)))
        (beginning-of-buffer)
        ;; Put before any import lines, or if none, the first class or
        ;; function.
        (when (re-search-forward (rx bol (or "import" "from") symbol-end) nil t)
          (re-search-forward (rx symbol-start (or "def" "class") symbol-end) nil t))
        (forward-line -1)
        (insert (format "\n__all__ = [\"%s\"]\n\n" thing))))))

(defun +python-executable-find (exe)
  "Resolve the path to the EXE executable.
Tries to be aware of your active conda/pipenv/virtualenv environment, before
falling back on searching your PATH."
  (if (file-name-absolute-p exe)
      (and (file-executable-p exe) exe)
    (let ((exe-root (format "bin/%s" exe)))
          ;; micromamba sets python-shell-virtualenv-root as well
      (or (and python-shell-virtualenv-root
               (let ((bin (expand-file-name exe-root python-shell-virtualenv-root)))
                 (and (file-exists-p bin) bin)))
          (executable-find exe)))))

(defun +python/open-repl ()
  "Open the Python REPL."
  (interactive)
  (require 'python)
  (unless python-shell-interpreter
    (user-error "`python-shell-interpreter' isn't set"))
  (pop-to-buffer
   (process-buffer
    (let ((dedicated (bound-and-true-p python-shell-dedicated)))
      (if-let* ((pipenv (+python-executable-find "pipenv"))
                (pipenv-project (pipenv-project-p)))
          (let ((default-directory pipenv-project)
                (python-shell-interpreter-args
                 (format "run %s %s"
                         python-shell-interpreter
                         python-shell-interpreter-args))
                (python-shell-interpreter pipenv))
            (run-python nil dedicated t))
        (run-python nil dedicated t))))))

(defvar +python-ipython-command '("ipython" "-i" "--simple-prompt" "--no-color-info")
  "Command to initialize the ipython REPL for `+python/open-ipython-repl'.")

(defun +python/open-ipython-repl ()
  "Open an IPython REPL."
  (interactive)
  (require 'python)
  (let ((python-shell-interpreter
         (or (+python-executable-find (car +python-ipython-command))
             "ipython"))
        (python-shell-interpreter-args
         (string-join (cdr +python-ipython-command) " ")))
    (+python/open-repl)))

(defun cadair/run-restart-repl ()
  "Run a new python repl in a window which does not have focus."
  (interactive)
  (setq initial-buffer (current-buffer))
  (if (python-shell-get-buffer)
          (kill-process (get-buffer-process (python-shell-get-buffer))))
  (sleep-for 0.5)
  (+python/open-ipython-repl)
  (evil-normal-state)
  (pop-to-buffer initial-buffer)
  )

(defun cadair/run-in-repl (arg)
  "Run a python buffer in a new ipython repl"
  (interactive "P")
  (cadair/run-restart-repl)
  (run-at-time 0.5 nil 'python-shell-send-buffer)
  )

(defun cadair/run-in-repl-switch (arg)
  "Run a python buffer in a new ipython repl"
  (interactive "P")
  (cadair/run-restart-repl)
  (run-at-time 0.5 nil 'python-shell-send-buffer)
  (run-at-time 1.0 nil (pop-to-buffer (python-shell-get-buffer)))
  )

(defun cadair/python-execute-file (arg)
  "Execute a python script in a shell."
  (interactive "P")
  ;; set compile command to buffer-file-name
  ;; universal argument put compile buffer in comint mode
  (let ((universal-argument t)
        (compile-command (format "python %s"
                                 (shell-quote-argument (file-name-nondirectory buffer-file-name)))))
    (if arg
        (call-interactively 'compile)
          (compile compile-command t)
          (with-current-buffer (get-buffer "*compilation*")
        (inferior-python-mode)))))

;; Always scroll to the end in a python shell
(add-hook 'inferior-python-mode-hook
                  (lambda ()
            (setq comint-move-point-for-output t)))

(my-local-leader
  :states 'normal
  :keymaps 'python-ts-mode-map
  "t a" 'python-pytest
  "t f" 'python-pytest-file-dwim
  "t F" 'python-pytest-file
  "t t" 'python-pytest-run-def-or-class-at-point-dwim
  "t T" 'python-pytest-run-def-or-class-at-point
  "t r" 'python-pytest-repeat
  "t p" 'python-pytest-dispatch

  "c" 'cadair/python-execute-file
  "r" 'cadair/run-in-repl
  "R" 'cadair/run-in-repl-switch
  "a" 'python-add-to-all

  ;; Reformatting
  "f i" 'python-isort-buffer
  "f b" 'python-black-buffer
  "f r" 'ruff-format-buffer
  "f c" 'ruff-check-buffer

  "m a" 'micromamba-activate
  "m d" 'micromamba-deactivate
  "v a" 'pyvenv-workon
  "v d" 'pyvenv-deactivate
  )

(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.asdf\\'" . yaml-ts-mode))

(use-package nix-ts-mode
 :mode "\\.nix\\'")

(use-package quarto-mode)

(my-local-leader
  :states 'normal
  :keymaps 'poly-quarto-polymode-map
  "m a" 'micromamba-activate
  "m d" 'micromamba-deactivate
  "v a" 'pyvenv-workon
  "v d" 'pyvenv-deactivate
  )

(define-derived-mode xonsh-mode python-ts-mode "xonsh" "Major mode for xonsh")
(add-hook 'xonsh-mode-hook (lambda () (flymake-mode 0)))
(add-to-list 'auto-mode-alist '("\\.xsh\\'" . xonsh-mode))
(add-to-list 'auto-mode-alist '("\\.xonshrc\\'" . xonsh-mode))

(use-package rustic
  :ensure t
  :config
  (setq rustic-format-on-save nil)
  :custom
  (rustic-cargo-use-last-stored-arguments t)
  (rustic-lsp-client 'eglot)
)

(use-package terraform-mode
  :ensure t
  :custom
  (terraform-indent-level 2)
  (terraform-format-on-save t)
)

(use-package jinja2-mode)

(use-package mermaid-mode)

(my-local-leader
  :states 'normal
  :keymaps 'mermaid-mode-map
  "c c" 'mermaid-compile
  "c f" 'mermaid-compile-file
  "c b" 'mermaid-compile-buffer
  "c r" 'mermaid-compile-region
  "o b" 'mermaid-open-browser
  "o d" 'mermaid-open-doc
  )

(use-package auctex
  :ensure t)

(use-package magit
  :commands magit-status
  )
(my-local-leader
  :states 'normal
  :keymaps 'git-commit-mode-map
  "i" '(git-commit-insert-trailer :wk "Insert Trailer")
  "c" '(with-editor-finish :wk "Commit")
  "k" '(with-editor-cancel :wk "Abort")
  )

(use-package forge
  :after magit
  )

(my-local-leader
  :states 'normal
  :keymaps 'forge-post-mode-map
  "d" '(forge-topic-toggle-draft :wk "Toggle Draft")
  )

(use-package diff-hl
  :hook ((dired-mode         . diff-hl-dired-mode-unless-remote)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

(use-package git-link
  :custom
  (git-link-use-commit t)
  )

(use-package git-timemachine)

(use-package blamer)

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.5)    ;; Lower popupinfo delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :after corfu
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  ;; The functions that are added later will be the first in the list

  (add-to-list 'completion-at-point-functions #'cape-dabbrev) ;; Complete word from current buffers
  ;; TODO: Make this find the nixos wordlist
  ;; https://github.com/NixOS/nixpkgs/issues/16545
  ;; (add-to-list 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  (add-to-list 'completion-at-point-functions #'cape-file) ;; Path completion
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ;; Complete elisp in Org or Markdown mode
  (add-to-list 'completion-at-point-functions #'cape-keyword) ;; Keyword/Snipet completion

  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev) ;; Complete abbreviation
  ;;(add-to-list 'completion-at-point-functions #'cape-history) ;; Complete from Eshell, Comint or minibuffer history
  ;;(add-to-list 'completion-at-point-functions #'cape-line) ;; Complete entire line from current buffer
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol) ;; Complete Elisp symbol
  (add-to-list 'completion-at-point-functions #'cape-tex) ;; Complete Unicode char from TeX command, e.g. \hbar
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml) ;; Complete Unicode char from SGML entity, e.g., &alpha
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345) ;; Complete Unicode char using RFC 1345 mnemonics
  )

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-count 20)
  )

;; (use-package vertico-posframe
;;   :init
;;   (setq vertico-posframe-parameters   '((left-fringe  . 12)    ;; Fringes
;;                                         (right-fringe . 12)
;;                                         (undecorated  . nil))) ;; Rounded frame
;;   :config
;;   (vertico-posframe-mode 1)
;;   :custom
;;   (vertico-posframe-width        120)                      ;; Narrow frame
;;   (vertico-posframe-height       vertico-count)            ;; Default height
;;   ;; Don't create posframe for these commands
;;   (vertico-multiform-commands    '((consult-line    (:not posframe))
;;                                    (consult-ripgrep (:not posframe))
;;                                    (consult-imenu   (:not posframe))
;;                                    (org-refile-get-location   (:not posframe)))
;;                                  )
;;   )

(savehist-mode) ;; Enables save history mode

(use-package marginalia
 :after vertico
 :init
 (marginalia-mode))

(use-package nerd-icons-completion
 :after marginalia
 :config
 (nerd-icons-completion-mode)
 :hook
 ('marginalia-mode-hook . 'nerd-icons-completion-marginalia-setup))

(use-package consult)

(use-package diminish)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init
  (which-key-mode 1)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display, because the default is only 1
  (which-key-idle-delay 0.8)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25)
  (which-key-allow-imprecise-window-fit nil)) ;; Fixes which-key window slipping out in Emacs Daemon

(use-package treemacs
  :ensure t
  :defer t
  :init (treemacs-project-follow-mode)
  )
(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t
  )
(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t
  )

(use-package ranger)

;; use-package with package.el:
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-display-icons-p t)     ; display icons on both GUI and terminal
  (dashboard-icon-type 'nerd-icons) ; use `nerd-icons' package
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-items '(
                     (projects  . 5)
                     (recents   . 5)
                     (agenda    . 5)
                     ))
  ;; TODO: Customise font faces for no underline
  )

(use-package browse-kill-ring)

(defun flyspell-on-for-buffer-type ()
  "Enable Flyspell appropriately for the major mode of the current buffer.  Uses `flyspell-prog-mode' for modes derived from `prog-mode', so only strings and comments get checked.  All other buffers get `flyspell-mode' to check all text.  If flyspell is already enabled, does nothing."
  (interactive)
  (if (not (symbol-value flyspell-mode)) ; if not already on
      (progn
        (if (derived-mode-p 'prog-mode)
            (progn
              (message "Flyspell on (code)")
              (flyspell-prog-mode))
          ;; else
          (progn
            (message "Flyspell on (text)")
            (flyspell-mode 1)))
        ;; I tried putting (flyspell-buffer) here but it didn't seem to work
        )))

(defun flyspell-toggle ()
  "Turn Flyspell on if it is off, or off if it is on.  When turning on, it uses `flyspell-on-for-buffer-type' so code-vs-text is handled appropriately."
  (interactive)
  (if (symbol-value flyspell-mode)
      (progn ; flyspell is on, turn it off
        (message "Flyspell off")
        (flyspell-mode -1))
                                                                                ; else - flyspell is off, turn it on
    (flyspell-on-for-buffer-type)))

(add-hook 'find-file-hook 'flyspell-on-for-buffer-type)

(use-package evil-nerd-commenter)

(use-package indent-bars
  :ensure t
  :hook ((emacs-lisp-mode
          markdown-mode
          rst-mode
          yaml-ts-mode) . indent-bars-mode))

(use-package eat
  :custom
  (shell-file-name "xonsh")
  )

(use-package zeal-at-point)

(setq cadair-year-plan
      (expand-file-name (format "~/Notebooks/%s.org"
                                (format-time-string "%Y"))))

(use-package org
  :defer t
  :custom
  (org-edit-src-content-indentation 2) ;; Set src block automatic indent to 4 instead of 2.
  :hook
  (org-mode . org-indent-mode) ;; Indent text

:config
(setq org-adapt-indentation t
      org-hide-leading-stars t
      org-pretty-entities t
      org-ellipsis "  ·"
      org-startup-folded "content"
      org-cycle-separator-lines -1
      )

(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-edit-src-content-indentation 0)

(setq org-log-done                       t
      org-auto-align-tags                t
      org-tags-column                    -80
      org-fold-catch-invisible-edits     'show-and-error
      org-special-ctrl-a/e               t
      org-insert-heading-respect-content t)

)

(setq org-fontify-done-headline t)
(custom-set-faces
 '(org-done ((t (:weight normal
                                                 :strike-through t))))
 '(org-headline-done
   ((((class color) (min-colors 16))
     (:strike-through t)))))

(add-hook 'org-mode-hook 'variable-pitch-mode)

;; Use the other two org fixes from the vertico readme
;; (advice-add #'org-make-tags-matcher :around #'vertico-enforce-basic-completion)
;; (advice-add #'org-agenda-filter :around #'vertico-enforce-basic-completion)

;; (defun vertico-enforce-basic-completion (&rest args)
;;   (minibuffer-with-setup-hook
;;       (:append
;;        (lambda ()
;;          (let ((map (make-sparse-keymap)))
;;            (define-key map [tab] #'minibuffer-complete)
;;            (use-local-map (make-composed-keymap (list map) (current-local-map))))
;;          (setq-local completion-styles (cons 'basic completion-styles)
;;                      vertico-preselect 'prompt)))
;;     (apply args)))

;; Alternative 2: Complete full paths
(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

;; (use-package org-superstar
;;   :after org
;;   :hook (org-mode . org-superstar-mode))

(use-package org-tempo
  :ensure nil
  :after org)

(use-package org-modern
  :hook
  (org-mode-hook . org-modern-mode)
  )

(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages 'org-babel-load-languages
                                                    '((python . t)
                                                      (emacs-lisp . t)
                                                      (org . t)
                                                      (shell . t)
                                                      ))

(use-package htmlize)

(use-package ox-reveal
  :vc (:url "https://github.com/Cadair/org-reveal.git"
       :rev "master"))

(my-local-leader
     :states '(normal visual)
     :keymaps 'org-mode-map

     "#" 'org-update-statistics-cookies
     "'" 'org-edit-special
     "*" 'org-ctrl-c-star
     "+" 'org-ctrl-c-minus
     "," 'org-switchb
     "." 'org-goto
     "@" 'org-cite-insert
     "." 'consult-org-heading
     "/" 'consult-org-agenda
     "A" 'org-archive-subtree-default
     "e" 'org-export-dispatch
     "f" 'org-footnote-action
     "h" 'org-toggle-heading
     "I" 'org-id-get-create
     ;; "K" #'+org/remove-result-blocks
     "n" 'org-store-link
     "o" 'org-set-property
     "q" 'org-set-tags-command
     "r" '(:ignore t :wk "Org Babel")
     "r b" 'org-babel-execute-buffer
     "r e" 'org-babel-execute-maybe
     "r k" 'org-babel-remove-result
     "t" 'org-todo
     "T" 'org-todo-list
     "x" 'org-toggle-checkbox
     "a" '(:ignore t :wk "Attachments")
     "a a" 'org-attach
     "a d" 'org-attach-delete-one
     "a D" 'org-attach-delete-all
     ;; "a f" #'+org/find-file-in-attachments
     ;; "a l" #'+org/attach-file-and-insert-link
     "a n" 'org-attach-new
     "a o" 'org-attach-open
     "a O" 'org-attach-open-in-emacs
     "a r" 'org-attach-reveal
     "a R" 'org-attach-reveal-in-emacs
     "a u" 'org-attach-url
     "a s" 'org-attach-set-directory
     "a S" 'org-attach-sync
     "b" '(:ignore t :wk "Tables")
     "b -" 'org-table-insert-hline
     "b a" 'org-table-align
     "b b" 'org-table-blank-field
     "b c" 'org-table-create-or-convert-from-region
     "b e" 'org-table-edit-field
     "b f" 'org-table-edit-formulas
     "b h" 'org-table-field-info
     "b s" 'org-table-sort-lines
     "b r" 'org-table-recalculate
     "b R" 'org-table-recalculate-buffer-tables
     ;; TODO: Figure these sub leader bindings out
     ;; "b s" '(:ignore t :wk "delete")
     ;; "b s c" 'org-table-delete-column
     ;; "b s r" 'org-table-kill-row
     ;; "b i" '(:ignore t :wk "insert")
     ;; "b i c" 'org-table-insert-column
     ;; "b i h" 'org-table-insert-hline
     ;; "b i r" 'org-table-insert-row
     ;; "b i H" 'org-table-hline-and-move
     ;; "b t" '(:ignore t :wk "toggle")
     ;; "b t f" 'org-table-toggle-formula-debugger
     ;; "b t o" 'org-table-toggle-coordinate-overlays
     "c" '(:ignore t :wk "clock")
     "c c" 'org-clock-cancel
     "c d" 'org-clock-mark-default-task
     "c e" 'org-clock-modify-effort-estimate
     "c E" 'org-set-effort
     "c g" 'org-clock-goto
     ;; "c G" (cmd! (org-clock-goto 'select))
     ;; "c l" #'+org/toggle-last-clock
     "c i" 'org-clock-in
     "c I" 'org-clock-in-last
     "c o" 'org-clock-out
     "c O" 'cadair/org-clock-out-at-time
     "c r" 'org-resolve-clocks
     "c R" 'org-clock-report
     "c t" 'org-evaluate-time-range
     "c =" 'org-clock-timestamps-up
     "c -" 'org-clock-timestamps-down
     "d" '(:ignore t :wk "date/deadline")
     "d d" 'org-deadline
     "d s" 'org-schedule
     "d t" 'org-time-stamp
     "d T" 'org-time-stamp-inactive
     "g" '(:ignore t :wk "goto")
     "g g" 'org-goto
     "g g" 'consult-org-heading
     "g G" 'consult-org-agenda
     "g c" 'org-clock-goto
     ;; "g C" (cmd! (org-clock-goto 'select))
     "g i" 'org-id-goto
     "g r" 'org-refile-goto-last-stored
     ;; "g v" #'+org/goto-visible
     "g x" 'org-capture-goto-last-stored
     "i" '(:ignore t :wk "Insert")
     "i b" 'org-insert-structure-template
     "l" '(:ignore t :wk "links")
     "l c" 'org-cliplink
     ;; "l d" #'+org/remove-link
     "l i" 'org-id-store-link
     "l l" 'org-insert-link
     "l L" 'org-insert-all-links
     "l r" 'cadair/org-insert-link-from-path
     "l s" 'org-store-link
     "l S" 'org-insert-last-stored-link
     "l t" 'org-toggle-link-display
     ;; "l y" #'+org/yank-link
     "P" '(:ignore t :wk "Publish")
     "P a" 'org-publish-all
     "P f" 'org-publish-current-file
     "P p" 'org-publish
     "P P" 'org-publish-current-project
     "P s" 'org-publish-sitemap
     "r" '(:ignore t :wk "refile")
     ;; "r ." #'+org/refile-to-current-file
     ;; "r c" #'+org/refile-to-running-clock
     ;; "r l" #'+org/refile-to-last-location
     ;; "r f" #'+org/refile-to-file
     ;; "r o" #'+org/refile-to-other-window
     ;; "r O" #'+org/refile-to-other-buffer
     ;; "r v" #'+org/refile-to-visible
     "r r" 'org-refile
     "r R" 'org-refile-reverse ; to all `org-refile-targets'
     "s" '(:ignore t :wk "tree/subtree")
     "s a" 'org-toggle-archive-tag
     "s b" 'org-tree-to-indirect-buffer
     "s c" 'org-clone-subtree-with-time-shift
     "s d" 'org-cut-subtree
     "s h" 'org-promote-subtree
     "s j" 'org-move-subtree-down
     "s k" 'org-move-subtree-up
     "s l" 'org-demote-subtree
     "s n" 'org-narrow-to-subtree
     "s r" 'org-refile
     "s s" 'org-sparse-tree
     "s A" 'org-archive-subtree-default
     "s N" 'widen
     "s S" 'org-sort
     "p" '(:ignore t :wk "priority & plan")
     "p d" 'org-priority-down
     "p p" 'org-priority
     "p u" 'org-priority-up
     "p n" 'stefanv/org-plan-next
     "p s
" 'stefanv/org-shift-timestamps-in-region
     )

(my-local-leader
  :states '(normal visual)
  :keymaps 'org-agenda-mode-map

  "d" '(:ignore t :wk "date/deadline")
  "d d" 'org-agenda-deadline
  "d s" 'org-agenda-schedule
  "c" '(:ignore t :wk "clock")
  "c c" 'org-agenda-clock-cancel
  "c g" 'org-agenda-clock-goto
  "c i" 'org-agenda-clock-in
  "c o" 'org-agenda-clock-out
  "c r" 'org-agenda-clockreport-mode
  "c s" 'org-agenda-show-clocking-issues
  "p" '(:ignore t :wk "priority")
  "p d" 'org-agenda-priority-down
  "p p" 'org-agenda-priority
  "p u" 'org-agenda-priority-up
  "q" 'org-agenda-set-tags
  "r" 'org-agenda-refile
  "t" 'org-agenda-todo
  )

;; Just regular evil key extras
(evil-define-key 'normal org-agenda-mode-map
  "r" 'org-agenda-redo
  "b" 'org-agenda-earlier
  "f" 'org-agenda-later
  "s" 'org-save-all-org-buffers
  "w" 'org-agenda-week-view
  "d" 'org-agenda-day-view
  "." 'org-agenda-goto-today
  )

;; All my org files live in one directory
(setq org-directory "~/Notebooks/")
(setq cadair-default-org-files (file-expand-wildcards "~/Notebooks/*.org"))
(setq cadair-extra-org-files '())

;; Some general config
(setq org-duration-format 'h:mm)
(setq org-cycle-separator-lines -1)
(setq org-clock-out-remove-zero-time-clock t)

;; Always save buffers on clock changes
(add-hook 'org-clock-in-hook #'save-buffer)
(add-hook 'org-clock-out-hook #'save-buffer)
(add-hook 'org-clock-in-hook #'org-agenda-redo)
(add-hook 'org-clock-out-hook #'org-agenda-redo)

;; Task States
;;;;;;;;;;;;;;

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "WIP(i)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)"))
                      )
       )

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "yellow" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              )))

(setq org-use-fast-todo-selection t)

(setq calendar-latitude 53.57)
(setq calendar-longitude -1.78)
(setq calendar-location-name "Holmfirth")

(defun cadair/org-clock-out-at-time ()
  "Clock out at a specified time"
  (interactive)
  (let ((time (org-read-date)))
    (org-clock-out nil nil (org-time-string-to-time time))))

(use-package alert
  :custom
  ;; TODO: This could be nicer, but at least it saves all the override
  (alert-default-style 'notifications)
  )

(use-package secretaria
  :hook
  (after-init-hook . secretaria-unknown-time-always-remind-me)
  :custom
  (secretaria-clocked-task-save-file "~/Notebooks/secretaria-clocked-task")
  (secretaria-notification-to-html t)
  )

(setq cadair-default-gh-repo "DKISTDC/dkist")

(defun cadair-gh-open (link)
  """Complete a link to a github issue / PR"""
  (if (string-prefix-p "#" link)
      (setq link2 (concat cadair-default-gh-repo link))
    (setq link2 link)
    )
  (setq ghlink (concat "https://github.com/" (replace-regexp-in-string "#" "/issues/" link2)))
  (org-open-link-from-string ghlink)
  )


(defun cadair-jira-open (link)
  """Complete a link to a jira ticket"""
  (setq ghlink (concat "https://nso.atlassian.net/browse/DCS-" link))
  (org-open-link-from-string ghlink)
  )

(with-eval-after-load 'org
  (org-add-link-type "gh" 'cadair-gh-open)
  (org-add-link-type "DCS" 'cadair-jira-open)
  )

(defadvice org-capture
    (after make-full-window-frame activate)
  "Advise capture to be the only window when used as a popup"
  (if (equal "emacs-capture" (frame-parameter nil 'name))
      (delete-other-windows)))

(defadvice org-capture-finalize
    (after delete-capture-frame activate)
  "Advise capture-finalize to close the frame"
  (if (equal "emacs-capture" (frame-parameter nil 'name))
      (delete-frame)))

(defvar cadair-capture-file "~/Notebooks/refile.org")
(setq org-default-notes-file cadair-capture-file)

;; This seems to work for protocol setup: http://www.mediaonfire.com/blog/2017_07_21_org_protocol_firefox.html
;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(require 'org-protocol)
(defun transform-square-brackets-to-round-ones(string-to-transform)
  "Transforms [ into ( and ] into ), other chars left unchanged."
  (concat
   (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c))) string-to-transform))
  )
(setq org-capture-templates
      (quote (("t" "todo (clock)" entry (file cadair-capture-file)
               "* TODO %i%?\n" :clock-in t :clock-resume t)
              ("x" "note" entry (file cadair-capture-file)
               "* TODO %i%?\n" :clock-in nil)
              ("L" "Protocol Link" entry (file cadair-capture-file)
               "* TODO %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\nCaptured On: %U")
              ("p" "Protocol" entry (file cadair-capture-file)
               "* TODO %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
              ("n" "note" entry (file cadair-capture-file)
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("h" "Habit" entry (file cadair-capture-file)
               "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n")
              ("d" "Day Block Planning" plain (file cadair-year-plan) (file "~/Notebooks/capture_templates/day_block.org") :empty-lines 1)
              ("w" "Week Block Planning" plain (file cadair-year-plan) (file "~/Notebooks/capture_templates/week_block.org") :empty-lines 1))))

; Targets include this file and any file contributing to the agenda 
(setq org-refile-targets (quote ((nil :maxlevel . 7)
                                 (org-agenda-files :maxlevel . 7))))

;; Use outline path file and complete in steps
;; this helps vertico work properly
;; (setq org-refile-use-outline-path 'file)

;; (setq org-outline-path-complete-in-steps nil)

; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

(setq org-highest-priority ?A)
(setq org-default-priority ?C)
(setq org-lowest-priority ?D)

;;set colours for priorities
(setq org-priority-faces '((?A . (:foreground "#F0DFAF" :weight bold))
                           (?B . (:foreground "LightSteelBlue"))
                           (?C . (:foreground "OliveDrab"))))

(setq org-agenda-files (append cadair-default-org-files cadair-extra-org-files))
;; Hide some tags from the agenda to reduce noise
(setq org-agenda-hide-tags-regexp "dkist\\|sunpy\\|reoccurring\\|aperiocontracts")

;; Agenda clock report parameters
(setq org-agenda-clockreport-parameter-plist
      (quote (:link t :maxlevel 10 :fileskip0 t :compact t :narrow 80)))

;;open agenda in current window
(setq org-agenda-window-setup (quote current-window))

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; Compact the block agenda view
(setq org-agenda-compact-blocks nil)

;; Always show the log at the top
(setq org-agenda-start-with-log-mode t)

;; Always show the clock table
(setq org-agenda-start-with-clockreport-mode t)

;;open agenda in current window
(setq org-agenda-window-setup (quote current-window))

;;warn me of any deadlines in next 7 days
(setq org-deadline-warning-days 7)

;; Weeks start on Monday you nutters
(setq org-agenda-start-on-weekday 1)
(setq org-agenda-start-day (format-time-string "%Y-%m-%d"))

;; Don't show tasks as scheduled if they are already shown as a deadline
(setq org-agenda-skip-scheduled-if-deadline-is-shown t)

;; Disable line numbers in agenda
(defun no-display-numbers-hook ()
  (display-line-numbers-mode 0)
  )
(add-hook 'org-agenda-mode-hook 'no-display-numbers-hook)

(setq org-agenda-custom-commands
      (quote
       (
        ("N" "Notes" tags "NOTE"
         ((org-agenda-overriding-header "Notes")
          (org-tags-match-list-sublevels t)))
        ("B" "Billable Agenda"
         ((agenda "" (
                      (org-agenda-span (quote month))
                      (org-agenda-skip-scheduled-if-deadline-is-shown nil)
                      (org-agenda-filter-by-tag 'billable)
                      ))
          ))
        ("n" "Noodling Agenda"
         ((agenda "" (
                      (org-agenda-span (quote day))
                      (org-agenda-skip-scheduled-if-deadline-is-shown nil)
                      (org-agenda-filter-by-tag 'noodling)
                      ))
          ))
        ("p" "Primary Agenda"
         ((agenda "" (
                      (org-agenda-span (quote day))
                      (org-agenda-skip-scheduled-if-deadline-is-shown nil)
                      ))
          (tags "REFILE"
                ((org-agenda-overriding-header "Tasks to Refile")
                 (org-tags-match-list-sublevels nil)))
          ;; Reoccurring Tasks
          (tags-todo "+reoccurring-HOLD-CANCELLED"
                     ((org-agenda-overriding-header "Reoccurring Tasks")
                      (org-tags-match-list-sublevels nil)
                      (org-agenda-sorting-strategy
                       '(category-keep))))
          ;; Priority Tasks
          (tags-todo "+PRIORITY=\"A\"|+PRIORITY=\"B\""
                     (
                      (org-agenda-overriding-header (concat "Priority Tasks"))
                      ;; (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                      ;; (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                      ;; (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                      (org-tags-match-list-sublevels 'indented)
                      (org-agenda-sorting-strategy
                       '(priority-down))
                      ))
          ;; DKIST Sprint
          (tags-todo "dkist&activesprint&-HOLD-CANCELLED"
                     ((org-agenda-overriding-header "This Sprint Tasks")
                      (org-tags-match-list-sublevels 'indented)
                      (org-agenda-sorting-strategy
                       '(category-keep))))
          ;; NASA Grant
          (tags-todo "sunpy&billable&-HOLD-CANCELLED"
                     ((org-agenda-overriding-header "SunPy NASA Tasks")
                      (org-tags-match-list-sublevels 'indented)
                      (org-agenda-sorting-strategy
                       '(category-keep))))
          ;; Active Contracts
          (tags-todo "aperiocontracts&-HOLD-CANCELLED/!"
                     ((org-agenda-overriding-header "Active Contracts")
                      (org-tags-match-list-sublevels 'indented)
                      (org-agenda-sorting-strategy
                       '(category-keep))))
          ;; Waiting and Postponed
          (tags-todo "-CANCELLED+WAITING|HOLD/!"
                     ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                            ;; (if bh/hide-scheduled-and-waiting-next-tasks
                                                            ;;     ""
                                                            ;;   " (including WAITING and SCHEDULED tasks)")
                                                                                                                    ))
                      (org-agenda-skip-function 'bh/skip-non-tasks)
                      (org-tags-match-list-sublevels nil)
                      ;; (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                      ;; (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                                      ))
          (tags "-REFILE/"
                ((org-agenda-overriding-header "Tasks to Archive")
                 ;; (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                 (org-tags-match-list-sublevels nil))))
         nil))))

(defun cadair-waybar-tooltip ()
  "The default tooltip to send to waybar."
    (message "boo")
    (let ((clocked-time (org-clock-get-clocked-time)))
      (format "%s: %s [%s] %s"
              (org-clock-waybar--get-task-category)
              (org-clock-waybar--get-task-title)
              (org-duration-from-minutes clocked-time)
              (format "%s" (org-clock-waybar--get-tags)))))

(use-package org-clock-waybar
  :vc (:url "https://gitea.polonkai.eu/Cadair/org-clock-waybar.git" :rev "configurable-output")
  :config
  (org-clock-waybar-setup)
  :custom
  (#'org-clock-waybar-tooltip-function 'cadair-waybar-tooltip)
  )

(use-package request
  ;; Enable these to debug org-clock-float requests
  ;; :custom
  ;; (request-log-level 'debug)
  ;; (request-message-level 'debug)
  )

(use-package org-clock-float
  :requires (request)
  :vc (:url "https://github.com/Cadair/org-clock-float.git" :rev :latest)
  ;; For local development
  ;; :load-path "/home/stuart/Git/org-clock-float/"
  :config
  (org-clock-float-setup)
  :custom
  (org-clock-float-email (plist-get (nth 0 (auth-source-search :max 1 :host "api.float.com")) :user))
  (org-clock-float-api-token (auth-info-password (nth 0 (auth-source-search :max 1 :host "api.float.com"))))
  )

(defun cadair/org-open-year-and-jump-to-today-plan ()
  (interactive)

  (let ((file-path (expand-file-name cadair-year-plan)))
    (unless (file-exists-p file-path)
      (user-error "File does not exist: %s" file-path))
    (let ((buffer (find-file-noselect file-path)))
      (pop-to-buffer buffer)
      (with-current-buffer buffer (stefanv/org-jump-to-today-plan)))))

(defun stefanv/org-jump-to-today-plan ()
  "Jump to the end of the 'Plan' heading under today's date headline."
  (interactive)
  (let* ((today (regexp-quote (format-time-string (org-time-stamp-format nil t))))
         (today-re (concat "^\\*+ .*?" today)))
    (goto-char (point-min))
    (if (not (re-search-forward today-re nil t))
        (message "Heading matching %s not found." today)
      (org-reveal)
      (save-restriction
        (org-narrow-to-subtree)
        (goto-char (point-min))
        ;; Matches 'Plan' heading and optional trailing tags
        (if (re-search-forward "^\\*+ Plan\\(?:[ \t]*\\(:[[:alnum:]_@:]+:\\)\\)?[ \t]*$" nil t)
          (org-end-of-subtree)
          (widen)
          (message "No exact 'Plan' heading found under today's date."))))))

(defun stefanv/org-plan-next ()
  "Create a new day plan entry following on the current or previous lines's active timestamp."
  (interactive)
  (let* ((ts-found (save-excursion
                     (end-of-line)
                     (when (re-search-backward org-ts-regexp0 nil t)
                       (let ((ctx (org-element-context)))
                         (when (eq (org-element-type ctx) 'timestamp) ctx)))))
         (is-blank (string-blank-p (buffer-substring (line-beginning-position) (line-end-position))))
         (is-header (org-at-heading-p))
         ;; Check if the found timestamp is actually on the current line
         (on-current-line (and ts-found
                               (>= (org-element-property :begin ts-found)
                                   (line-beginning-position)))))
    (if (not ts-found)
        (user-error "No timestamp found above point")
      (cond
       ;; Already has TS OR is plain text -> new heading below
       ((or on-current-line (and (not is-blank) (not is-header)))
        (end-of-line)
        (org-insert-heading)
        (save-excursion (stefanv/insert-formatted-org-ts ts-found)))

       ;; Current line is blank -> turn into heading here
       (is-blank
        (org-insert-heading)
        (save-excursion (stefanv/insert-formatted-org-ts ts-found)))

       ;; Current line is a header (no TS) -> append TS and return cursor
       (t
        (save-excursion
          (end-of-line)
          (stefanv/insert-formatted-org-ts ts-found)))))))

(defun stefanv/insert-formatted-org-ts (ts)
  "Helper to insert formatted timestamp with exactly one preceding space."
  (just-one-space)
  (insert (format "<%s %02d:%02d>"
                  (org-format-timestamp ts "%Y-%m-%d %a")
                  (or (org-element-property :hour-end ts)
                      (org-element-property :hour-start ts) 0)
                  (or (org-element-property :minute-end ts)
                      (org-element-property :minute-start ts) 0))))

(defun stefanv/org-shift-timestamps-in-region (minutes)
  "Shift all active timestamps in the region (or current line) forward by MINUTES minutes."
  (interactive "nMinutes to shift: ")
  (let* ((region-active (use-region-p))
         (beg (if region-active (region-beginning) (line-beginning-position)))
         (end (copy-marker (if region-active (region-end) (line-end-position))))
         ;; Regex for active timestamps: matches < followed by anything until >
         (active-ts-re "<\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}.*?\\)>"))
    ;; Allow undoing everything in one step
    (atomic-change-group
      (save-excursion
        (goto-char beg)
        ;; Shift active timestamps
        (while (re-search-forward active-ts-re end t)
          (save-excursion
            (goto-char (match-beginning 0))
            (org-timestamp-change minutes 'minute)
            (when (fboundp 'org-element-cache-refresh)
              (org-element-cache-refresh (point)))))

        ;; Re-align tags for any headlines in the range
        (goto-char beg)
        (while (re-search-forward org-outline-regexp-bol end t)
          (org-align-tags))))

    ;; Refresh
    (font-lock-flush beg end)
    (set-marker end nil)
    (message "Shifted active timestamps by %s minutes." minutes)))

(defun cadair/org-insert-link-from-path (path)
  "Insert an Org mode link to the heading selected by PATH."
  (interactive
   (list
    (let ((org-refile-use-outline-path t))
      (org-refile-get-location "Insert link to: "))))

  (let* ((file (nth 1 path))
         (full-path (nth 0 path))
         (path-components (split-string full-path "/")) ; Split the path into components
         (heading (nth (- (length path-components) 2) path-components)) ; Extract the second-to-last component
         (buffer (find-file-noselect file)))
    (unless buffer
      (user-error "Buffer for file %s not found" file))

    ;; Create the link string directly
    (let ((link (concat "file:" file "::*" heading)))
      (insert (concat "[[" link "][" heading "]]")))))

(use-package ement)

(defun cadair/ement-connect ()
  (interactive)
  (ement-connect :user-id "@cadair:cadair.com" :uri-prefix "http://localhost:8009")
  )

(defun thanos/wtype-text (text)
  "Process TEXT for wtype, handling newlines properly."
  (let* ((has-final-newline (string-match-p "\n$" text))
         (lines (split-string text "\n"))
         (last-idx (1- (length lines))))
    (string-join
     (cl-loop for line in lines
              for i from 0
              collect (cond
                       ;; Last line without final newline
                       ((and (= i last-idx) (not has-final-newline))
                        (format "wtype -s 350 \"%s\""
                                (replace-regexp-in-string "\"" "\\\\\"" line)))
                       ;; Any other line
                       (t
                        (format "wtype -s 350 \"%s\" && wtype -k Return"
                                (replace-regexp-in-string "\"" "\\\\\"" line)))))
     " && ")))

(define-minor-mode thanos/type-mode
  "Minor mode for inserting text via wtype."
  :keymap `((,(kbd "C-c C-c") . ,(lambda () (interactive)
                                   (call-process-shell-command
                                    (thanos/wtype-text (buffer-string))
                                    nil 0)
                                   (delete-frame)))
            (,(kbd "C-c C-k") . ,(lambda () (interactive)
                                   (kill-buffer (current-buffer))))))

(defun thanos/type ()
  "Launch a temporary frame with a clean buffer for typing."
  (interactive)
  (let ((frame (make-frame '((name . "emacs-float")
                             (fullscreen . 0)
                             (undecorated . t)
                             (width . 140)
                             (height . 20))))
        (buf (get-buffer-create "emacs-float")))
    (select-frame frame)
    (switch-to-buffer buf)
    (with-current-buffer buf
      (erase-buffer)
      (markdown-mode)
      (flyspell-mode)
      (thanos/type-mode)
      (setq-local header-line-format
                  (format " %s to insert text or %s to cancel."
                          (propertize "C-c C-c" 'face 'help-key-binding)
                          (propertize "C-c C-k" 'face 'help-key-binding)))
      ;; Make the frame more temporary-like
      (set-frame-parameter frame 'delete-before-kill-buffer t)
      (set-window-dedicated-p (selected-window) t))))

(defun cadair/new-client-frame ()
  "Launch a new frame on the dashboard."
  (interactive)
  (let ((frame (make-frame '((fullscreen . 0)
                             (undecorated . f)))))
  (select-frame frame)
    (dashboard-open)))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb
