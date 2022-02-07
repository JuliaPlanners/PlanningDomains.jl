(define (problem blocksworld-1)
	(:domain blocksworld)
	(:objects
		a b - block
	)
	(:init
		(handempty)
		(ontable a)
		(ontable b)
		(clear a)
		(clear b)
	)
	(:goal (and
		(clear a) (ontable b) (on a b)
	))
)
