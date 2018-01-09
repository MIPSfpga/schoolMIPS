
            .text
            .org    0x0
init:       li      $t0, 0x40           # timer init
            mtc0    $t0, $11            #   cp0.Compare = 0x20
            mtc0    $0,  $9             #   cp0.Count   = 0;

            addiu   $t0, $0, 0x8001     # exceptions init 8001
            mtc0    $t0, $12            #   cp0.Status = {IE = 1, IM7 = 1}

end:        nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            b       end                 # while(1);


            .org    0x100
exception:  li      $t0, 0x40           # timer reset
            mtc0    $t0, $11            #   cp0.Compare = 0x20
            mtc0    $0,  $9             #   cp0.Count   = 0;
            eret
