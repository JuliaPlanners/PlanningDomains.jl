(define (problem blocksworld-axioms-3)
  (:domain blocksworld-axioms)
  (:objects
    a b c d
  )
  (:init
    (ontable d)
    (on b c)
    (on c a)
    (on a d)
  )
	(:goal (and
    (clear d) (ontable b) (above d c) (above d a) (above d b)
  ))
)
