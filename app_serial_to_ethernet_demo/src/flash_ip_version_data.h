// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: flash_ip_version_data.h
 Project : app_serial_to_ethernet_demo
 Author  : XMOS Ltd
 Version : 1v0
 Purpose : This file declares interface for writing ipconfig and version to
 flash
 -----------------------------------------------------------------------------


 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#ifndef _flash_ip_version_data_h_
#define _flash_ip_version_data_h_

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define IP_SECTOR_MAGIC_NUMBER          0xCAFEF00D

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

#ifndef FLASH_THREAD

void flash_write_ip_data(xtcp_ipconfig_t ipconfig,
                         unsigned address);

xtcp_ipconfig_t flash_read_ip_data(unsigned address);

#else

void flash_write_ip_data(chanend cPersData,
                         xtcp_ipconfig_t ipconfig,
                         unsigned address);

xtcp_ipconfig_t flash_read_ip_data(chanend cPersData, unsigned address);

#endif

void flash_write_version_data(chanend cPersData,
                              unsigned char version_size,
                              unsigned char version[],
                              unsigned address);

void flash_read_version_data(chanend cPersData,
                             unsigned char version_size,
                             unsigned char version[],
                             unsigned address);

#endif
