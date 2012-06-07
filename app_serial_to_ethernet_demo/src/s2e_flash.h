// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename:
 Project :
 Author  :
 Version :
 Purpose
 -----------------------------------------------------------------------------


 ===========================================================================*/
#ifndef S2E_FLASH_H_
#define S2E_FLASH_H_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "common.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
// required for calculation of config_address and other stuff
#define FLASH_SIZE_PAGE             256
#define WPAGE_NUM_FILES             2
#define WPAGE_FILE_NAME_LEN			32

// flash_operation defines
#define FLASH_ROM_READ              '@'
#define FLASH_DATA_WRITE            '~'
#define FLASH_DATA_READ             '!'
#define FLASH_GET_DATA_ADDRESS      '#'

// indicate if there is data present in flash
#define FLASH_VALID_DATA_PRESENT    '$'

// Index sectors where the data is present
#define UART_CONFIG                 0
#define IPVER                       1

// Flash error or ok
#define S2E_FLASH_ERROR             -1
#define S2E_FLASH_OK                0

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef struct
{
    char name[WPAGE_FILE_NAME_LEN];
    int page;
    int length;
}fsdata_t;

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/
extern fsdata_t fsdata[];

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/
#ifndef FLASH_THREAD

int read_from_flash(int address, char data[]);
int write_to_flash(int address, char data[]);
int flash_read_rom(int page, char data[]);
int get_flash_data_address(int data_type);

#else //FLASH_THREAD

int get_data_address(int data_type, chanend cPersData);
void flash_data_access(chanend cPersData);
int flash_access(char flash_operation,
                 char data[],
                 int address,
                 chanend cPersData);

#endif //FLASH_THREAD

#endif /* S2E_FLASH_H_ */
/*=========================================================================*/
