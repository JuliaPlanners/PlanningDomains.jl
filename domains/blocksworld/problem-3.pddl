(define (problem blocksworld-3)
  (:domain blocksworld)
  (:objects
    a b c d - block
  )
  (:init
    (handempty)
	  (clear b)
    (ontable d)
    (on b c)
    (on c a)
    (on a d)
  )
	(:goal (and
    (clear d) (ontable b) (on d c) (on c a) (on a b)
  ))
)
