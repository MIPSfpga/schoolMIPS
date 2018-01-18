
#define FORWARD_EPC_NONE    0
#define FORWARD_EPC_E       1
#define FORWARD_EPC_M       2

#define MODE    FORWARD_EPC_NONE

#define c0_status   $12
#define c0_EPC      $14
#define c0_cause    $13

            .text
            .org    0x0
init:       addiu   $t0, $0, 0x1
            li      $v0, 0x0

            nop
            nop
            addu    $v0, $v0, $t0
            subu    $v0, $v0, $t0

            mfhi    $0            # reserved instruction

            addu    $v0, $v0, $t0
            subu    $v0, $v0, $t0
            nop
            nop
            b       init                 # while(1);

#if MODE == FORWARD_EPC_E
            .org    0x100
exception:  move    $t1, $v0            # save v0
            mfc0    $v0, c0_status      # load cp0.Status
            mfc0    $v0, c0_cause       # load cp0.Cause
            mfc0    $v0, c0_EPC         # load cp0.EPC
            move    $t2, $v0
            move    $v0, $t1            # restore v0
            addiu   $t2, $t2, 0x4       # increment EPC to skip error
            mtc0    $t2, c0_EPC         # save cp0.EPC
            eret                        # new EPC value is now on E stage

#elif MODE == FORWARD_EPC_M
            .org    0x100
exception:  move    $t1, $v0            # save v0
            mfc0    $v0, c0_status      # load cp0.Status
            mfc0    $v0, c0_cause       # load cp0.Cause
            mfc0    $v0, c0_EPC         # load cp0.EPC
            move    $t2, $v0
            move    $v0, $t1            # restore v0
            addiu   $t2, $t2, 0x4       # increment EPC to skip error
            mtc0    $t2, c0_EPC         # save cp0.EPC
            nop
            eret                        # new EPC value is now on M stage

#else
# MODE == FORWARD_EPC_NONE
            .org    0x100
exception:  move    $t1, $v0            # save v0
            mfc0    $v0, c0_status      # load cp0.Status
            mfc0    $v0, c0_cause       # load cp0.Cause
            mfc0    $v0, c0_EPC         # load cp0.EPC
            addiu   $v0, $v0, 0x4       # increment EPC to skip error
            mtc0    $v0, c0_EPC         # save cp0.EPC
            move    $v0, $t1            # restore v0
            nop
            nop
            eret
#endif
