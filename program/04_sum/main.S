

            .text

start:      li     $t0, 0
            li     $t1, 0
            li     $v0, 0
            
square:     addu  $t1, $t1, 1
            addu  $t0, $t0, $t1
            move   $v0, $t0
            b      square
