(define (problem blocksworld-4)
  (:domain blocksworld)
  (:objects
    a b c d e - block
  )
  (:init
    (handempty)
    (clear b)
    (clear e)
    (clear c)
    (ontable d)
    (ontable e)
    (ontable c)
    (on b a)
    (on a d)
  )
  (:goal (and
    (on d c) (on c b) (on b a) (on a e)
  ))
)
