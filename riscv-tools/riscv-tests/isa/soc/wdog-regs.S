# Copyright 2018 Tomas Brabec
#
# See LICENSE for license details.

#include "riscv_test.h"
#undef RVTEST_RV64M
#define RVTEST_RV64M RVTEST_RV32M

#include "test_macros.h"
#include "soc.h"

#define TEST_WDOG_RW_ADDR( testnum, value, mask, offset, base ) \
      .set myres,value & mask; \
    TEST_CASE( testnum, x30, myres, \
      li  x1, base; \
      li  x30,WDOG_KEY_VALUE; \
      sw  x30,WDOG_KEY_OFST(x1); \
      li  x30,value; \
      sw x30, offset(x1); \
      lw x30, offset(x1); \
    )

#define TEST_WDOG_RW_ADDR_IGNORE( testnum, value, mask, offset, base, ignmask ) \
      .set myres,value & mask & ignmask; \
    TEST_CASE( testnum, x30, myres, \
      li  x1, base; \
      li  x30,WDOG_KEY_VALUE; \
      sw  x30,WDOG_KEY_OFST(x1); \
      li  x30,value; \
      sw x30, offset(x1); \
      lw x30, offset(x1); \
      li x29,ignmask; \
      and x30,x30,x29; \
    )

#define TEST_WDOG_RO_ADDR( testnum, value, expected, offset, base ) \
    TEST_CASE( testnum, x30, expected, \
      li  x1, base; \
      li  x30,WDOG_KEY_VALUE; \
      sw  x30,WDOG_KEY_OFST(x1); \
      li  x30,value; \
      sw x30, offset(x1); \
      lw x30, offset(x1); \
    )

RVTEST_RV32M
RVTEST_CODE_BEGIN

# -----------------------------------------------
# Test the WDT (Watchdog Timer)
# -----------------------------------------------

test_reset_value:
    TEST_LD_ADDR       ( 1, lw, WDOG_CFG_RSTV,    WDOG_CFG_OFST,    AON_BASE )
    TEST_LD_ADDR       ( 2, lw, WDOG_CNT_RSTV,    WDOG_CNT_OFST,    AON_BASE )
    TEST_LD_ADDR       ( 3, lw, WDOG_SCALED_RSTV, WDOG_SCALED_OFST, AON_BASE )
    TEST_LD_ADDR       ( 4, lw, WDOG_CMP_RSTV,    WDOG_CMP_OFST,    AON_BASE )
    TEST_LD_ADDR       ( 5, lw, WDOG_KEY_RSTV,    WDOG_KEY_OFST,    AON_BASE )
    TEST_LD_ADDR       ( 6, lw, WDOG_FEED_RSTV,   WDOG_FEED_OFST,   AON_BASE )

test_read_write:
    TEST_RO_ADDR( 100, 0xFFFFFFFF, WDOG_KEY_RSTV, WDOG_KEY_OFST, AON_BASE )
    TEST_RO_ADDR( 101, 0xaaaaaaaa, WDOG_KEY_RSTV, WDOG_KEY_OFST, AON_BASE )
    TEST_RO_ADDR( 102, 0x55555555, WDOG_KEY_RSTV, WDOG_KEY_OFST, AON_BASE )
    TEST_RO_ADDR( 103, 0x00000000, WDOG_KEY_RSTV, WDOG_KEY_OFST, AON_BASE )

    # Note that we intentionally set the last exercised CMP value to all ones.
    # This is to avoid triggering a reset event later on when exercising the
    # Configuration register.
    TEST_WDOG_RW_ADDR( 110, 0xaaaaaaaa, WDOG_CMP_MASK, WDOG_CMP_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 111, 0x55555555, WDOG_CMP_MASK, WDOG_CMP_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 112, 0x00000000, WDOG_CMP_MASK, WDOG_CMP_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 113, 0xFFFFFFFF, WDOG_CMP_MASK, WDOG_CMP_OFST, AON_BASE )

    TEST_WDOG_RO_ADDR( 120, 0xFFFFFFFF, WDOG_SCALED_RSTV, WDOG_SCALED_OFST, AON_BASE )
    TEST_WDOG_RO_ADDR( 121, 0xaaaaaaaa, WDOG_SCALED_RSTV, WDOG_SCALED_OFST, AON_BASE )
    TEST_WDOG_RO_ADDR( 122, 0x55555555, WDOG_SCALED_RSTV, WDOG_SCALED_OFST, AON_BASE )
    TEST_WDOG_RO_ADDR( 123, 0x00000000, WDOG_SCALED_RSTV, WDOG_SCALED_OFST, AON_BASE )

    TEST_WDOG_RW_ADDR( 130, 0xFFFFFFFF, WDOG_CNT_MASK, WDOG_CNT_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 131, 0xaaaaaaaa, WDOG_CNT_MASK, WDOG_CNT_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 132, 0x55555555, WDOG_CNT_MASK, WDOG_CNT_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 133, 0x00000000, WDOG_CNT_MASK, WDOG_CNT_OFST, AON_BASE )

    TEST_WDOG_RO_ADDR( 140, 0xFFFFFFFF, WDOG_FEED_RSTV, WDOG_FEED_OFST, AON_BASE )
    TEST_WDOG_RO_ADDR( 141, 0xaaaaaaaa, WDOG_FEED_RSTV, WDOG_FEED_OFST, AON_BASE )
    TEST_WDOG_RO_ADDR( 142, 0x55555555, WDOG_FEED_RSTV, WDOG_FEED_OFST, AON_BASE )
    TEST_WDOG_RO_ADDR( 143, 0x00000000, WDOG_FEED_RSTV, WDOG_FEED_OFST, AON_BASE )

    # As the IP (interrupt pending) bit is read/write, we do not need to make any
    # exceptions here.
    TEST_WDOG_RW_ADDR( 150, 0xFFFFFFFF, WDOG_CFG_MASK, WDOG_CFG_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 151, 0xaaaaaaaa, WDOG_CFG_MASK, WDOG_CFG_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 152, 0x55555555, WDOG_CFG_MASK, WDOG_CFG_OFST, AON_BASE )
    TEST_WDOG_RW_ADDR( 153, 0x00000000, WDOG_CFG_MASK, WDOG_CFG_OFST, AON_BASE )

test_feed:
    # set non-zero counter value
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    .set val,0x0f
    li t5, val
    sw t3, WDOG_KEY_OFST(t4)
    sw t5, WDOG_CNT_OFST(t4)

    TEST_LD_ADDR       ( 200, lw, val,  WDOG_CNT_OFST, AON_BASE )

    # feed watchdog
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    li t5, WDOG_FEED_VALUE
    sw t3, WDOG_KEY_OFST(t4)
    sw t5, WDOG_FEED_OFST(t4)

    TEST_LD_ADDR       ( 201, lw, 0,  WDOG_CNT_OFST, AON_BASE )

test_interrupt_pending:
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    sw t3, WDOG_KEY_OFST(t4)
    sw x0, WDOG_CFG_OFST(t4)
    sw t3, WDOG_KEY_OFST(t4)
    sw x0, WDOG_CNT_OFST(t4)
    li t5, 1
    sw t3, WDOG_KEY_OFST(t4)
    sw t5, WDOG_CMP_OFST(t4)

    # test IP cleared
    TEST_LD_ADDR       ( 210, lw, 0,  WDOG_CFG_OFST, AON_BASE )

    # test IP sets when CNT >= CMP
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    li t5, 1
    sw t3, WDOG_KEY_OFST(t4)
    sw t5, WDOG_CNT_OFST(t4)

    TEST_LD_ADDR       ( 211, lw, 0x10000000,  WDOG_CFG_OFST, AON_BASE )

    # tests IP does not clear on writing 0 and CNT >= CMP
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    sw t3, WDOG_KEY_OFST(t4)
    sw x0, WDOG_CFG_OFST(t4)

    TEST_LD_ADDR       ( 212, lw, 0x10000000,  WDOG_CFG_OFST, AON_BASE )

    # test IP remains asserted when CNT < CMP
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    sw t3, WDOG_KEY_OFST(t4)
    sw x0, WDOG_CNT_OFST(t4)

    TEST_LD_ADDR       ( 213, lw, 0x10000000,  WDOG_CFG_OFST, AON_BASE )

    # tests IP clears on writing 0 (and CNT < CMP)
    li t4, AON_BASE
    li t3, WDOG_KEY_VALUE
    sw t3, WDOG_KEY_OFST(t4)
    sw x0, WDOG_CFG_OFST(t4)

    TEST_LD_ADDR       ( 214, lw, 0x00000000,  WDOG_CFG_OFST, AON_BASE )


    # Test End
    TEST_PASSFAIL


RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN

TEST_DATA

#data1: .word 0
#data2: .word 0

RVTEST_DATA_END

