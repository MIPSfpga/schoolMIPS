

            .text

init:       li      $t0, 1
write:      sw      $t0, 0x0 ($0)
            nop
            nop

start:      lw      $t1, 0x0 ($0)
            addu    $v0, $t1, $t1   # pipleline should be stalled

            nop
            nop
            nop
            nop
end:        b       end
