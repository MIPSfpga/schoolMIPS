
#define c0_status   $12
#define c0_EPC      $14

            .text
            .org    0x0
init:       addiu   $t1, $0, 0x1
            nop
            nop
            nop
            nop
            nop
            nop
            addu    $v0, $v0, $t1
            subu    $v0, $v0, $t1

            mfhi    $0            # reserved instruction

            addu    $v0, $v0, $t1
            subu    $v0, $v0, $t1
            nop
            nop
            nop
            nop
            nop
            nop
            b       init                 # while(1);

            .org    0x100
exception:  or      $t1, $0, $v0        # save v0
            mfc0    $v0, c0_status      # load cp0.Status
            mfc0    $v0, c0_EPC         # load cp0.EPC
            addiu   $v0, $v0, 0x1       # increment EPC to skip error
            mtc0    $v0, c0_EPC         # save cp0.EPC
            or      $v0, $0, $t1        # restore v0
            eret
