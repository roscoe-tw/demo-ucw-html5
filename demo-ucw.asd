;;;;  -*- lisp -*-
;;; tangled : demo-ucw.org

(in-package :cl-user)
(in-package :asdf-user)

(defsystem #:demo-ucw
  :version "0.0.1"
  :author "Colin <every.push.colin@gmail.com>"
  :depends-on (:cl-ppcre :asdf :ucw-dui :quri)
  :components ((:file "packages")
	       (:file "demo-ucw")))
