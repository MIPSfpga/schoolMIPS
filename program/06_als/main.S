
            .text

init:       move    $t0, $0             # int cur_delay = 0;
            li      $t1, 0x100          # int max_delay = 0x200

delay:      addiu   $t0, $t0, 1         # cur_delay++;
            bne     $t0, $t1, delay     # if(cur_delay != max_delay) goto delay
            move    $t0, $0             # cur_delay = 0;

get_ligth:  lw      $v0, 0x00007f20 ($0) # var = SM_ALS_REG;
write_pwm:  sw      $v0, 0x00007f10 ($0) # SM_PWM_REG = var;
            beqz    $0,  delay
