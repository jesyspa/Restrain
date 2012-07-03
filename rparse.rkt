#lang racket

(require parser-tools/lex
         parser-tools/yacc
         (prefix-in re- parser-tools/lex-sre)
         "rtree.rkt")

(provide (contract-out
          [rparse (input-port? . -> . rtree?)]
          [rparse-string (string? . -> . rtree?)]))


;;;
;;; Token and regex definitions
;;;

(define-tokens rparse-tok
  (number symbol))

(define-empty-tokens rparse-empty-tok
  (lparen rparen comma dot at tilde quote qquote eof underscore))

(define-lex-abbrev not-allowed
  (re-or #\( #\) #\, #\. #\` #\' #\@ #\~ #\_))

(define-lex-abbrev allowed-any-char
  (re-- (re-or alphabetic punctuation symbolic)
        not-allowed))

(define-lex-abbrev allowed-nonfirst-char
  (re-* (re-or allowed-any-char numeric)))


;;;
;;; Lexer and parser
;;;

(define rparse-lexer
  (lexer
   [(re-+ numeric) (token-number (string->number lexeme))]
   [(re-: allowed-any-char allowed-nonfirst-char)
    (token-symbol lexeme)]
   [#\( (token-lparen)]
   [#\) (token-rparen)]
   [#\, (token-comma)]
   [#\. (token-dot)]
   [#\' (token-quote)]
   [#\` (token-qquote)]
   [#\@ (token-at)]
   [#\~ (token-tilde)]
   [#\_ (token-underscore)]
   [blank (rparse-lexer input-port)]
   [(eof) (token-eof)]))

(define rparse-parse
  (parser
   (grammar
    (expr ((number) `(number ,$1))
          ((symbol) `(symbol ,$1))
          ((tilde) `(magic))
          ((quote expr) `(list (magic) (symbol "quote") ,$2))
          ((qquote expr) `(list (magic) (symbol "quasiquote") ,$2))
          ((comma expr) `(list (symbol "unquote") ,$2))
          ((comma at expr) `(list (symbol "unquote-splice") ,$3))
          ((lparen list rparen) $2))
    (list ((list dot rhslist) `(list ,@(cons $1 $3)))
          ((rhslist) `(list ,@$1)))
    (rhslist ((expr rhslist) (cons $1 $2))
             (() '())))
   (tokens rparse-tok rparse-empty-tok)
   (start expr)
   (end eof)
   (error (lambda (tok-ok? tok-name tok-value)
            (printf "Error: ~a ~a ~a" tok-ok? tok-name tok-value)))))

(define (rparse input-port)
  (rparse-parse (λ () (rparse-lexer input-port))))

(define (rparse-string str)
  (rparse (open-input-string str)))


;;;
;;; Tests
;;;

(require rackunit)

(provide lex-tests
         parse-tests)



(define (lex-check-equal? string type value)
  (let ([result (rparse-lexer (open-input-string string))])
    (check-equal? (token-name result) type)
    (check-equal? (token-value result) value)))

(define lex-tests
  (test-suite
   "Tests for the lexer."
   
   (test-case
    "Numbers are lexed correctly."
    (lex-check-equal? "5" 'number 5)
    (lex-check-equal? "100" 'number 100)
    (lex-check-equal? "0" 'number 0))
   
   (test-case
    "Symbols are lexed correctly."
    (lex-check-equal? "x" 'symbol "x")
    (lex-check-equal? "+" 'symbol "+")
    (lex-check-equal? "-" 'symbol "-")
    (lex-check-equal? "*" 'symbol "*")
    (lex-check-equal? "/" 'symbol "/")
    (lex-check-equal? "%" 'symbol "%")
    (lex-check-equal? "?" 'symbol "?")
    (lex-check-equal? "a5" 'symbol "a5"))
   
   (test-case
    "Literals are lexed correctly."
    (lex-check-equal? "(" 'lparen #f)
    (lex-check-equal? ")" 'rparen #f)
    (lex-check-equal? "," 'comma #f)
    (lex-check-equal? "." 'dot #f)
    (lex-check-equal? "'" 'quote #f)
    (lex-check-equal? "`" 'qquote #f)
    (lex-check-equal? "@" 'at #f)
    (lex-check-equal? "~" 'tilde #f)
    (lex-check-equal? "_" 'underscore #f))))

(define parse-tests
  (test-suite
   "Tests for the parser"
   
   (test-case
    "Ensure symbols are parsed correctly."
    (check-equal? (rparse-string "x") '(symbol "x")))
   
   (test-case
    "Ensure numbers are parsed correctly."
    (check-equal? (rparse-string "5") '(number 5)))
   
   (test-case
    "Ensure that lists are parsed correctly."
    (check-equal? (rparse-string "()") '(list))
    (check-equal? (rparse-string "(5 5)") '(list (number 5) (number 5)))
    (check-equal? (rparse-string "(5 . 5)") '(list (list (number 5)) (number 5)))
    (check-equal? (rparse-string "(. 5)") '(list (list) (number 5)))
    (check-equal? (rparse-string "(5 .)") '(list (list (number 5)))))
   
   (test-case
    "Ensure quotes are parsed correctly."
    (check-equal? (rparse-string "'()") '(list (magic) (symbol "quote") (list)))
    (check-equal? (rparse-string "`()")
                  '(list (magic) (symbol "quasiquote") (list))))
   
   (test-case
    "Ensure unquotes are parsed correctly."
    (check-equal? (rparse-string ",x") '(list (symbol "unquote") (symbol "x")))
    (check-equal? (rparse-string ",@x") '(list (symbol "unquote-splice") (symbol "x"))))))