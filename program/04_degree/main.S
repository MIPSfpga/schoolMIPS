
        .text

init:   
        li      $v0, 0x1           
        li      $t0, 0x2           
        li      $t1, 0x3           
        li      $t2, 0x1	      
        beq     $t1, $0, stop    
        move    $v0, $0          
    
loop:   subu    $t1, $t1, $t2    
        addu    $v0, $v0, $t0    
        move    $t0, $v0         
        bne     $t1, $0, loop    

stop:   b       stop             
