
OUTPUT_ARCH(mips)

/**** Start point ****/
hwreset = 0x0;
ENTRY(hwreset)

SECTIONS
{
  .text = .;

    /DISCARD/ :
    {
      *(.MIPS.abiflags)
      *(.reginfo)
      *(.gnu.attributes)
    }

}
