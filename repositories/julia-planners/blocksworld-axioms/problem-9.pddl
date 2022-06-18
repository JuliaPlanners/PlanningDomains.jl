(define (problem blocksworld-axioms-9)
  (:domain blocksworld-axioms)
  (:objects
    a b c d e f g h i j
  )
  (:init
    (ontable a)
    (ontable c)
    (on j i)
    (on i h)
    (on h f)
    (on f d)
    (on d e)
    (on e g)
    (on g b)
    (on b a)
  )
  (:goal (and
    (clear b) (ontable d)
    (above b d) (above b i) (above b g)
    (above b h) (above b c) (above b a)
    (above b f) (above b j) (above b d)
  ))
)
