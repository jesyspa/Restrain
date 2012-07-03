#lang racket

(provide (contract-out
          [rtree? (any/c . -> . boolean?)]))

(define (rtree? tree)
  (cond
    [(not (list? tree)) #f]
    [(empty? tree) #f]
    [(equal? (first tree) 'number) (and (= (length tree) 2)
                                        (number? (second tree)))]
    [(equal? (first tree) 'symbol) (and (= (length tree) 2)
                                        (string? (second tree)))]
    [(equal? (first tree) 'magic) (= (length tree) 1)]
    [(equal? tree '(boolean #f)) #t]
    [(equal? tree '(boolean #t)) #t]
    [(equal? (first tree) 'list) (andmap rtree? (cdr tree))]
    [else #f]))


;;;;
;;;; Tests
;;;;

(require rackunit)

(provide rtree-tests)

(define rtree-tests
  (test-suite
   "Ensure that only valid ASTs are accepted."
   
   (test-case
    "Ensure the empty tree is not accepted."
    (check-equal? (rtree? '()) #f))
   
   (test-case
    "Ensure only valid numbers are accepted as such."
    (check-equal? (rtree? '(number 5)) #t)
    (check-equal? (rtree? '(number 5 6)) #f)
    (check-equal? (rtree? '(number)) #f)
    (check-equal? (rtree? '(number "x")) #f))
   
   (test-case
    "Ensure only valid symbols are accepted as such."
    (check-equal? (rtree? '(symbol "x")) #t)
    (check-equal? (rtree? '(symbol "x" "y")) #f)
    (check-equal? (rtree? '(symbol)) #f)
    (check-equal? (rtree? '(symbol 5)) #f))
   
   (test-case
    "Ensure valid lists are accepted."
    (check-equal? (rtree? '(list)) #t)
    (check-equal? (rtree? '(list (number 5))) #t))
   
   (test-case
    "Ensure invalid lists are rejected."
    (check-equal? (rtree? '(list 5)) #f))
   
   (test-case
    "Ensure only true magic is accepted."
    (check-equal? (rtree? '(magic)) #t)
    (check-equal? (rtree? '(magic 5)) #f))))