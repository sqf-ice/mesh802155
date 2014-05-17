/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"
#include "app_profile.h"

module meshDeviceC
{
  uses {
    interface Boot;
    interface Leds;

    // MESH layer
    interface MHME_RESET;
    interface MHME_SET;
    interface MHME_GET;

    interface MHME_DISCOVER;
    interface MHME_START_DEVICE;
    interface MHME_JOIN;
    interface MESH_DATA;

	// MAC layer
	interface MLME_SET;
    interface MLME_GET;

    interface Timer<T62500hz> as DiscoverNetworksTimer;
  }
} implementation {

  	//Functions
	void startApp();

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

 	  	//Setting MESH attributes
    	mesh_CapabilityInfo.DeviceType = TRUE;
		mesh_CapabilityInfo.PowerSource = FALSE;
		mesh_CapabilityInfo.ReceiverOnWhenIdle = TRUE;
		mesh_CapabilityInfo.AllocateAddress = TRUE;
		call MHME_SET.meshCapabilityInformation(mesh_CapabilityInfo);
    	call MHME_SET.meshAcceptMeshDevice(TRUE);
		call MHME_SET.meshAcceptEndDevice(TRUE);
		call MHME_SET.meshChildNbReportTime(15);
		call MHME_SET.meshASESExpected(TRUE);
	  	call MHME_SET.meshActiveOrder(ACTIVE_ORDER);
	  	call MHME_SET.meshWakeupOrder(WAKEUP_ORDER);

	  	//Setting MAC attributes
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
					&& (MeshDescriptorList[scanIndex].Address == 0x0000))	// Mesh Coordinator
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

				channelMask += ((uint32_t) 1) << logicalChannel;

				call MHME_JOIN.request(
						TRUE,
						parentShortAddress,
						PANIdToJoin,
						0x00,
						TRUE,
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

	event void MHME_JOIN.indication(uint16_t NetworkAddress,uint64_t ExtendedAddress, ieee154_CapabilityInformation_t CapabilityInformation, uint8_t RejoinNetwork)
	{
	}

	event void MHME_JOIN.confirm(uint8_t status, uint16_t NetworkAddress, uint16_t PANId, uint8_t ChannelPage, uint8_t ActiveChannel)
	{
		if(status == IEEE154_ASSOCIATION_SUCCESSFUL)
			call Leds.led1On();
		else
			call MHME_RESET.request();
	}

	//---------------------- MHME_START_DEVICE-------------------//
	event void MHME_START_DEVICE.confirm (ieee154_status_t status) { }

	//---------------------- MESH_DATA-------------------//
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

	event void MESH_DATA.confirm (uint8_t mhpduHandle, ieee154_status_t status, uint8_t *mhsdu)
	{}
 }

