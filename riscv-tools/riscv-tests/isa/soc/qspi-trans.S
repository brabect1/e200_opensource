# See LICENSE for license details.
#
# Description:
#   This test exercises simple transactions to an SPI flash device model. The
#   transactions are executed through the SPI master interface (i.e. the other
#   than the flash interface available for QSPI0).

#include "riscv_test.h"
#undef RVTEST_RV64M
#define RVTEST_RV64M RVTEST_RV32M

#include "test_macros.h"
#include "soc.h"


RVTEST_RV32M
RVTEST_CODE_BEGIN

#define SPI_CMD_LOOP 0xff
#define SPI_CMD_READ 0x03
#define SPI_CMD_FAST_READ 0x0b

#ifndef SPI_BASE
#define SPI_BASE SPI0_BASE
#endif

#define SPI_SET_DIR( BASE, DIR ) \
    .set mask,(1 << SPI_BIT_FMT_DIR) ^ 0xffffffff; \
    .set val, (DIR << SPI_BIT_FMT_DIR); \
    li t4,BASE; \
    lw t5,SPI_FMT_OFST(t4); \
    andi t5,t5,mask; \
    ori t5,t5,val; \
    sw t5,SPI_FMT_OFST(t4);

#define SPI_SET_CS( BASE, VAL, CSID ) \
    .set mask,(1 << CSID) ^ 0xffffffff; \
    .set val, (VAL << CSID); \
    li t4,BASE; \
    lw t5,SPI_CSDEF_OFST(t4); \
    andi t5,t5,mask; \
    ori t5,t5,val; \
    sw t5,SPI_CSDEF_OFST(t4);

# Wait loop (set to the expected number of cycles + some overhead)
#define SPI_TX_WAIT( DIV, BYTES ) \
    .set cycles,BYTES*8*(2*(DIV+1)) + 50; \
    li t5,cycles; \
1:  addi t5,t5,-1; \
    bgez t5,1b;

# -----------------------------------------------
# Test the QSPI (manual CS control)
# -----------------------------------------------

    # settings
    li t4,SPI_BASE
    sw x0,SPI_IE_OFST(t4)       # disable interrupts
    sw x0,SPI_FCTRL_OFST(t4)    # switch to non-mapped mode
    sw x0,SPI_SCKDIV_OFST(t4)   # set SCK divisor (using 0 for fastest speed)
    li t5,1
    sw t5,SPI_TXMARK_OFST(t4)     # set TX watermark
    li t5,SPI_CSMODE_OFF
    sw t5,SPI_CSMODE_OFST(t4) # set manual CS control

    # set single data transfer, msb first, 8 bits
    .set fmt, 0
    .set fmt, fmt | (SPI_PROTO_SINGLE << SPI_BIT_FMT_PROTO)
    .set fmt, fmt | (8 << SPI_BIT_FMT_LEN)
    .set fmt, fmt | (SPI_ENDIAN_MSBF << SPI_BIT_FMT_ENDIAN)
    li t5,fmt
    sw t5,SPI_FMT_OFST(t4)

test_cmd_read_cmd:
    SPI_SET_DIR( SPI_BASE, SPI_DIR_TX )
    # CS assert
    SPI_SET_CS( SPI_BASE, 0, 0 )
    # set command (READ) + address (0)
    li t4,SPI_BASE
    li t5,SPI_CMD_READ
    sw t5,SPI_TXDATA_OFST(t4)
    sw x0,SPI_TXDATA_OFST(t4)
    sw x0,SPI_TXDATA_OFST(t4)
    sw x0,SPI_TXDATA_OFST(t4)

    SPI_TX_WAIT( 0, 4)

    # check TX buffer empty (txwm interrupt pending)
    TEST_LD_ADDR_IGNORE( 1, lw, 0x00000001, SPI_IP_OFST, SPI_BASE, 1 )

    # check RX buffer empty
    TEST_LD_ADDR_IGNORE( 2, lw, 0x80000000, SPI_RXDATA_OFST, SPI_BASE, 0xffffff00 )

test_cmd_read_data:
    SPI_SET_DIR( SPI_BASE, SPI_DIR_RX )
    # set command (READ) + address (0)
    li t4,SPI_BASE
    sw x0,SPI_TXDATA_OFST(t4)
    sw x0,SPI_TXDATA_OFST(t4)
    sw x0,SPI_TXDATA_OFST(t4)
    sw x0,SPI_TXDATA_OFST(t4)

    # check no TXWM interrupt pending
    TEST_LD_ADDR_IGNORE( 3, lw, 0x00000000, SPI_IP_OFST, SPI_BASE, 1 )

    SPI_TX_WAIT( 0, 4 )

    # CS deassert
    SPI_SET_CS( SPI_BASE, 1, 0 )

    # check txwm and rxwm interrupts pending
    TEST_LD_ADDR_IGNORE( 5, lw, 0x00000003, SPI_IP_OFST, SPI_BASE, 3 )

    # check RX buffer
    TEST_LD_ADDR       ( 6, lw, 0x000000aa, SPI_RXDATA_OFST, SPI_BASE )
    TEST_LD_ADDR       ( 7, lw, 0x00000055, SPI_RXDATA_OFST, SPI_BASE )
    TEST_LD_ADDR       ( 8, lw, 0x00000081, SPI_RXDATA_OFST, SPI_BASE )
    TEST_LD_ADDR       ( 9, lw, 0x0000000f, SPI_RXDATA_OFST, SPI_BASE )

    # check RX buffer empty
    TEST_LD_ADDR_IGNORE(10, lw, 0x80000000, SPI_RXDATA_OFST, SPI_BASE, 0xffffff00 )

    TEST_PASSFAIL


RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN

TEST_DATA

#data1: .word 0
#data2: .word 0

RVTEST_DATA_END
