
            .text

init:       move    $t0, $0             # int cur_delay = 0;
            li      $t1, 0x10           # int max_delay = 0x20;

delay:      addiu   $t0, $t0, 1         # cur_delay++;
            bne     $t0, $t1, delay     # if(cur_delay != max_delay) goto delay
            move    $t0, $0             # cur_delay = 0;

read:       lw      $v0, 0x00007f00 ($0) # var = SM_GPIO_REG_INPUT;
write:      sw      $v0, 0x00007f04 ($0) # SM_GPIO_REG_OUTPUT = var;
            beqz    $0,  delay
