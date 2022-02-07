(define (problem blocksworld-6)
  (:domain blocksworld)
  (:objects
    a b c d e f g - block
  )
  (:init
    (handempty)
    (clear a)
    (clear c)
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
    (on a e) (on e b) (on b f) (on f g) (on g c) (on c d)
  ))
)
