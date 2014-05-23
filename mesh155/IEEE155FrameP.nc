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

#include "Mesh155.h"

module IEEE155FrameP
{
  provides
  {
		interface IEEE155Frame;
  }
}

implementation
{
	// GET FUNCTIONS
	command	uint8_t IEEE155Frame.getHeaderLength(uint8_t* mhpdu)
	{
		uint8_t offset = 0;
		offset = sizeof(uint16_t); 	// Frame Control

		offset += ((call IEEE155Frame.getDstAddrMode(mhpdu) == SHORT_ADDR_MODE) ? sizeof(uint16_t) : sizeof(uint64_t));
		offset += ((call IEEE155Frame.getSrcAddrMode(mhpdu) == SHORT_ADDR_MODE) ? sizeof(uint16_t) : sizeof(uint64_t));
		return offset;
	}

	command uint8_t IEEE155Frame.getProtocolVersion(uint8_t* mhpdu)
	{
		uint8_t protoVer;
		nx_uint16_t frameControl;

		memcpy(&frameControl, mhpdu, sizeof(uint16_t));
		protoVer = ((frameControl & 0xF000) >> 12);

		return protoVer;
	}

	command uint8_t IEEE155Frame.getFrameType(uint8_t* mhpdu)
	{
		uint8_t frameType;
		nx_uint16_t frameControl;

		memcpy(&frameControl, mhpdu, sizeof(uint16_t));

		frameType = ((frameControl & 0x0800) >> 11);
		return frameType;
	}

	command	uint8_t IEEE155Frame.getDstAddrMode(uint8_t* mhpdu)
	{
		uint8_t dstAddrMode;
		nx_uint16_t frameControl;

		memcpy(&frameControl, mhpdu, sizeof(uint16_t));
		dstAddrMode = ((frameControl & 0x0400) >> 10);

		return dstAddrMode;
	}

	command	uint8_t IEEE155Frame.getSrcAddrMode(uint8_t* mhpdu)
	{
		uint8_t srcAddrMode;
		nx_uint16_t frameControl;

		memcpy(&frameControl, mhpdu, sizeof(uint16_t));
		srcAddrMode = ((frameControl & 0x0200) >> 9);
		return srcAddrMode;
	}

	command	uint8_t IEEE155Frame.getTxOptions(uint8_t* mhpdu)
	{
		uint8_t txOpt = 0;
		nx_uint16_t frameControl;

		memcpy(&frameControl, mhpdu, sizeof(uint16_t));
		txOpt = ((frameControl & 0x01E0) >> 5);

		return txOpt;
	}

	command void IEEE155Frame.getDstAddress(uint8_t* mhpdu, ieee155_address_t * dstAddr)
	{
		nx_uint16_t shortAddr;
		nx_uint64_t extAddr;

		if(call IEEE155Frame.getDstAddrMode(mhpdu) == SHORT_ADDR_MODE)
		{
			memcpy(&shortAddr, mhpdu + sizeof(uint16_t), sizeof(uint16_t));
			dstAddr->shortAddress = shortAddr;
		}
		else
		{
			memcpy(&extAddr, mhpdu + sizeof(uint16_t), sizeof(uint64_t));
			dstAddr->extendedAddress = extAddr;
		}
	}

	command void IEEE155Frame.getSrcAddress(uint8_t* mhpdu, ieee155_address_t * srcAddr)
	{
		uint8_t dstOffset = 0;
		nx_uint16_t shortAddr;
		nx_uint64_t extAddr;

		dstOffset = ((call IEEE155Frame.getDstAddrMode(mhpdu) == SHORT_ADDR_MODE) ? sizeof(uint16_t) : sizeof(uint64_t));
		if(call IEEE155Frame.getSrcAddrMode(mhpdu) == SHORT_ADDR_MODE)
		{
			memcpy(&shortAddr, mhpdu + sizeof(uint16_t) + dstOffset, sizeof(uint16_t));
			srcAddr->shortAddress = shortAddr;
		}
		else
		{
			memcpy(&extAddr, mhpdu + sizeof(uint16_t) + dstOffset, sizeof(uint64_t));
			srcAddr->extendedAddress = extAddr;
		}
	}

	command uint16_t IEEE155Frame.getDstShortAddress(uint8_t* mhpdu)
	{
		ieee155_address_t dstAddr;
		call IEEE155Frame.getDstAddress(mhpdu, &dstAddr);
		return dstAddr.shortAddress;
	}

	command uint16_t IEEE155Frame.getSrcShortAddress(uint8_t* mhpdu)
	{
		ieee155_address_t srcAddr;
		call IEEE155Frame.getSrcAddress(mhpdu, &srcAddr);

		return srcAddr.shortAddress;
	}

	command uint8_t* IEEE155Frame.getPayload(uint8_t* mhpdu)
	{
		uint8_t * mhsdu;
		uint8_t offset;

		offset = sizeof(uint16_t);
		offset += (call IEEE155Frame.getDstAddrMode(mhpdu) == SHORT_ADDR_MODE) ? sizeof(uint16_t) : sizeof(uint64_t);
		offset += (call IEEE155Frame.getSrcAddrMode(mhpdu) == SHORT_ADDR_MODE) ? sizeof(uint16_t) : sizeof(uint64_t);

		return mhsdu = mhpdu + offset;
	}

	command uint8_t IEEE155Frame.getCommandType(uint8_t* mhpdu)
 	{
 		uint8_t* mhsdu = NULL;
 		mhsdu = call IEEE155Frame.getPayload(mhpdu);
 		return mhsdu[0];
 	}

	command uint8_t IEEE155Frame.getSequenceNumber(uint8_t* mhpdu)
	{
		uint8_t* mhsdu = NULL;
 		mhsdu = call IEEE155Frame.getPayload(mhpdu);
 		return mhsdu[0];
	}
	command uint8_t IEEE155Frame.getRoutingControl(uint8_t* mhpdu)
	{
		uint8_t* mhsdu = NULL;
 		mhsdu = call IEEE155Frame.getPayload(mhpdu);
 		return mhsdu[1];
	}

	// SET FUNCTIONS
	command void IEEE155Frame.setAddressingFields(uint8_t* mhpdu,
							uint8_t *offset,
							uint8_t frameType,
							uint8_t dest_AddrMode,
							uint8_t src_AddrMode,
							ieee155_address_t destAddress,
							ieee155_address_t sourceAddress,
							uint8_t txOptions)
	{
		nx_uint16_t frameControl;
		nx_uint16_t srcAddr16, dstAddr16;
		nx_uint64_t srcAddr64, dstAddr64;

		if(mhpdu == NULL)
			return;	// IEEE155_INVALID_MESH_FRAME

		frameControl = 0;
		frameControl = (frameControl & 0x0FFF) + (((uint16_t)PROTOCOL_VERSION) << 12);
		frameControl = (frameControl & 0xF7FF) + (((uint16_t)frameType) << 11);
		frameControl = (frameControl & 0xFBFF) + (((uint16_t)dest_AddrMode) << 10);
		frameControl = (frameControl & 0xFDFF) + (((uint16_t)src_AddrMode) << 9);
		frameControl = (frameControl & 0xFE1F) + (((uint16_t)txOptions) << 5);
		memcpy(mhpdu, &frameControl, sizeof(uint16_t));

		*offset = sizeof(uint16_t);	// Mesh Control Frame

		if(dest_AddrMode == SHORT_ADDR_MODE)
		{
			dstAddr16 = destAddress.shortAddress;
			memcpy(mhpdu + *offset, &dstAddr16, sizeof(uint16_t));
			*offset += sizeof(uint16_t);
		}
		else
		{
			dstAddr64 = destAddress.extendedAddress;
        	memcpy(mhpdu + *offset, &dstAddr64, sizeof(uint64_t));
        	*offset += sizeof(uint64_t);
        }

   		if(src_AddrMode == SHORT_ADDR_MODE)
   		{
   			srcAddr16 = sourceAddress.shortAddress;
	 		memcpy(mhpdu + *offset, &srcAddr16, sizeof(uint16_t));
	 		*offset += sizeof(uint16_t);
		}
   		else
   		{
   			srcAddr64 = sourceAddress.extendedAddress;
   			memcpy(mhpdu + *offset, &srcAddr64, sizeof(uint16_t));
   			*offset += sizeof(uint64_t);
   		}
	}

	/*
	 * Command: Children Number Report (See 5.3.2.2.1)
	 * Command frame identifier: 0x01
	 * Mandatory
	*/

	command void IEEE155Frame.ChildrenNbReport(
										uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint16_t numOfDesc,
										uint16_t numOfReqAddr)
	{
		uint8_t ID = CHILDREN_NUMBER_REPORT;
		uint8_t offset = 0;
  		nx_uint16_t nx_numOfDesc;
		nx_uint16_t nx_numOfReqAddr;

	  	nx_numOfDesc = numOfDesc;
  		nx_numOfReqAddr = numOfReqAddr;

		/* 1. We populate the Mesh Sublayer Header */
		call IEEE155Frame.setAddressingFields(mhpdu,
							&offset,
							COMMAND_FRAME,
							dest_AddrMode,
							src_AddrMode,
							destAddress,
							sourceAddress,
							MESH_TX_OPTIONS_ACK);


		/* 2. We populate the Data Frame Mesh Sublayer Payload of Children Number Report command  */
		// Command Frame Identifier
		memcpy(mhpdu + offset, &ID, sizeof(uint8_t));
	 	offset += sizeof(uint8_t);
	  	// Number of Descendants
		memcpy(mhpdu + offset, &nx_numOfDesc, sizeof(uint16_t));
	  	offset += sizeof(uint16_t);
	  	// Number of Requested Addresses
		memcpy(mhpdu + offset, &nx_numOfReqAddr, sizeof(uint16_t));
	}

	/*
	 * Command: Address assignment (See 5.3.2.2.2)
	 * Command frame identifier: 0x02
	 * Mandatory
	*/

	command void IEEE155Frame.AddressAssignment(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint16_t begAddr,
										uint16_t endAddr,
										uint16_t parentTreeLvl)
	{
		uint8_t ID = ADDRESS_ASSIGNMENT;
		uint8_t offset = 0;
		nx_uint16_t nx_begAddr, nx_endAddr, nx_ParentTreeLvl;

		nx_begAddr = begAddr;
		nx_endAddr = endAddr;
		nx_ParentTreeLvl = parentTreeLvl;

		/* 1. We populate the Mesh Sublayer Header */
		call IEEE155Frame.setAddressingFields(mhpdu,
							&offset,
							COMMAND_FRAME,
							dest_AddrMode,
							src_AddrMode,
							destAddress,
							sourceAddress,
							MESH_TX_OPTIONS_ACK);

		/* 2. We populate the Data Frame Mesh Sublayer Payload of Address Assignment command */
  		// Command Frame Identifier
   		memcpy(mhpdu + offset, &ID, sizeof(uint8_t));
	  	offset += sizeof(uint8_t);
	  	// Beginning Address
		memcpy(mhpdu + offset, &nx_begAddr, sizeof(uint16_t));
	  	offset += sizeof(uint16_t);
	  	// Ending Address
		memcpy(mhpdu + offset, &nx_endAddr, sizeof(uint16_t));
	  	offset += sizeof(uint16_t);
		// Tree Level of Parent Device
		memcpy(mhpdu + offset, &nx_ParentTreeLvl, sizeof(uint16_t));
	}

	/*
	 * Command: Hello (See 5.3.2.2.3)
	 * Command frame identifier: 0x03
	 * Mandatory
	*/
	command void IEEE155Frame.Hello(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t sourceAddress,
										uint8_t ttl,
										uint16_t begAddr,
										uint16_t endAddr,
										uint16_t treeLvl,
										uint8_t helloCtrl,
										uint8_t	numOfOneHopNb,
										uint8_t numOfMultiCastG)
	{
		uint8_t ID = HELLO;
		uint8_t offset = 0;
		nx_uint8_t nx_ttl, nx_helloCtrl, nx_numOfOneHopNb, nx_numOfMulticastG;
		nx_uint16_t nx_begAddr, nx_endAddr, nx_treeLvl;
		ieee155_address_t destAddress;

		if(dest_AddrMode == SHORT_ADDR_MODE)
			destAddress.shortAddress = 0xFFFF;
		else
			destAddress.extendedAddress = 0xFFFFFFFF;

		nx_ttl = ttl;
		nx_begAddr = begAddr;
		nx_endAddr = endAddr;
		nx_treeLvl = treeLvl;
		nx_helloCtrl = helloCtrl;
		nx_numOfOneHopNb = numOfOneHopNb;
		nx_numOfMulticastG = numOfMultiCastG;

		/* 1. We populate the Mesh Sublayer Header */
		call IEEE155Frame.setAddressingFields(mhpdu,
							&offset,
							COMMAND_FRAME,
							dest_AddrMode,
							src_AddrMode,
							destAddress,
							sourceAddress,
							MESH_TX_OPTIONS_BROADCAST);

		/* 2. We populate the Data Frame Mesh Sublayer Payload of Hello command */
		// Command Frame Identifier
   		memcpy(mhpdu + offset, &ID, sizeof(uint8_t));
		offset += sizeof(uint8_t);
		// TTL
		memcpy(mhpdu + offset, &nx_ttl, sizeof(uint8_t));
		offset += sizeof(uint8_t);
		// Beginning Address
		memcpy(mhpdu + offset, &nx_begAddr, sizeof(uint16_t));
		offset += sizeof(uint16_t);
	  	// Ending Address
		memcpy(mhpdu + offset, &nx_endAddr, sizeof(uint16_t));
		offset += sizeof(uint16_t);
		// Tree Level
		memcpy(mhpdu + offset, &nx_treeLvl, sizeof(uint16_t));
		offset += sizeof(uint16_t);
		// Hello Control
		memcpy(mhpdu + offset, &nx_helloCtrl, sizeof(uint8_t));
		offset += sizeof(uint8_t);
		// Number of One-hop Neighbors
		memcpy(mhpdu + offset, &nx_numOfOneHopNb, sizeof(uint8_t));
		offset += sizeof(uint8_t);
		// Number of Multicast Groups
		memcpy(mhpdu + offset, &nx_numOfMulticastG, sizeof(uint8_t));
		// Addresses of One-hop Neighbors away from the sender
		// and addresses of Multicast Groups ought to be added after
		// calling this function
	}

	/*
	 * Command: Wakeup notification (See 5.3.2.2.13)
	 * Command frame identifier: 0x0d
	 * Optional
	*/
	command void IEEE155Frame.WakeupNotification(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t sourceAddress,
										uint8_t asesTimeInfo)
	{
		uint8_t ID = WAKEUP_NOTIFICATION;
		uint8_t offset = 0;
		nx_uint8_t nx_asesTimeInfo;
		ieee155_address_t destAddress;

		nx_asesTimeInfo = asesTimeInfo;

		if(dest_AddrMode == SHORT_ADDR_MODE)
			destAddress.shortAddress = 0xFFFF;
		else
			destAddress.extendedAddress = 0xFFFFFFFF;

		/* 1. We populate the Mesh Sublayer Header */
		call IEEE155Frame.setAddressingFields(mhpdu,
							&offset,
							COMMAND_FRAME,
							dest_AddrMode,
							src_AddrMode,
							destAddress,
							sourceAddress,
							MESH_TX_OPTIONS_BROADCAST);

		/* 2. We populate the Data Frame Mesh Sublayer Payload of Wakeup Notification command */
  		// Command Frame Identifier
   		memcpy(mhpdu + offset, &ID, sizeof(uint8_t));
	  	offset += sizeof(uint8_t);
	  	// ASES Time Info
		memcpy(mhpdu + offset, &nx_asesTimeInfo, sizeof(uint16_t));
	}

	/*
	 * Command: Extension request (See 5.3.2.2.14)
	 * Command frame identifier: 0x0e
	 * Optional
	*/
	command void IEEE155Frame.EREQ(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint8_t extTime)
	{
		uint8_t ID = EXTENSION_REQUEST;
		uint8_t offset = 0;
		nx_uint8_t nx_extTime;

		nx_extTime = extTime;

		if(dest_AddrMode == SHORT_ADDR_MODE)
			destAddress.shortAddress = 0xFFFF;
		else
			destAddress.extendedAddress = 0xFFFFFFFF;

		/* 1. We populate the Mesh Sublayer Header */
		call IEEE155Frame.setAddressingFields(mhpdu,
							&offset,
							COMMAND_FRAME,
							dest_AddrMode,
							src_AddrMode,
							destAddress,
							sourceAddress,
							MESH_TX_OPTIONS_BROADCAST);

		/* 2. We populate the Data Frame Mesh Sublayer Payload of Extension REQuest command */
  		// Command Frame Identifier
   		memcpy(mhpdu + offset, &ID, sizeof(uint8_t));
	  	offset += sizeof(uint8_t);
	  	// Extension Time
		memcpy(mhpdu + offset, &nx_extTime, sizeof(uint16_t));
	}

	/*
	 * Command: Extension reply (See 5.3.2.2.15)
	 * Command frame identifier: 0x0f
	 * Optional
	*/
	command void IEEE155Frame.EREP(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress)
	{
		uint8_t ID = EXTENSION_REPLY;
		uint8_t offset = 0;

		if(dest_AddrMode == SHORT_ADDR_MODE)
			destAddress.shortAddress = 0xFFFF;
		else
			destAddress.extendedAddress = 0xFFFFFFFF;

		/* 1. We populate the Mesh Sublayer Header */
		call IEEE155Frame.setAddressingFields(mhpdu,
							&offset,
							COMMAND_FRAME,
							dest_AddrMode,
							src_AddrMode,
							destAddress,
							sourceAddress,
							MESH_TX_OPTIONS_BROADCAST);

		/* 2. We populate the Data Frame Mesh Sublayer Payload of Extension REPly command */
  		// Command Frame Identifier
   		memcpy(mhpdu + offset, &ID, sizeof(uint8_t));
	  	offset += sizeof(uint8_t);
	}
}

