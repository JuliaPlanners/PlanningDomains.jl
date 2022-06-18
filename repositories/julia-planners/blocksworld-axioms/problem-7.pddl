(define (problem blocksworld-axioms-7)
  (:domain blocksworld-axioms)
  (:objects
    a b c d e f g h
  )
  (:init
    (ontable c)
    (ontable g)
    (ontable d)
    (ontable f)
    (on e c)
    (on h a)
    (on a b)
    (on b g)
  )
  (:goal (and
    (clear c) (ontable e)
    (above c d) (above c b) (above c g)
    (above c f) (above c h) (above c a) (above c e)
  ))
)
