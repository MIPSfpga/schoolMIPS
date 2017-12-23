

            .text

init:       li      $t0, 1
check:      bne     $t0, $0, w1
            addu    $v0, $t0
            addu    $v0, $t0
            addu    $v0, $t0
            nop

w1:         li      $t1, 3
            li      $t2, 3
            beq     $t1, $t2, w2
            addu    $v0, $t0
            addu    $v0, $t0
            addu    $v0, $t0
            nop

w2:         nop
            nop
            nop
            nop
end:        b       end
