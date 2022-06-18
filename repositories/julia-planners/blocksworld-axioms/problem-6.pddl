(define (problem blocksworld-axioms-6)
  (:domain blocksworld-axioms)
  (:objects
    a b c d e f g
  )
  (:init
    (ontable g)
    (ontable f)
    (on a g)
    (on c d)
    (on d b)
    (on b e)
    (on e f)
  )
  (:goal (and
    (clear a) (ontable d)
    (above a e) (above a b) (above a f) (above a g) (above a c) (above a d)
  ))
)
