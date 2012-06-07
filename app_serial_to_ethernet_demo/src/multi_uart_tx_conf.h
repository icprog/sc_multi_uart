// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
/*===========================================================================
 Filename: Multi-UART Transmit Configuration file
 Project :
 Author  :
 Version :
 Purpose
 -----------------------------------------------------------------------------


 ===========================================================================*/

#ifndef MUART_TX_CONF_H_
#define MUART_TX_CONF_H_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
/**
 * Define to use external clock reference
 */
#define UART_TX_USE_EXTERNAL_CLOCK
 
/**
 * Define the master clock rate
 */
#ifdef UART_TX_USE_EXTERNAL_CLOCK
#define UART_TX_CLOCK_RATE_HZ       1843200
#else
#define UART_TX_CLOCK_RATE_HZ       100000000
#endif


/**
 * Define the max baud rate - validated to 230kbaud
 */
#define UART_TX_MAX_BAUD_RATE       115200


/**
 * Clock divider value that defines max baud rate - this is only used when using the internal clock
 */
#define UART_TX_CLOCK_DIVIDER      (UART_TX_CLOCK_RATE_HZ/UART_TX_MAX_BAUD_RATE)

/**
 * Define the oversampling of the clock - this is where the UART_TX_CLOCK_DIVIDER is > 255 
 * (otherwise set to 1) - only used when using an internal clock reference
 */
#define UART_TX_OVERSAMPLE          2

/**
 * Define the buffer size in UART word entries - needs to be a power of 2 (i.e. 1,2,4,8,16,32)
 */
#define UART_TX_BUF_SIZE            16

/**
 * Define the number of channels that are to be supported, must fit in the port. Also, 
 * must be a power of 2 (i.e. 1,2,4,8,16) - not all channels have to be utilised
 */
#define UART_TX_CHAN_COUNT          8

/**
 * Define the number of interframe bits
 */
#define UART_TX_IFB                 0

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

#endif // MUART_TX_CONF_H_
/*=========================================================================*/
