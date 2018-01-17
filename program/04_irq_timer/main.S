
            .set    TimerPeriod, 0x31
            
            .text
            .org    0x0
init:       li      $t0, TimerPeriod    # timer init
            mtc0    $t0, $11            #   cp0.Compare = 0x20
            mtc0    $0,  $9             #   cp0.Count   = 0;

            addiu   $t0, $0, 0x8001     # exceptions init 8001
            mtc0    $t0, $12            #   cp0.Status = {IE = 1, IM7 = 1}

            li      $v0, 0x0            # reset bug detecting value

end:        addiu   $t1, $0, 0x1
            addu    $v0, $v0, $t1
            subu    $v0, $v0, $t1
            addu    $v0, $v0, $t1
            subu    $v0, $v0, $t1
            addu    $v0, $v0, $t1
            subu    $v0, $v0, $t1
            addu    $v0, $v0, $t1
            subu    $v0, $v0, $t1
            b       end                 # while(1);

            .org    0x100
exception:  li      $t0, TimerPeriod    # timer reset
            mtc0    $t0, $11            #   cp0.Compare = 0x20
            mtc0    $0,  $9             #   cp0.Count   = 0;
            # nop
            # nop
            # nop
            eret
