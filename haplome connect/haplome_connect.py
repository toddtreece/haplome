# 
# connect.py
#  __                        ___                                       
# /\ \                      /\_ \                                      
# \ \ \___      __     _____\//\ \     ___    ___ ___      __          
#  \ \  _ `\  /'__`\  /\ '__`\\ \ \   / __`\/' __` __`\  /'__`\        
#   \ \ \ \ \/\ \L\.\_\ \ \L\ \\_\ \_/\ \L\ \\ \/\ \/\ \/\  __/        
#    \ \_\ \_\ \__/.\_\\ \ ,__//\____\ \____/ \_\ \_\ \_\ \____\       
#     \/_/\/_/\/__/\/_/ \ \ \/ \/____/\/___/ \/_/\/_/\/_/\/____/       
#                        \ \_\                                         
#                         \/_/
# haplome connect
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# Created by Todd Treece on 12/1/10.
# Copyright 2010 Todd Treece. All rights reserved.
#

import select
import socket
import sys
import pybonjour
import OSC
import time, random, threading

regtype  = '_haplome_osc._udp'
inPort = int(sys.argv[1])
outPort = int(sys.argv[2])
client = OSC.OSCClient()
receive_address = '127.0.0.1', inPort
msg = OSC.OSCMessage()
connected = False
haplomePort = 1234
haplomeIP = ''
localIP = ''
timeout  = 5
queried  = []
resolved = []

def message_handler(addr, tags, stuff, source):
    msg = OSC.OSCMessage()
    msg.setAddress(addr)
    msg.append(stuff)
    client.send(msg)


def query_record_callback(sdRef, flags, interfaceIndex, errorCode, fullname,
                          rrtype, rrclass, rdata, ttl):
    if errorCode == pybonjour.kDNSServiceErr_NoError:
        global connected
        global client
        haplomeIP = socket.inet_ntoa(rdata)
        localIP = socket.gethostbyname(socket.getfqdn())
        if connected == False:
            global server
            global serverThread
            client.connect( (haplomeIP, haplomePort) )
       	    server = OSC.OSCServer(receive_address)
            server.addMsgHandler("default", message_handler)
            serverThread = threading.Thread( target = server.serve_forever )
            serverThread.start()
            connected = True
		
        msg = OSC.OSCMessage()
        msg.setAddress("/sys/connection")
        msg.append(localIP)
        msg.append(outPort)
        client.send(msg)
        queried.append(True)


def resolve_callback(sdRef, flags, interfaceIndex, errorCode, fullname,
                     hosttarget, port, txtRecord):
    if errorCode != pybonjour.kDNSServiceErr_NoError:
        return

    print 'Connected.'
    haplomePort = port

    query_sdRef = \
        pybonjour.DNSServiceQueryRecord(interfaceIndex = interfaceIndex,
                                        fullname = hosttarget,
                                        rrtype = pybonjour.kDNSServiceType_A,
                                        callBack = query_record_callback)

    try:
        while not queried:
            ready = select.select([query_sdRef], [], [], timeout)
            if query_sdRef not in ready[0]:
                print 'Query record timed out'
                break
            pybonjour.DNSServiceProcessResult(query_sdRef)
        else:
            queried.pop()
    finally:
        query_sdRef.close()

    resolved.append(True)


def browse_callback(sdRef, flags, interfaceIndex, errorCode, serviceName,
                    regtype, replyDomain):
    if errorCode != pybonjour.kDNSServiceErr_NoError:
        return

    if not (flags & pybonjour.kDNSServiceFlagsAdd):	
        print 'Disconnected.'
        sys.exit(0)
        return

    print 'Attempting to connect...'

    resolve_sdRef = pybonjour.DNSServiceResolve(0,
                                                interfaceIndex,
                                                serviceName,
                                                regtype,
                                                replyDomain,
                                                resolve_callback)

    try:
        while not resolved:
            ready = select.select([resolve_sdRef], [], [], timeout)
            if resolve_sdRef not in ready[0]:
                print 'Resolve timed out'
                break
            pybonjour.DNSServiceProcessResult(resolve_sdRef)
        else:
            resolved.pop()
    finally:
        resolve_sdRef.close()


browse_sdRef = pybonjour.DNSServiceBrowse(regtype = regtype,
                                          callBack = browse_callback)


try:
    try:
        while True:
            ready = select.select([browse_sdRef], [], [])
            if browse_sdRef in ready[0]:
                pybonjour.DNSServiceProcessResult(browse_sdRef)
    except KeyboardInterrupt:
        pass
finally:
    global server
    global serverThread
    browse_sdRef.close()
    print "\nClosing OSCServer."
    server.close()
    print "Waiting for Server-thread to finish"
    serverThread.join() ##!!!
    print "Done"