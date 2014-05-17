/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"
#include "app_profile.h"

module coordinatorC
{
	uses {
		interface Boot;
		interface Leds;

		// MESH layer
		interface MHME_RESET;
		interface MHME_SET;
		interface MHME_GET;
		interface MHME_JOIN;
		interface MHME_START_NETWORK;
		interface MESH_DATA;

		// MAC layer
		interface MLME_SET;
		interface MLME_GET;
	}
}
implementation
{
 	event void Boot.booted()
 	{
 		call MHME_RESET.request();
  	}

	event void MHME_RESET.confirm(ieee155_status_t status)
	{
		ieee154_phyChannelsSupported_t channelMask = 0;

		channelMask += ((uint32_t) 1) << RADIO_CHANNEL;

		call MLME_SET.phyTransmitPower(TX_POWER);
		call MHME_SET.meshDeviceType(MESH_COORD);

		call MHME_SET.meshPANId(PAN_ID);
		call MHME_SET.meshAcceptMeshDevice(TRUE);
		call MHME_SET.meshAcceptEndDevice(TRUE);
		call MHME_SET.meshASESExpected(TRUE);
	  	call MHME_SET.meshActiveOrder(ACTIVE_ORDER);
	  	call MHME_SET.meshWakeupOrder(WAKEUP_ORDER);

		// Start the network
		call MHME_START_NETWORK.request(channelMask, 5, 0, 15, 15);
	}

	event void MHME_START_NETWORK.confirm(ieee155_status_t status) {
		call Leds.led0On(); call Leds.led1On(); call Leds.led2On();
	}

	event void MHME_JOIN.indication(uint16_t NetworkAddress,uint64_t ExtendedAddress, ieee154_CapabilityInformation_t CapabilityInformation, uint8_t RejoinNetwork)
	{
	}

	event void MHME_JOIN.confirm(uint8_t status, uint16_t NetworkAddress, uint16_t PANId, uint8_t ChannelPage, uint8_t ActiveChannel) {}

	event uint8_t* MESH_DATA.indication (
									uint8_t SrcAddrMode,
									uint16_t SrcPANId,
									ieee154_address_t SourceAddress,
									uint8_t mhsduLen,
									uint8_t *mhsdu
								)
	{
		// we received a data message -> toggle LED2
    	call Leds.led2Toggle();
		return mhsdu;
	}

	event void MESH_DATA.confirm (uint8_t mhpduHandle, ieee154_status_t status, uint8_t *mhsdu)
	{}
}

