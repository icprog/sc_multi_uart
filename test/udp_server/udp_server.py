import socket
import time

#Ports for sendig and Listening
send_port = 15534 
recv_port = 15533

ip = socket.gethostbyname(socket.gethostname())
Host_IP=str(ip)

print '\n'+'-------------------------------------------------------'
print '     WELCOME TO XMOS UDP BROADCAST SERVER FOR S2E      '
print '-------------------------------------------------------' + '\n'

print 'Your IP Address is :' +Host_IP +'\n'
option=raw_input( "Press 'y' to continue or 'n' to enter your IP address (y/n):")
option=str(option)
if( option == 'n'):
	Host_IP = raw_input('Enter Your IP Address : ') # IP from where python scripts are running
	Host_IP=str(Host_IP)


print '\n' + 'Using Default Send Port : ' + str(send_port)
print 'Using Default Receive Port : ' + str(recv_port)

s = socket.socket( socket.AF_INET, socket.SOCK_DGRAM ) # Socket for sending data
s1 = socket.socket( socket.AF_INET, socket.SOCK_DGRAM ) # Socket for Listening Data

sock = socket.socket( socket.AF_INET, socket.SOCK_DGRAM ) # Socket fro Broadcasting Hello Message
sock.bind( ( '', 0 ) )
sock.setsockopt( socket.SOL_SOCKET, socket.SO_BROADCAST, 1 )
sock.sendto( 'XMOS S2E REPLY', ( '<broadcast>',  send_port ) )

print 'Brodcasted command: XMOS S2E REPLY '
    
try:   
    s1.bind( ( Host_IP, recv_port ) )
    msg_ack = s1.recv( 150 )
    
    print '\n' + 'Received Acknowledgement : ' + msg_ack  + '\n'

    i = 0
    version	= '- '
    mac_addr	= '- '
    ip_addr	= '- '
    while(msg_ack[i]!= 'V'):
    	i+=1;
    
    while msg_ack[ i ] != ';' :
        version = version + msg_ack[ i ]
        i+=1
    i=i+1
    while msg_ack[ i ] != ';' :
        mac_addr = mac_addr + msg_ack[ i ]
        i+=1
    i=i+1
    while  (i) != len(msg_ack) :
        ip_addr = ip_addr + msg_ack[ i ]
        i+=1
    k=0
    Dest_IP=ip_addr[5:len(ip_addr)]
  
except Exception, msg:
    print msg
    s1.close()
    s.close()
    exit( 1 )

print '--------------S2E DETAILS----------------'
print version
print mac_addr
print ip_addr    
print '------------------------------------------'

try:
    inp=raw_input( 'Do u want to send IP change request (y/n) : ' ) # Sending IP Change Request
    if inp == 'y' :
    	ipaddress = raw_input('Input new IP adress : ' )
        s.sendto( "XMOS S2E IPCHANGE " + str( ipaddress ), ( Dest_IP, send_port ) )
	print ipaddress
      
    else:
        s1.close()
        s.close()
        exit( 1 )
    
except Exception, msg:
    print msg
    s1.close()
    s.close()

    exit( 1 )

try:
    s1.close()
    s.close()
    sec=raw_input('Enter time (sec) to wait for sending Broadcast Message : ')
    sec=int(sec)
    time.sleep(sec)
   
    s = socket.socket( socket.AF_INET, socket.SOCK_DGRAM ) # Socket for sending data
    s1 = socket.socket( socket.AF_INET, socket.SOCK_DGRAM ) # Socket for Listening Data

    sock = socket.socket( socket.AF_INET, socket.SOCK_DGRAM ) # Socket fro Broadcasting Hello Message
    sock.bind( ( '', 0 ) )
    sock.setsockopt( socket.SOL_SOCKET, socket.SO_BROADCAST, 1 )
    sock.sendto( 'XMOS S2E REPLY', ( '<broadcast>',  send_port ) )

    print 'Brodcasted command: XMOS S2E REPLY '

    s1.bind( ( Host_IP, recv_port ) )
    msg_ack = s1.recv( 150 )
    
    print '\n' + 'Received Acknowledgement : ' + msg_ack  + '\n'

    i = 0
    version	= '- '
    mac_addr	= '- '
    ip_addr	= '- '
    while(msg_ack[i]!= 'V'):
    	i+=1;
    
    while msg_ack[ i ] != ';' :
        version = version + msg_ack[ i ]
        i+=1
    i=i+1
    while msg_ack[ i ] != ';' :
        mac_addr = mac_addr + msg_ack[ i ]
        i+=1
    i=i+1
    while  (i) != len(msg_ack) :
        ip_addr = ip_addr + msg_ack[ i ]
        i+=1
    k=0
    Dest_IP=ip_addr[5:len(ip_addr)]
  	
     
    print '--------------S2E DETAILS----------------'
    print version
    print mac_addr
    print ip_addr
    print '------------------------------------------'+'\n'+'\n'
    
except Exception,msg:
    print msg
    s1.close()
    s.close()
    exit( 1 )
inp=raw_input(' -- @@ -- PRESS ANY KEY TO EXIT -- @@ -- ')
s1.close()
s.close()
