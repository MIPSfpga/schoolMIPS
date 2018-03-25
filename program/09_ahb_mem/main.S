
#define MAX_ADDR_OFFSET      0x20

## comment for block or scratchpad ram
#define AHB_MEM_TEST

#ifdef AHB_MEM_TEST
    #define MEM_START 0x20000000
#else
    #define MEM_START 0x00000000
#endif

            .text

init:       li      $t0, MEM_START       # int i = 0;
            move    $v0, $0              # int a = 0;
            addiu   $t1, $t0, MAX_ADDR_OFFSET # int maxAddr = MEM_START + MAX_ADDR_OFFSET;

write:      sw      $v0, 0x0 ($t0)      # mem[i] = a;
            lw      $v1, 0x0 ($t0)      #   read after write hazard
            addiu   $t0, $t0, 4         # i += 4;
            addiu   $v0, $v0, 1         # a++;
            bne     $t0, $t1, write	    # if (i != max) goto write

            li      $t0, MEM_START      # i = 0;
read:       lw      $v0, 0x0 ($t0)      # a = mem[i];
            addiu   $t0, $t0, 4         # i += 4;
            bne     $t0, $t1, read      # if (i != max) goto write

end:        b       end                 # while(1);
