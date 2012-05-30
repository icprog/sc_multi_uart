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
//#define FLASH_CHECKSUM

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

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
void flash_write_ip_data(chanend cPersData,
                         xtcp_ipconfig_t ipconfig,
                         unsigned address)
{
    unsigned i;
    unsigned checksum = IP_SECTOR_MAGIC_NUMBER_CKSUM; //This is the checksum for 0xCAFEF00D
    unsigned char flash_data[FLASH_SIZE_PAGE];
    int flash_result;

    // Read data from flash
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);

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
#ifdef FLASH_CHECKSUM
    for(i=4;i<16;i++)
    {
        checksum += flash_data[i];
    }
    flash_data[16] = checksum&0xff;
    flash_data[17] = (checksum>>8)&0xff;
#endif

    // Write data to flash
    flash_result = flash_access(FLASH_DATA_WRITE, flash_data, address, cPersData);
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
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);

    for(i = 0; i < version_size; i++)
    {
        flash_data[ sizeof(xtcp_ipconfig_t)+i] = version[i];
    }

    // Write data to flash
    flash_result = flash_access(FLASH_DATA_WRITE, flash_data, address, cPersData);
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
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);

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
xtcp_ipconfig_t flash_read_ip_data(chanend cPersData, unsigned address)
{
    unsigned i, checksum = IP_SECTOR_MAGIC_NUMBER_CKSUM, o_checksum;
    unsigned char flash_data[FLASH_SIZE_PAGE];
    xtcp_ipconfig_t ipconfig;
    int flash_result;

    xtcp_ipconfig_t dhcp_ipconfig =
    {
     { 0, 0, 0, 0 },
     { 0, 0, 0, 0 },
     { 0, 0, 0, 0 }
    };

    // Read data from flash
    flash_result = flash_access(FLASH_DATA_READ, flash_data, address, cPersData);

    if((flash_data[0]|(flash_data[1]<<8)|(flash_data[2]<<16)|(flash_data[3]<<24)) == IP_SECTOR_MAGIC_NUMBER )
    {
#ifdef FLASH_CHECKSUM
        for(i=4;i<16;i++)
        {
            checksum+= flash_data[i];
        }
        o_checksum = flash_data[16] + (flash_data[17]<<8);
        if(checksum == o_checksum)
        {
            for(i = 0; i < 4; i++ )
            {
                ipconfig.ipaddr[i] = flash_data[ i+4 ];
                ipconfig.netmask[i] = flash_data[ i+8 ];
                ipconfig.gateway[i] = flash_data[ i+12 ];
            }
            return ipconfig;
        }
        else
        {
            return dhcp_ipconfig;
        }
#else
        for(i = 0; i < 4; i++ )
        {
            ipconfig.ipaddr[i] = flash_data[ i+4 ];
            ipconfig.netmask[i] = flash_data[ i+8 ];
            ipconfig.gateway[i] = flash_data[ i+12 ];
        }

        return ipconfig;
#endif

    }
    else
    {
        return dhcp_ipconfig;
    }
}

/*=========================================================================*/
