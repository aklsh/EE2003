.global fib
fib:
    li a1,1        # Initialise f(n-1) to 1
    li a2,0        # Initialise f(n-2) to 0
    li a3,1        # constant 1

.MAIN:
    add a4,a1,a2
    mv a2,a1
    mv a1,a4
    sub a0,a0,a3
    beq a0,x0,.FINALISE
    bne a0,x0,.MAIN

.FINALISE:
    mv a0,a2
    jr ra           # Return address was stored by original call
