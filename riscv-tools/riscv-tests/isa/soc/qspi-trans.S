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
#define SPI_CMD_FAST_READ_S 0x0b
#define SPI_CMD_FAST_READ_D 0x3b
#define SPI_CMD_FAST_READ_Q 0x6b

#ifndef SPI_BASE
#define SPI_BASE SPI0_BASE
#endif

#define SPI_SET_PROTO( BASE, PROTO  ) \
    .set mask,SPI_MASK_FMT_PROTO ^ 0xffffffff; \
    .set val, (PROTO << SPI_BIT_FMT_PROTO); \
    li t4,BASE; \
    lw t5,SPI_FMT_OFST(t4); \
    andi t5,t5,mask; \
    ori t5,t5,val; \
    sw t5,SPI_FMT_OFST(t4);

#define SPI_SET_DIR( BASE, DIR ) \
    .set mask,SPI_MASK_FMT_DIR ^ 0xffffffff; \
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

#define _TEST_LD_ADDR( testnum, inst, result, offset, base ) \
    li  x1, base; \
    inst x30, offset(x1); \
    li  x29, MASK_XLEN(result); \
    li  TESTNUM, testnum; \
    bne x30, x29, fail;

#define _TEST_LD_ADDR_IGNORE( testnum, inst, result, offset, base, mask ) \
    li  x1, base; \
    inst x30, offset(x1); \
    andi x30,x30, mask; \
    li  x29, MASK_XLEN(result); \
    li  TESTNUM, testnum; \
    bne x30, x29, fail;

# Read 4 bytes from SPI device address 0
# (command and address are sent in a single mode, data is received
# in the specified mode (PROTO))
#define TEST_SPI_READ( TESTNUM_BASE, CMD, PROTO ) \
    .set tnum,TESTNUM_BASE; \
    /* set single data transfer, msb first, 8 bits */ \
    .set fmt, 0; \
    .set fmt, fmt | (SPI_PROTO_SINGLE << SPI_BIT_FMT_PROTO); \
    .set fmt, fmt | (8 << SPI_BIT_FMT_LEN); \
    .set fmt, fmt | (SPI_ENDIAN_MSBF << SPI_BIT_FMT_ENDIAN); \
    li t4,SPI_BASE; \
    li t5,fmt; \
    sw t5,SPI_FMT_OFST(t4); \
                            \
    /* TX command + address */ \
    /* -------------------- */ \
    SPI_SET_DIR( SPI_BASE, SPI_DIR_TX ) \
    /* CS assert */ \
    SPI_SET_CS( SPI_BASE, 0, 0 ) \
    /* set command (READ) + address (0) */ \
    li t4,SPI_BASE; \
    li t5,CMD; \
    sw t5,SPI_TXDATA_OFST(t4); \
    sw x0,SPI_TXDATA_OFST(t4); \
    sw x0,SPI_TXDATA_OFST(t4); \
    sw x0,SPI_TXDATA_OFST(t4); \
\
    SPI_TX_WAIT( 0, 4) \
\
    /* check TX buffer empty (txwm interrupt pending) */ \
    _TEST_LD_ADDR_IGNORE( tnum, lw, 0x00000001, SPI_IP_OFST, SPI_BASE, 1 ) \
    .set tnum, tnum+1; \
\
    /* check RX buffer empty */ \
    _TEST_LD_ADDR_IGNORE( tnum, lw, 0x80000000, SPI_RXDATA_OFST, SPI_BASE, 0xffffff00 ) \
    .set tnum, tnum+1; \
\
    /* Receive data */ \
    /* ------------ */ \
    SPI_SET_DIR( SPI_BASE, SPI_DIR_RX ) \
    SPI_SET_PROTO( SPI_BASE, PROTO ) \
    /* set command (READ) + address (0) */ \
    li t4,SPI_BASE; \
    sw x0,SPI_TXDATA_OFST(t4); \
    sw x0,SPI_TXDATA_OFST(t4); \
    sw x0,SPI_TXDATA_OFST(t4); \
    sw x0,SPI_TXDATA_OFST(t4); \
\
    /* check no TXWM interrupt pending */ \
    _TEST_LD_ADDR_IGNORE( tnum, lw, 0x00000000, SPI_IP_OFST, SPI_BASE, 1 ) \
    .set tnum, tnum+1; \
\
    SPI_TX_WAIT( 0, 4 ) \
\
    /* CS deassert */ \
    SPI_SET_CS( SPI_BASE, 1, 0 ) \
\
    /* check txwm and rxwm interrupts pending */ \
    _TEST_LD_ADDR_IGNORE( tnum, lw, 0x00000003, SPI_IP_OFST, SPI_BASE, 3 ) \
    .set tnum, tnum+1; \
\
    /* check RX buffer */ \
    _TEST_LD_ADDR       ( tnum, lw, 0x000000aa, SPI_RXDATA_OFST, SPI_BASE ) \
    .set tnum, tnum+1; \
    _TEST_LD_ADDR       ( tnum, lw, 0x00000055, SPI_RXDATA_OFST, SPI_BASE ) \
    .set tnum, tnum+1; \
    _TEST_LD_ADDR       ( tnum, lw, 0x00000081, SPI_RXDATA_OFST, SPI_BASE ) \
    .set tnum, tnum+1; \
    _TEST_LD_ADDR       ( tnum, lw, 0x0000000f, SPI_RXDATA_OFST, SPI_BASE ) \
    .set tnum, tnum+1; \
\
    /* check RX buffer empty */ \
    _TEST_LD_ADDR_IGNORE( tnum, lw, 0x80000000, SPI_RXDATA_OFST, SPI_BASE, 0xffffff00 )

# -----------------------------------------------
# Test the QSPI (manual CS control)
# -----------------------------------------------

    # settings
    li t4,SPI_BASE
    sw x0,SPI_IE_OFST(t4)       # disable interrupts
    sw x0,SPI_FCTRL_OFST(t4)    # switch to non-mapped mode
    sw x0,SPI_SCKDIV_OFST(t4)   # set SCK divisor (using 0 for fastest speed)
    li t5,1
    sw t5,SPI_TXMARK_OFST(t4)   # set TX watermark
    li t5,SPI_CSMODE_OFF
    sw t5,SPI_CSMODE_OFST(t4)   # set manual CS control

    TEST_SPI_READ( 1, SPI_CMD_READ, SPI_PROTO_SINGLE )
    TEST_SPI_READ( 10, SPI_CMD_FAST_READ_S, SPI_PROTO_SINGLE )
    TEST_SPI_READ( 20, SPI_CMD_FAST_READ_D, SPI_PROTO_DUAL )
    TEST_SPI_READ( 30, SPI_CMD_FAST_READ_Q, SPI_PROTO_QUAD )

    TEST_PASSFAIL


RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN

TEST_DATA

#data1: .word 0
#data2: .word 0

RVTEST_DATA_END
