(define (problem blocksworld-8)
  (:domain blocksworld)
  (:objects
    a b c d e f g h i - block
  )
  (:init
    (handempty)
    (clear c)
    (clear f)
    (ontable c)
    (ontable b)
    (on f g)
    (on g e)
    (on e a)
    (on a i)
    (on i d)
    (on d h)
    (on h b)
  )
  (:goal (and
    (clear g) (ontable h)
    (on g d) (on d b) (on b c) (on c a) (on a i) (on i f) (on f e) (on e h)
  ))
)
