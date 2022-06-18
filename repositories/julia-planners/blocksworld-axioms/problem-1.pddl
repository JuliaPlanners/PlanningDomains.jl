(define (problem blocksworld-axioms-1)
	(:domain blocksworld-axioms)
	(:objects
		a b
	)
	(:init
		(ontable a)
		(ontable b)
	)
	(:goal (and
		(clear a) (ontable b) (above a b)
	))
)
