(define (problem blocksworld-axioms-8)
  (:domain blocksworld-axioms)
  (:objects
    a b c d e f g h i
  )
  (:init
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
    (above g d) (above g b) (above g c) (above g a)
    (above g i) (above g f) (above g e) (above g h)
  ))
)
