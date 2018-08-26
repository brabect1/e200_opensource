OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  flash (rxai!w) : ORIGIN = 0x20000000, LENGTH = 8M
  ram (wxai) : ORIGIN = 0x80000000, LENGTH = 64K
}

SECTIONS
{
  .text.init : { *(.text.init) } >flash AT>flash
  .text : { *(.text) } >flash AT>flash
  .tohost : ALIGN(0x1000) {
      . = . + 0x1000;
      *(.tohost)
  } >ram AT>flash
  .data : ALIGN(0x1000) { *(.data) } >ram AT>flash
  .bss : { *(.bss) } >ram AT>ram
  _end = .;
}

