            .text #sum of the elements of arithmetical progression
start:		li $t0, 4 # first element
			li $t1, 54 # last element
			li $t2, 10 # number of elements
			li $t3, 0 # sum of progression
			li $t4, 0 #temporary variable for cycle to make t2/2 iterations
			li $v0, 0 # output variable
prog:		addu $t0, $t0, $t1 # sum of the first and last elements
			
LOOP:		
			addu $t3, $t3, $t0 # "multiplication" - sum of an element and itself
			addu $t2, $t2, -1 # counter
			addu $t4, $t4, 1 #counter #2
			move $v0, $t3 # put result of sum into output
			beq $t2, $t4, end # if t2=t4 then branch to end
			b LOOP #branch to the beginning of the loop
end:		b end #end