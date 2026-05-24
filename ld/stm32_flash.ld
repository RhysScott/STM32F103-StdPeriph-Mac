/*
 *****************************************************************************
 **
 **  File        : stm32_flash.ld
 **
 **  Abstract    : Linker script for STM32F103C8T6
 **                64KB FLASH, 20KB SRAM
 **
 **  Target      : STM32F103C8T6 (Medium Density)
 **
 *****************************************************************************
 */

/* 入口点 */
ENTRY(Reset_Handler)

/* 栈顶地址（SRAM 末尾：0x20000000 + 20KB） */
_estack = 0x20005000;

/* 堆和栈最小尺寸检查 */
_Min_Heap_Size = 0x200;   /* 512 字节堆 */
_Min_Stack_Size = 0x400;  /* 1KB 栈 */

/* 内存区域定义 */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
  RAM  (xrw) : ORIGIN = 0x20000000, LENGTH = 20K
}

/* 输出段定义 */
SECTIONS
{
  /* 中断向量表放在 FLASH 最前面 */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  /* 代码和只读数据 */
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    *(.glue_7)
    *(.glue_7t)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* 代码段结束 */
  } >FLASH

  /* ARM 异常表 */
  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH

  /* C++ 静态构造/析构 */
  .preinit_array :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH

  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(.fini_array*))
    KEEP (*(SORT(.fini_array.*)))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH

  /* .data 段初始化数据在 FLASH 中的存储地址 */
  _sidata = LOADADDR(.data);

  /* 已初始化数据段（加载到 RAM，初始值存于 FLASH） */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } >RAM AT> FLASH

  /* 未初始化数据段（BSS） */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
    __bss_end__ = _ebss;
  } >RAM

  PROVIDE ( end = _ebss );
  PROVIDE ( _end = _ebss );

  /* 堆栈空间预留检查 */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( __heap_start = . );
    . = . + _Min_Heap_Size;
    PROVIDE ( __heap_end = . );
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

  /* 丢弃调试信息（减小固件体积） */
  /DISCARD/ :
  {
    *(.ARM.attributes)
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
}
