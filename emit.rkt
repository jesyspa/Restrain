#lang racket

(require "rtree.rkt")

(provide (contract-out
          [emit-c++ (rtree? . -> . string?)]))

(define (emit-c++ tree)
  "")

;;;;
;;;; Tests
;;;;

(require rackunit)

(provide emit-c++-tests)

(define emit-c++-tests
  (test-suite
   "Ensure correct C++ is emitted for the given trees."))