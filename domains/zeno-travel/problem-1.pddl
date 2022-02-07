(define (problem zeno-travel-1)
	(:domain zeno-travel)
	(:objects
		plane1 - aircraft
		person1 - person
		city0 - city
		city1 - city
		)
	(:init
		(at plane1 city0)
		(= (capacity plane1) 10232)
		(= (fuel plane1) 3956)
		(= (slow-burn plane1) 4)
		(= (fast-burn plane1) 15)
		(= (onboard plane1) 0)
		(= (zoom-limit plane1) 8)
		(at person1 city0)
		(= (distance city0 city0) 0)
		(= (distance city0 city1) 678)
		(= (distance city1 city0) 678)
		(= (total-fuel-used) 0)
		(= (total-time) 0)
	)
	(:goal (and
		(at plane1 city0)
		(at person1 city1)
	))
	(:metric minimize (+ (* 4 (total-time))  (* 5 (total-fuel-used))))
)
