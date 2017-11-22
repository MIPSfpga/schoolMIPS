        .text
		  #
		  #b1(1-qⁿ)/(1-q), q ≠ 1
		  #
		  #t0(8)  = b1
		  #t1(9)  = q
		  #t2(10) = n
		  #t3(11) = qⁿ
		  #t4(12) = b1(1-qⁿ)
		  #t5(13) = 1-q
		  #t7(15) = i
		  #t8(24)  = sum
		  #v0(2) = result
		  #
init:   li      $t0, 1          ## b1 = 1
        li      $t1, 3          ## q =3
		  li		 $v0, 0			  ## sum = 0
		  li		 $t2, 0          ## n = 0
while:  li	    $t7, 0          ## i counter
		  move    $t3, $t1        ##
pow:	  beq     $t2, $t7, calc  ## while (i != n)
		  mul		 $t3, $t3, $t1   ## $t3 = qⁿ
		  addiu   $t7, $t7, 1     ## increment i
		  b       pow
calc:   li      $v1, 1          ##
		  subu    $t4, $v1, $t3   ## $t4 = 1-qⁿ
		  subu    $t5, $v1, $t1   ## $t5 = 1-q
		  mul     $t4, $t4, $t0   ## $t4 = b1(1-qⁿ)
		  li      $t8, 0          ## $t8 - sum
div:	  beq		 $t4, $0, next   ## if ($t4 == 0)
		  subu    $t4, $t4, $t5   ## $t4 = b1(1-qⁿ) - (1-q)
		  addiu   $t8, $t8, 1     ## $t8 = b1(1-qⁿ)/(1-q)
		  b       div
next:   addiu	 $t2, $t2, 1	  ## increment n
		  move    $v0, $t8        ## v0 - result
		  b       while