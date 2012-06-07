// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: flash_ip_version_data.xc
 Project : app_serial_to_ethernet_demo
 Author  : XMOS Ltd
 Version : 1v0
 Purpose : This file contains the functions calls for writing ip configuration
 and version information to the flash.
 -----------------------------------------------------------------------------


 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "s2e_flash.h"
#include "xtcp_client.h"
#include "flash_ip_version_data.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define USE_STATIC_IP   0

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
xtcp_ipconfig_t xtcp_ipconfig =
{
#if USE_STATIC_IP
 { 169, 254, 196, 178 },
 { 255, 255, 0, 0 },
 { 0, 0, 0, 0 }
#else
 { 0, 0, 0, 0 },
 { 0, 0, 0, 0 },
 { 0, 0, 0, 0 }
#endif
};

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

/** =========================================================================
 *  flash_write_ip_data
 *
 *  \param cPersData
 *  \param ipconfig
 *  \param address
 *
 **/
#ifndef FLASH_THREAD
void flash_write_ip_data(xtcp_ipconfig_t ipconfig,
                         unsigned address)
#else
void flash_write_ip_data(chanend cPersData,
                         xtcp_ipconfig_t ipconfig,
                         unsigned address)
#endif
{
    unsigned i;
    unsigned char flash_data[FLASH_SIZE_PAGE];
    int flash_result;

    // Read data from flash
#ifndef FLASH_THREAD
    flash_result = read_from_flash(address, flash_data);
#else
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);
#endif

    for(i = 0; i < 4; i++ )
    {
        flash_data[i] = (IP_SECTOR_MAGIC_NUMBER>>(i*8)) & 0xff;
    }
    for(i = 0; i < 4; i++ )
    {
        flash_data[ i+4 ] = ipconfig.ipaddr[i];
        flash_data[ i+8 ] = ipconfig.netmask[i];
        flash_data[ i+12 ] = ipconfig.gateway[i];
    }

    // Write data to flash
#ifndef FLASH_THREAD
    flash_result = write_to_flash(address, flash_data);
#else
    flash_result = flash_access(FLASH_DATA_WRITE, flash_data, address, cPersData);
#endif
}

/** =========================================================================
 *  flash_write_version_data
 *
 *  \param cPersData
 *  \param version_size
 *  \param version[]
 *  \param address
 *
 **/
void flash_write_version_data(chanend cPersData,
                              unsigned char version_size,
                              unsigned char version[],
                              unsigned address)
{
    unsigned i;
    unsigned char flash_data[FLASH_SIZE_PAGE];
    int flash_result;

    // Read data from flash
#ifndef FLASH_THREAD
    flash_result = read_from_flash(address, flash_data);
#else
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);
#endif

    for(i = 0; i < version_size; i++)
    {
        flash_data[ sizeof(xtcp_ipconfig_t)+i] = version[i];
    }

    // Write data to flash
#ifndef FLASH_THREAD
    flash_result = write_to_flash(address, flash_data);
#else
    flash_result = flash_access(FLASH_DATA_WRITE, flash_data, address, cPersData);
#endif
}

/** =========================================================================
 *  flash_read_version_data
 *
 *  \param cPersData
 *  \param version_size
 *  \param version[]
 *  \param address
 *
 **/
void flash_read_version_data(chanend cPersData,
                             unsigned char version_size,
                             unsigned char version[],
                             unsigned address)
{
    unsigned i;
    unsigned char flash_data[FLASH_SIZE_PAGE];
    int flash_result;

    // Read data from flash
#ifndef FLASH_THREAD
    flash_result = read_from_flash(address, flash_data);
#else
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);
#endif

    for(i = 0; i < version_size; i++)
    {
        version[i] = flash_data[sizeof(xtcp_ipconfig_t)+i];
    }
}

/** =========================================================================
 *  flash_read_ip_data
 *
 *  \param cPersData
 *  \param address
 *
 **/
#ifndef FLASH_THREAD
xtcp_ipconfig_t flash_read_ip_data(unsigned address)
#else
xtcp_ipconfig_t flash_read_ip_data(chanend cPersData, unsigned address)
#endif
{
    unsigned i;
    unsigned char flash_data[FLASH_SIZE_PAGE];
    int flash_result;

    // Read data from flash
#ifndef FLASH_THREAD
    flash_result = read_from_flash(address, flash_data);
#else
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);
#endif

    if((flash_data[0]|(flash_data[1]<<8)|(flash_data[2]<<16)|(flash_data[3]<<24)) == IP_SECTOR_MAGIC_NUMBER )
    {
        for(i = 0; i < 4; i++ )
        {
            xtcp_ipconfig.ipaddr[i] = flash_data[ i+4 ];
            xtcp_ipconfig.netmask[i] = flash_data[ i+8 ];
            xtcp_ipconfig.gateway[i] = flash_data[ i+12 ];
        }
    }
    return xtcp_ipconfig;
}

/*=========================================================================*/
