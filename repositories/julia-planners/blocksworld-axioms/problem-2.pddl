(define (problem blocksworld-axioms-2)
	(:domain blocksworld-axioms)
	(:objects
		a b c
	)
	(:init
		(ontable a)
		(ontable b)
		(ontable c)
	)
	(:goal (and
		(clear c) (ontable b) (above c b) (above c a)
	))
)
