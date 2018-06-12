;;; -*- indent-tabs-mode: nil -*-
;;; declutter.el --- Read paywall sites without clutter

;; Copyright (c) 2018 Sanel Zukan
;;
;; Author: Sanel Zukan <sanelz@gmail.com>
;; URL: http://www.github.com/sanel/declutter
;; Version: 0.1.0
;; Keywords: html, web browser 

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Allows reading paywall sites without clutter. Uses outline.com service

;;; Installation:

;; Copy it to your load-path and run with:
;; M-: (require 'declutter)

;;; Usage:

;; M-x declutter

;;; Code:

(require 'json)
(require 'shr)

(defgroup declutter nil
  "Declutter web sites."
  :prefix "declutter-"
  :group 'applications)

(defcustom outline-api "https://outlineapi.com/parse_article?source_url="
  "Outline service, used to get cleaned content."
  :type 'string
  :group 'declutter)

(defun declutter-fetch-json (url)
  "Tries to get json from given url."
  (with-temp-buffer
    (url-insert-file-contents url)
    (let ((json-false :false))
      (json-read))))

(defun declutter-get-html (url)
  "Construct properl url and call outline.com service. Expects json response
and retrieve html part from it."
  (let* ((full-url (concat outline-api (url-hexify-string url)))
         (response (declutter-fetch-json full-url)))
    (cdr
     (assoc 'html (assoc 'data response)))))

(defun declutter-url (url)
  "Calls (declutter-get-html) inside new buffer and parses it as html.
Creates temporary buffer just to get html, as (shr-render-buffer) will create
own dedicated *html* buffer with parsed content."
  (with-temp-buffer
    (prog1
		(insert
		 (declutter-get-html url))
	  (shr-render-buffer (current-buffer)))))

(defun declutter-under-point ()
  "Tries to load url under point and runs (declutter-url) on it. First it
tries with (shr-url). If fails, it will try with (browse-url-url-at-point) and if
that fails, it will report error."
  (interactive)
  (let* ((url (get-text-property (point) 'shr-url))
         (url (if url url (browse-url-url-at-point))))
    (if url
        (declutter-url url)
        (message "No URL under point"))))

;;;###autoload
(defun declutter (url)
  "Reads url and declutter it, using outline.com service."
  (interactive
   (list
    (read-string (format "Enter URL: ") nil nil nil)))
  (declutter-url url))

(provide 'declutter)

;;; declutter.el ends here
