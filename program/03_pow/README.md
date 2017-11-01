# Calculating the power of the number
The program calculates 5 to the power 3. The result shows intermediate calculations. At first, 5 to the power 1, then to the power 2 and, finally, 3.

## Code of the program in C++
     a = 5;
     m = 3;
	   x = 5;
	   z = x;
     for (i=0; m-1; i++)
	   {
         z = x; 
         for (j=0; a-1; j++) 
		   {
             x = x + z;
         }
     }
     printf("%d", x);

## Code of the program in Assembler

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
				move 	$v0, $s3		 # print intermediate result
	
				li	 	$t1, 0			 # j = 0
	cycle2:		addiu	$t1, $t1, 1		 # j = j + 1
				addu	$s0, $s0, $s3 	 # x = x + z
				bne		$t1, $t2, cycle2 # if j != a-1 goto cycle2 
				bne		$t0, $t3, cycle1 # if i != m-1 goto cycle1
				
				move 	$v0, $s0		 # print x

	end:    	b       end		 		 #while(1) 


## Transcript of modeling 

![1](/program/03_pow/doc/1.jpg)