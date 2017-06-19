;;;; -*- lisp -*-
;;; tangled : demo-ucw.org

(in-package :demo-ucw)

(defvar *every-push-ucw-server*
  (make-instance 'standard-server
		 :backend (make-backend :httpd :port 8090)))

(defun start-demo-ucw-server ()
  (startup-server *every-push-ucw-server*))

(defun stop-demo-ucw-server ()
  (shutdown-server *every-push-ucw-server*))

(defvar *www-root-demo-ucw*
  (uiop:merge-pathnames* (asdf:component-pathname
				   (asdf:find-system :demo-ucw))))

(defclass demo-ucw-application (static-roots-application-mixin
				standard-application
				cookie-session-application-mixin)
  ()
  (:default-initargs
   :url-prefix "/demo-ucw/"
    :static-roots (list
		   (cons "/" *www-root-demo-ucw*)
		   (cons "static/" (uiop:merge-pathnames* #p"static/"
							  *www-root-demo-ucw*)))))

(defparameter *demo-ucw-application*
  (make-instance 'demo-ucw-application))

(register-application *every-push-ucw-server*
		      *demo-ucw-application*)

(defentry-point "index.ucw" (:application *demo-ucw-application*) ()
  (call 'demo-ucw-window))

(defcomponent demo-ucw-window (standard-window-component)
  ()
  (:default-initargs
      :title "DEMO UCW"
    :icon "static/favicon.ico"
    :doctype "html"
    :html-tag-attributes (list "lang" "zh-TW" "xmlns" #.+xhtml-namespace-uri+)
    :body (make-instance 'demo-ucw-component)))

(define-symbol-macro $window (context.window-component *context*))

(define-symbol-macro $body (window-body $window))

(defcomponent demo-ucw-component ()
  ((test :component test :accessor test)
   (demo :component demo :accessor demo)))

;; (defmethod demo ((self demo-ucw-component))
;;   (demo self))

(define-symbol-macro $test (test $body))

(define-symbol-macro $demo (demo $body))

(defmethod render ((self demo-ucw-component))
  (<:h1 "DEMO UCW")
  (render (slot-value self 'test))
  (<:div
   :style "border:1px solid block;"
   (render (slot-value self 'demo))))

(defcomponent demo ()
  ((message :initform "測試 UCW 功能" :accessor message :initarg :message)))

(defmethod render ((self demo))
  (<:as-html (format nil "Message: ~A" (message self))))

(defcomponent audio-play (demo)
  ((source :initform nil :accessor source :initarg :source)
   (autoplay :initform nil :accessor autoplay :initarg :autoplay)
   (controls :initform "controls" :accessor controls :initarg :controls)))

(defmethod render ((self audio-play))
  (call-next-method)
  (<:div
   (<:audio :controls (controls self) :autoplay (autoplay self)
	    (mapcar #'(lambda (x)
			(<:source :src x :type "audio/mp3"))
		    (source self)))))

(defcomponent multiple-audio (audio-play)
  ((music :initform nil :accessor music :initarg :music))
  (:default-initargs
      :message "Multiple Audio"))

(defmethod render ((self multiple-audio))
  ;;(render (make-instance 'demo :message (message self)))
  ;; (call-next-method)
  (setf (message $demo) (message self))
  (mapcar #'(lambda (x)
	      (render (make-instance 'audio-play
				     :controls t
				     :type "audio/mp3; charset=UTF-8"
				     ;; :charset "utf-8"
				     :source (list x))))
	  (music self)))

(defcomponent test ()
  ())

(defmethod render ((self test))
  (<:ul
   (<:li (<ucw:a
	  :function
	  (lambda ()
	    (setf (message $demo)
		  ;;(format nil "~A" (message $demo))))
		  "Test <:A :FUNCTION type actions OK"))
	  "Test <:A :FUNCTION type actions"))
   (<:li (<ucw:a
	  :action
	  (call-component $demo
			  (make-instance 'audio-play
					 :message "Test CALL-COMPONENT/ANSWER-COMPONEMT AND <:AUDIO> OK，使用的音源是 b4283 口譯  Bjarne Stroustrup 的談話"
					 :controls t
					 :autoplay nil
					 :source (list
						  ;; (print-uri-to-string
						  "static/b4283錄音關於C++.mp3")))
						  ;; "static/愛著啊.mp3")))
						  ;; "aaa")))
;; "static/audio1.mp3")))
;; "static/audio2.mp3")))
	  "Test CALL-COMPONENT/ANSWER-COMPONEMT AND <:AUDIO>"))))
   ;; (<:li (<ucw:a
   ;; 	  :action
   ;; 	  (call-component $demo
   ;; 			  (make-instance 'multiple-audio
   ;; 					 :message "Test Multiple Audio OK"
   ;; 					 :music (list
   ;; 						 "static/audio1.mp3"
   ;; 						 "static/audio2.mp3")))
   ;; 	  "Test Multiple Audio!!"))))

(defentry-point "bbb" (:application *demo-ucw-application*) ()
;;  (serve-file (merge-pathnames #p"static/愛著啊.mp3" *www-root-demo-ucw*)))
  (serve-file (merge-pathnames #p"static/audio1.mp3" *www-root-demo-ucw*)))

(defentry-point "aaa"
    (:application *demo-ucw-application*)
    ((file (quri:url-encode "static/愛著啊.mp3")))
  (serve-file (uiop:merge-pathnames* (quri:url-decode file) *www-root-demo-ucw*)))
	      ;; :content-type "audio/mpeg; charset=UTF-8"))
;;  (serve-file (uiop:merge-pathnames* #p"愛著啊.mp3" *www-root-demo-ucw*)))
