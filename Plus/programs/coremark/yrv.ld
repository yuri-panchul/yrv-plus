OUTPUT_ARCH( "riscv" )
ENTRY(_start)
MEMORY
{
  BRAM     (rx) : ORIGIN = 0x00000000, LENGTH = 30K
}
_TRAP_ACK = 0x040;
_NMI_VECT = 0x100;
_DBG_VEC =  0x140;
_DEX_VEC =  0x1c0;
_RST_BASE = 0x200;

 SECTIONS
 {

 PROVIDE(__stack_top = ORIGIN(BRAM) + LENGTH(BRAM));

 .text :
 {
    *(.text.eset_led)
    . = _TRAP_ACK;
    *(.text.trap_ack)
    . = _NMI_VECT;
    *(.text.nmi_vec)
    . = _DBG_VEC;
    *(.text.dbg_vec)
    . = _DEX_VEC;
    *(.text.dex_vec)
    . = _RST_BASE;
    *(.text.init)
    *(.text.startup)
    *(.text)
    . = ALIGN(4);
 } 


  .data : {
        *(.data)
	*(.rodata .data.*)
        *(.gnu.linkonce.d.*)
        *(.sdata .sdata.* .sdata2.*)
        *(.gnu.linkonce.s.*)
        . = ALIGN(8);
        PROVIDE( __global_pointer$ = . + 0x800 );
	_edata = .;
  } >BRAM


    .bss : {
        *(.sbss*)
        *(.gnu.linkonce.sb.*)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
    }>BRAM

  /DISCARD/ :
  {
    *(.note.gnu.build-id)
    *(.riscv.attributes)
    *(.comment)
    *(.eh_frame .eh_frame.*)
  }

_end = .;
 }