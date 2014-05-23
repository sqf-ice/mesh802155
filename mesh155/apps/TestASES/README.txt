
/*
 * Copyright (c) 2013-2014, Technical University of Cartagena
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright 
 *   notice, this list of conditions and the following disclaimer in the 
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technical University of Cartagena nor the names 
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Revision -------------------------------------------------------------
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */
 
README for TestASES
Author/Contact: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>

Description:

In this application one node takes the role of mesh coordinator (MC) of an IEEE 
802.15.5 LR-WPAN Mesh. The MC initiates a mesh network, and waits for new
devices requesting for joining the network. Whenever a device tries to
join, the mesh coordinator accepts it. Other four nodes act as intermediate
devices (mesh-devices), and a fifth node acts as end-device. All of them,
the mesh-devices and the end-device switch to the pre-defined channel by the
MC and then try to join it. Once all nodes join the network, the following tree
multi-hop topology is formed:

MC (0x0000) <--> MD-1 (0x75E2) <--> MD-2 (0xB0D3) <--> MD-3 (0xEBC4) <--> MD-4 (0x26B5) <--> ED-1 (0x9C97)

		MC = Mesh Coordinator
		MD-<ID> = Mesh Device i, i = 1,2,3,4
		ED = End Device

	The numbers as <0x75E2> are the mac addresses of devices, randomly generated
	by TKN154 libraries, and obtained through testing.

Once the tree multi-hop topology is completed, it begins the address assignment
process as defined by the IEEE 802.15.5 standard. Every node requests for a logical
short address (16-bit IEEE). Furthermore, mesh devices request for other 2 additional
addresses as extra space for future use (e.g., new nodes willing to join). On the other
hand, the MC reserves the logical short address 0 (0x0000); and the end-device requests
only for one address.

Following with the mesh formation, it starts the mesh links generation phase. At this
point, every node broadcasts several Hello messages to share the information stored
in its neighbor list with every node in coverage range. After several Hello
messages and once the neighbor list of every node contains information of all neighbors
placed up to k=2 hops, the mesh topology is finally formed. Note that if all nodes are
in coverage area, then all of them will communicate with each other (no multi-hop). So pay
attention to the emplacements of devices and the transmission power (see app_profile.h).

Once completed the above procedure, every node begins to operate using an asynchronous
energy-saving mode, which is compatible with the Asynchronous Energy Saving mode defined
by the IEEE 802.15.5 standard). Then, the end-device begin transmitting data periodically
every 5 seconds with destination the Mesh Coordinator.

Criteria for a successful test:

Assuming one coordinator, four mesh-devices and one end-device has been installed, all
nodes different from the MC should switch on LED1, whilst MC should switch on all LEDs.
This indicates that the MC has initiated the network sussessfully, the rest of nodes
joined correctly, obtained a logical short address, every node completed its
neighbor list and initiated the asynchronous mode. Once the end-device begin
transmitting data, the MC should toggle the LED2 periodically. That's all.


Tools:
	Degug using printf libraries:
	java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSBx:<platform>

Usage:

1. 	Install the coordinator:

    $ cd coordinator; make <platform> install

2.	Install each of the four mesh-devices. It should be done as follows:

    $ cd mesh-device-1; make <platform> install,1
    $ cd mesh-device-2; make <platform> install,2
    $ cd mesh-device-3; make <platform> install,3
    $ cd mesh-device-4; make <platform> install,4

3. Install one (or more until 4 end-devices, all of them connected to the MD4) end-devices.
   It should be indicated a different number <ID> for each new mesh-device, ID > 4

    $ cd end-device; make <platform> install,<ID>

Some of the configuration parameters here used can be modified through app_profile.h


Known bugs/limitations: NONE

$Id: README.txt,v 1.0 2013-06-03 10:41:02 davidrodenasherraiz Exp $o
