

            .text

init:       li      $t0, 1
write:      sw      $t0, 0x0 ($0)
            nop
            nop

start:      lw      $t1, 0x0 ($0)
            addu    $t2, $t1, $t1

            nop
            nop
            nop
            nop
end:        b       end
