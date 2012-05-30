#ifndef __XC__
#include "xtcp_client.h"
extern void fetch_user_data(
		xtcp_connection_t *conn,
		char data);

#endif

#define TELNET_APPLICATION_CALLBACK fetch_user_data
