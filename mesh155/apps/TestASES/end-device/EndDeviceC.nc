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
#include "app_profile.h"

module EndDeviceC
{
  uses {
    interface Boot;
    interface Leds;

    // MESH Layer
    interface MHME_RESET;
    interface MHME_DISCOVER;
    interface MHME_JOIN;
    interface MHME_SET;
    interface MHME_GET;
    interface MESH_DATA;

	// MAC layer
    interface MLME_SET;
    interface MLME_GET;

    interface Timer<T62500hz> as DiscoverNetworksTimer;
    interface Timer<T62500hz> as DataTimer;

    // MTS300 sensor board
    interface Read<uint16_t> as Temp;
  }
}
implementation
{
	bool m_dataConfirmPending;
	uint16_t reading;
	uint16_t readings[NREADINGS];
	uint8_t m_payloadLen;

  	//Functions
	void startApp();
	uint16_t TempADCtoCelsius(uint16_t data);

	event void Boot.booted() {
		call MHME_RESET.request();
	}

	event void MHME_RESET.confirm(ieee155_status_t status)
	{
		startApp();
	}

  	void startApp()
  	{
	  	ieee155_meshCapabilityInformation_t mesh_CapabilityInfo;
	  	ieee154_phyChannelsSupported_t channelMask = 0;
	  	channelMask += ((uint32_t) 1) << RADIO_CHANNEL;

	  	m_payloadLen = NREADINGS * sizeof(uint16_t);
	  	reading = 0;

	  	call MHME_SET.meshAcceptMeshDevice(FALSE);
		call MHME_SET.meshAcceptEndDevice(FALSE);

	 	mesh_CapabilityInfo.DeviceType = FALSE;
		mesh_CapabilityInfo.PowerSource = FALSE;
		mesh_CapabilityInfo.ReceiverOnWhenIdle = TRUE;
		mesh_CapabilityInfo.AllocateAddress = TRUE;
	  	call MHME_SET.meshCapabilityInformation(mesh_CapabilityInfo);
	  	call MHME_SET.meshASESExpected(TRUE);
	  	call MHME_SET.meshActiveOrder(ACTIVE_ORDER);
	  	call MHME_SET.meshWakeupOrder(WAKEUP_ORDER);

	  	//Setting attributes of the MAC Layer Management Entity
	  	call MLME_SET.phyTransmitPower(TX_POWER);
	    call MLME_SET.phyCurrentChannel(RADIO_CHANNEL);

	    //We only scan the single channel on which we expect the MC
	    call MHME_DISCOVER.request(channelMask,	5, 0x00, RSSI);
  	}


//----------------------- MHME_DISCOVER -----------------------//

	event void MHME_DISCOVER.confirm(ieee154_status_t status, uint8_t NetworkCount, ieee155_MDT_t* MeshDescriptorList)
	{
		uint8_t scanIndex = 0, logicalChannel = 0;
		uint16_t parentTreeLvl = 0, PANIdToJoin = 0;
		bool parentFound = FALSE;
		uint16_t parentShortAddress = 0xFFFF;
		ieee154_phyChannelsSupported_t channelMask = 0;

		if(status == IEEE154_SUCCESS)
		{
			for(scanIndex = 0; scanIndex < NetworkCount; scanIndex++)
			{
				if((MeshDescriptorList[scanIndex].Address != 0xFFFF)
					&& (MeshDescriptorList[scanIndex].PANId != 0XFFFF)
					&& (MeshDescriptorList[scanIndex].Address == 0x26B5))	// Mesh Device 4 (MD-4)
				{
					if(((call MHME_GET.meshDeviceType() == MESH_DEVICE) && (MeshDescriptorList[scanIndex].AcceptMeshDevice == TRUE))
							|| ((call MHME_GET.meshDeviceType() == END_DEVICE) && (MeshDescriptorList[scanIndex].AcceptEndDevice == TRUE)))
					{
						PANIdToJoin = MeshDescriptorList[scanIndex].PANId;
						parentShortAddress = MeshDescriptorList[scanIndex].Address;
						parentTreeLvl = MeshDescriptorList[scanIndex].TreeLevel;
						logicalChannel = MeshDescriptorList[scanIndex].LogicalChannel;
						parentFound = TRUE;
					}
				}
			}
			if(parentFound)
			{
				call MHME_SET.meshTreeLevel(parentTreeLvl + 1);
				if(parentTreeLvl == 0)
					call MLME_SET.macAssociatedPANCoord(TRUE);
				else
					call MLME_SET.macAssociatedPANCoord(FALSE);

				channelMask = ((uint32_t) 1) << logicalChannel;

				call MHME_JOIN.request(
						TRUE,
						parentShortAddress,
						PANIdToJoin,
						0x00,
						FALSE,
						channelMask,
						5,
						0x00,
						call MHME_GET.meshCapabilityInformation());
			}
			else
				call DiscoverNetworksTimer.startOneShot(3 * 62500U);
		}
		else
			call DiscoverNetworksTimer.startOneShot(3 * 62500U);
	}

	event void DiscoverNetworksTimer.fired()
	{
		ieee154_phyChannelsSupported_t channelMask = 0;
		channelMask += ((uint32_t) 1) << RADIO_CHANNEL;
		call MHME_DISCOVER.request(channelMask,	MAX_MDT_SIZE, 0x00, RSSI);
	}

	//---------------------- MHME_JOIN----------------------------//

	event void MHME_JOIN.indication(uint16_t NetworkAddress,uint64_t ExtendedAddress, ieee154_CapabilityInformation_t CapabilityInformation, uint8_t RejoinNetwork){}

	event void MHME_JOIN.confirm(uint8_t status, uint16_t NetworkAddress, uint16_t PANId, uint8_t ChannelPage, uint8_t ActiveChannel)
	{
		if(status == IEEE154_ASSOCIATION_SUCCESSFUL)
		{
			call Leds.led1On();
			call DataTimer.startPeriodic(DATA_TRANSFER_PERIOD);
		}
		else
			call MHME_RESET.request();
	}

	event uint8_t* MESH_DATA.indication (
									uint8_t SrcAddrMode,
									uint16_t SrcPANId,
									ieee154_address_t SourceAddress,
									uint8_t mhsduLen,
									uint8_t* mhsdu
								)
	{
		return mhsdu;
	}

	event void MESH_DATA.confirm (uint8_t mhpduHandle, ieee154_status_t status, uint8_t* mhsdu)
	{
		if(status == IEEE154_SUCCESS)
			call Leds.led2Toggle();
		m_dataConfirmPending = FALSE;
	}

	event void DataTimer.fired()
  	{
	    ieee155_address_t destinationAddress;
	    uint8_t mhsdu[m_payloadLen];

	    destinationAddress.shortAddress = SINK_ADDRESS; // destination

	    if(reading == NREADINGS)
	    {
	    	reading = 0;
	    	if (m_dataConfirmPending)
	      		return;

	    	memcpy(mhsdu, readings, m_payloadLen);
	    	if(call MESH_DATA.request (SHORT_ADDR_MODE,
              		SHORT_ADDR_MODE,
              		destinationAddress,
              		m_payloadLen,
              		mhsdu,
              		0,
              		TRUE,
              		FALSE,
              		FALSE,
              		FALSE) == IEEE155_FAIL)
				m_dataConfirmPending = FALSE;
		}
		if(call Temp.read() != SUCCESS)
			call Leds.led1Toggle();
  	}

  	event void Temp.readDone(error_t result, uint16_t val) {
  	 	uint16_t celsius;
  	 	if (result != SUCCESS)
  	 	{
  	 		val = 0xFFFF;
  	 		call Leds.led0Toggle();
  	 	}
  	 	if (reading < NREADINGS)
  	 	{
  	 		celsius = TempADCtoCelsius(val);
  	 		readings[reading++] = celsius;
  	 	}
  	}

  	uint16_t TempADCtoCelsius(uint16_t data)
  	{
  		uint16_t dataInt = 0;
  		double a = 0.001307050;
  		double b = 0.000214381;
  		double c = 0.000000093;
  		double sensorData = (double)data;
  		double temp = 0, rthr = 0, aux = 0;

  		rthr = 10000 * ((1023 - sensorData) / sensorData);
  		temp = 1 / (a + (b * log(rthr)) + (c * pow(log(rthr), 3)));

  		temp = temp - 273.15;
  		aux = (double)temp - (double)(floor(temp));

  		if(aux <= 0.5)
  			dataInt = (uint16_t)(floor(temp));
  		else
  			dataInt = (uint16_t)(ceil(temp));

  		return dataInt;
  	}
}
