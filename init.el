;;; .emacs --- My emacs config -*- lexical-binding: t; -*-

;; configuration of straight, intallateur de package
;; Bootstrap `straight.el'
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; installation of use-package, configurateur de package
(straight-use-package 'use-package)
(require 'package)
;; always download package automatically (without :ensure t)
;;(setq use-package-always-ensure t)
;; Use straight.el for use-package expressions with the first line
(setq straight-use-package-by-default t)
;; Load the helper package for commands like `straight-x-clean-unused-repos'
(require 'straight-x)

;; (setq use-package-always-defer t)
(setq use-package-verbose t)
(setq use-package-minimum-reported-time 0.00001)

;; .emacs.d propre
(use-package no-littering
  :config
  ;; définition de l'emplacement de certains fichiers
  (setq custom-file (no-littering-expand-var-file-name "custom.el")
	grammalecte-settings-file (no-littering-expand-var-file-name
				   "grammalecte-cache.el") ;;pour grammalecte
	)
  )

;;installation d'org mode
;;ici, je prends juste celui par défault
(use-package org :straight (:type built-in))

;; load les variables customiser (chemin définit par no-littering)
;; (org-babel-load-file (expand-file-name "~/.emacs.d/var/custom.el"))
(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

;;on lance le reste
(org-babel-load-file (if (eq system-type 'gnu/linux)
			     "~/.emacs.d/config.org"
			   "c:/Users/mateo/AppData/Roaming/.emacs.d/config.org"
			   ))
