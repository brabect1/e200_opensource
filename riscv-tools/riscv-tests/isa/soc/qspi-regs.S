# See LICENSE for license details.

#include "riscv_test.h"
#undef RVTEST_RV64M
#define RVTEST_RV64M RVTEST_RV32M

#include "test_macros.h"


#define TEST_RW_ADDR( testnum, value, mask, offset, base ) \
      .set myres,value & mask; \
    TEST_CASE( testnum, x30, myres, \
      li  x1, base; \
      li  x30,value; \
      sw x30, offset(x1); \
      lw x30, offset(x1); \
    )

#define TEST_RO_ADDR( testnum, value, expected, offset, base ) \
    TEST_CASE( testnum, x30, expected, \
      li  x1, base; \
      li  x30,value; \
      sw x30, offset(x1); \
      lw x30, offset(x1); \
    )

#define TEST_RO_ADDR_IGNORE( testnum, value, expected, offset, base, mask ) \
    TEST_CASE( testnum, x30, expected, \
      li  x1, base; \
      li  x30,value; \
      sw x30, offset(x1); \
      lw x30, offset(x1); \
      andi x30,x30, mask; \
    )

#define TEST_LD_ADDR( testnum, inst, result, offset, base ) \
    TEST_CASE( testnum, x30, result, \
      li  x1, base; \
      inst x30, offset(x1); \
    )

#define TEST_LD_ADDR_IGNORE( testnum, inst, result, offset, base, mask ) \
    TEST_CASE( testnum, x30, result, \
      li  x1, base; \
      inst x30, offset(x1); \
      andi x30,x30, mask; \
    )

RVTEST_RV32M
RVTEST_CODE_BEGIN

# -----------------------------------------------
# Test the QSPI0
# -----------------------------------------------
# The memory map is listed below. For complete periph IP reference
# see "SiFive E300 Platform Reference Manual"
#
# Memory map:
#   0x10014000 sckdiv Serial clock divisor
#   0x10014004 sckmode Serial clock mode
#   0x10014010 csid Chip select ID
#   0x10014014 csdef Chip select default
#   0x10014018 csmode Chip select mode
#   0x10014028 delay0 Delay control 0
#   0x1001402C delay1 Delay control 1
#   0x10014040 fmt Frame format
#   0x10014048 txdata Tx FIFO data
#   0x1001404C rxdata Rx FIFO data
#   0x10014050 txmark Tx FIFO watermark
#   0x10014054 rxmark Rx FIFO watermark
#   0x10014060 fctrl* SPI flash interface control
#   0x10014064 ffmt* SPI flash instruction format
#   0x10014070 ie SPI interrupt enable
#   0x10014074 ip SPI interrupt pending

#define SPI0_BASE 0x10014000

#define SPI_SCKDIV_OFST 0
#define SPI_SCKDIV_RSTV 0x00000003
#define SPI_SCKDIV_MASK 0x00000fff

#define SPI_SCKMODE_OFST 4
#define SPI_SCKMODE_RSTV 0x00000000
#define SPI_SCKMODE_MASK 0x00000003

# !!! There is a change in e203 SoC as opposed to SiFive freedom-e300-arty
# !!! (SiFive assumes full register width RW, whicle sirv uses only LSB)
#define SPI_CSID_OFST 16
#define SPI_CSID_RSTV 0x00000000
#define SPI_CSID_MASK 0x00000001

# !!! There is a change in e203 SoC as opposed to SiFive freedom-e300-arty
# !!! (SiFive resets to 0x0000ffff and assumes register full width, sirv uses
# !!! only LSB)
#define SPI_CSDEF_OFST 20
#define SPI_CSDEF_RSTV 0x00000001
#define SPI_CSDEF_MASK 0x00000001

#define SPI_CSMODE_OFST 24
#define SPI_CSMODE_RSTV 0x00000000
#define SPI_CSMODE_MASK 0x00000003

#define SPI_DELAY0_OFST 40
#define SPI_DELAY0_RSTV 0x00010001
#define SPI_DELAY0_MASK 0x00ff00ff

#define SPI_DELAY1_OFST 44
#define SPI_DELAY1_RSTV 0x00000001
#define SPI_DELAY1_MASK 0x00ff00ff

#define SPI_FMT_OFST 64
#define SPI_FMT_RSTV 0x00080000
#define SPI_FMT_MASK 0x000f000f

#define SPI_TXDATA_OFST 72
#define SPI_TXDATA_RSTV 0x00000000
#define SPI_TXDATA_MASK 0x800000FF

#define SPI_RXDATA_OFST 76
#define SPI_RXDATA_RSTV 0x80000000
#define SPI_RXDATA_MASK 0x800000FF

# !!! There is a change in e203 SoC as opposed to SiFive freedom-e300-arty
# !!! (SiFive assumes 3-bit register, sirv uses 4 bits)
#define SPI_TXMARK_OFST 80
#define SPI_TXMARK_RSTV 0x00000000
#define SPI_TXMARK_MASK 0x0000000F

# !!! There is a change in e203 SoC as opposed to SiFive freedom-e300-arty
# !!! (SiFive assumes 3-bit register, sirv uses 4 bits)
#define SPI_RXMARK_OFST 84
#define SPI_RXMARK_RSTV 0x00000000
#define SPI_RXMARK_MASK 0x0000000F

#define SPI_FCTRL_OFST 96
#define SPI_FCTRL_RSTV 0x00000001
#define SPI_FCTRL_MASK 0x00000001

#define SPI_FFMT_OFST 100
#define SPI_FFMT_RSTV 0x00030007
#define SPI_FFMT_MASK 0xffff3fff

#define SPI_IE_OFST 112
#define SPI_IE_RSTV 0x00000000
#define SPI_IE_MASK 0x00000003

#define SPI_IP_OFST 116
#define SPI_IP_RSTV 0x00000000
#define SPI_IP_MASK 0x00000003


test_reset_value:
    TEST_LD_ADDR       ( 1, lw, SPI_SCKDIV_RSTV,   SPI_SCKDIV_OFST,    SPI0_BASE )
    TEST_LD_ADDR       ( 2, lw, SPI_SCKMODE_RSTV,  SPI_SCKMODE_OFST,   SPI0_BASE )
    TEST_LD_ADDR       ( 3, lw, SPI_CSID_RSTV,     SPI_CSID_OFST,      SPI0_BASE )
    TEST_LD_ADDR       ( 4, lw, SPI_CSDEF_RSTV,    SPI_CSDEF_OFST,     SPI0_BASE )
    TEST_LD_ADDR       ( 5, lw, SPI_CSMODE_RSTV,   SPI_CSMODE_OFST,    SPI0_BASE )
    TEST_LD_ADDR       ( 6, lw, SPI_DELAY0_RSTV,   SPI_DELAY0_OFST,    SPI0_BASE )
    TEST_LD_ADDR       ( 7, lw, SPI_DELAY1_RSTV,   SPI_DELAY1_OFST,    SPI0_BASE )
    TEST_LD_ADDR       ( 8, lw, SPI_FMT_RSTV,      SPI_FMT_OFST,       SPI0_BASE )
    TEST_LD_ADDR       ( 9, lw, SPI_TXDATA_RSTV,   SPI_TXDATA_OFST,    SPI0_BASE )
    TEST_LD_ADDR_IGNORE(10, lw, SPI_RXDATA_RSTV,   SPI_RXDATA_OFST,    SPI0_BASE, 0xffffff00 )
    TEST_LD_ADDR       (11, lw, SPI_TXMARK_RSTV,   SPI_TXMARK_OFST,    SPI0_BASE )
    TEST_LD_ADDR       (12, lw, SPI_RXMARK_RSTV,   SPI_RXMARK_OFST,    SPI0_BASE )
    TEST_LD_ADDR       (13, lw, SPI_FCTRL_RSTV,    SPI_FCTRL_OFST,     SPI0_BASE )
    TEST_LD_ADDR       (14, lw, SPI_FFMT_RSTV,     SPI_FFMT_OFST,      SPI0_BASE )
    TEST_LD_ADDR       (15, lw, SPI_IE_RSTV,       SPI_IE_OFST,        SPI0_BASE )
    TEST_LD_ADDR       (16, lw, SPI_IP_RSTV,       SPI_IP_OFST,        SPI0_BASE )

test_read_write:
    TEST_RW_ADDR( 100, 0xFFFFFFFF, SPI_SCKDIV_MASK, SPI_SCKDIV_OFST, SPI0_BASE )
    TEST_RW_ADDR( 101, 0xaaaaaaaa, SPI_SCKDIV_MASK, SPI_SCKDIV_OFST, SPI0_BASE )
    TEST_RW_ADDR( 102, 0x55555555, SPI_SCKDIV_MASK, SPI_SCKDIV_OFST, SPI0_BASE )
    TEST_RW_ADDR( 103, 0x00000000, SPI_SCKDIV_MASK, SPI_SCKDIV_OFST, SPI0_BASE )

    TEST_RW_ADDR( 110, 0xFFFFFFFF, SPI_SCKMODE_MASK, SPI_SCKMODE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 111, 0xaaaaaaaa, SPI_SCKMODE_MASK, SPI_SCKMODE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 112, 0x55555555, SPI_SCKMODE_MASK, SPI_SCKMODE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 113, 0x00000000, SPI_SCKMODE_MASK, SPI_SCKMODE_OFST, SPI0_BASE )

    TEST_RW_ADDR( 120, 0xFFFFFFFF, SPI_CSID_MASK, SPI_CSID_OFST, SPI0_BASE )
    TEST_RW_ADDR( 121, 0xaaaaaaaa, SPI_CSID_MASK, SPI_CSID_OFST, SPI0_BASE )
    TEST_RW_ADDR( 122, 0x55555555, SPI_CSID_MASK, SPI_CSID_OFST, SPI0_BASE )
    TEST_RW_ADDR( 123, 0x00000000, SPI_CSID_MASK, SPI_CSID_OFST, SPI0_BASE )

    TEST_RW_ADDR( 130, 0xFFFFFFFF, SPI_CSDEF_MASK, SPI_CSDEF_OFST, SPI0_BASE )
    TEST_RW_ADDR( 131, 0xaaaaaaaa, SPI_CSDEF_MASK, SPI_CSDEF_OFST, SPI0_BASE )
    TEST_RW_ADDR( 132, 0x55555555, SPI_CSDEF_MASK, SPI_CSDEF_OFST, SPI0_BASE )
    TEST_RW_ADDR( 133, 0x00000000, SPI_CSDEF_MASK, SPI_CSDEF_OFST, SPI0_BASE )

    TEST_RW_ADDR( 140, 0xFFFFFFFF, SPI_CSMODE_MASK, SPI_CSMODE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 141, 0xaaaaaaaa, SPI_CSMODE_MASK, SPI_CSMODE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 142, 0x55555555, SPI_CSMODE_MASK, SPI_CSMODE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 143, 0x00000000, SPI_CSMODE_MASK, SPI_CSMODE_OFST, SPI0_BASE )

    TEST_RW_ADDR( 150, 0xFFFFFFFF, SPI_DELAY0_MASK, SPI_DELAY0_OFST, SPI0_BASE )
    TEST_RW_ADDR( 151, 0xaaaaaaaa, SPI_DELAY0_MASK, SPI_DELAY0_OFST, SPI0_BASE )
    TEST_RW_ADDR( 152, 0x55555555, SPI_DELAY0_MASK, SPI_DELAY0_OFST, SPI0_BASE )
    TEST_RW_ADDR( 153, 0x00000000, SPI_DELAY0_MASK, SPI_DELAY0_OFST, SPI0_BASE )

    TEST_RW_ADDR( 160, 0xFFFFFFFF, SPI_DELAY1_MASK, SPI_DELAY1_OFST, SPI0_BASE )
    TEST_RW_ADDR( 161, 0xaaaaaaaa, SPI_DELAY1_MASK, SPI_DELAY1_OFST, SPI0_BASE )
    TEST_RW_ADDR( 162, 0x55555555, SPI_DELAY1_MASK, SPI_DELAY1_OFST, SPI0_BASE )
    TEST_RW_ADDR( 163, 0x00000000, SPI_DELAY1_MASK, SPI_DELAY1_OFST, SPI0_BASE )

    TEST_RW_ADDR( 170, 0xFFFFFFFF, SPI_FCTRL_MASK, SPI_FCTRL_OFST, SPI0_BASE )
    TEST_RW_ADDR( 171, 0xaaaaaaaa, SPI_FCTRL_MASK, SPI_FCTRL_OFST, SPI0_BASE )
    TEST_RW_ADDR( 172, 0x55555555, SPI_FCTRL_MASK, SPI_FCTRL_OFST, SPI0_BASE )
    TEST_RW_ADDR( 173, 0x00000000, SPI_FCTRL_MASK, SPI_FCTRL_OFST, SPI0_BASE )

    TEST_RW_ADDR( 180, 0xFFFFFFFF, SPI_FFMT_MASK, SPI_FFMT_OFST, SPI0_BASE )
    TEST_RW_ADDR( 181, 0xaaaaaaaa, SPI_FFMT_MASK, SPI_FFMT_OFST, SPI0_BASE )
    TEST_RW_ADDR( 182, 0x55555555, SPI_FFMT_MASK, SPI_FFMT_OFST, SPI0_BASE )
    TEST_RW_ADDR( 183, 0x00000000, SPI_FFMT_MASK, SPI_FFMT_OFST, SPI0_BASE )

    TEST_RW_ADDR( 190, 0xFFFFFFFF, SPI_IE_MASK, SPI_IE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 191, 0xaaaaaaaa, SPI_IE_MASK, SPI_IE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 192, 0x55555555, SPI_IE_MASK, SPI_IE_OFST, SPI0_BASE )
    TEST_RW_ADDR( 193, 0x00000000, SPI_IE_MASK, SPI_IE_OFST, SPI0_BASE )

    TEST_RO_ADDR( 200, 0xFFFFFFFF, SPI_IP_RSTV, SPI_IP_OFST, SPI0_BASE )
    TEST_RO_ADDR( 201, 0xaaaaaaaa, SPI_IP_RSTV, SPI_IP_OFST, SPI0_BASE )
    TEST_RO_ADDR( 202, 0x55555555, SPI_IP_RSTV, SPI_IP_OFST, SPI0_BASE )
    TEST_RO_ADDR( 203, 0x00000000, SPI_IP_RSTV, SPI_IP_OFST, SPI0_BASE )

    TEST_RO_ADDR_IGNORE( 210, 0xFFFFFFFF, SPI_RXDATA_RSTV, SPI_RXDATA_OFST, SPI0_BASE, 0xffffff00 )
    TEST_RO_ADDR_IGNORE( 211, 0xaaaaaaaa, SPI_RXDATA_RSTV, SPI_RXDATA_OFST, SPI0_BASE, 0xffffff00 )
    TEST_RO_ADDR_IGNORE( 212, 0x55555555, SPI_RXDATA_RSTV, SPI_RXDATA_OFST, SPI0_BASE, 0xffffff00 )
    TEST_RO_ADDR_IGNORE( 213, 0x00000000, SPI_RXDATA_RSTV, SPI_RXDATA_OFST, SPI0_BASE, 0xffffff00 )

    TEST_RW_ADDR( 220, 0xFFFFFFFF, SPI_RXMARK_MASK, SPI_RXMARK_OFST, SPI0_BASE )
    TEST_RW_ADDR( 221, 0xaaaaaaaa, SPI_RXMARK_MASK, SPI_RXMARK_OFST, SPI0_BASE )
    TEST_RW_ADDR( 222, 0x55555555, SPI_RXMARK_MASK, SPI_RXMARK_OFST, SPI0_BASE )
    TEST_RW_ADDR( 223, 0x00000000, SPI_RXMARK_MASK, SPI_RXMARK_OFST, SPI0_BASE )

    TEST_RW_ADDR( 230, 0xFFFFFFFF, SPI_TXMARK_MASK, SPI_TXMARK_OFST, SPI0_BASE )
    TEST_RW_ADDR( 231, 0xaaaaaaaa, SPI_TXMARK_MASK, SPI_TXMARK_OFST, SPI0_BASE )
    TEST_RW_ADDR( 232, 0x55555555, SPI_TXMARK_MASK, SPI_TXMARK_OFST, SPI0_BASE )
    TEST_RW_ADDR( 233, 0x00000000, SPI_TXMARK_MASK, SPI_TXMARK_OFST, SPI0_BASE )

test_cmd_tx:
    # initialize registers
    li t4, SPI0_BASE
    li t5, -1
    sw t5, SPI_CSDEF_OFST(t4)   # default CS to high
    sw x0, SPI_SCKDIV_OFST(t4)  # SCK = CLK div 2
    sw x0, SPI_CSMODE_OFST(t4)  # AUTO chip select control
    sw x0, SPI_FCTRL_OFST(t4)   # switch to non-mapped mode
    sw x0, SPI_IE_OFST(t4)      # disable interrupts
    li t5, 0x00080008
    sw t5, SPI_FMT_OFST(t4)     # Tx, 8 bits, single mode
    sw x0, SPI_DELAY0_OFST(t4)  # no delay
    sw x0, SPI_DELAY1_OFST(t4)  # no delay

    # send data bytes
    li t5, 0x000000AA
    sw t5, SPI_TXDATA_OFST(t4)
    li t5, 0x00000000
    sw t5, SPI_TXDATA_OFST(t4)
    li t5, 0x00000055
    sw t5, SPI_TXDATA_OFST(t4)

    # Wait loop
    li t5, 0x00000064
1:  addi t5,t5,-1
    bgez t5,1b
    

    # Dummy ops
    li a1, 0xAA55A55A

    # Test End
#   li TESTNUM, 1
    TEST_PASSFAIL


RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN

TEST_DATA

#data1: .word 0
#data2: .word 0

RVTEST_DATA_END
