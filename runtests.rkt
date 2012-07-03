#lang racket

(require rackunit/text-ui
         "rtree.rkt"
         "rparse.rkt"
         "emit.rkt")

(run-tests rtree-tests)
(run-tests lex-tests)
(run-tests parse-tests)