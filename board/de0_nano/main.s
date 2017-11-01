##     a = 5;
##     m = 3;
##	   x = 5;
##	   z = x;
##     for (i=0; m-1; i++)
##	   {
##         z = x; 
##         for (j=0; a-1; j++) 
##		   {
##             x = x + z;
##         }
##     }
##     printf("%d", x);

				.text
		
	init:		li		$s1, 5			# a
				li		$s2, 3			# m
				li		$t5, 1			# for substraction
				subu	$t2, $s1, $t5	# a-1 
				subu	$t3, $s2, $t5	# m-1 
				move 	$s0, $s1		# x = a

				li 		$t0, 0			 # i = 0

	cycle1:		addiu	$t0, $t0, 1		 # i = i + 1
				move	$s3, $s0		 # z = x
	
				li	 	$t1, 0			 # j = 0
	cycle2:		addiu	$t1, $t1, 1		 # j = j + 1
				addu	$s0, $s0, $s3 	 # x = x + z
				move 	$v0, $s3		 # print z
				bne		$t1, $t2, cycle2 # if j != a-1 goto cycle2 
				move	$s3, $s0		 # z = x
				bne		$t0, $t3, cycle1 # if i != m-1 goto cycle1
				
				move 	$v0, $s0		 # print x

	end:    	b       end		 #while(1) 

	
