
            .text

init:       move    $t0, $0             # int cur_delay = 0;
            li      $t1, 0x100          # int max_delay = 0x200

delay:      addiu   $t0, $t0, 1         # cur_delay++;
            bne     $t0, $t1, delay     # if(cur_delay != max_delay) goto delay
            move    $t0, $0             # cur_delay = 0;

pwm_step:   lw      $v0, 0x00007f10 ($0) # var = SM_PWM_REG;
            addiu   $v0, $v0, 0x10
write:      sw      $v0, 0x00007f10 ($0) # SM_PWM_REG = var;
            beqz    $0,  delay
