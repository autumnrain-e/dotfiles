;;; init.el --- personal config -*- lexical-binding: t -*-

;; Keep Customize out of this file; custom.el stays untracked.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; MELPA, for packages not on GNU/NonGNU ELPA (e.g. gruvbox-theme).
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq use-package-always-ensure t)

(tool-bar-mode -1)
;; Drop the macOS titlebar, and with it the three window buttons. Corners go
;; square: rounded-and-undecorated needs `undecorated-round', an emacs-plus patch
;; this build (the emacs-app cask) does not carry.
(add-to-list 'default-frame-alist '(undecorated . t))
(set-face-attribute 'default nil :height 180 :family "PragmataPro Mono Liga")
(define-key global-map (kbd "<escape>") #'keyboard-quit)
