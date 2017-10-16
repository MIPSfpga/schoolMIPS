
        .text

init:   li      $t0, 17          ##  Check if t0 = x * ?
        li      $v0, 0           ##  Result reset
        li      $t1, 9           ##  x = t1
        li      $t3, 1           ##  t3 = 1

	  beq		$t1, $t3, yes
        
step:   slt     $t2, $t0, $t1    ##  If t0 < t1
        beq     $t2, $t3, stop   ##  Stop

        beq     $t0, $t1, yes    ##  If t0 == t1, return 1

        subu    $t0, $t0, $t1    ##  Else t0 -= t1
        b       step             ##  Next step

yes:    move    $v0, $t3         ##  v0 becomes 1

stop:   b       stop             ##  Stop
