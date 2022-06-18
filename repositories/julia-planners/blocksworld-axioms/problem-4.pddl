(define (problem blocksworld-axioms-4)
  (:domain blocksworld-axioms)
  (:objects
    a b c d e
  )
  (:init
    (ontable d)
    (ontable e)
    (ontable c)
    (on b a)
    (on a d)
  )
  (:goal (and
    (clear d) (above d c) (above d b) (above d a) (above d e) (ontable e)
  ))
)
