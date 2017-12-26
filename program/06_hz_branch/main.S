

            .text

init:       li      $t0, 1
            sw      $t0, 0x0 ($0)

check:      bne     $t0, $0, w1
            addu    $v0, $t0    # should be flushed from E-stage (with pipeline stall)
            addu    $v0, $t0    # unreacheble
            addu    $v0, $t0    # unreacheble
            nop                 # unreacheble

w1:         li      $t1, 3
            li      $t2, 3
            beq     $t1, $t2, w2
            addu    $v0, $t0    # should be flushed from E-stage (with pipeline stall)
            addu    $v0, $t0    # unreacheble
            addu    $v0, $t0    # unreacheble
            nop                 # unreacheble

w2:         lw      $t1, 0x0 ($0)
            bne     $t1, $t2, w3
            addu    $v0, $t0    # should be flushed from E-stage (with pipeline stall)
            addu    $v0, $t0    # unreacheble
            addu    $v0, $t0    # unreacheble
            nop                 # unreacheble

w3:         nop                 # v0 should be 0 here
            nop
            nop
            nop
end:        b       end
