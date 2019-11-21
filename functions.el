;; some helper functions to have available in init.el

(defun get-string-from-file (filePath)
  "Return filePath's file content.
  Credit: http://ergoemacs.org/emacs/elisp_read_file_content.html"
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))
(defun md5-file (filePath)
  (md5 (get-string-from-file filePath)))

(defun load-org-cached (rel-path)
  "Loading an org file (using a relative path from the init file)
- If the tangled .el file exists and the md5 checksum hasn't changed, then the .el file is loaded without parsing the .org file.
- Otherwise, the .org file is parsed and loaded."
  (let* ((path (relative-from-init rel-path))
	 ;; Note: make-symbol is not gonna work
	 (symbol (intern (concat "md5_" path)))
	 (checksum (md5-file path))
	 (stored-checksum (if (boundp symbol) (symbol-value symbol) nil ))
	 (el-path (concat (file-name-sans-extension path)
			  ".el")))
    (if (and
	 (equal checksum stored-checksum)
	 (file-exists-p el-path))
	(progn
	  (message "Loading cached .el file %s " el-path)
	  (load-file el-path)
	  )
      (progn
	(message "Checksum mismatch, or .el not found, loading .org file %s" path)
	(require 'org)
	(org-babel-load-file path)
	)
      )
    (when (not (equal checksum stored-checksum))
      (message "Saving new checksum for %s" path)
      ;; after all went good, store the checksum
      (customize-save-variable symbol checksum))))