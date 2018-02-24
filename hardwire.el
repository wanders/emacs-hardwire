;;; hardwire.el --- Replace linked html resources with their contents  -*- lexical-binding: t -*-

;; Copyright (C) 2018  Anders Waldenborg

;; Author: Anders Waldenborg <anders@0x63.nu>

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package allows reworking html documents replacing links to
;; external css and js file with the actual contents.  With some luck
;; this will make the html file self contained.  The primary use
;; originally intended is after org-mode exporting to html.

;;; Code:

(defun -hardwire-type (re opentag closetag)
  "Internal function for hardwiring external resources of sepecific type.

RE is a regular expression matching the tag that references an external
resource, the expression should have a capture group that contains the url.

The strings OPENTAG and CLOSETAG is text that should be added
before respectivly after the contents of the linked resource."
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (when (looking-at re)
	(let ((url (match-string 1)))
	  (delete-region (match-beginning 0) (match-end 0))
	  (insert opentag)
	  (insert "/* This is downloaded from: ")
	  (insert url)
	  (insert " */\n")
	  (insert (with-temp-buffer
		    (url-insert-file-contents url)
		    (buffer-string)))
	  (insert closetag)))
      (forward-line))))

(defun hardwire-css-js-in-buffer ()
  "Replace external javascript and stylesheets with the actual contents."
  (interactive)

  ; CSS
  (-hardwire-type
   "<link rel=\"stylesheet\".* href=\"\\([^\"]*\\)\"/>"
   "<style type=\"text/css\">\n"
   "</style>")

  ; JS
  (-hardwire-type
   "<script .*src=\"\\([^\"]*\\)\"></script>"
   "<script>\n<!--/*--><![CDATA[/*><!--*/\n"
   "/*]]>*///-->\n</script>")

  ; Imports in CSS
  (-hardwire-type
   "@import url(\\([^)]*\\));"
   "" ""))


(provide 'hardwire)
;;; hardwire.el ends here
