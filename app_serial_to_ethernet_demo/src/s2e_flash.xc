// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: s2e_flash.xc
 Project :
 Author  :
 Version :
 Purpose
 -----------------------------------------------------------------------------


 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include <platform.h>
#include <flashlib.h>
#include <flash.h>
#include <string.h>
#include "s2e_flash.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
on stdcore[0] : extern fl_SPIPorts flash_ports;

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/


// Webpage file information generated from the script must be copied here
fsdata_t fsdata[] =
{
 { "/index.html", 0, 5276 },
 { "/img/xmos_logo.gif", 21, 915 },
};


#define LAST_FS_PAGE    (fsdata[WPAGE_NUM_FILES - 1].page)
#define LAST_FS_SIZE    (fsdata[WPAGE_NUM_FILES - 1].length)


// Array of allowed flash devices from "SpecMacros.h"
fl_DeviceSpec myFlashDevices[] = { FL_DEVICE_NUMONYX_M25P16 };

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/
static int get_flash_data_page_address(int data_page);
static int connect_flash();

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

/** =========================================================================
 *  get_flash_data_page_address
 *
 *  \param int data_page page number
 *  \return int          S2E_FLASH_OK / S2E_FLASH_ERROR
 *
 **/
static int get_flash_data_page_address(int data_page)
{
    int address, index_data_sector;

    // connect to flash
    if (S2E_FLASH_OK != connect_flash())    { return S2E_FLASH_ERROR; }
    // get the index of data sector
    index_data_sector = fl_getNumSectors() - fl_getNumDataSectors();
    // address of the requested page is data_sector start address + page*page_size
    address = fl_getSectorAddress(index_data_sector) +
                    (data_page * fl_getPageSize());
    return address;
}

/** =========================================================================
 *  connect_flash
 *
 *  \return int          S2E_FLASH_OK / S2E_FLASH_ERROR
 **/
static int connect_flash()
{
    // connect to flash
    if (0 != fl_connectToDevice(flash_ports, myFlashDevices, 1)) { return S2E_FLASH_ERROR; }
    // get flash type
    switch (fl_getFlashType())
    {
        case NUMONYX_M25P16: break;
        default: return S2E_FLASH_ERROR; break;
    }
    // all ok
    return S2E_FLASH_OK;
}

/** =========================================================================
 *  read_from_flash
 *
 *  \param int  address  address in flash to read data from
 *  \param char data     array where read data will be stored
 *  \return int          S2E_FLASH_OK / S2E_FLASH_ERROR
 **/
#pragma unsafe arrays
int read_from_flash(int address, char data[])
{
    // connect to flash
    if (S2E_FLASH_OK != connect_flash())            { return S2E_FLASH_ERROR; }
    // Read from the data partition
    if (S2E_FLASH_OK != fl_readPage(address, data)) { return S2E_FLASH_ERROR; }
    // Disconnect from the flash
    if (S2E_FLASH_OK != fl_disconnect())            { return S2E_FLASH_ERROR; }
    // return all ok
    return S2E_FLASH_OK;
}

/** =========================================================================
 *  write_to_flash
 *
 *  \param int  address  address in flash to write data to
 *  \param char data     array that will be written to flash
 *  \return int          S2E_FLASH_OK / S2E_FLASH_ERROR
 *
 **/
#pragma unsafe arrays
int write_to_flash(int address, char data[])
{
    int ix_sector;
    int num_sectors;
    int sector;
    int current_sector_address;

    // connect to flash
    if (S2E_FLASH_OK != connect_flash())    { return S2E_FLASH_ERROR; }

    // find the sector where the address resides
    num_sectors = fl_getNumSectors();
    for (ix_sector = 0; ix_sector < num_sectors; ix_sector++)
    {
        current_sector_address = fl_getSectorAddress(ix_sector);

        if (current_sector_address == address)
        {
            sector = ix_sector;
            break;
        }
        else if (current_sector_address >= address)
        {
            sector = ix_sector - 1;
            break;
        }
    }
    // erase sector
    if (S2E_FLASH_OK != fl_eraseSector(sector))      {return S2E_FLASH_ERROR;}
    // write page
    if (S2E_FLASH_OK != fl_writePage(address, data)) {return S2E_FLASH_ERROR;}
    // disconnect
    if (S2E_FLASH_OK != fl_disconnect())             {return S2E_FLASH_ERROR;}
    // return all ok
    return S2E_FLASH_OK;
}

/** =========================================================================
 *  get_flash_data_address
 *
 *  \param data_type    CONFIG / IPVER
 *  \return int         S2E_FLASH_OK / S2E_FLASH_ERROR
 *
 **/
#pragma unsafe arrays
int get_flash_data_address(int data_type)
{
    int total_rom_bytes;
    int temp;
    int index_data_sector;
    int done = 0;
    int address = 0;

    // connect to flash
    if (S2E_FLASH_OK != connect_flash())    { return S2E_FLASH_ERROR; }

    // get number of bytes in ROM
    total_rom_bytes = LAST_FS_PAGE + ((1 + LAST_FS_SIZE) / FLASH_SIZE_PAGE);
    total_rom_bytes *= FLASH_SIZE_PAGE;

    // check if data partition is defined
    if (fl_getDataPartitionSize() == 0)     { return S2E_FLASH_ERROR; }

    // get the index of data sector
    index_data_sector = fl_getNumSectors() - fl_getNumDataSectors();

    // ROM resides in data partition.
    // Start of data partition + ROM size up-capped to sector
    while (done != 1)
    {
        temp = fl_getSectorSize(index_data_sector);
        if ((total_rom_bytes - temp) <= 0)
        {
            done = 1;
        }
        else
        {
            total_rom_bytes -= temp;
        }

        if (index_data_sector < fl_getNumSectors())
        {
            index_data_sector++;
        }
        else
        {
            return -1;
        }
    } // while
    address = fl_getSectorAddress(index_data_sector + data_type);

    // disconnect
    if (S2E_FLASH_OK != fl_disconnect())   { return S2E_FLASH_ERROR; }

    // return the flash address
    return address;
}

#ifndef FLASH_THREAD

/** =========================================================================
*  flash_read_rom
*
*  \param int  page    page number to read
*  \param char data[]  flash data will be stored here
*  \return int         S2E_FLASH_OK / S2E_FLASH_ERROR
*
**/
#pragma unsafe arrays
int flash_read_rom(int page, char data[])
{
    int address;
    address = get_flash_data_page_address(page);
    // return error if there was error in flash access
    if(address == S2E_FLASH_ERROR)    { return S2E_FLASH_ERROR; }
    // read data from flash
    read_from_flash(address, data);
    // return ok
    return S2E_FLASH_OK;
}

#else //FLASH_THREAD
/** =========================================================================
 *  flash_data_access
 *
 *  \param chanend cPersData channel to pass data from Core 0
 *                           (Flash port present in Core0)
 *
 **/
#pragma unsafe arrays
void flash_data_access(chanend cPersData)
{
    char channel_data;
    int address, page, i, data_type;
    char flash_page_data[FLASH_SIZE_PAGE];
    int flash_result;

    while (1)
    {
        select
        {
            case cPersData :> channel_data :
            {
                if (FLASH_ROM_READ == channel_data)
                {
                    cPersData :> page;
                    // get page address
                    address = get_flash_data_page_address(page);
                    // read ROM
                    flash_result = read_from_flash(address, flash_page_data);
                    // send flash access result
                    cPersData <: flash_result;
                    // send data if flash read was ok
                    if(S2E_FLASH_OK == flash_result)
                    {
                        for(i = 0; i < FLASH_SIZE_PAGE; i++)
                        {
                            cPersData <: flash_page_data[i];
                        }
                    }
                }
                else if(FLASH_DATA_WRITE == channel_data)
                {
                    cPersData :> address;
                    for(i = 0; i < FLASH_SIZE_PAGE; i++)
                    {
                        cPersData :> flash_page_data[i];
                    }
                    // write config
                    flash_result = write_to_flash(address, flash_page_data);
                    // send flash access result
                    cPersData <: flash_result;
                }
                else if(FLASH_DATA_READ == channel_data)
                {
                    cPersData :> address;
                    flash_result = read_from_flash(address, flash_page_data);
                    // send flash access result
                    cPersData <: flash_result;
                    // send data if flash read was ok
                    if(S2E_FLASH_OK == flash_result)
                    {
                        for(i = 0; i < FLASH_SIZE_PAGE; i++)
                        {
                            cPersData <: flash_page_data[i];
                        }
                    }
                }
                else if(FLASH_GET_DATA_ADDRESS == channel_data)
                {
                    cPersData :> data_type;
                    address = get_flash_data_address(data_type);
                    cPersData <: address;
                }
                break;
            } // case cPersData :> channel_data :
            default: break;
        } // select
    } // while(1)
}

/** =========================================================================
*  flash_access
*
*  \param char flash_operation: the operation to perform, see s2e_flash.h for #defines
*  \param char data[]: array where data is got from / stored to
*  \param int address: for rom_read: address is the page number
*           for config: it is the actual address (get address using get_data_address)
*  \param chanend cPersData: channel to pass data from Core 0 (Flash port present in Core0)
*  see: s2e_flash.xc: flash_data_access()
*
**/
#pragma unsafe arrays
int flash_access(char flash_operation, char data[], int address, chanend cPersData)
{
    int i, rtnval, flash_result;

    switch (flash_operation)
    {
        case FLASH_ROM_READ:
        {
            cPersData <: FLASH_ROM_READ;
            cPersData <: address; // this is page number
            cPersData :> flash_result;

            if(S2E_FLASH_OK == flash_result)
            {
                for(i = 0; i < FLASH_SIZE_PAGE; i++)
                {
                    cPersData :> data[i];
                }
            }
            break;
        }
        case FLASH_DATA_WRITE:
        {
            // Write
            cPersData <: FLASH_DATA_WRITE;
            cPersData <: address;

            for(i = 0; i < FLASH_SIZE_PAGE; i++)
            {
                cPersData <: data[i];
            }

            cPersData :> flash_result;

            break;
        }
        case FLASH_DATA_READ:
        {
            // Read
            cPersData <: FLASH_DATA_READ;
            cPersData <: address;
            cPersData :> flash_result;

            if(S2E_FLASH_OK == flash_result)
            {
                for(i = 0; i < FLASH_SIZE_PAGE; i++)
                {
                    cPersData :> data[i];
                }
            }
            break;
        }

        default: break;
    }
    return flash_result;
}

/** =========================================================================
*  get_data_address
*
*  \param int data_type:     CONFIG / IPVER
*  \param chanend cPersData: channel to pass data from Core 0
*                            (Flash port present in Core0)
*  \return int address address in flash
*  see: s2e_flash.xc: flash_data_access()
*
**/
int get_data_address(int data_type, chanend cPersData)
{
    int address;
    cPersData <: FLASH_GET_DATA_ADDRESS;
    cPersData <: data_type;
    cPersData :> address;
    return address;
}
#endif //FLASH_THREAD

/*=========================================================================*/
