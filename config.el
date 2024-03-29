(use-package xah-fly-keys
      :straight (xah-fly-keys
		 :type git
		 :host github
		 :repo "xahlee/xah-fly-keys")
      :config
      (require 'xah-fly-keys)
      (xah-fly-keys-set-layout "optimot")
      (xah-fly-keys 1)
  )

(global-set-key (kbd "<home>") 'xah-fly-mode-toggle)

(use-package keyfreq
  :config
  ;;   Pour exclure des commandes
  (setq keyfreq-excluded-commands
        '(
          mouse-drag-region
          lsp-ui-doc--handle-mouse-movement
          mouse-set-point
          mwheel-scroll
          ))
  (setq keyfreq-buffer "*keyfreq-buffer*")
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1))

(use-package xah-fly-keys-layer
    :after xah-fly-keys
    :straight (xah-fly-keys-layer
               :type git
               :host github
               :repo "Cletip/xah-fly-keys-layer")

    :config

    ;; change variable before require the extension
    (setq xah-fly-keys-layer-auto-command-mode
          '(recentf-cancel-dialog
            dashboard-jump-to-bookmarks
            org-agenda-show-dashboard
            dired-jump
            vertico-exit
            ace-link-eww
            debugger-quit
            ))
    (setq xah-fly-keys-layer-auto-insert-mode
          '(
            execute-extended-command-for-buffer
            org-meta-return
            org-insert-heading-respect-content
            org-insert-link
            recentf-open-files
            ;; org-capture ;; désactivé car fait bugguer !
            ))
    (require 'xah-fly-keys-layer-auto-mode))

;;for all other extensions, you can change variable after require the extension

      (require 'xah-fly-keys-layer-better-remap)

(use-package expand-region)

      (setq xah-fly-keys-layer-isearch-forward-variable 'consult-line
	    ;; xah-fly-keys-layer-ispell-word-variable 'flyspell-correct-wrapper
	    xah-fly-keys-layer-xah-extend-selection-variable 'er/expand-region
	    ;; xah-fly-keys-layer-xah-open-file-at-cursor-variable 'cp/open-link
	    xah-fly-keys-layer-recentf-open-files-variable 'consult-recent-file
	    ;; since I don't use save-buffer, I prefer this
	    ;; xah-fly-keys-layer-save-buffer-variable 'avy-goto-char-2
	    ;; xah-fly-keys-layer-describe-function-variable 'helpful-symbol
  ;; 	  xah-fly-keys-layer-describe-variable-variable 'helpful-at-point)
	    )
					  ; 
  (xah-fly-keys-layer-add-keys-to-keymap 'xah-fly-command-map "0"
					     'avy-goto-char-2)

(defvar goto-last-change-undo nil
  "The `buffer-undo-list' entry of the previous \\[goto-last-change] command.")
(make-variable-buffer-local 'goto-last-change-undo)

(defun goto-last-change (&optional mark-point minimal-line-distance)
    "Set point to the position of the last change.
  Consecutive calls set point to the position of the previous change.
  With a prefix arg (optional arg MARK-POINT non-nil), set mark so \
  \\[exchange-point-and-mark]
  will return point to the current position."
    (interactive "P")
    ;; (unless (buffer-modified-p)
    ;;   (error "Buffer not modified"))
    (when (eq buffer-undo-list t)
      (error "No undo information in this buffer"))
    (when mark-point
      (push-mark))
    (unless minimal-line-distance
      (setq minimal-line-distance 10))
    (let ((position nil)
          (undo-list (if (and (eq this-command last-command)
                              goto-last-change-undo)
                         (cdr (memq goto-last-change-undo buffer-undo-list))
                       buffer-undo-list))
          undo)
      (while (and undo-list
                  (or (not position)
                      (eql position (point))
                      (and minimal-line-distance
                           ;; The first invocation always goes to the last change, subsequent ones skip
                           ;; changes closer to (point) then minimal-line-distance.
                           (memq last-command '(goto-last-change
                                                goto-last-change-with-auto-marks))
                           (< (count-lines (min position (point-max)) (point))
                              minimal-line-distance))))
        (setq undo (car undo-list))
        (cond ((and (consp undo) (integerp (car undo)) (integerp (cdr undo)))
               ;; (BEG . END)
               (setq position (cdr undo)))
              ((and (consp undo) (stringp (car undo))) ; (TEXT . POSITION)
               (setq position (abs (cdr undo))))
              ((and (consp undo) (eq (car undo) t))) ; (t HIGH . LOW)
              ((and (consp undo) (null (car undo)))
               ;; (nil PROPERTY VALUE BEG . END)
               (setq position (cdr (last undo))))
              ((and (consp undo) (markerp (car undo)))) ; (MARKER . DISTANCE)
              ((integerp undo))		; POSITION
              ((null undo))		; nil
              (t (error "Invalid undo entry: %s" undo)))
        (setq undo-list (cdr undo-list)))
      (cond (position
             (setq goto-last-change-undo undo)
             (goto-char (min position (point-max))))
            ((and (eq this-command last-command)
                  goto-last-change-undo)
             (setq goto-last-change-undo nil)
             (error "No further undo information"))
            (t
             te	   (setq goto-last-change-undo nil)
             (error "Buffer not modified")))))

(defun cp/xah-pop-local-mark-ring ()
    "Move cursor to last mark position of current buffer.
      Call this repeatedly will cycle all positions in `mark-ring'.

      URL `http://xahlee.info/emacs/emacs/emacs_jump_to_previous_position.html'
      Version: 2016-04-04"
    (interactive)
  
    (if current-prefix-arg
    (goto-last-change)
      (xah-pop-local-mark-ring)))

(define-key xah-fly-command-map [remap xah-pop-local-mark-ring] #'cp/xah-pop-local-mark-ring)

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "2")) 'universal-argument)

(define-key key-translation-map (kbd "<escape>") (kbd "C-g"))

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "'")) 'kill-word)

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "p")) 'set-mark-command)

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "y")) 'undo)

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "f")) 'xah-pop-local-mark-ring)

(defun cp/xah-pop-global-mark-ring ()
  "Move cursor to last mark position in another buffer."
  (interactive)
  (let ((current-buffer (current-buffer)))

    ;; on va Ã  un autre buffer
    (while (equal current-buffer (current-buffer))
      (pop-global-mark))

    ;; si il y a un prefix-argument, on ferme l'ancien buffer
    (when current-prefix-arg
      (save-window-excursion

	(switch-to-buffer current-buffer)
	(xah-close-current-buffer)

	)
      )

    ;;si on n'est pas dans un buffer utile, on passe au suivant
    (when (not (xah-user-buffer-p))
      (xah-next-user-buffer))))

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "SPC f")) 'cp/xah-pop-global-mark-ring)

(define-key xah-fly-command-map (kbd (xah-fly--convert-kbd-str "o")) 'ma-fonction)


(defun ma-fonction ()
  (interactive)
  (if (or buffer-read-only
      (equal major-mode 'minibuffer-mode)
      ;; (string-equal major-mode "org-agenda-mode")
      ;; (string-equal major-mode "fundamental-mode")
      )
      (execute-kbd-macro (kbd "RET"))
    (open-line 1)))

(define-key xah-fly-command-map [remap hippie-expand] #'dabbrev-expand)

(defun xah-save-all-unsaved ()
  "Save all unsaved files. no ask.
Version 2019-11-05"
  (interactive)
  (save-some-buffers t ))

(add-hook 'focus-out-hook 'xah-save-all-unsaved)

(add-hook 'xah-fly-command-mode-activate-hook 'xah-save-all-unsaved)

(use-package which-key
    ;; :diminish which-key-mode
    :config
    ;;activer which-key
    (which-key-mode)
    ;;temps avant déclenchement de wich-key minimum
    (setq which-key-idle-delay 0.01)
    ;; affichage sur le côté, mais si marche pas en bas
    (which-key-setup-side-window-right-bottom)
    (setq which-key-frame-max-height 100)
    (setq which-key-min-display-lines 1000))

(use-package avy
    ;;\ pour l'espace
    :custom
    ;;personnalition des touches, important
    ;; (avy-keys '(?a ?u ?e ?i ?t ?s ?r ?n ?\ ?\^M)) ;;^M=enter
    ;; todo adapter à xah-fly-key !
    (avy-keys '(?\ ?e ?u ?i ?a ?s ?t ?r ?. ?c))
    (avy-background t)
    ;;nouvelle touches pour escape avy go timer
    (avy-escape-chars '(?\e ?\M-g))
    :config
    (setq avy-timeout-seconds 0.25)

    ;; pour que ça marche sur toutse les fenêtres
    (setq avy-all-windows 'all-frames)

    ;;personnaliser chaque commande :
    ;; (setq avy-keys-alist
    ;; `((avy-goto-char . ,(number-sequence ?a ?f))
    ;; (avy-goto-word-1 . (?f ?g ?h ?j))))

    (defun avy-goto-char-timer-end (&optional arg)
      "Read one or many consecutive chars and jump to the last one.
  The window scope is determined by `avy-all-windows' (ARG negates it)."
      (interactive "P")
      (avy-goto-char-timer arg)
      (forward-char (length avy-text))))

(electric-pair-mode 1)

(use-package consult)

(setq initial-scratch-message "Buffer scratch en org-mode !")

(defvaralias 'major-mode-for-buffer-scratch 'initial-major-mode)
(setq major-mode-for-buffer-scratch 'org-mode)

(use-package recentf
  :config

  (recentf-mode 1)
  (setq recentf-max-menu-items 100)
  (setq recentf-max-saved-items 100)

  ;; fichier à exclure de recentf
  ;; If you use recentf then you might find it convenient to exclude all of the files in the no-littering directories using something like the following.
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory)
  (add-to-list 'recentf-exclude "/tmp/") ;;pour emacs-everywhere notamment
  ;; Exlcude the org-agenda files
  ;; (they flood the recentf because dashboard always checks their content)
  ;; (with-eval-after-load 'org ;;important
  ;; (add-to-list 'recentf-exclude (org-agenda-files))
  ;; )
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (setq savehist-file (concat user-emacs-directory "var/savehist.el"))
  :config
  (setq history-length 200)
  ;;List of additional variables to save.
  (setq savehist-additional-variables '(kill-ring search-ring recentf-list))
  (savehist-mode t)

  ;; pour améliorer les perf ? voir avec Mathieu
  (put 'minibuffer-history 'history-length 50)
  (put 'evil-ex-history 'history-length 50)
  (put 'kill-ring 'history-length 25)
  )

;;sauvegarde à tout les changement de fenêtre
;; (defun xah-save-all-unsaved (&rest args)
  ;; "Save all unsaved files. no ask.
	;; Version 2019-11-05"
  ;; (interactive)
  ;; (unless (string-equal (file-name-extension buffer-file-name) "gpg")
    ;; (save-some-buffers t))
  ;; )

;; mis dans xfk-layer
;; (defun cp/xah-fly-save-buffer-if-file-not-gpg ()
;; "Save current buffer if it is a file."
;; (interactive)
;; (when (and (buffer-file-name) (not (string-equal (file-name-extension buffer-file-name) "gpg")))
;; (save-buffer)))

;; (add-to-list 'window-state-change-functions 'xah-save-all-unsaved)
;; sauvegarde automatique avec command mode
;; (add-hook 'xah-fly-command-mode-activate-hook 'cp/xah-fly-save-buffer-if-file-not-gpg)

(setq make-backup-files t	  ; backup of a file the first time it is saved.
      backup-by-copying t	  ; don't clobber symlinks
      version-control t		  ; version numbers for backup files
      delete-old-versions t	  ; delete excess backup files silently
      delete-by-moving-to-trash t ; Put the deleted files in the trash
      kept-old-versions 6 ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9 ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t ; auto-save every buffer that visits a file into another file, not the original
      auto-save-timeout 20 ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200 ; number of keystrokes between auto-saves (default: 300)
      ;; auto-save-visited-file-name t ;; sauvegarde directement sur le fichier original
      )

;;fichier à ne pas copier dans les backups
(setq auto-mode-alist
      (append
       (list
	'("\\.\\(vcf\\|gpg\\)$" . sensitive-minor-mode))
       auto-mode-alist))

(fset 'yes-or-no-p 'y-or-n-p)

(global-auto-revert-mode t)

(setq revert-without-query '(".pdf"))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(delete-selection-mode t)

(save-place-mode 1)

(cd user-emacs-directory)

(setq enable-recursive-minibuffers t)

(use-package vertico

  ;;charger les extensions de vertico
  :load-path "straight/build/vertico/extensions"
  :custom
  (vertico-cycle t)
  :custom-face
  (vertico-current ((t (:background "#3a3f5a"))))
  :config

  ;; Prefix the current candidate with “» ”. From
  ;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
  (advice-add #'vertico--format-candidate :around
	      (lambda (orig cand prefix suffix index _start)
		(setq cand (funcall orig cand prefix suffix index _start))
		(concat
		 (if (= vertico--index index)
		     (propertize "» " 'face 'vertico-current)
		   "  ")
		 cand)))

  ;;pour activer vertico directory (remonte d'un dossier à chaque fois, pratique ! )
  (require 'vertico-directory)
  ;; (define-key vertico-map [remap backward-kill-word] #'vertico-directory-up)
  ;; (define-key vertico-map [remap xah-delete-backward-char-or-bracket-text] #'vertico-directory-up)
  (define-key vertico-map [remap open-line] #'vertico-directory-up)
  ;; (define-key vertico-map [remap delete-backward-char] #'vertico-directory-up)

  ;; pour pouvoir jump à une entrée
  ;; (define-key vertico-map [remap avy-goto-char] #'vertico-quick-jump)

  (with-eval-after-load 'avy

    (defun divide-list-in-two-equal-part (lst)
      (let ((len (length lst)))
	(list (seq-subseq lst 0 (/ len 2))
	      (seq-subseq lst (/ len 2)))))

    (setq avy-keys-alist-two-part (divide-list-in-two-equal-part (mapconcat 'char-to-string '(?\ ?e ?u ?i ?a ?s ?t ?r ?n) "")))

    ;; lorsqu'il y a une touche
    (setq vertico-quick1 (car avy-keys-alist-two-part))
    ;; deux touches
    (setq vertico-quick2 (cadr avy-keys-alist-two-part))

    (require 'vertico-quick)
    (use-package vertico-quick
      :straight nil
      :after vertico
      :custom (test 2)
      :bind (:map vertico-map
		  ("C-<return>" . vertico-quick-exit))))

  (vertico-mode))

(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode)
  )

;; Complétation par candidats      
;; Use the `orderless' completion style.
;; Enable `partial-completion' for files to allow path expansion.
;; You may prefer to use `initials' instead of `partial-completion'.
(use-package orderless
  :init

  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))
  :config

  (setq orderless-matching-styles
        '(
          orderless-regexp
          ;; orderless-literal
          orderless-initialism ;;très puissant
          ;; orderless-prefixes ;; utile pour les commandes de temps en temps
          ;; orderless-flex ;; sert à rien pour moi, donne même des candidats inutiles
          ;; orderless-without-literal ;; à ne pas utiliser directement
          ))

(setq orderless-component-separator 'orderless-escapable-split-on-space)

  ;;couleur avec company
  (defun just-one-face (fn &rest args)
    (let ((orderless-match-faces [completions-common-part]))
      (apply fn args)))
  (advice-add 'company-capf--candidates :around #'just-one-face))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src sh"))
(add-to-list 'org-structure-template-alist '("cd" . "src C"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp\n\n"))
(add-to-list 'org-structure-template-alist '("sc" . "src scheme"))
(add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
(add-to-list 'org-structure-template-alist '("json" . "src json"))

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   ;; (ditaa      . t)
   (C          . t)
   (dot        . t)
   (emacs-lisp . t)
   ;; (scheme     . t)
   ;; (gnuplot    . t)
   ;; (haskell    . t)
   (latex      . t)
   ;; (js         . t)
   ;; (ledger     . t)
   ;; (matlab     . t)
   ;; (ocaml      . t)
   ;; (octave     . t)
   ;; (plantuml   . t)
   (python     . t)
   ;; (R          . t)
   ;; (ruby       . t)
   ;; (screen     . nil)
   ;; (scheme     . t)
   (shell      . t)
   (sql        . t)
   (sqlite     . t)
   (java     . t)
   (js . t) ;;javascripts
   ))

(setq org-babel-python-command "python")

(setq org-confirm-babel-evaluate nil	  ;; for running code blocks
      org-confirm-elisp-link-function nil ;; for elisp links
      org-confirm-shell-link-function nil)  ;; for shell links

(setq org-src-tab-acts-natively t)

(setq org-src-fontify-natively t)

(setq org-blank-before-new-entry
      '((heading . t)
        (plain-list-item . auto)))



(defun reload-configuration-of-emacs()
  (interactive)
  (org-babel-load-file (if (eq system-type 'gnu/linux)
			   "~/.emacs.d/config.org"
			 "c:/Users/mateo/AppData/Roaming/.emacs.d/config.org"
			 )))

(defvar 
  xah-fly-major-mode-key "i"
  "Touche pour avoir les touches xah-fly-major-mode-map"
  )

(defun xah-fly-keys-major-mode-change (&rest args)
  (let ((xah-fly-major-mode-map (intern (concat "xah-fly-" (symbol-name major-mode) "-map"))))
    (define-key xah-fly-command-map 

      ;; todo mettre (kbd (xah-fly--convert-kbd-str xah-fly-major-mode-key)) pour pas Ã  avoir Ã  la calculer Ã  chaque fois ?
      (kbd (xah-fly--convert-kbd-str xah-fly-major-mode-key))

      (if (fboundp xah-fly-major-mode-map)
          xah-fly-major-mode-map
        'xah-fly-keys-no-major-mode
        ))))

(defun xah-fly-keys-no-major-mode ()
  "Function to call when there is no keymap mode to this major"
  (interactive)
  (message "There is no custom keymap for the major mode  %s. You can do a pull
          request" major-mode))

(if (>= emacs-major-version 28)
    (add-to-list 'window-state-change-functions 'xah-fly-keys-major-mode-change)
  (progn
    (add-to-list 'window-buffer-change-functions #'xah-fly-keys-major-mode-change)
    (add-to-list 'window-selection-change-functions #'xah-fly-keys-major-mode-change)
    (add-hook 'window-selection-change-functions #'xah-fly-keys-major-mode-change)))

(xah-fly--define-keys
 (define-prefix-command 'xah-fly-org-mode-map)
 '(

   ;; ("SPC" . org-mode-babel-keymap)

   ;; ("-" . "^") NOTE: this is a dead key
   ("'" . org-table-create-or-convert-from-region)
   ("," . org-mark-element)
   ("." . org-todo)
   (";" . org-toggle-narrow-to-subtree)
   ;; ("/" . "x")

   ;; ("[" . "=")
   ;; ("]" . "%")

   ;; ("=" . "Ã§")

   ("a" . org-export-dispatch)
   ;; ("b" . org-goto)
   ("b" . consult-org-heading) ;; mieux
   ("c" . org-insert-link)
   ("L" . org-store-link)
   ;; ("d" . org-mode-keymap-movement)
   ("e" . org-meta-return)
   ;; ("E" . org-insert-todo-heading)
   ;; ("f" . org-roam-ref-add)
   ;; ("g" . org-roam-buffer-toggle)
   ;; ("h" . vulpea-insert)
   ;; ("i" . ",")
   ;; ("j" . org-deadline)
   ;; ("k" . org-schedule)
   ("l" . "cp-vulpea-buffer-tags-remove-BROUILLON")
   ;; ("m" . org-insert-todo-heading)
   ;; ("n" . vulpea-tags-add)
   ("o" . org-insert-structure-template)

   ;; ("p" . org-set-tags-command)
   ("q" . org-sort)
   ;; ("r" . vulpea-meta-add)
   ;; ("s" . citar-insert-citation)
   ;; ("t" . vulpea-find-backlink)
   ;; ("u" . org-capture-keymap) ;; TODO, mis dans SPC SPC
   ;; ("u" . org-capture)  ;; TODO changer

   ("v" . org-insert-todo-heading)
   ;; ("v" . cp-vulpea-meta-fait-add)
   ;; ("w" . consult-org-roam-forward-links)
   ;; ("x" . org-time-stamp)
   ;; ("y" . "b")
   ;; ("z" . "v")
   ))

(xah-fly--define-keys
 (define-prefix-command 'xah-fly-emacs-lisp-mode-map)
 '(

   ("SPC" . org-mode-babel-keymap)

   ;; ("-" . "^") NOTE: this is a dead key
   ("'" . org-table-create-or-convert-from-region)
   ("," . org-mark-element)
   ("." . org-todo)
   (";" . org-toggle-narrow-to-subtree)
   ;; ("/" . "x")

   ;; ("[" . "=")
   ;; ("]" . "%")

   ;; ("=" . "Ã§")

   ("a" . linum-modeh)
   ;; ("b" . org-goto)
   ("b" . consult-org-heading) ;; mieux
   ("c" . org-insert-link)
   ("L" . org-store-link)
   ("d" . org-mode-keymap-movement)
   ("e" . org-meta-return)
   ;; ("E" . org-insert-todo-heading)
   ("f" . org-roam-ref-add)
   ("g" . org-roam-buffer-toggle)
   ("h" . vulpea-insert)
   ;; ("i" . ",")
   ("j" . org-deadline)
   ("k" . org-schedule)
   ("l" . "cp-vulpea-buffer-tags-remove-BROUILLON")
   ;; ("m" . org-insert-todo-heading)
   ("n" . vulpea-tags-add)
   ("o" . org-refile)
   ("p" . org-set-tags-command)
   ("q" . org-sort)
   ("r" . vulpea-meta-add)
   ("s" . citar-insert-citation)
   ;; ("t" . vulpea-find-backlink)
   ;; ("u" . org-capture-keymap) ;; TODO, mis dans SPC SPC
   ;; ("u" . org-capture)  ;; TODO changer

   ("v" . org-insert-todo-heading)
   ;; ("v" . cp-vulpea-meta-fait-add)
   ("w" . consult-org-roam-forward-links)
   ("x" . org-time-stamp)
   ;; ("y" . "b")
   ;; ("z" . "v")
   ))

;; (cd "c:/Users/mateo/Desktop/")

(customize-set-variable 'use-short-answers t)

(use-package embark)

(use-package embark-consult)

(setq python-shell-interpreter "python")

(setq-default c-basic-offset 4)

(use-package eglot
  ;; :hook ((c-mode . eglot-ensure)
	 ;; (c++-mode . eglot-ensure))
  :config
  (add-hook 'c-mode-hook 'eglot-ensure)
  (add-hook 'c++-mode-hook 'eglot-ensure)

    (add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd" "--header-insertion=never")))

(when (eq system-type 'gnu/linux)
  (shell-command "chmod +x ~/Xmodmap && xmodmap ~/Xmodmap")
  (shell-command "xkbcomp -w0 ~/Optimot_Linux_ISO/Optimot_Linux_ISO-ISO.xkb $DISPLAY")
  )
