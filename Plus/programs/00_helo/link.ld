OUTPUT_ARCH( "riscv" )
ENTRY( main )
MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000200, LENGTH = 0x00000800
  ram      (rwx) : ORIGIN = 0x00000800, LENGTH = 8K
}
STACK_SIZE = 0x020;


 SECTIONS
 {
 /* text: test code section */
 . = 0x200;
 .text :
 {
 *(.text)
 . = ALIGN(4);
 }>rom 

 /* data: Initialized data segment */
 .data :
 {
 *(.data)
 }> rom
 /* End of uninitalized data segement */
    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        . = ALIGN(8);
    } > ram

  /DISCARD/ :
  {
    *(.note.gnu.build-id)
    *(.riscv.attributes)
    *(.comment)
  }
 

_end = .;
 }