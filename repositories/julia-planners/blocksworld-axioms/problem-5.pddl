(define (problem blocksworld-axioms-5)
  (:domain blocksworld-axioms)
  (:objects
    a b c d e f
  )
  (:init
    (ontable c)
    (ontable b)
    (on d a)
    (on a c)
    (on f e)
    (on e b)
  )
  (:goal (and
    (clear c) (ontable d)
    (above c b) (above c a) (above c e) (above c f) (above c d)
  ))
)
