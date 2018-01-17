

            .text

init:       li      $t0, 1
start:      addu    $t1, $t0, $t0   # forward both args from M to E stage
            addu    $t2, $t0, $t0   # forward both args from W to E stage
            addu    $t3, $t0, $t0   # no forwarding

            nop
            nop
            nop
            nop
end:        b       end
