
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
exception:  b       exception


#             .text

# init:       move    $t0, $0             # int i = 0;
#             move    $v0, $0             # int a = 0;
#             li      $t1, 0x20           # int max = 0x20;

# write:      sw      $v0, 0x0 ($t0)      # mem[i] = a;
#             addiu   $t0, $t0, 4         # i += 4;
#             addiu   $v0, $v0, 1         # a++;
#             bne     $t0, $t1, write	    # if (i != max) goto write

#             move    $t0, $0             # i = 0;
# read:       lw      $v0, 0x0 ($t0)      # a = mem[i];
#             addiu   $t0, $t0, 4         # i += 4;
#             bne     $t0, $t1, read      # if (i != max) goto write

# end:        b       end                 # while(1);
