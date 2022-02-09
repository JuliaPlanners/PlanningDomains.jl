(define (problem blocksworld-5)
  (:domain blocksworld)
  (:objects
    a b c d e f - block
  )
  (:init
    (handempty)
    (clear d)
    (clear f)
    (ontable c)
    (ontable b)
    (on d a)
    (on a c)
    (on f e)
    (on e b)
  )
  (:goal (and
    (clear c) (ontable d) (on c b) (on b a) (on a e) (on e f) (on f d)
  ))
)
