
""" sending OSC with pyOSC
https://trac.v2.nl/wiki/pyOSC
example by www.ixi-audio.net based on pyOSC documentation
"""


import OSC
import time, random

"""
note that if there is nobody listening in the other end we get an error like this
    OSC.OSCClientError: while sending: [Errno 111] Connection refused
so we need to have an app listening in the receiving port for this to work properly

this is a very basic example, for detailed info on pyOSC functionality check the OSC.py file 
or run pydoc pyOSC.py. you can also get the docs by opening a python shell and doing
>>> import OSC
>>> help(OSC)
"""


## the most basic ##
client = OSC.OSCClient()
msg = OSC.OSCMessage()
msg.setAddress("/print")
msg.append(1234)
client.sendto(msg, ('127.0.0.1', 9000)) # note that the second arg is a tupple and not two arguments



## better practice ##
client = OSC.OSCClient()
client.connect( ('127.0.0.1', 9000) ) # note that the argument is a tupple and not two arguments
msg = OSC.OSCMessage() #  we reuse the same variable msg used above overwriting it
msg.setAddress("/print")
msg.append(4321)
client.send(msg) # now we dont need to tell the client the address anymore





## in mode detail ##



# tupple with ip, port. i dont use the () but maybe you want -> send_address = ('127.0.0.1', 9000)
send_address = '127.0.0.1', 9000

# OSC basic client
c = OSC.OSCClient()
c.connect( send_address ) # set the address for all following messages


# single message
msg = OSC.OSCMessage()
msg.setAddress("/print") # set OSC address
msg.append(44) # int
msg.append(4.5233) # float
msg.append( "the white cliffs of dover" ) # string

c.send(msg) # send it!


# bundle : few messages sent together
# use them to send many different messages on every loop for instance in a game. saves CPU and it is faster
bundle = OSC.OSCBundle()
bundle.append(msg) # append prev mgs
bundle.append( {'addr':"/print", 'args':["bundled messages:", 2]} ) # and some more stuff ...
bundle.setAddress("/*print")
bundle.append( ("no,", 3, "actually.") )

c.send(bundle) # send it!




# lets try sending a different random number every frame in a loop

try :
    seed = random.Random() # need to seed first 
    
    while 1: # endless loop
        rNum= OSC.OSCMessage()
        rNum.setAddress("/print")
        n = seed.randint(1, 1000) # get a random num every loop
        rNum.append(n)
        c.send(rNum)
        time.sleep(5) # wait here some secs

except KeyboardInterrupt:
    print "Closing OSCClient"
    c.close()
    print "Done"
        
