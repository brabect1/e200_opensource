# See LICENSE for license details.

#ifndef __soc_h
#define __soc_h



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


# -----------------------------------------------
# QSPI0
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

# -----------------------------------------------
# GPIO0
# -----------------------------------------------
# The memory map is listed below. For complete periph IP reference
# see "SiFive E300 Platform Reference Manual"
#
# Memory map:
#   0x10012000 value  Pin value
#   0x10012004 inen   Pin input enable
#   0x10012008 outen  Pin output enable
#   0x1001200c port   Output port value
#   0x10012038 iofen  IOF enable
#   0x1001203c iofsel IOF select
#   0x10012040 outxor Ouput XOR mask
#
# IOF Map:
#   IO 16   0:UART0 RxD
#   IO 17   0:UART0 TxD

#define GPIO0_BASE 0x10012000

#define GPIO_VALUE_OFST 0
#define GPIO_VALUE_RSTV 0x00000000
#define GPIO_VALUE_MASK 0xffffffff

#define GPIO_INEN_OFST 4
#define GPIO_INEN_RSTV 0x00000000
#define GPIO_INEN_MASK 0xffffffff

#define GPIO_OUTEN_OFST 8
#define GPIO_OUTEN_RSTV 0x00000000
#define GPIO_OUTEN_MASK 0xffffffff

#define GPIO_PORT_OFST 12
#define GPIO_PORT_RSTV 0x00000000
#define GPIO_PORT_MASK 0xffffffff

#define GPIO_IOFEN_OFST 56
#define GPIO_IOFEN_RSTV 0x00000000
#define GPIO_IOFEN_MASK 0xffffffff

#define GPIO_IOFSEL_OFST 60
#define GPIO_IOFSEL_RSTV 0x00000000
#define GPIO_IOFSEL_MASK 0xffffffff

#define GPIO_XOR_OFST 64
#define GPIO_XOR_RSTV 0x00000000
#define GPIO_XOR_MASK 0xffffffff

# -----------------------------------------------
# UART0
# -----------------------------------------------
# The memory map is listed below. For complete periph IP reference
# see "SiFive E300 Platform Reference Manual"
#
# Memory map:
#   0x10013000 txdata Transmit data 
#   0x10013004 rxdata Receive data
#   0x10013008 txctrl Transmit control
#   0x1001300c rxctrl Receive control
#   0x10013010 ie UART interrupt enable
#   0x10013014 ip UART interrupt pending
#   0x10013018 div Baud rate divisor

#define UART0_BASE 0x10013000

#define UART_TXDATA_OFST 0
#define UART_TXDATA_RSTV 0x00000000
#define UART_TXDATA_MASK 0x800000FF

#define UART_RXDATA_OFST 4
#define UART_RXDATA_RSTV 0x80000000
#define UART_RXDATA_MASK 0x800000FF

#define UART_TXCTRL_OFST 8
#define UART_TXCTRL_RSTV 0x00000000
#define UART_TXCTRL_MASK 0x000F0003

#define UART_RXCTRL_OFST 12
#define UART_RXCTRL_RSTV 0x00000000
#define UART_RXCTRL_MASK 0x000F0001

#define UART_IE_OFST 16
#define UART_IE_RSTV 0x00000000
#define UART_IE_MASK 0x00000003

#define UART_IP_OFST 20
#define UART_IP_RSTV 0x00000000
#define UART_IP_MASK 0x00000003

#define UART_DIV_OFST 24
#define UART_DIV_RSTV 0x0000021e
#define UART_DIV_MASK 0x0000ffff

#endif
