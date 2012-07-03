#lang racket

(require "rtree.rkt")

(provide (contract-out
          [emit-c++ (rtree? . -> . string?)]))

(define (emit-c++ tree)
  "")

(define (emit-expr tree)
  (cond
    [(equal? (first tree) 'number) (number->string (second tree))]))

;;;;
;;;; Tests
;;;;

(require rackunit
         "rparse.rkt")

(provide emit-c++-expr-tests)

(define emit-c++-expr-tests
  (test-suite
   "Ensure correct C++ is emitted for the given trees."
   
   (test-case
    "Ensure numbers are generated verbatim."
    (check-equal? (emit-expr '(number 5)) "5"))))