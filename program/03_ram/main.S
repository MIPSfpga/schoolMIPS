


            .text

init:       move    $t0, $0             # int i = 0;
            move    $v0, $0             # int a = 0;
            li      $t1, 0x20           # int max = 0x20;

write:      sw      $v0, 0x0 ($t0)      # mem[i] = a;
            addiu   $t0, $t0, 4         # i += 4;
            addiu   $v0, $v0, 1         # a++;
            bne     $t0, $t1, write	    # if (i != max) goto write

            move    $t0, $0             # i = 0;
read:       lw      $v0, 0x0 ($t0)      # a = mem[i];
            addiu   $t0, $t0, 4         # i += 4;
            bne     $t0, $t1, read      # if (i != max) goto write

end:        b       end                 # while(1);
