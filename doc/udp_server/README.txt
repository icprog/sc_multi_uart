
Overview:
=========
This application is intended to demonstrate UDP Broadcast server implementation.


Software requirements: 
======================
	Python pkgs --> Socket
	OS type : Windows / Linux / Mac


Hardware Requirements:
======================
	1. Main Slice board
	2. Ethernet and UART slice
	3. XTAG slice (if required)


Platform Dependency:
====================
	1. Windows Users can use directly the Executable in the Windows folder ( availabe in the UDP_server Package).
 	2. Mac / Linux users can use the udp_server.py file from Mac/Linux folder (available in the UDP_server Package) and run from console.


Folder Structure:
=================
	For Windows: UDP_Server\Windows\dist\Udp_server.exe
	For Mac/Linux : UDP_Server\Mac-Linux\udp_server.py


UDP Server Software Usage:
==========================

   Server IP address selection:
   ----------------------------	
 	1. Initially the software picks up IP address of your network and displays it on the screen.
 	2. Asks the user to confirm the IP address(‘y’) and continue.
 	3. If the picked IP address is not correct. User can change the IP address by entering the option (‘n’).
    4. Displays the ports used for transmitting and receiving data.
 
<< Screen shot of these 4 steps can be seen in server_ip_selection.png >>

   Brodcast S2E query:	 
   -------------------
	5. Broadcasts the command to all the devices in the network (‘XMOS S2E REPLY’).
 	     Broadcast Command:
		XMOS S2E REPLY -- This command will be broadcasted to all the devices in the network.
		
                  The received Acknowledgement is in the format: XMOS S2E VER:XXXX;MAC:xx:xx:xx:xx:xx:xx;IP:xxx.xxx.xxx.xxx
			VER --> Firmware Version
			MAC --> MAC Address
			IP  --> IP address of the Device
 	6. S2E Device will reply to the device with an acknowledgement

<< Screen shot of the these 2 steps can be seen in broadcast_s2e_query.png >>
 
  Brodcast S2E IP change flow:
  ----------------------------
 	7. User can select the IP change Request by selecting ('y').
	8. Application asks the user to enter the new IP address that has to be assigned to S2E Device.
	9. IP Change Request is sent to the Device in the format below:
	   IP CHange Request:
	     XMOS S2E IPCHANGE aaa.bbb.ccc.ddd -- This command asks the S2E Device to change the IP address.
	10. Waits for user to input the time to wait after IP change to send broad cast reequest again.
 
<< Screen shot of the next 2 steps can be seen in ip_change.png>>
 
	11. Application again sends the broadcast command to device to see if the change request is effective.

