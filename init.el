;; -*- coding: utf-8 -*-
;(defvar best-gc-cons-threshold gc-cons-threshold "Best default gc threshold value. Should't be too big.")


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(let ((minver "24.4"))
  (when (version< emacs-version minver)
    (error "This config requires Emacs v%s or higher" minver)))

(defvar best-gc-cons-threshold 4000000 "Best default gc threshold value. Should't be too big.")
;; don't GC during startup to save time
(setq gc-cons-threshold most-positive-fixnum)

(setq emacs-load-start-time (current-time))

;; {{ emergency security fix
;; https://bugs.debian.org/766397
(eval-after-load "enriched"
  '(defun enriched-decode-display-prop (start end &optional param)
     (list start end)))
;; }}
;;----------------------------------------------------------------------------
;; Which functionality to enable (use t or nil for true and false)
;;----------------------------------------------------------------------------
(setq *is-a-mac* (eq system-type 'darwin))
(setq *win64* (eq system-type 'windows-nt) )
(setq *cygwin* (eq system-type 'cygwin) )
(setq *linux* (or (eq system-type 'gnu/linux) (eq system-type 'linux)) )
(setq *unix* (or *linux* (eq system-type 'usg-unix-v) (eq system-type 'berkeley-unix)) )
(setq *emacs24* (and (not (featurep 'xemacs)) (or (>= emacs-major-version 24))) )
(setq *emacs25* (and (not (featurep 'xemacs)) (or (>= emacs-major-version 25))) )
(setq *no-memory* (cond
                   (*is-a-mac*
                    (< (string-to-number (nth 1 (split-string (shell-command-to-string "sysctl hw.physmem")))) 4000000000))
                   (*linux* nil)
                   (t nil)))

;; emacs 24.3-
(setq *emacs24old*  (or (and (= emacs-major-version 24) (= emacs-minor-version 3))
                        (not *emacs24*)))

;; @see https://www.reddit.com/r/emacs/comments/55ork0/is_emacs_251_noticeably_slower_than_245_on_windows/
;; Emacs 25 does gc too frequently
(when *emacs25*
  ;; (setq garbage-collection-messages t) ; for debug
  (setq gc-cons-threshold (* 64 1024 1024) )
  (setq gc-cons-percentage 0.5)
  (run-with-idle-timer 5 t #'garbage-collect))

(defmacro local-require (pkg)
  `(load (file-truename (format "~/.emacs.d/site-lisp/%s/%s" ,pkg ,pkg))))

(defmacro require-init (pkg)
  `(load (file-truename (format "~/.emacs.d/lisp/%s" ,pkg))))

;; *Message* buffer should be writable in 24.4+
(defadvice switch-to-buffer (after switch-to-buffer-after-hack activate)
  (if (string= "*Messages*" (buffer-name))
      (read-only-mode -1)))

;; @see https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
;; Normally file-name-handler-alist is set to
;; (("\\`/[^/]*\\'" . tramp-completion-file-name-handler)
;; ("\\`/[^/|:][^/|]*:" . tramp-file-name-handler)
;; ("\\`/:" . file-name-non-special))
;; Which means on every .el and .elc file loaded during start up, it has to runs those regexps against the filename.
(let ((file-name-handler-alist nil))
  (require-init 'init-autoload)
  (require-init 'init-modeline)
  ;; (require 'cl-lib) ; it's built in since Emacs v24.3
  (require-init 'init-compat)
  (require-init 'init-utils)

  ;; Windows configuration, assuming that cygwin is installed at "c:/cygwin"
  ;; (condition-case nil
  ;;     (when *win64*
  ;;       ;; (setq cygwin-mount-cygwin-bin-directory "c:/cygwin/bin")
  ;;       (setq cygwin-mount-cygwin-bin-directory "c:/cygwin64/bin")
  ;;       (require 'setup-cygwin)
  ;;       ;; better to set HOME env in GUI
  ;;       ;; (setenv "HOME" "c:/cygwin/home/someuser")
  ;;       )
  ;;   (error
  ;;    (message "setup-cygwin failed, continue anyway")
  ;;    ))
  (require-init 'init-elpa)
  (require-init 'init-exec-path) ;; Set up $PATH
  ;; any file use flyspell should be initialized after init-spelling.el
  ;; actually, I don't know which major-mode use flyspell.
  (require-init 'init-spelling)
  (require-init 'init-gui-frames)
  (require-init 'init-uniquify)
  (require-init 'init-ibuffer)
  (require-init 'init-ivy)
  (require-init 'init-hippie-expand)
  (require-init 'init-windows)
  (require-init 'init-markdown)
  (require-init 'init-erlang)
  (require-init 'init-javascript)
  (require-init 'init-org)
  (require-init 'init-css)
  (require-init 'init-python-mode)
  (require-init 'init-haskell)
  (require-init 'init-ruby-mode)
  (require-init 'init-lisp)
  (require-init 'init-elisp)
  (require-init 'init-yasnippet)
  ;; Use bookmark instead
  (require-init 'init-cc-mode)
  (require-init 'init-gud)
  (require-init 'init-linum-mode)
  (require-init 'init-git) ;; git-gutter should be enabled after `display-line-numbers-mode' turned on
  ;; (require-init 'init-gist)
  (require-init 'init-gtags)
  ;; init-evil dependent on init-clipboard
  (require-init 'init-clipboard)
  ;; use evil mode (vi key binding)
  (require-init 'init-evil)
  (require-init 'init-multiple-cursors)
  (require-init 'init-sh)
  (require-init 'init-ctags)
  (require-init 'init-bbdb)
  (require-init 'init-gnus)
  (require-init 'init-lua-mode)
  (require-init 'init-workgroups2)
  (require-init 'init-term-mode)
  (require-init 'init-web-mode)
  (require-init 'init-company)
  (require-init 'init-chinese) ;; cannot be idle-required
  ;; need statistics of keyfreq asap
  (require-init 'init-keyfreq)
  (require-init 'init-httpd)

  ;; projectile costs 7% startup time

  ;; misc has some crucial tools I need immediately
  (require-init 'init-misc)

  (require-init 'init-emacs-w3m)
  (require-init 'init-hydra)

  (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
  ;; {{ idle require other stuff
  (local-require 'idle-require)
  (setq idle-require-idle-delay 2)
  (setq idle-require-symbols '(init-perforce
                               init-slime
                               init-misc-lazy
                               init-which-func
                               init-fonts
                               init-hs-minor-mode
                               init-writting
                               init-pomodoro
                               init-dired
                               init-artbollocks-mode
                               init-semantic))
  (idle-require-mode 1) ;; starts loading
  ;; }}

  (when (require 'time-date nil t)
    (message "Emacs startup time: %d seconds."
             (time-to-seconds (time-since emacs-load-start-time))))

  ;; @see https://github.com/hlissner/doom-emacs/wiki/FAQ
  ;; Adding directories under "~/.emacs.d/site-lisp/" to `load-path' slows
  ;; down all `require' statement. So we do this at the end of startup
  ;; Besides, no packages from ELPA is dependent "~/.emacs.d/site-lisp" now.
  (require-init 'init-site-lisp)

  ;; my personal setup, other major-mode specific setup need it.
  ;; It's dependent on init-site-lisp.el
  (if (file-exists-p "~/.custom.el") (load-file "~/.custom.el")))

;; @see https://www.reddit.com/r/emacs/comments/4q4ixw/how_to_forbid_emacs_to_touch_configuration_files/
(setq custom-file (concat user-emacs-directory "custom-set-variables.el"))
(load custom-file 'noerror)

(setq gc-cons-threshold best-gc-cons-threshold)
;;; Local Variables:
;;; no-byte-compile: t
;;; End:
(put 'erase-buffer 'disabled nil)
