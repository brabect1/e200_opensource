# Copyright 2019 Tomas Brabec
#
# See LICENSE for license details.

#include "riscv_test.h"
#undef RVTEST_RV64M
#define RVTEST_RV64M RVTEST_RV32M

#include "test_macros.h"

# Need to define PWM_CMPWIDTH prior including soc.h
#define PWM_CMPWIDTH 8
#include "soc.h"

#define PWM_BASE PWM0_BASE

RVTEST_RV32M
RVTEST_CODE_BEGIN

# -----------------------------------------------
# Test the PWM0
# -----------------------------------------------

test_reset_value:
    TEST_LD_ADDR       ( 1, lw, PWM_CFG_RSTV,      PWM_CFG_OFST,       PWM_BASE )
    TEST_LD_ADDR       ( 2, lw, PWM_CNT_RSTV,      PWM_CNT_OFST,       PWM_BASE )
    TEST_LD_ADDR       ( 3, lw, PWM_SCALED_RSTV,   PWM_SCALED_OFST,    PWM_BASE )
    TEST_LD_ADDR       ( 4, lw, PWM_CMP0_RSTV,     PWM_CMP0_OFST,      PWM_BASE )
    TEST_LD_ADDR       ( 5, lw, PWM_CMP1_RSTV,     PWM_CMP1_OFST,      PWM_BASE )
    TEST_LD_ADDR       ( 6, lw, PWM_CMP2_RSTV,     PWM_CMP2_OFST,      PWM_BASE )
    TEST_LD_ADDR       ( 7, lw, PWM_CMP3_RSTV,     PWM_CMP3_OFST,      PWM_BASE )

test_read_write:
    TEST_RO_ADDR( 100, 0xaaaaaaaa, PWM_SCALED_RSTV, PWM_SCALED_OFST, PWM_BASE )
    TEST_RO_ADDR( 101, 0x55555555, PWM_SCALED_RSTV, PWM_SCALED_OFST, PWM_BASE )
    TEST_RO_ADDR( 102, 0x00000000, PWM_SCALED_RSTV, PWM_SCALED_OFST, PWM_BASE )
    TEST_RO_ADDR( 103, 0xFFFFFFFF, PWM_SCALED_RSTV, PWM_SCALED_OFST, PWM_BASE )

    TEST_RW_ADDR( 110, 0xFFFFFFFF, PWM_CNT_MASK, PWM_CNT_OFST, PWM_BASE )
    TEST_RW_ADDR( 111, 0xaaaaaaaa, PWM_CNT_MASK, PWM_CNT_OFST, PWM_BASE )
    TEST_RW_ADDR( 112, 0x55555555, PWM_CNT_MASK, PWM_CNT_OFST, PWM_BASE )
    TEST_RW_ADDR( 113, 0x00000000, PWM_CNT_MASK, PWM_CNT_OFST, PWM_BASE )

    # Intentionally make the last write test the largest value so that later
    # when testing the CFG register we use the longest PWM cycle.
    TEST_RW_ADDR( 120, 0xaaaaaaaa, PWM_CMP0_MASK, PWM_CMP0_OFST, PWM_BASE )
    TEST_RW_ADDR( 121, 0x55555555, PWM_CMP0_MASK, PWM_CMP0_OFST, PWM_BASE )
    TEST_RW_ADDR( 122, 0x00000000, PWM_CMP0_MASK, PWM_CMP0_OFST, PWM_BASE )
    TEST_RW_ADDR( 123, 0xFFFFFFFF, PWM_CMP0_MASK, PWM_CMP0_OFST, PWM_BASE )

    TEST_RW_ADDR( 130, 0xaaaaaaaa, PWM_CMP1_MASK, PWM_CMP1_OFST, PWM_BASE )
    TEST_RW_ADDR( 131, 0x55555555, PWM_CMP1_MASK, PWM_CMP1_OFST, PWM_BASE )
    TEST_RW_ADDR( 132, 0x00000000, PWM_CMP1_MASK, PWM_CMP1_OFST, PWM_BASE )
    TEST_RW_ADDR( 133, 0xFFFFFFFF, PWM_CMP1_MASK, PWM_CMP1_OFST, PWM_BASE )

    TEST_RW_ADDR( 140, 0xaaaaaaaa, PWM_CMP2_MASK, PWM_CMP2_OFST, PWM_BASE )
    TEST_RW_ADDR( 141, 0x55555555, PWM_CMP2_MASK, PWM_CMP2_OFST, PWM_BASE )
    TEST_RW_ADDR( 142, 0x00000000, PWM_CMP2_MASK, PWM_CMP2_OFST, PWM_BASE )
    TEST_RW_ADDR( 143, 0xFFFFFFFF, PWM_CMP2_MASK, PWM_CMP2_OFST, PWM_BASE )

    TEST_RW_ADDR( 150, 0xaaaaaaaa, PWM_CMP3_MASK, PWM_CMP3_OFST, PWM_BASE )
    TEST_RW_ADDR( 151, 0x55555555, PWM_CMP3_MASK, PWM_CMP3_OFST, PWM_BASE )
    TEST_RW_ADDR( 152, 0x00000000, PWM_CMP3_MASK, PWM_CMP3_OFST, PWM_BASE )
    TEST_RW_ADDR( 153, 0xFFFFFFFF, PWM_CMP3_MASK, PWM_CMP3_OFST, PWM_BASE )

    # Certain bits have side effects that may go effective with a too short
    # PWM cycle. We hence assume the CMPx register have been set large enough.
    # Also we ignore the state of IPx configuration/status bits as these need
    # too be exercised separately.
    TEST_RW_ADDR_IGNORE( 160, 0xFFFFFFFF, PWM_CFG_MASK, PWM_CFG_OFST, PWM_BASE, 0x00FFFFFF )
    TEST_RW_ADDR_IGNORE( 161, 0xaaaaaaaa, PWM_CFG_MASK, PWM_CFG_OFST, PWM_BASE, 0x00FFFFFF )
    TEST_RW_ADDR_IGNORE( 162, 0x55555555, PWM_CFG_MASK, PWM_CFG_OFST, PWM_BASE, 0x00FFFFFF )
    TEST_RW_ADDR_IGNORE( 163, 0x00000000, PWM_CFG_MASK, PWM_CFG_OFST, PWM_BASE, 0x00FFFFFF )

    # The following will test IPx flags in the CFG register. The flags can be
    # read and written, but the write is specific. If the IP status is not
    # sticky, then the written value is immediately overwritten with the
    # actual state of compare results.
test_cfg_ip:
    li   t5, PWM_BASE
    li   t4, 1
    sw   t4, PWM_CMP0_OFST(t5)
    slli t4,t4,1
    sw   t4, PWM_CMP1_OFST(t5)
    slli t4,t4,1
    sw   t4, PWM_CMP2_OFST(t5)
    slli t4,t4,1
    sw   t4, PWM_CMP3_OFST(t5)
    sw   x0, PWM_CNT_OFST(t5)
    sw   x0, PWM_CFG_OFST(t5)

    # With the above setting we shall read 0 from the CFG register.
    TEST_LD_ADDR       ( 200, lw, 0x00000000, PWM_CFG_OFST, PWM_BASE )

    # Test setting IP0 by compare
    li   t4, 1
    li   t5, PWM_BASE
    sw   t4, PWM_CNT_OFST(t5)
    TEST_LD_ADDR       ( 210, lw, 0x10000000, PWM_CFG_OFST, PWM_BASE )

    # Test setting IP0-1 by compare
    li   t4, 2
    li   t5, PWM_BASE
    sw   t4, PWM_CNT_OFST(t5)
    TEST_LD_ADDR       ( 211, lw, 0x30000000, PWM_CFG_OFST, PWM_BASE )

    # Test setting IP0-2 by compare
    li   t4, 4
    li   t5, PWM_BASE
    sw   t4, PWM_CNT_OFST(t5)
    TEST_LD_ADDR       ( 212, lw, 0x70000000, PWM_CFG_OFST, PWM_BASE )

    # Test setting IP0-3 by compare
    li   t4, 8
    li   t5, PWM_BASE
    sw   t4, PWM_CNT_OFST(t5)
    TEST_LD_ADDR       ( 213, lw, 0xF0000000, PWM_CFG_OFST, PWM_BASE )

    # Test clearing IP0-3 by compare
    li   t5, PWM_BASE
    sw   x0, PWM_CNT_OFST(t5)
    TEST_LD_ADDR       ( 214, lw, 0x00000000, PWM_CFG_OFST, PWM_BASE )

    # Test sticky IP status by setting and clearing IP0-3 by writing CFG.
    # (IMPORTANT: The implementation is such that there is an extra flop
    # for the sticky flag and hence the flag need to be set before changing
    # the IP bits)
test_cfg_ip_sticky:
    .set sticky, 1 << PWM_BIT_CFG_STICKY
    li   t5, PWM_BASE
    ori  t4,x0,sticky
    sw   t4,  PWM_CFG_OFST(t5)      # setting the sticky flag
    li   t4, 0xF0000000
    ori  t4,t4,sticky
    sw   t4,  PWM_CFG_OFST(t5)      # setting IPx bits
    lw   t3, PWM_CFG_OFST(t5)      # reading IPx bits
    li   TESTNUM, 220
    bne  t3, t4, fail              # expect IPx all set

    li   t5, PWM_BASE
    ori  t4,x0,sticky
    sw   t4,  PWM_CFG_OFST(t5)      # clearing IPx bits
    lw   t3, PWM_CFG_OFST(t5)      # reading IPx bits
    li   TESTNUM, 221
    bne  t3, t4, fail              # expect IPx all clear

    # Test sticky IP status by compare.
    # (We assume the sticky bit has been already set.)
    li   t4, 8
    li   t5, PWM_BASE
    sw   t4, PWM_CNT_OFST(t5)
    sw   x0, PWM_CNT_OFST(t5)
    li   t4, 0xF0000000
    ori  t4,t4,sticky
    lw   t3, PWM_CFG_OFST(t5)
    li   TESTNUM, 222
    bne  t3, t4, fail

    # This will test all CFG.SCALE values. The idea is to set CNT to some value and
    # then change CFG.SCALE and read the scaled value back through SCALED (PWMS).
test_cfg_scale:
    .set cnt_val,0x89ABDCEF & PWM_CNT_MASK
    li   t2,230
    li   t5, PWM_BASE
    addi t4,x0,0x0F
    sw   t4, PWM_CFG_OFST(t5)
    li   t4, cnt_val
    sw   t4, PWM_CNT_OFST(t5)
1:  li   t5, PWM_BASE
    lw   t4, PWM_CFG_OFST(t5)
    addi t4, t4, 1
    andi t4, t4, 0x0F
    sw   t4, PWM_CFG_OFST(t5)
    li   t3, cnt_val
    srl  t3, t3, t4
    li   t4, PWM_SCALED_MASK
    and  t3, t3, t4
    lw   t4, PWM_SCALED_OFST(t5)
    add  TESTNUM, t2, x0
    bne  t4, t3, fail  
    addi t2, t2, 1
    li   t5, 247
    blt  t2, t5, 1b

    # This will test some of the scale values. The idea is to set the CMPx registers
    # neighboring one hot codes and the see how scale affects the IPx flags (non-sticky).
test_cfg_scale_cmp:
    .set ip_mask,0xF0000000
#if PWM_CMPWIDTH < 15
    .set max_shift,PWM_CMPWIDTH
#else
    .set max_shift,15
#endif
    .set cnt_val,1<<(max_shift-1)     # set CNT so that PWMS with scale=0 has only MSB set
    li   t5, PWM_BASE
    sw   x0, PWM_CFG_OFST(t5)
    ori  t4,x0,1
    sw   t4, PWM_CMP0_OFST(t5)
    ori  t4,x0,2
    sw   t4, PWM_CMP1_OFST(t5)
    ori  t4,x0,4
    sw   t4, PWM_CMP2_OFST(t5)
    ori  t4,x0,8
    sw   t4, PWM_CMP3_OFST(t5)
    li   t4, cnt_val
    sw   t4, PWM_CNT_OFST(t5)

    # Test all IPx set
    li   t4,ip_mask
    lw   t3, PWM_CFG_OFST(t5)
    and  t3,t3,t4
    li   TESTNUM, 250
    bne  t3, t4, fail

    # Set max scale
    li   t5, PWM_BASE
    li   t4, max_shift
    sw   t4, PWM_CFG_OFST(t5)

    # Test all IPx clear
    li   t4,ip_mask
    lw   t3, PWM_CFG_OFST(t5)
    and  t3,t3,t4
    li   TESTNUM, 251
    bne  t3, x0, fail

    # Iteratively decrease the scale and see individual IPx flags being
    # set.
    .set testnum, 252
    .set ip0_mask, 0x10000000
    li   t2,testnum
1:  li   t5, PWM_BASE
    lw   t4, PWM_CFG_OFST(t5)       # get CFG value (incl. IPx and SCALE)
    li   t3,ip_mask
    and  t3,t3,t4                   # mask only IP3-0 value
    addi t4,t4,-1                   # decrease SCALE (note that SCALE is large enough not to
                                    # underrun and hence not to change other CFG bits)
    sw   t4, PWM_CFG_OFST(t5)       # change SCALE
    slli t3,t3,1
    li   t4,ip0_mask
    or   t3,t3,t4                   # change expected IP3-0 by shifting it left and setting IP0
                                    # (this change shall correspond to the SCALE change above
                                    # and values pre-set to the CMPx registers)
    lw   t4, PWM_CFG_OFST(t5)       # get the new CFG value
    li   t5,ip_mask
    and  t4,t4,t5                   # mask only IP3-0 bits
    add  TESTNUM, t2, x0
    bne  t4, t3, fail               # compare the actual and expected IP3-0 value
    addi t2,t2,1
    li   t5, 256
    blt  t2,t5,1b                   # loop 4 times

    # Test that CNT values above the scaled window (PWMS) are ignored.
    # Here we set SCALE=0, CMPx=1 and CNT such that all but bits
    # in the scale window are set (i.e. CNT!=0 and PWMS=0). We expect
    # to see IPx clear.
    .set cnt_val,PWM_CNT_MASK ^ ((1 << PWM_CMPWIDTH)-1)
    li   t5, PWM_BASE
    sw   x0, PWM_CFG_OFST(t5)
    li   t4, 1
    sw   t4, PWM_CMP0_OFST(t5)
    sw   t4, PWM_CMP1_OFST(t5)
    sw   t4, PWM_CMP2_OFST(t5)
    sw   t4, PWM_CMP3_OFST(t5)
    li   t4, cnt_val
    sw   t4, PWM_CNT_OFST(t5)
    lw   t3, PWM_CFG_OFST(t5)
    lw   t2, PWM_SCALED_OFST(t5)
    li   TESTNUM, 256
    bne  t2, x0, fail              # expect PWMS==0
    li   TESTNUM, 257
    bne  t3, x0, fail              # expect IP3-0==0 (and in fact the whole CFG==0)

test_counting:
    li   t5, PWM_BASE
    sw   x0, PWM_CFG_OFST(t5)
    li   t4, PWM_CMP0_MASK
    sw   t4, PWM_CMP0_OFST(t5)
    sw   t4, PWM_CMP1_OFST(t5)
    sw   t4, PWM_CMP2_OFST(t5)
    sw   t4, PWM_CMP3_OFST(t5)

    # Test if on ENALWAYS the counter advances
    .set bit_enalways_set,1<<PWM_BIT_CFG_ENALWAYS
    .set bit_enalways_clr,0xFFFFFFFF ^ bit_enalways_set
    li   t5, PWM_BASE
    sw   x0, PWM_CNT_OFST(t5)
    lw   t3, PWM_CNT_OFST(t5)
    li   TESTNUM, 300
    bne  t3, x0, fail               # expect CNT==0
    li   t5, PWM_BASE
    li   t4, bit_enalways_set       # enable counting by ENALWAYS
    sw   t4, PWM_CFG_OFST(t5)
    li   t3, bit_enalways_clr       # disable counting
    and  t4, t4, t3
    sw   t4, PWM_CFG_OFST(t5)
    lw   t3, PWM_CNT_OFST(t5)
    li   TESTNUM, 301
    beq  t3, x0, fail               # expect CNT!=0

    # Test if on ENONESHOT the counter advances
    .set bit_enoneshot_set,1<<PWM_BIT_CFG_ENONESHOT
    .set bit_enoneshot_clr,0xFFFFFFFF ^ bit_enoneshot_set
    li   t5, PWM_BASE
    sw   x0, PWM_CNT_OFST(t5)
    lw   t3, PWM_CNT_OFST(t5)
    li   TESTNUM, 302
    bne  t3, x0, fail               # expect CNT==0
    li   t5, PWM_BASE
    li   t4, bit_enoneshot_set      # enable counting by ENONESHOT
    sw   t4, PWM_CFG_OFST(t5)
    li   t3, bit_enoneshot_clr      # disable counting
    and  t4, t4, t3
    sw   t4, PWM_CFG_OFST(t5)
    lw   t3, PWM_CNT_OFST(t5)
    li   TESTNUM, 303
    beq  t3, x0, fail               # expect CNT!=0

    # Test that CNT wraps aound and counts on when ENALWAYS.
    # (Assuming CPMx are already set to max.)
    li   t5, PWM_BASE
    li   t4, PWM_CNT_MASK           # set CNT to max
    sw   t4, PWM_CNT_OFST(t5)
    lw   t2, PWM_CNT_OFST(t5)
    lw   t1, PWM_CFG_OFST(t5)
    li   t3, ip_mask
    and  t1, t1, t3
    li   TESTNUM, 304
    bne  t2, t4, fail               # expect CNT==max
    li   TESTNUM, 305
    bne  t1, t3, fail               # expect IP3-0==all 1s
    li   t5, PWM_BASE
    li   t4, bit_enalways_set       # enable counting by ENALWAYS
    sw   t4, PWM_CFG_OFST(t5)
    li   t3, bit_enalways_clr       # disable counting
    and  t4, t4, t3
    sw   t4, PWM_CFG_OFST(t5)
    lw   t2, PWM_CNT_OFST(t5)
    lw   t1, PWM_CFG_OFST(t5)
    li   t3, ip_mask
    and  t1, t1, t3
    li   TESTNUM, 306
    beq  t2, x0, fail              # expect CNT!=0
    li   TESTNUM, 307
    bne  t1, x0, fail              # expect IP3-0==all 0s

    # Test that CNT wraps around and stops at zero when ENONESHOT. ENONESHOT
    # shall clear on the wrap around and hence we need not to disable counting.
    # (Assuming CPMx are already set to max.)
    .set ip_and_enoneshot_mask,(ip_mask | bit_enoneshot_set)
    li   t5, PWM_BASE
    li   t4, PWM_CNT_MASK           # set CNT to max
    sw   t4, PWM_CNT_OFST(t5)
    lw   t2, PWM_CNT_OFST(t5)
    lw   t1, PWM_CFG_OFST(t5)
    li   t3, ip_mask
    and  t1, t1, t3
    li   TESTNUM, 308
    bne  t2, t4, fail               # expect CNT==max
    li   TESTNUM, 309
    bne  t1, t3, fail               # expect IP3-0==all 1s
    li   t5, PWM_BASE
    li   t4, bit_enoneshot_set      # enable counting by ENALWAYS
    sw   t4, PWM_CFG_OFST(t5)
    li   t2, 10
1:  addi t2,t2,-1                   # Wait loop before reading back CFG and CNT
    bne  t2,x0,1b
    lw   t2, PWM_CNT_OFST(t5)
    lw   t1, PWM_CFG_OFST(t5)
    li   t3, ip_and_enoneshot_mask  # Mask IP3-0 and ENONESHOT
    and  t1, t1, t3
    li   TESTNUM, 310
    bne  t2, x0, fail               # expect CNT==0
    li   TESTNUM, 311
    bne  t1, x0, fail               # expect IP3-0==all 0s and ENONESHOT==0

    # Test that CNT resets on CMP condition when ZEROCMP. We assume that CNT
    # resets even when not enabled to count (neither by ENALWAYS nor by ENONESHOT).
    # Hence by writing to CNT a value of CMPx will yield CNT=0.
    .set bit_zerocmp_set,(1<<PWM_BIT_CFG_ZEROCMP)
    .set bit_zerocmp_clr,0xFFFFFFFF ^ bit_zerocmp_set
    li   t5, PWM_BASE
    li   t4, bit_zerocmp_set
    sw   t4, PWM_CFG_OFST(t5)
    li   t4, 10
    sw   t4, PWM_CMP0_OFST(t5)
    sw   t4, PWM_CNT_OFST(t5)       # set CNT = CMP0
    lw   t2, PWM_CNT_OFST(t5)
    li   TESTNUM, 320
    bne  t2, x0, fail               # expect CNT==0
    li   t4, 11                     # set CNT > CMP0
    sw   t4, PWM_CNT_OFST(t5)
    lw   t2, PWM_CNT_OFST(t5)
    li   TESTNUM, 321
    bne  t2, x0, fail               # expect CNT==0
    li   t4, 9                      # set CNT < CMPx
    sw   t4, PWM_CNT_OFST(t5)
    lw   t2, PWM_CNT_OFST(t5)
    li   TESTNUM, 322
    bne  t2, t4, fail               # expect CNT==last written


    # Test End
    TEST_PASSFAIL


RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN

TEST_DATA

#data1: .word 0
#data2: .word 0

RVTEST_DATA_END
