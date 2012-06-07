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

#ifndef TELNETD_H_
#define TELNETD_H_

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/
#include "xtcp_client.h"
#include "xccompat.h"

#ifdef __telnetd_conf_h_exists__
#include "telnetd_conf.h"
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
// Maximum number of concurrent connections
#ifndef NUM_TELNETD_CONNECTIONS
#define NUM_TELNETD_CONNECTIONS 9
#endif

#ifndef TELNET_LINE_BUFFER_LEN
#define TELNET_LINE_BUFFER_LEN (160 * 1)
#endif

#define TELNETD_PORT            23

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
void telnetd_init(chanend tcp_svr);

void telnetd_init_conn(chanend tcp_svr);

void telnetd_init_state(chanend tcp_svr,
                        REFERENCE_PARAM(xtcp_connection_t, conn));

void telnetd_handle_event(
                chanend tcp_svr,
                REFERENCE_PARAM(xtcp_connection_t, conn));

int telnetd_send_line(chanend tcp_svr, int i, char line[]);

int telnetd_send(chanend tcp_svr, int i, char line[]);

int fetch_connection_state_index(int conn_id);

void telnet_buffered_send_handler(chanend tcp_svr,
                                  REFERENCE_PARAM(xtcp_connection_t, conn));

void telnetd_recv(chanend tcp_svr, REFERENCE_PARAM(xtcp_connection_t, conn));

int telnetd_recv_data(chanend tcp_svr,
                      REFERENCE_PARAM(xtcp_connection_t, conn),
                      REFERENCE_PARAM(char, data),
                      REFERENCE_PARAM(char, actual_data));

void telnetd_sent_line(chanend tcp_svr, int i);

void telnetd_new_connection(chanend tcp_svr, int id);

void telnetd_connection_closed(chanend tcp_svr, int id);

void telnetd_free_state(REFERENCE_PARAM(xtcp_connection_t, conn));

#ifndef __XC__
void register_callback(void (*fnCallBack)(xtcp_connection_t *conn, char data));
#endif

#endif // TELNETD_H_
/*=========================================================================*/
