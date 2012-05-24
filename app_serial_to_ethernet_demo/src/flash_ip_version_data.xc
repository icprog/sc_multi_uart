// Copyright (c) 2011, XMOS Ltd, All rights reserved
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


#include "s2e_flash.h"
#include "xtcp_client.h"
#include "debug.h"
#include "flash_ip_version_data.h"

//#define FLASH_CHECKSUM



unsigned get_flash_address(chanend cPersData)
{
	unsigned sector_size, sector_num, address, config_address;
    cPersData <: FLASH_GET_CONFIG_ADDRESS;
    cPersData <: fsdata[WPAGE_NUM_FILES - 1].page;
    cPersData <: fsdata[WPAGE_NUM_FILES - 1].length;
    cPersData :> config_address; //Get the address of the configuration sector


    cPersData <: FLASH_GET_NEXT_SECTOR_ADDRESS;
    cPersData <: config_address;
    cPersData :> address;
    return address;
}

void flash_write_ip_data(chanend cPersData, xtcp_ipconfig_t ipconfig, unsigned address)
{
	unsigned i;
	unsigned checksum = IP_SECTOR_MAGIC_NUMBER_CKSUM; //This is the checksum for 0xCAFEF00D
	unsigned char flash_data[FLASH_IP_VER_SIZE];



	/*Read contents of IPVER sector in flash*/
	cPersData <: FLASH_IPVER_READ;
	cPersData <: address;
	for(i = 0; i < FLASH_IP_VER_SIZE; i++)
    {
        cPersData :> flash_data[i];
    }
	for(i = 0; i < 4 ; i++ )
	{
		flash_data[i] = (IP_SECTOR_MAGIC_NUMBER>>(i*8)) & 0xff;
	}
    for(i = 0; i < 4 ; i++ )
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

    cPersData <: FLASH_IPVER_WRITE;
    cPersData <: address;

    for(i = 0; i < FLASH_IP_VER_SIZE; i++)
    {
        cPersData <: flash_data[i];
    }
}


void flash_write_version_data(chanend cPersData, unsigned char version_size, unsigned char version[], unsigned address)
{
	unsigned i;
	unsigned char flash_data[FLASH_IP_VER_SIZE];
	cPersData <: FLASH_IPVER_READ;
	cPersData <: address;
    for(i = 0; i < FLASH_IP_VER_SIZE; i++)
    {
        cPersData :> flash_data[i];
    }
    for(i = 0;i<version_size;i++)
    {
    	flash_data[ sizeof(xtcp_ipconfig_t)+i] = version[i];
    }
    cPersData <: FLASH_IPVER_WRITE;
    cPersData <: address;

    for(i = 0; i < FLASH_IP_VER_SIZE; i++)
    {
        cPersData <: flash_data[i];
    }
}

void flash_read_version_data(chanend cPersData, unsigned char version_size, unsigned char version[], unsigned address)
{
	unsigned i;
	unsigned char flash_data[FLASH_IP_VER_SIZE];
	cPersData <: FLASH_IPVER_READ;
	cPersData <: address;
    for(i = 0; i < FLASH_IP_VER_SIZE; i++)
    {
        cPersData :> flash_data[i];
    }
    for(i = 0;i<version_size;i++)
    {
    	version[i] = flash_data[ sizeof(xtcp_ipconfig_t)+i];
    }
}

xtcp_ipconfig_t flash_read_ip_data(chanend cPersData, unsigned address)
{
	unsigned i, checksum = IP_SECTOR_MAGIC_NUMBER_CKSUM, o_checksum;
	unsigned char flash_data[FLASH_IP_VER_SIZE];
	xtcp_ipconfig_t ipconfig;
	xtcp_ipconfig_t dhcp_ipconfig =
	{
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 }
	};
	cPersData <: FLASH_IPVER_READ;
	cPersData <: address;

    for(i = 0; i < FLASH_IP_VER_SIZE; i++)
    {
        cPersData :> flash_data[i];
    }

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
            for(i = 0; i < 4 ; i++ )
            {
            	ipconfig.ipaddr[i]  = flash_data[ i+4 ];
            	ipconfig.netmask[i] = flash_data[ i+8 ];
            	ipconfig.gateway[i] = flash_data[ i+12 ];
            }
            return ipconfig;
        }
        else
        	return dhcp_ipconfig;
#else
        for(i = 0; i < 4 ; i++ )
        {
        	ipconfig.ipaddr[i]  = flash_data[ i+4 ];
        	ipconfig.netmask[i] = flash_data[ i+8 ];
        	ipconfig.gateway[i] = flash_data[ i+12 ];
        }
        return ipconfig;
#endif

    }
    else
    	return dhcp_ipconfig;
}
