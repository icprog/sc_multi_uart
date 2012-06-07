// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


/*===========================================================================
 Filename: main.xc
 Project : app_serial_to_ethernet_demo
 Author  : XMOS Ltd
 Version : 1v1v3
 Purpose : This file defines resources (ports, clocks, threads and interfaces)
 required to implement serial to ethernet bridge application demostration
 -----------------------------------------------------------------------------

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include <platform.h>
#include <xs1.h>
#include "getmac.h"
#include "uip_single_server.h"
#include "app_manager.h"
#include "web_server.h"
#include "multi_uart_rxtx.h"
#include <flash.h>
#include "s2e_flash.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define	TWO_THREAD_ETH	1 // Enable this to use 2 thread ethernet
#define L1_BUILD_TEST   0 // Enable this to put everything on one core for
                          // testing the build for an L1 Device

#if L1_BUILD_TEST
#define MUART_CORE_NUM  0 // Core to place MUART comp and APP Manager Thread
#define WEB_SERVER_CORE 0 // Core to place the WEB server
#else
#define MUART_CORE_NUM	1 // Core to place MUART comp and APP Manager Thread
#define WEB_SERVER_CORE 1 // Core to place the WEB server
#endif

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
/* MUART TX port configuration */
#define PORT_TX         on stdcore[MUART_CORE_NUM]: XS1_PORT_8B
#define PORT_RX         on stdcore[MUART_CORE_NUM]: XS1_PORT_8A
#define PORT_ETH_FAKE   on stdcore[0]: XS1_PORT_8A

// Define 1 bit external clock
on stdcore[MUART_CORE_NUM]: in port uart_ref_ext_clk = XS1_PORT_1F;
on stdcore[MUART_CORE_NUM]: clock uart_clock_tx = XS1_CLKBLK_1;
on stdcore[MUART_CORE_NUM]: clock uart_clock_rx = XS1_CLKBLK_2;

#if L1_BUILD_TEST
// Currently we have not got enough clock blocks, so this is
// initialized with an invalid clock initilizer for build testing
on stdcore[0]: clock clk_smi = 0xBADF00D;
#else
on stdcore[0]: clock clk_smi = XS1_CLKBLK_5;
#endif

on stdcore[0] : fl_SPIPorts flash_ports =
{ PORT_SPI_MISO,
  PORT_SPI_SS,
  PORT_SPI_CLK,
  PORT_SPI_MOSI,
  XS1_CLKBLK_3
};

on stdcore[0]: struct otp_ports otp_ports =
{
  XS1_PORT_32B,
  XS1_PORT_16C,
  XS1_PORT_16D
};

on stdcore[0]: mii_interface_t mii =
{
 XS1_CLKBLK_1,
 XS1_CLKBLK_2,
 PORT_ETH_RXCLK_1,
 PORT_ETH_ERR_1,
 PORT_ETH_RXD_1,
 PORT_ETH_RXDV_1,
 PORT_ETH_TXCLK_1,
 PORT_ETH_TXEN_1,
 PORT_ETH_TXD_1,
 PORT_ETH_FAKE
};

on stdcore[0]: smi_interface_t smi =
{
  0,
  PORT_ETH_MDIO_1,
  PORT_ETH_MDC_1
};

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
s_multi_uart_tx_ports uart_tx_ports = { PORT_TX };
s_multi_uart_rx_ports uart_rx_ports = {	PORT_RX };

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/
static xtcp_ipconfig_t ipconfig;

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

/** =========================================================================
 *  main
 *  Program entry point function:
 *  (i) spwans ethernet, uIp, web server, eth-uart application manager and
 *  multi-uart rx and tx threads
 *  (ii) interfaces ethernet and uIp server threads, tcp and web server
 *  threads, multi-uart application manager and muart tx-rx threads
 *
 *  \param	None
 *  \return	0
 *
 **/
int main(void)
{
	streaming chan cWbSvr2AppMgr;
    streaming chan cTxUART;
    streaming chan cRxUART;
	chan cAppMgr2WbSvr;
	chan xtcp[1];

#ifdef FLASH_THREAD
    chan cPersData;
#endif //FLASH_THREAD

	par
	{
        on stdcore[0]:
        {
            char mac_address[6], i;
            ethernet_getmac_otp(otp_ports, mac_address);
            for(i = 0; i < 4; i++)
            {
            	xtcp[0] :> ipconfig.ipaddr[i];
            	xtcp[0] :> ipconfig.netmask[i];
            	xtcp[0] :> ipconfig.gateway[i];
            }
            // Start server
            uipSingleServer(clk_smi, null, smi, mii, xtcp, 1, ipconfig,
                            mac_address);
        }

#ifdef FLASH_THREAD
	            on stdcore[0]: flash_data_access(cPersData);

	            on stdcore[WEB_SERVER_CORE]: web_server(xtcp[0],
	                                                    cWbSvr2AppMgr,
	                                                    cAppMgr2WbSvr,
	                                                    cPersData);
#else //FLASH_THREAD
	            on stdcore[WEB_SERVER_CORE]: web_server(xtcp[0],
	                                                    cWbSvr2AppMgr,
	                                                    cAppMgr2WbSvr);
#endif //FLASH_THREAD

	            /* The multi-uart application manager thread to handle uart data
	             * communication to web server clients */
	            on stdcore[MUART_CORE_NUM]: app_manager_handle_uart_data(
	                            cWbSvr2AppMgr,
	                            cAppMgr2WbSvr,
	                            cTxUART,
	                            cRxUART);

	            /* run multi-uart RX & TX with a common external clock - (2 threads) */
	            on stdcore[MUART_CORE_NUM]: run_multi_uart_rxtx( cTxUART,
	                                                             uart_tx_ports,
	                                                             cRxUART,
	                                                             uart_rx_ports,
	                                                             uart_clock_rx,
	                                                             uart_ref_ext_clk,
	                                                             uart_clock_tx);
	 } // par
	return 0;
}
