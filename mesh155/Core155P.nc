/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

module Core155P
{
  provides
  {
    interface MHME_START_NETWORK;
    interface MHME_START_DEVICE;
    interface MHME_DISCOVER;
	interface MHME_JOIN;
    interface MESH_DATA;
    interface MESH_PURGE;
  }
  uses {
	interface MHME_GET;
	interface MHME_SET;
	interface IEEE155Frame as MeshFrame;
	interface NeighborList;
	interface Timer<T62500hz> as WaitingForAssociationsRequest;
	interface Timer<T62500hz> as ChildrenReportTimer;
	interface Timer<T62500hz> as HelloTimer;
	interface Timer<T62500hz> as WITimer;
   	interface Timer<T62500hz> as EREPTimer;
	interface DataForwarding;

	interface MLME_GET;
	interface MLME_SET;
	interface MLME_START;
	interface MLME_SCAN;
	interface IEEE154TxBeaconPayload;
	interface Random;
	interface MLME_BEACON_NOTIFY;
	interface IEEE154Frame as Frame;
	interface MLME_ASSOCIATE;
	interface MLME_COMM_STATUS;
	interface Leds;
	interface MCPS_DATA;
  	interface Packet;
  	interface MLME_RX_ENABLE;
   	interface MCPS_PURGE;

  	interface Queue<ieee155_txframe_t*>;
	interface Pool<ieee155_txframe_t>;
  }
}
implementation
{
	/* Variables */

	// Network Status
	ieee155_network_status_t networkStatus = NO_ASSOCIATED;

	// Variables and functions regarding MHME_START_NETWORK and MHME_START_DEVICE
	ieee154_phyChannelsSupported_t channelMask = 0;
	int8_t EDList [27];
	uint8_t BO, SO;
	uint8_t	scanDuration;

	void start_request(uint16_t PANID,
  					uint8_t LogicalChannel,
  					uint8_t ChannelPage,
  					bool PANC,
  					uint8_t BeaconOrder,
  					uint8_t SuperframeOrder);

	// Variables and functions regarding MHME_DISCOVER
	ieee155_MDT_t mdt[MAX_MDT_SIZE];
	bool blocked = TRUE;
	uint8_t MDT_SIZE;

	typedef struct beaconPayload{
		uint16_t beaconSAddr;
		uint8_t beaconPayload [4];
	}beaconPayload_t;

	beaconPayload_t bPayload[MAX_MDT_SIZE];
	uint8_t numBeaconPayload = 0;

	void populateMDT(ieee154_PANDescriptor_t* PANDescriptorList,
					uint8_t SIZE,
					ieee155_MDT_t* meshDiscoveryTable);

	message_t cmdFrame;
	uint16_t numOfReqAddr = 0;
	uint8_t nbOfChNR_recvd = 0;
	bool transmittingCmd = FALSE;

	task void sendChildrenNbReportCmd();
	task void sendAddressAssignmentCmd();

	task void sendHelloCmd();
	task void forwardData();
	uint8_t numHello = NUM_HELLO;

	bool transmittingData = FALSE;
	bool processingHello = FALSE;
	message_t dataFrame;
	uint8_t SN = 0;

	uint8_t ARC;
	uint16_t WI, AD, sourceEREP = 0xFFFF, pending_daddr = 0xFFFF;
	uint32_t WISymbol154, ADSymbol154, WI154Compliant, AD154Compliant;
	uint32_t dataTransactionTime, WNTransactionTime;
	bool pending_tx; // there are data pending for be transmitted
	bool WN_Recv;
	uint8_t minBE, macMaxCSMABackoffs;

	void startAsynchronousEnergySaving(void);
	task void sendWakeupNotificationCmd();
	task void sendExtensionRequestCmd();
	task void sendExtensionReplyCmd();

	/* MHME_START_NETWORK */
	command void MHME_START_NETWORK.request(
							uint32_t ScanChannels,
							uint8_t	ScanDuration,
							uint8_t	ChannelPage,
							uint8_t	BeaconOrder,
							uint8_t	SuperframeOrder)
	{
		uint8_t i = 0;
		uint8_t numChannels = 0;
		int8_t EDList_t [27];
		call MLME_SET.macAssociationPermit(TRUE);
		call MLME_SET.macRxOnWhenIdle(TRUE);

		channelMask = ScanChannels;
		BO = BeaconOrder;
		SO = SuperframeOrder;
		scanDuration = ScanDuration;
		for(i = 0 ; i < 27 ; i++)
			numChannels += ((ScanChannels >> i) & 0x01);

		call MLME_SCAN.request  (
								ENERGY_DETECTION_SCAN,	// ScanType
								ScanChannels,			// ScanChannels
								ScanDuration,			// ScanDuration
								ChannelPage,			// ChannelPage
								numChannels,       		// EnergyDetectListNumEntries
								EDList_t,				// EnergyDetectList
								0,			// PANDescriptorListNumEntries
								NULL,        // PANDescriptorList
								0                       // security
							);
	}

	default event void MHME_START_NETWORK.confirm (ieee155_status_t status){}

	/* MHME_START_DEVICE */

	command void MHME_START_DEVICE.request (uint8_t BeaconOrder, uint8_t SuperframeOrder)
	{
		if((networkStatus == NO_ASSOCIATED) || ((call MHME_GET.meshAcceptMeshDevice() == FALSE) && (call MHME_GET.meshAcceptEndDevice() == FALSE)))
		{
			signal MHME_START_DEVICE.confirm(IEEE155_INVALID_REQUEST);
			return;
		}

		call MLME_SET.macAssociationPermit(TRUE);

		start_request(call MLME_GET.macPANId(),
					call MLME_GET.phyCurrentChannel(),
					call MLME_GET.phyCurrentPage(),
					FALSE,
					BeaconOrder,
					SuperframeOrder);
	}

  	default event void MHME_START_DEVICE.confirm (ieee154_status_t status){}

  	event void MLME_SCAN.confirm (
                          ieee154_status_t status,
                          uint8_t ScanType,
                          uint8_t ChannelPage,
                          uint32_t UnscannedChannels,
                          uint8_t EnergyDetectListNumEntries,
                          int8_t* EnergyDetectList,
                          uint8_t PANDescriptorListNumEntries,
                          ieee154_PANDescriptor_t* PANDescriptorList)
  	{
  		uint8_t i, j;
  		ieee154_PANDescriptor_t m_PANDescriptor[EnergyDetectListNumEntries];
  		uint8_t preferredCH;
  		uint16_t PANId;
  		int8_t maxED;
		uint8_t numPANSCH[27];

  		switch(ScanType)
  		{
  			case ENERGY_DETECTION_SCAN:
  				if(call MHME_GET.meshDeviceType() == MESH_COORD)
  				{
	  				j = 0;
	  				for(i = 0 ; i < 27 ; i++)
	  				{
	  					if((channelMask >> i) & 0x01)
		  				if(!((UnscannedChannels >> i) & 0x01))
		  				{
		  					EDList[i] = EnergyDetectList[j];
		  					j++;
		  				}
	  				}
	  				call MLME_SCAN.request  (
									ACTIVE_SCAN,	// ScanType
									channelMask,			// ScanChannels
									scanDuration,			// ScanDuration
									ChannelPage,			// ChannelPage
									0,       				// EnergyDetectListNumEntries
									NULL,			        // EnergyDetectList
									EnergyDetectListNumEntries,		// PANDescriptorListNumEntries
									m_PANDescriptor,        // PANDescriptorList
									0                       // security
								);
  				}
  				else
  					signal MHME_DISCOVER.confirm(status, MDT_SIZE, NULL);
  				break;
  			case ACTIVE_SCAN:
  				if(call MHME_GET.meshDeviceType() == MESH_COORD)
  				{
	  				preferredCH = 0xFF;
	  				PANId = call MHME_GET.meshPANId();

	  				if(PANId == 0xFFFF)
	  					PANId = 0x0000 + (uint16_t)call Random.rand16()%(0xFFFE - 0x0001);

	  				// We select the most appropiate channel
	  				if(!PANDescriptorListNumEntries)
	  				{
	  					maxED = 0;
	  					for(i = 0; i < 27; i++)
	  					{
	  						if(maxED >= EDList[i])
	  						{
	  							maxED = EDList[i];
	  							preferredCH = i;
	  						}
	  					}
	  				}
	  				else
	  				{
						for(i = 0 ; i < 27 ; i++)
	  						numPANSCH[i] = 0;

						for(i = 0; i < PANDescriptorListNumEntries ; i++)
							numPANSCH[PANDescriptorList[i].LogicalChannel] ++;

						// We look for a clean channel
	  					for(i = 27 ; i > 0 ; i--)
	  					{
	  						if(EDList[i - 1] < -90)
	  						if(numPANSCH[i - 1] == 0)
	  						{
	  							preferredCH = i - 1;
	  							break;
	  						}
	  					}

	  					if(preferredCH == 0xFF)	// No clean channel found
	  					{
	  						maxED = 0;
	  						for(i = 0; i < 27; i++)
	  						if(maxED >= EDList[i])
	  						{
	  							maxED = EDList[i];
	  							preferredCH = i;
	  						}
	  						// We need to be aware that the PANID selected is not the same as any already existing
	  						for(i = 0; i < PANDescriptorListNumEntries ; i++)
	  							if((preferredCH == PANDescriptorList[i].LogicalChannel) && (PANId == PANDescriptorList[i].CoordPANId))
	  							{
	  								PANId = 0x0000 + (uint16_t)call Random.rand16()%(0xFFFE - 0x0001);
	  								i = 0xFF;
	  							}
	  					}
	  				}
	  				call MHME_SET.meshTreeLevel(0);
					call MHME_SET.meshNetworkAddress(0);
					call MLME_SET.macShortAddress(0);
					call MHME_SET.meshPANId(PANId);
					call NeighborList.setEndingAddress(0xFFFE);
		  			start_request(PANId, preferredCH, ChannelPage, TRUE, BO, SO);
	  			}
	  			else
	  			{
	  				if((status == IEEE154_SUCCESS) && (blocked == FALSE))
					{
						MDT_SIZE = PANDescriptorListNumEntries;
						if(!PANDescriptorListNumEntries) //List empty.
						{
							signal MHME_DISCOVER.confirm(status, MDT_SIZE, NULL);
							break;
						}
						populateMDT(PANDescriptorList, MDT_SIZE, mdt);
						blocked = TRUE;
						signal MHME_DISCOVER.confirm(status, MDT_SIZE, mdt);
					}
					else
						signal MHME_DISCOVER.confirm(status, MDT_SIZE, NULL);
	  			}
  				break;
  			default:
  				if(call MHME_GET.meshDeviceType() == MESH_COORD)
  					signal MHME_START_NETWORK.confirm(IEEE155_STARTUP_FAILURE);
  				else
  					signal MHME_DISCOVER.confirm(status, MDT_SIZE, NULL);
  				break;
  		}
  	}

	void start_request(uint16_t PANID,
  					uint8_t LogicalChannel,
  					uint8_t ChannelPage,
  					bool PANC,
  					uint8_t BeaconOrder,
  					uint8_t SuperframeOrder)
 	{
 		uint8_t length = 4*sizeof(uint8_t);
		uint8_t beaconPayload [4];

		memset(beaconPayload, 0, length);

		beaconPayload[0] = (beaconPayload[0] & 0x0f) + (0x01 << 4);
		beaconPayload[0] = (beaconPayload[0] & 0xf0) 		// tree level (0-3)
											+ ((call MHME_GET.meshTreeLevel() & 0xf0) >> 4);
		beaconPayload[1] = (beaconPayload[1] & 0x0f) 		// tree level (4-7)
											+ ((call MHME_GET.meshTreeLevel() & 0x0f) << 4);
		beaconPayload[1] = (beaconPayload[1] & 0xf7)
											+ (((call MHME_GET.meshAcceptMeshDevice() == TRUE)?1:0) << 3);	// MD
		beaconPayload[1] = (beaconPayload[1] & 0xfb)
											+ (((call MHME_GET.meshAcceptEndDevice() == TRUE)?1:0) << 2);	// ED
		beaconPayload[1] = (beaconPayload[1] & 0xfd) + (0x01 << 1);	// RB
		beaconPayload[1] = (beaconPayload[1] & 0xfe)
											+ ((call MHME_GET.meshSESExpected() == TRUE)?1:0);		// SES
		beaconPayload[2] = (beaconPayload[2] & 0x7f)
											+ (((call MHME_GET.meshASESExpected() == TRUE)?1:0) << 7);	// ASES
		beaconPayload[2] = (beaconPayload[2] & 0x87) + ((call MHME_GET.meshActiveOrder() & 0x0f) << 3); // AO
		beaconPayload[2] = (beaconPayload[2] & 0xf8) + ((call MHME_GET.meshWakeupOrder() & 0x0e) >> 1); // WO

		beaconPayload[3] = (beaconPayload[3] & 0x7f) + ((call MHME_GET.meshWakeupOrder() & 0x01) << 7);

		call IEEE154TxBeaconPayload.setBeaconPayload(beaconPayload, length);

		call MLME_START.request(
						PANID,   		  // PANId
						LogicalChannel,	  // LogicalChannel
						ChannelPage,	  // ChannelPage,
						0,                // StartTime,
						BeaconOrder,      // BeaconOrder
						SuperframeOrder,  // SuperframeOrder
						PANC,   		  // PANCoordinator
						FALSE,            // BatteryLifeExtension
						FALSE,            // CoordRealignment
						NULL,             // no realignment security
						NULL              // no beacon security
								);
	}

	event void MLME_START.confirm(ieee154_status_t status) {
		uint32_t waitTime;
		if(call MHME_GET.meshDeviceType() == MESH_COORD)
		{
			signal MHME_START_NETWORK.confirm(status);
		}
		else
			signal MHME_START_DEVICE.confirm(status);
		if(status == IEEE154_SUCCESS)
		{
			waitTime = call MHME_GET.meshChildNbReportTime() * 62500U;
			call WaitingForAssociationsRequest.startOneShot(waitTime);
		}
	}

	event void IEEE154TxBeaconPayload.setBeaconPayloadDone(void *beaconPayload, uint8_t length) {}
  	event void IEEE154TxBeaconPayload.modifyBeaconPayloadDone(uint8_t offset, void *buffer, uint8_t bufferLength) {}
  	event void IEEE154TxBeaconPayload.aboutToTransmit() {}
  	event void IEEE154TxBeaconPayload.beaconTransmitted() {}


	/* -- Association and tree-links formation*/
	event void WaitingForAssociationsRequest.fired() { // tree-links formation
		uint32_t waitTime = call MHME_GET.meshChildNbReportTime() * 62500U;

		if((call MHME_GET.meshDeviceType() == MESH_COORD) && (call MHME_GET.meshNbOfChildren() == 0))
			call WaitingForAssociationsRequest.startOneShot(waitTime);
		else if(call NeighborList.getNumChildren() == 0)	// Leaf device
		{
			networkStatus = SENDING_CHILDREN_NR;
			post sendChildrenNbReportCmd();
		}
		else
		{
			if(call MHME_GET.meshDeviceType() == MESH_COORD)	networkStatus = SENDING_CHILDREN_NR;
			call ChildrenReportTimer.startOneShot(waitTime);
		}
	}


	/* MHME_DISCOVER */

	command void MHME_DISCOVER.request(uint32_t ScanChannels, uint8_t ScanDuration, uint8_t ChannelPage, ieee155_reportCriteria_t ReportCriteria)
	{
		ieee154_PANDescriptor_t m_PANDescriptor[5];
		blocked = FALSE;
		call MLME_SCAN.request  (
								ACTIVE_SCAN,			// ScanType
								ScanChannels,			// ScanChannels
								ScanDuration,				// ScanDuration
								ChannelPage,				// ChannelPage
								0,	                    			// EnergyDetectListNumEntries
								NULL,			        		// EnergyDetectList
								MAX_MDT_SIZE,      			// PANDescriptorListNumEntries
								m_PANDescriptor,        // PANDescriptorList
								0                       			// security
							);
	}

	void populateMDT(ieee154_PANDescriptor_t* PANDescriptorList,
				uint8_t SIZE,
				ieee155_MDT_t* meshDiscoveryTable)
	{
		uint8_t scanIndex = 0, beaconIndex = 0;

		uint8_t meshVersion;
		bool acceptMD, acceptED, relBx, SES, ASES;
		uint8_t treeLevel, ao, wo;

		for(scanIndex = 0 ; scanIndex < SIZE ; scanIndex++)
		{
			beaconIndex = 0;
			while((beaconIndex < numBeaconPayload) && (bPayload[beaconIndex].beaconSAddr != PANDescriptorList[scanIndex].CoordAddress.shortAddress))
				beaconIndex++;

			if(beaconIndex < numBeaconPayload)
			{
				meshVersion = (bPayload[beaconIndex].beaconPayload[0] & 0xf0) >> 4;
				treeLevel = ((bPayload[beaconIndex].beaconPayload[0] & 0x0f) << 4) | ((bPayload[beaconIndex].beaconPayload[1] & 0xf0) >> 4);
				acceptMD = ((bPayload[beaconIndex].beaconPayload[1] & 0x08) >> 3)?TRUE:FALSE;
				acceptED = ((bPayload[beaconIndex].beaconPayload[1] & 0x04) >> 2)?TRUE:FALSE;
				relBx = ((bPayload[beaconIndex].beaconPayload[1] & 0x02) >> 1)?TRUE:FALSE;
				SES = (bPayload[beaconIndex].beaconPayload[1] & 0x01)?TRUE:FALSE;
				ASES = ((bPayload[beaconIndex].beaconPayload[2] & 0x80) >> 7)?TRUE:FALSE;
				ao = ((bPayload[beaconIndex].beaconPayload[2] & 0x78) >> 3);
				wo = ((bPayload[beaconIndex].beaconPayload[2] & 0x07) << 1) | ((bPayload[beaconIndex].beaconPayload[3] & 0x80) >> 7);
			}
			else
			{
				meshVersion = 0x00;
				treeLevel = 0xFF;
				acceptMD = FALSE;
				acceptED = FALSE;
				relBx = FALSE;
				SES = FALSE;
				ASES = FALSE;
				ao = 0x0F;
				wo = 0x0F;
			}

			meshDiscoveryTable[scanIndex].PANId = PANDescriptorList[scanIndex].CoordPANId;
			meshDiscoveryTable[scanIndex].Address = PANDescriptorList[scanIndex].CoordAddress.shortAddress;
			meshDiscoveryTable[scanIndex].LogicalChannel = PANDescriptorList[scanIndex].LogicalChannel;
			meshDiscoveryTable[scanIndex].ChannelPage = PANDescriptorList[scanIndex].ChannelPage;
			meshDiscoveryTable[scanIndex].MeshVersion  = meshVersion;
			meshDiscoveryTable[scanIndex].BeaconOrder = 0x0F;  //Set to 0x0f indicating no periodic beacons are transmitted.
			meshDiscoveryTable[scanIndex].SuperframeOrder = 0x0F; //Set to 0x0f indicating no periodic beacons are transmitted.
			meshDiscoveryTable[scanIndex].LinkQuality = PANDescriptorList[scanIndex].LinkQuality;
			meshDiscoveryTable[scanIndex].RSSI = PANDescriptorList[scanIndex].RSSI;
			meshDiscoveryTable[scanIndex].TreeLevel = treeLevel;
			meshDiscoveryTable[scanIndex].AcceptMeshDevice = acceptMD;
			meshDiscoveryTable[scanIndex].AcceptEndDevice  = acceptED;
			meshDiscoveryTable[scanIndex].SyncEnergySaving = SES;
			meshDiscoveryTable[scanIndex].AsyncEnergySaving = ASES;

			memset(bPayload[scanIndex].beaconPayload, 0, 4*sizeof(uint8_t));
		}
		numBeaconPayload = 0;
	}

	event message_t* MLME_BEACON_NOTIFY.indication (message_t *beaconFrame)
	{
		uint8_t * beaconPayload_ = call Frame.getPayload(beaconFrame);
		ieee154_address_t saddr;

		if(numBeaconPayload < MAX_MDT_SIZE)
		{
			call Frame.getSrcAddr(beaconFrame, &saddr);
			bPayload[numBeaconPayload].beaconSAddr = saddr.shortAddress;
			memcpy(bPayload[numBeaconPayload].beaconPayload, beaconPayload_ + 4*sizeof(uint8_t), 4*sizeof(uint8_t));

			numBeaconPayload++;
		}
		return beaconFrame;
	}

	default event void MHME_DISCOVER.confirm (ieee154_status_t status, uint8_t NetworkCount,ieee155_MDT_t* MeshDescriptorList){ }

	/* MHME_JOIN */

	command void MHME_JOIN.request(bool DirectJoin,
								uint16_t ParentDevAddr,
								uint16_t PANId ,
								uint8_t RejoinNetwork,
								bool JoinAsMeshDevice,
								uint32_t ScanChannels,
								uint8_t ScanDuration,
								uint8_t ChannelPage ,
								ieee155_meshCapabilityInformation_t CapabilityInformation)
	{
		uint8_t logicalChannel, i;
		ieee154_address_t parentAddr;
		ieee154_CapabilityInformation_t mac_capabilityInformation;
		uint8_t CoordAddrMode;

		if((networkStatus >= ASSOCIATED) && (RejoinNetwork == 0x00)) {
			signal MHME_JOIN.confirm(IEEE155_NOT_PERMITTED, 0xFFFF, PANId, ChannelPage, call MLME_GET.phyCurrentChannel());
			return;
		}
		else if((networkStatus == NO_ASSOCIATED) & (RejoinNetwork == 0x00)  & (DirectJoin == TRUE))
		{
			mac_capabilityInformation.AlternatePANCoordinator = 0;
			mac_capabilityInformation.DeviceType = (CapabilityInformation.DeviceType == TRUE)?1:0;
			mac_capabilityInformation.PowerSource = (CapabilityInformation.PowerSource == TRUE)?1:0;
			mac_capabilityInformation.ReceiverOnWhenIdle = (CapabilityInformation.ReceiverOnWhenIdle == TRUE)?1:0;
			mac_capabilityInformation.AllocateAddress = (CapabilityInformation.AllocateAddress == TRUE)?1:0;
			mac_capabilityInformation.SecurityCapability = 0;
			mac_capabilityInformation.Reserved = 0;

			parentAddr.shortAddress = ParentDevAddr;

			i = 0;
			while((i < 27) && (((ScanChannels >> i) & 0x01) == 0))
				i++;
			if(i == 27)
				signal MHME_JOIN.confirm(IEEE155_INVALID_REQUEST, 0xFFFF, PANId, ChannelPage, call MLME_GET.phyCurrentChannel());

			logicalChannel = i;

			CoordAddrMode = (RejoinNetwork == 0x01)?ADDR_MODE_SHORT_ADDRESS:ADDR_MODE_EXTENDED_ADDRESS;
			call MLME_ASSOCIATE.request(
									logicalChannel,
									0, //phyCurrentPage
									ADDR_MODE_SHORT_ADDRESS,
									PANId,
									parentAddr, // ieee154_address_t
									mac_capabilityInformation,
									NULL  // security
									);
		}
		else if (DirectJoin == FALSE){}
	}

	event void MLME_ASSOCIATE.indication(
				uint64_t deviceAddress,
				ieee154_CapabilityInformation_t capabilityInformation,
				ieee154_security_t *security)
	{
		uint16_t deviceShortAddr;

		if((call MLME_GET.macAssociationPermit() == FALSE) || ((call MHME_GET.meshAcceptMeshDevice() == FALSE) && (call MHME_GET.meshAcceptEndDevice() == FALSE)))
			call MLME_ASSOCIATE.response(deviceAddress, 0xFFFF, IEEE154_ACCESS_DENIED, 0);
		else
		{
			//set to 0xFFFE (intial state: generation of tree links)
			if(call WaitingForAssociationsRequest.isRunning())	call WaitingForAssociationsRequest.stop();

			deviceShortAddr = deviceAddress & 0x0000FFFF;
			call NeighborList.addChildren(deviceAddress, deviceShortAddr, FALSE);
			call MLME_ASSOCIATE.response(deviceAddress, deviceShortAddr, IEEE154_ASSOCIATION_SUCCESSFUL, 0);
			signal MHME_JOIN.indication(0xFFFE, deviceAddress, capabilityInformation, 0x00);
		}
	}

	event void MLME_ASSOCIATE.confirm(
				uint16_t assocShortAddress,
				uint8_t status,
				ieee154_security_t *security
			)
	{
		uint16_t networkAddress;
		if (status == IEEE154_ASSOCIATION_SUCCESSFUL)
		{
			// we are associated with the Parent
			networkAddress = assocShortAddress;

			networkStatus = ASSOCIATED;
			call MHME_SET.meshPANId(call MLME_GET.macPANId());
			call NeighborList.addParent(call MLME_GET.macCoordShortAddress());

			// This should be signaled once a 16-bit IEEE logical address be assigned
			if(call MHME_GET.meshDeviceType() == END_DEVICE)
			{
				networkStatus = SENDING_CHILDREN_NR;
				post sendChildrenNbReportCmd();
			}
			else
			{
				call MHME_START_DEVICE.request(0x0f, 0x0f);
			}
		} else
		{
			signal MHME_JOIN.confirm(status, 0xFFFF, call MLME_GET.macPANId(), call MLME_GET.phyCurrentPage(), call MLME_GET.phyCurrentChannel());
			networkStatus = NO_ASSOCIATED;
		}
	}

	event void MLME_COMM_STATUS.indication (
							  uint16_t PANId,
							  uint8_t SrcAddrMode,
							  ieee154_address_t SrcAddr,
							  uint8_t DstAddrMode,
							  ieee154_address_t DstAddr,
							  ieee154_status_t status,
							  ieee154_security_t *security
						) {}

	default event void MHME_JOIN.indication (
								uint16_t NetworkAddress,
								uint64_t ExtendedAddress,
								ieee154_CapabilityInformation_t CapabilityInformation,
								uint8_t RejoinNetwork){}
	default event void MHME_JOIN.confirm (
								uint8_t status,
								uint16_t NetworkAddress,
								uint16_t PANId,
								uint8_t ChannelPage,
								uint8_t ActiveChannel){}

	event void ChildrenReportTimer.fired()
	{
		uint32_t waitTime = call MHME_GET.meshChildNbReportTime() * 62500U;
		if(call NeighborList.getNumChildren() == nbOfChNR_recvd)
		{
			networkStatus = SENDING_CHILDREN_NR;
			post sendChildrenNbReportCmd();
		}
		else
			call ChildrenReportTimer.startOneShot(waitTime);
	}

	task void sendChildrenNbReportCmd()
	{
		uint8_t mhpduLen, mhpduHandle, macTxOptions;
		uint8_t * mhpdu;
		ieee155_address_t sourceAddress, destAddress;
		ieee154_status_t status;

		mhpduLen = sizeof(uint16_t)	// Frame Control
					+ sizeof(uint16_t) // Destination Address
					+ sizeof(uint16_t) // Source Address
					+ sizeof(uint8_t)	// Command Frame Identifier
					+ sizeof(uint16_t)	// Number of Descendants
					+ sizeof(uint16_t);	// Number of requested Addresses

		if (mhpduLen <= call Packet.maxPayloadLength())
		{
			memset(&cmdFrame, 0, sizeof(message_t));
			mhpdu = call Frame.getPayload(&cmdFrame);

			mhpduHandle = CHILDREN_NUMBER_REPORT;
			macTxOptions = TX_OPTIONS_ACK;

			destAddress.shortAddress = call MLME_GET.macCoordShortAddress();
			sourceAddress.shortAddress = call MLME_GET.macShortAddress();

			call MeshFrame.ChildrenNbReport(mhpdu,
							SHORT_ADDR_MODE,
							SHORT_ADDR_MODE,
							destAddress,
							sourceAddress,
							//call NeighborList.getNumChildren() + 1,
							call MHME_GET.meshNbOfChildren() + 1,
							numOfReqAddr + // Addr requested by children nodes, if any
								((call MHME_GET.meshDeviceType() == MESH_DEVICE) ? (1 + ADDRESS_SPACE) : (1)) // Own Addresses
							);

			call Frame.setAddressingFields(
					   		&cmdFrame,
					        ADDR_MODE_SHORT_ADDRESS,	// SrcAddrMode,
					        ADDR_MODE_SHORT_ADDRESS,	 // DstAddrMode,
					        call MLME_GET.macPANId(),    // DstPANId,
					        &destAddress,         		 // DstAddr,
					        NULL                         // security
					 	  );

			if((status = call MCPS_DATA.request(
					        &cmdFrame,         // frame,
					        mhpduLen,		// payloadLength,
					        mhpduHandle,    // mhpduHandle,
					        macTxOptions	// TxOptions,
					     )) != IEEE154_SUCCESS)
			{
				call Leds.led0Toggle();
			}
			else transmittingCmd = TRUE;
		}
		else
			call Leds.led0Toggle();
	}

	task void sendAddressAssignmentCmd()
	{
		uint8_t mhpduLen, mhpduHandle, macTxOptions;
		uint8_t * mhpdu;
		ieee155_address_t sourceAddress, destAddress;
		uint16_t begAddr, endAddr;
		ieee154_status_t status;
		uint32_t waitTime;
		/*
		 * nextNbToAssignAddress returns IEEE155_SUCCESS when there is a child
		 * node that needs to be informed about its address block.
		 * Otherwise, nextNbToAssignAddress returns IEEE155_FAIL so the algorithm
		 * ends.
		*/
		if((call MHME_GET.meshDeviceType() != END_DEVICE)
			&& (call NeighborList.nextNbToAssignAddress(&destAddress, &begAddr, &endAddr) == IEEE155_SUCCESS))
		{

			mhpduLen = sizeof(uint16_t)	// Frame Control
						+ sizeof(uint16_t) // Destination Address
						+ sizeof(uint16_t) // Source Address
						+ sizeof(uint8_t)	// Command Frame Identifier
						+ sizeof(uint16_t)	// Beginning Address
						+ sizeof(uint16_t)	// Ending Address
						+ sizeof(uint16_t);	// Tree Level of Parent Device

			if (mhpduLen <= call Packet.maxPayloadLength())
			{
				memset(&cmdFrame, 0, sizeof(message_t));
				mhpdu = call Frame.getPayload(&cmdFrame);

				sourceAddress.shortAddress = call MHME_GET.meshNetworkAddress();

				call MeshFrame.AddressAssignment(mhpdu,
											SHORT_ADDR_MODE,
											SHORT_ADDR_MODE,
											destAddress,
											sourceAddress,
											begAddr,
											endAddr,
											call MHME_GET.meshTreeLevel());

				mhpduHandle = ADDRESS_ASSIGNMENT;
				macTxOptions = TX_OPTIONS_ACK;
				call Frame.setAddressingFields(
						   		&cmdFrame,
						        ADDR_MODE_SHORT_ADDRESS,	// SrcAddrMode,
						        ADDR_MODE_SHORT_ADDRESS,	 // DstAddrMode,
						        call MLME_GET.macPANId(),    // DstPANId,
						        &destAddress,         		 // DstAddr,
						        NULL                         // security
						 	  );

				if((status = call MCPS_DATA.request(
						        &cmdFrame,         // frame,
						        mhpduLen,		// payloadLength,
						        mhpduHandle,    // mhpduHandle,
						        macTxOptions	// TxOptions,
						     )) != IEEE154_SUCCESS)
				{
					call Leds.led0Toggle();
				}
				else transmittingCmd = TRUE;
			}
		}
		else
		{
			if(call MHME_GET.meshDeviceType() != END_DEVICE)
			{
				networkStatus = SENDING_HELLO;
				waitTime = 6*MIN_HELLO_INTERVAL + call Random.rand32() % (MAX_HELLO_INTERVAL - MIN_HELLO_INTERVAL);
				call HelloTimer.startOneShot(waitTime);	// I wait for 3 seconds and start the mesh generation phase
			}
			else
			{
				networkStatus = NETWORK_FORMATION_COMPLETED;
				if(call MHME_GET.meshASESExpected())
					startAsynchronousEnergySaving();
			}

			if(call MHME_GET.meshDeviceType() != MESH_COORD)
			{
				call MLME_SET.macShortAddress(call MHME_GET.meshNetworkAddress());
				signal MHME_JOIN.confirm(IEEE155_SUCCESS,
							call MHME_GET.meshNetworkAddress(),
							call MLME_GET.macPANId(),
							call MLME_GET.phyCurrentPage(),
							call MLME_GET.phyCurrentChannel());
			}
		}
	}

	event message_t* MCPS_DATA.indication ( message_t* frame__ )
	{
		uint8_t *mhpdu, *mhsdu;
		uint8_t mhpdu_length, mhsdu_length;
  		ieee155_address_t sourceAddress, dstAddress, SrcMACAddr;
  		ieee155_txframe_t *txFrame;

  		uint16_t numOfDesc = 0;
  		uint16_t beginningAddress, endingAddress, treeLevel;

  		bool updateNb = FALSE;

  		relationship_t relation;
  		uint8_t leaveNet, addOfMG, newJoinMG, newLeftMG, fullMMemberUpdate, numOfOneHopNb, numOfMGroups;
  		uint8_t * khopNeighbors = NULL, * groupMember = NULL;
  		uint32_t waitTime;
  		uint16_t SrcPANId;
  		uint8_t up_down_flag;
  		uint32_t destWI, destAD;
		uint32_t remainDestAD, elapsed_time, RxOnDuration;

  		mhpdu = call Frame.getPayload(frame__);
	 	mhpdu_length = call Frame.getPayloadLength(frame__);

	 	call Frame.getSrcAddr(frame__, &SrcMACAddr);

		// Safety check on the payload length
		if (mhpdu_length <= sizeof(uint8_t))
			return frame__; // Bad packet received .. discarding it

		mhsdu = call MeshFrame.getPayload(mhpdu);

		call MeshFrame.getSrcAddress(mhpdu, &sourceAddress);
		call MeshFrame.getDstAddress(mhpdu, &dstAddress);

		if(call MeshFrame.getFrameType(mhpdu) == COMMAND_FRAME)
		{

			switch(call MeshFrame.getCommandType(mhpdu))
			{
				case CHILDREN_NUMBER_REPORT:
					if(
						((call MHME_GET.meshDeviceType() == MESH_COORD)
						&& (call NeighborList.check_Relationship(SrcMACAddr.shortAddress) == CHILD))

						||

					   ((call MHME_GET.meshDeviceType() == MESH_DEVICE)
					   	&& (call MHME_GET.meshNetworkAddress() == 0xFFFF)
						&& (call NeighborList.check_Relationship(SrcMACAddr.shortAddress) == CHILD))
					   )
					{
						// We employ the beginAddr and endAddr fields in the neighbor list
						// to store the number of requested addresses:
						// 		beginAddr <-- 0xFFFE   ;  endAddr <-- numOfReqAddr;
						// Later after the address assignment, we will update the entry with
						// the correct values

						if(call NeighborList.setNbOfReqAddr(sourceAddress, ((uint16_t)mhsdu[3]) << 8 | mhsdu[4]) == IEEE155_FAIL)
						{
							call Leds.led0Toggle();
							break;
						}

						nbOfChNR_recvd ++;

						numOfDesc = ((uint16_t)mhsdu[1]) << 8 | mhsdu[2];
						numOfReqAddr += ((uint16_t)mhsdu[3]) << 8 | mhsdu[4];

						// Update meshNbOfChildren
						call MHME_SET.meshNbOfChildren(call MHME_GET.meshNbOfChildren() + numOfDesc - 1);

						if((call MHME_GET.meshDeviceType() == MESH_COORD) && (call NeighborList.getNumChildren() == nbOfChNR_recvd))
						{
							// We assign 16-bit IEEE logical short addresses
							// to nodes according with the number of addresses
							// requested
							if(call ChildrenReportTimer.isRunning())	call ChildrenReportTimer.stop();
							networkStatus = SENDING_ADDRESS_ASS;
							post sendAddressAssignmentCmd();
						}
						else if((call MHME_GET.meshDeviceType() == MESH_DEVICE) && (call NeighborList.getNumChildren() == nbOfChNR_recvd))
						{
							if(call ChildrenReportTimer.isRunning())	call ChildrenReportTimer.stop();
							networkStatus = SENDING_CHILDREN_NR;
							post sendChildrenNbReportCmd();
						}
					}
					break;

				case ADDRESS_ASSIGNMENT: //Address assignment

					if( (call MHME_GET.meshDeviceType() != MESH_COORD)
					   	&& (call MHME_GET.meshNetworkAddress() == 0xFFFF)
						&& (call NeighborList.check_Relationship(SrcMACAddr.shortAddress) == PARENT))
					{
						beginningAddress = ((uint16_t)mhsdu[1]) << 8 | mhsdu[2];
						endingAddress = ((uint16_t)mhsdu[3]) << 8 | mhsdu[4];
						treeLevel = ((uint16_t)mhsdu[5]) << 8 | mhsdu[6];
						if((endingAddress - beginningAddress) < (numOfReqAddr + ((call MHME_GET.meshDeviceType() == MESH_DEVICE)?ADDRESS_SPACE:0)))
						{
							call Leds.led0Toggle();
							break;
						}

						call NeighborList.updateNbInfo(SrcMACAddr.shortAddress,
									FALSE,
				  					sourceAddress.shortAddress, 	// begAddr (uint16_t)
				  					0xFFFE,				// endAddr (uint16_t) -- Unknown
				  					treeLevel,			// treeLevel (uint16_t)
				  					PARENT,				// relation (relationship_t)
				  					TRUE,				// rBcast (bool)
				  					KNOWN,				// status (status_t)
				  					1,					// numHops (uint8_t)
				  					0,					// numOfMGroups (uint8_t)
				  					NULL,				// groupMember (uint8_t *)
				  					0,					// numOfOneHopNb (uint8_t)
				  					NULL,				// khopNeighbors (uint8_t *)
				  					call Frame.getLinkQuality(frame__),	// lqi
				  					call Frame.getRSSI(frame__), // rssi
				  					&updateNb);			// updated (bool)


						call MLME_SET.macCoordShortAddress(sourceAddress.shortAddress);	// We update the coordinator address

						call MHME_SET.meshNetworkAddress(beginningAddress);
						call NeighborList.setEndingAddress(endingAddress);

						post sendAddressAssignmentCmd();
						networkStatus = SENDING_ADDRESS_ASS;
					}

					break;
				case HELLO:
					if(
						((call MHME_GET.meshDeviceType() != END_DEVICE)
						&& (call MHME_GET.meshNetworkAddress() != 0xFFFF))

						||

						((call MHME_GET.meshDeviceType() == END_DEVICE)
						&& (call NeighborList.check_Relationship(SrcMACAddr.shortAddress) == PARENT))

						||
						!processingHello
						)
					{
						if(call HelloTimer.isRunning())
							call HelloTimer.stop();
						processingHello = TRUE;
						beginningAddress = ((uint16_t)mhsdu[2]) << 8 | mhsdu[3];
						endingAddress = ((uint16_t)mhsdu[4]) << 8 | mhsdu[5];
						treeLevel = ((uint16_t)mhsdu[6]) << 8 | mhsdu[7];
						relation = call NeighborList.check_Relationship(sourceAddress.shortAddress);
						if(relation == NO_RELATIONSHIP)
							relation = SIBLING_DEVICE;

						leaveNet = (mhsdu[8] & 0x80) >> 7;	// '1'--> the sender is leaving the network

						addOfMG = (mhsdu[8] & 0x40) >> 6;	// '1'--> addrOfMultiCastG is empty

						newJoinMG = (mhsdu[8] & 0x20) >> 5;	// '1'--> addrOfMultiCastG only includes addresses
						  										// of those multicast groups of which the device
						  										// just became a member since last hello command frame

						newLeftMG = (mhsdu[8] & 0x10) >> 4;	// '1'--> addrOfMultiCastG only includes those multicast
																// groups from which this device just left since last
																// hello command frame

						fullMMemberUpdate = (mhsdu[8] & 0x08) >> 3;	// 1-> addrOfMultiCastG includes a full list of
																		// multicast groups of which this device is member
						numOfOneHopNb = mhsdu[9];
						if(numOfOneHopNb)
							khopNeighbors = mhsdu + sizeof(uint8_t)	// Command Frame Identifier
												+ sizeof(uint8_t)	// TTL
												+ sizeof(uint16_t)	// Beginning Address
												+ sizeof(uint16_t)	// Ending Address
												+ sizeof(uint16_t)	// Tree Level
												+ sizeof(uint8_t)	// Hello Control
												+ sizeof(uint8_t)	// Number of One-hop Neighbors
												+ sizeof(uint8_t);	// Number of Multicast Groups
						numOfMGroups = mhsdu[10];
						if(numOfMGroups)
							groupMember = khopNeighbors + numOfOneHopNb * 2 * sizeof(uint16_t);

						atomic
						call NeighborList.updateNbInfo(SrcMACAddr.shortAddress,
									(leaveNet ? TRUE : FALSE),
				  					beginningAddress, 	// begAddr (uint16_t)
				  					endingAddress,		// endAddr (uint16_t)
				  					treeLevel,			// treeLevel (uint16_t)
				  					relation,			// relation (relationship_t)
				  					TRUE,				// rBcast (bool)
				  					KNOWN,				// status (status_t)
				  					mhsdu[1],			// numHops (uint8_t)
				  					numOfMGroups,		// numOfMGroups (uint8_t)
				  					groupMember,		// groupMember (uint8_t *)
				  					numOfOneHopNb,		// numOfOneHopNb (uint8_t)
				  					khopNeighbors,		// khopNeighbors (uint8_t *)
				  					call Frame.getLinkQuality(frame__),	// lqi
				  					call Frame.getRSSI(frame__), // rssi
				  					&updateNb);			// updated (bool)

						processingHello = FALSE;
						if(call MHME_GET.meshDeviceType() != END_DEVICE)
						{
							if(updateNb && !transmittingCmd)
							{
								transmittingCmd = TRUE;
								post sendHelloCmd();
							}
							else if(networkStatus == SENDING_HELLO)
							{
								waitTime = MIN_HELLO_INTERVAL + call Random.rand32()%(MAX_HELLO_INTERVAL - MIN_HELLO_INTERVAL);
								call HelloTimer.startOneShot(waitTime);
							}
						}
					}
					break;
				case WAKEUP_NOTIFICATION:
					call NeighborList.updateLinkQuality(sourceAddress.shortAddress,
					  					call Frame.getLinkQuality(frame__),
					  					call Frame.getRSSI(frame__));

					if(pending_tx && (sourceAddress.shortAddress == pending_daddr))
					{
						WN_Recv = TRUE;
						destWI = IEEE155_meshcBaseActiveDuration << ((mhsdu[1] & 0xF0) >> 4);
						destAD = IEEE155_meshcBaseActiveDuration << (mhsdu[1] & 0x0F);
						call MHME_SET.meshDestActiveOrder(destAD);

						if(destWI > destAD)	// the receiver node has an inactive period
						{
							/** We estimate if destination is in the active duration **/
							// reception time of destination's WN
							remainDestAD = ((uint32_t)(destWI - destAD))*1000 - WNTransactionTime;	//usec

							if(remainDestAD > dataTransactionTime)
								post forwardData();
							else if(remainDestAD >= 3*IEEE155_meshcTimeUnit*1000)
								post sendExtensionRequestCmd();
							else
							{
								if((call MHME_GET.meshActiveOrder() != call MHME_GET.meshWakeupOrder())
									&& (call MHME_GET.meshWakeupOrder() < 15))
								{
									elapsed_time = call WITimer.getNow() - call WITimer.gett0();
									if(elapsed_time > AD154Compliant)
										call MLME_RX_ENABLE.request(FALSE, 0, 0);
								}
							}
						}
						else // AO and WO must be equal, so the destination is always ON
							post forwardData();
					}
					break;
				case EXTENSION_REQUEST:
					if(dstAddress.shortAddress == call MHME_GET.meshNetworkAddress())
					{
						if(transmittingData)	// we are transmitting a data message right now.
						{
							call MESH_PURGE.request(0);
							transmittingData = FALSE;
						}

						sourceEREP = sourceAddress.shortAddress;
						if((call MHME_GET.meshActiveOrder() != call MHME_GET.meshWakeupOrder())
							&& (call MHME_GET.meshWakeupOrder() < 15))
						{
							elapsed_time = call WITimer.getNow() - call WITimer.gett0();
							RxOnDuration = ((((AD154Compliant - elapsed_time)*1000000)/62500U) >> 4)
															+ (((uint32_t)mhsdu[1])*1000 >> 4);
							call MLME_RX_ENABLE.request(FALSE, 0, RxOnDuration);
						}
						post sendExtensionReplyCmd();
					}
					break;
				case EXTENSION_REPLY:
					if((dstAddress.shortAddress == call MHME_GET.meshNetworkAddress()) && call EREPTimer.isRunning())
					{
						call EREPTimer.stop();
						post forwardData();
					}
					break;
				default:
					break;
			}
		}
		else if(call MeshFrame.getFrameType(mhpdu) == DATA_FRAME)
		{
			call Frame.getSrcPANId(frame__, &SrcPANId);
			call NeighborList.updateLinkQuality(sourceAddress.shortAddress, call Frame.getLinkQuality(frame__), call Frame.getRSSI(frame__));

			mhsdu_length = mhpdu_length - call MeshFrame.getHeaderLength(mhpdu);
			if(dstAddress.shortAddress == call MHME_GET.meshNetworkAddress()) // Destination of data
				signal MESH_DATA.indication(call MeshFrame.getSrcAddrMode(mhpdu), SrcPANId, sourceAddress, mhsdu_length, mhsdu);
			else
			{
				call Leds.led2Toggle();

				if (!(txFrame = call Pool.get()))
					return frame__; // no empty frame left!
				txFrame->headerLen = call MeshFrame.getHeaderLength(mhpdu);
				memcpy(txFrame->header, mhpdu, txFrame->headerLen);

				if(call MHME_GET.meshASESOn())
				{
					pending_daddr = call DataForwarding.nextHop(dstAddress.shortAddress, &up_down_flag, ROUTING_CRITERIA);
					memset(mhsdu + sizeof(uint8_t), (up_down_flag << 7), sizeof(uint8_t));
				}
				txFrame->payloadLen = mhsdu_length;
				memcpy(txFrame->payload, mhsdu, txFrame->payloadLen);

				if(call Queue.enqueue(txFrame) != SUCCESS)
				{
					call Pool.put(txFrame);
					return frame__;
				}
				if(call MHME_GET.meshASESOn() && !pending_tx)
				{
					pending_tx = TRUE;
					ARC = 0;
					WN_Recv = FALSE;
				}
				if(!(call MHME_GET.meshASESOn()) && (networkStatus == NETWORK_FORMATION_COMPLETED))
				{
					atomic
					if((call Queue.size() > 0) && !transmittingCmd && !transmittingData)
						post forwardData();
				}
			}
		}
		return frame__;
	}

	event void MCPS_DATA.confirm(
                          message_t *msg,
                          uint8_t msduHandle,
                          ieee154_status_t status,
                          uint32_t Timestamp
                        )
  	{
  		uint8_t *mhpdu;
  		uint8_t mhpdu_length;
  		ieee154_status_t status_;
		ieee155_address_t sourceAddress;
		uint32_t elapsed_time, RxOnDuration = 0;

   		mhpdu = call Frame.getPayload(msg);
   		mhpdu_length = call Frame.getPayloadLength(msg);
   		if(call MeshFrame.getFrameType(mhpdu) == COMMAND_FRAME)
		{
			transmittingCmd = FALSE;
   			if(status == IEEE154_SUCCESS)
   			{
				switch(call MeshFrame.getCommandType(mhpdu))
				{
					case CHILDREN_NUMBER_REPORT:
						break;
					case ADDRESS_ASSIGNMENT:
						post sendAddressAssignmentCmd();
						break;
					case HELLO:
						break;
					case WAKEUP_NOTIFICATION:
					case EXTENSION_REPLY:
						call MLME_SET.macMinBE(minBE);
						call MLME_SET.macMaxCSMABackoffs(macMaxCSMABackoffs);
						break;
					case EXTENSION_REQUEST:
						call MLME_SET.macMaxCSMABackoffs(macMaxCSMABackoffs);
						break;
					default:
						break;
				}
			}
    		else
    		{
				switch(call MeshFrame.getCommandType(mhpdu))
				{
					case CHILDREN_NUMBER_REPORT:
					case ADDRESS_ASSIGNMENT:
						memset(&cmdFrame, 0, sizeof(message_t));
						memcpy(&cmdFrame, msg, mhpdu_length);
						transmittingCmd = TRUE;
						if((status_ = call MCPS_DATA.request(
						        &cmdFrame,         // frame,
						        mhpdu_length,		// payloadLength,
						        msduHandle,    // mhpduHandle,
						        TX_OPTIONS_ACK	// TxOptions,
						     )) != IEEE154_SUCCESS)
						{
							call Leds.led0Toggle();
						}
						break;
					case HELLO:
						break;
					case WAKEUP_NOTIFICATION:
					case EXTENSION_REPLY:
						call MLME_SET.macMinBE(minBE);
						call MLME_SET.macMaxCSMABackoffs(macMaxCSMABackoffs);
						break;
					case EXTENSION_REQUEST:
						call MLME_SET.macMaxCSMABackoffs(macMaxCSMABackoffs);
						break;
					default:
						break;
				}
			}
		}
		else if(call MeshFrame.getFrameType(mhpdu) == DATA_FRAME)
		{
			transmittingData = FALSE;
			call MeshFrame.getSrcAddress(mhpdu, &sourceAddress);
			if(call MHME_GET.meshASESOn())
			{
				if(status == IEEE154_SUCCESS)
				{
					pending_tx = FALSE;
					pending_daddr = 0xFFFF;
					ARC = 0;
					call Pool.put(call Queue.dequeue());
					if(sourceAddress.shortAddress == call MHME_GET.meshNetworkAddress()) // I am the source
						signal MESH_DATA.confirm(msduHandle, status, (call MeshFrame.getPayload(mhpdu) + 2*sizeof(uint8_t)));
				}
				else
				{
					if(++ARC >= call MHME_GET.meshMaxNumASESRetries())
					{
						pending_tx = FALSE;
						pending_daddr = 0XFFFF;
						ARC = 0;
						call Pool.put(call Queue.dequeue());
						if(sourceAddress.shortAddress == call MHME_GET.meshNetworkAddress()) // I am the source
							signal MESH_DATA.confirm(msduHandle, IEEE154_CHANNEL_ACCESS_FAILURE, (call MeshFrame.getPayload(mhpdu) + 2*sizeof(uint8_t)));
					}
				}
				if((call MHME_GET.meshActiveOrder() != call MHME_GET.meshWakeupOrder())
					&& (call MHME_GET.meshWakeupOrder() < 15))
				{
					elapsed_time = call WITimer.getNow() - call WITimer.gett0();
					if(elapsed_time < AD154Compliant)
					{
						RxOnDuration = ((AD154Compliant - elapsed_time)*1000)/62500U;	// TKN154 units --> milliseconds
						RxOnDuration = RxOnDuration*1000 >> 4; // milliseconds --> IEEE802154 symbols
					}
					// If the above condition is not met, then the node witch off instantly (RxOnDuration = 0)
					call MLME_RX_ENABLE.request(FALSE, 0, RxOnDuration);
				}
			}
			else
			{
				call Pool.put(call Queue.dequeue());
				if(sourceAddress.shortAddress == call MHME_GET.meshNetworkAddress()) // I am the source
					signal MESH_DATA.confirm(msduHandle, status, (call MeshFrame.getPayload(mhpdu) + 2*sizeof(uint8_t)));
			}
    	}
    	if((networkStatus == NETWORK_FORMATION_COMPLETED) && (call MHME_GET.meshASESOn() == FALSE))
		atomic
    	if((call Queue.size() > 0) && !transmittingCmd && !transmittingData)
    		post forwardData();
  	}

	task void sendHelloCmd()
	{
		uint8_t mhpduLen, mhpduHandle, macTxOptions;
		uint8_t * mhpdu;
		ieee155_address_t sourceAddress, destAddress;
		ieee154_status_t status;

		// Multicast function has not been implemented in this version of the code
		mhpduLen = sizeof(uint16_t)	// Frame Control
					+ sizeof(uint16_t) // Destination Address
					+ sizeof(uint16_t) // Source Address
					+ sizeof(uint8_t)	// Command Frame Identifier
					+ sizeof(uint8_t)	// TTL
					+ sizeof(uint16_t)	// Beginning Address
					+ sizeof(uint16_t)	// Ending Address
					+ sizeof(uint16_t)	// Tree Level
					+ sizeof(uint8_t)	// Hello Control
					+ sizeof(uint8_t)	// Number of One-hop Neighbors
					+ sizeof(uint8_t)	// Number of Multicast Groups
					+ (call NeighborList.getNumOfOneHopNb()
						* (2 * sizeof(uint16_t)))	// Addresses of One-hop Neighbors:
					+ 0;	// Addresses of Multicast Groups

		if (mhpduLen <= call Packet.maxPayloadLength())
		{
			memset(&cmdFrame, 0, sizeof(message_t));
			mhpdu = call Frame.getPayload(&cmdFrame);

			mhpduHandle = HELLO;
			macTxOptions = 0x00;	// MESH_TX_OPTIONS_BROADCAST

			destAddress.shortAddress = IEEE155_meshcBroadcastAddress;
			sourceAddress.shortAddress = call MHME_GET.meshNetworkAddress();

			call MeshFrame.Hello(mhpdu,
							SHORT_ADDR_MODE,
							SHORT_ADDR_MODE,
							sourceAddress,
							call MHME_GET.meshTTLOfHello(),			// TTL
							call MHME_GET.meshNetworkAddress(),		// Beginning Address
							call NeighborList.getEndingAddress(), 	// Ending Address
							call MHME_GET.meshTreeLevel(),			// Tree Level
							0x40,									// Hello Control
							call NeighborList.getNumOfOneHopNb(), 	//Number of One-hop Neighbors
							0);										//Number of Multicast Groups

			call NeighborList.getNbInformation(mhpdu);

			call Frame.setAddressingFields(
					   		&cmdFrame,
					        ADDR_MODE_SHORT_ADDRESS,	// SrcAddrMode,
					        ADDR_MODE_SHORT_ADDRESS,	 // DstAddrMode,
					        call MLME_GET.macPANId(),    // DstPANId,
					        &destAddress,         		 // DstAddr,
					        NULL                         // security
					 	  );

			if((status = call MCPS_DATA.request(
					        &cmdFrame,         // frame,
					        mhpduLen,		// payloadLength,
					        mhpduHandle,    // mhpduHandle,
					        macTxOptions	// TxOptions,
					     )) != IEEE154_SUCCESS)
			{
				call Leds.led0Toggle();
			}
			else transmittingCmd = TRUE;
		}
		else
			call Leds.led0Toggle();
	}

	event void HelloTimer.fired()
	{
		uint32_t waitTime;
		post sendHelloCmd();

		if(numHello)
		{
			numHello--;
			waitTime = MIN_HELLO_INTERVAL + call Random.rand32() % (MAX_HELLO_INTERVAL - MIN_HELLO_INTERVAL);
			call HelloTimer.startOneShot(waitTime);
		}
		else
		{
			networkStatus = NETWORK_FORMATION_COMPLETED;
			if(call MHME_GET.meshASESExpected())
				startAsynchronousEnergySaving();
			else
			atomic
			if((call Queue.size() > 0) && !transmittingCmd && !transmittingData)
				post forwardData();
		}
	}

	command ieee155_status_t MESH_DATA.request (uint8_t SrcAddrMode,
							uint8_t DstAddrMode,
							ieee155_address_t DstAddr,
							uint8_t mhsduLenght,
							uint8_t* mhsdu,
							uint8_t mhsduHandle,
							bool AckTransmission,
							bool McstTransmission,
							bool BcstTransmission,
							bool ReliableBcst)
	{
		uint8_t meshTxOptions = 0;
		uint8_t offset = 0;
		ieee155_address_t sourceAddress;
		ieee155_txframe_t *txFrame;
		uint8_t up_down_flag;

		if((DstAddrMode == EXTENDED_ADDR_MODE) || (SrcAddrMode == EXTENDED_ADDR_MODE))
			return IEEE154_INVALID_PARAMETER;	// No supported in this version of the code
		else if(McstTransmission || ReliableBcst)
			return IEEE154_INVALID_PARAMETER;
		else if(mhsduLenght <= (call Packet.maxPayloadLength() + IEEE155_meshcMaxMeshHeaderLength))
		{
			if (!(txFrame = call Pool.get()))
			{
				signal MESH_DATA.confirm(txFrame->handle, IEEE154_TRANSACTION_OVERFLOW, mhsdu);
      			return IEEE155_FAIL;
      		}

			sourceAddress.shortAddress = call MHME_GET.meshNetworkAddress();
			meshTxOptions |= AckTransmission  ? (1 << 3) : 0;
			meshTxOptions |= McstTransmission ? (1 << 2) : 0;
			meshTxOptions |= BcstTransmission ? (1 << 1) : 0;
			meshTxOptions |= ReliableBcst 	  ?     1 	 : 0;

			// Populate Mesh Sublayer Header
			call MeshFrame.setAddressingFields(txFrame->header,
									&offset,
									DATA_FRAME,
									DstAddrMode,
									SrcAddrMode,
									DstAddr,
									sourceAddress,
									meshTxOptions);

			txFrame->headerLen = offset;
			memset(txFrame->payload, SN, sizeof(uint8_t));
			memcpy(txFrame->payload + 2*sizeof(uint8_t), mhsdu, mhsduLenght);
			txFrame->payloadLen = mhsduLenght + 2*sizeof(uint8_t);
			txFrame->handle = mhsduHandle;

			if(call MHME_GET.meshASESOn() && !pending_tx)
			{
				pending_daddr = call DataForwarding.nextHop(DstAddr.shortAddress, &up_down_flag, ROUTING_CRITERIA);
				memset(txFrame->payload + sizeof(uint8_t), (up_down_flag << 7), sizeof(uint8_t));
				pending_tx = TRUE;
				ARC = 0;
				WN_Recv = FALSE;
			}
			if(call Queue.enqueue(txFrame) != SUCCESS)
			{
				if(call MHME_GET.meshASESOn())
				{
					pending_tx = FALSE;
					pending_daddr = 0xFFFF;
					call Pool.put(txFrame);
				}
				signal MESH_DATA.confirm(txFrame->handle, IEEE154_TRANSACTION_OVERFLOW, mhsdu);
				return IEEE155_FAIL;
			}

			SN++;	// Increase the value of Sequence Number

			atomic
			if(!(call MHME_GET.meshASESOn()) && !transmittingData && !transmittingCmd)
			{
				post forwardData();
			}
			return IEEE155_SUCCESS;
		}
		else
			call Leds.led0Toggle();

		return IEEE155_FAIL;
	}

	default event void MESH_DATA.confirm(uint8_t mhpduHandle,
									ieee154_status_t status,
									uint8_t *mhsdu) {}

	default event uint8_t* MESH_DATA.indication (uint8_t SrcAddrMode,
									uint16_t SrcPANId,
									ieee154_address_t SourceAddress,
									uint8_t mhsduLen,
									uint8_t* mhsdu) { return mhsdu; }

	command void MESH_PURGE.request (uint8_t mhsduHandle)
	{
		if(call MCPS_PURGE.request(mhsduHandle) == IEEE154_SUCCESS)
			signal MESH_PURGE.confirm(mhsduHandle, IEEE154_SUCCESS);
		else
			signal MESH_PURGE.confirm(mhsduHandle, IEEE154_INVALID_HANDLE);
	}
	default event void MESH_PURGE.confirm (uint8_t mhsduHandle,
              ieee154_status_t status) {}

	task void forwardData()
	{
		uint8_t *mhpdu;
		uint8_t up_down_flag = 0, payloadLength = 0, meshTxOptions = 0, macTxOptions = 0;
		ieee155_address_t DstAddr, next_hop;
		ieee154_status_t status;
		ieee155_txframe_t * txFrame;
		txFrame = call Queue.head();

		memset(&dataFrame, 0, sizeof(message_t));
		mhpdu = call Frame.getPayload(&dataFrame);
		memcpy(mhpdu, txFrame->header, txFrame->headerLen);

		meshTxOptions = call MeshFrame.getTxOptions(txFrame->header);
		if(meshTxOptions == 0x08)	// Acknowledged transmission
		{
			call MeshFrame.getDstAddress(txFrame->header, &DstAddr);
			if(call MHME_GET.meshASESOn())
				next_hop.shortAddress = pending_daddr;
			else
			{
				if((next_hop.shortAddress = call DataForwarding.nextHop(DstAddr.shortAddress, &up_down_flag, ROUTING_CRITERIA)) == 0xFFFF)
				{
					call Leds.led0Toggle();
					return;
				}
				memset(txFrame->payload + sizeof(uint8_t), (up_down_flag << 7), sizeof(uint8_t));
			}
			macTxOptions = TX_OPTIONS_ACK;
		}
		else if(meshTxOptions == 0x04)	// Multicast transmission
		{
				call Leds.led0Toggle();
				return;
		}
		else if(meshTxOptions == 0x02)	// Broadcast transmission
		{
				macTxOptions = 0x00;
				next_hop.shortAddress = IEEE155_meshcBroadcastAddress;
		}
		else if(meshTxOptions == 0x01)	// Reliable broadcast
		{
				call Leds.led0Toggle();
				return;
		}
		else
		{
			call Leds.led0Toggle();
			return;
		}

		// Populate Mesh Sublayer Payload
		memcpy(mhpdu + txFrame->headerLen, txFrame->payload, txFrame->payloadLen);
		payloadLength = txFrame->headerLen + txFrame->payloadLen;

		call Frame.setAddressingFields(
					   		&dataFrame,
					        ((call MeshFrame.getSrcAddrMode(mhpdu) == SHORT_ADDR_MODE) ? ADDR_MODE_SHORT_ADDRESS : ADDR_MODE_EXTENDED_ADDRESS) ,	// SrcAddrMode,
					        ((call MeshFrame.getDstAddrMode(mhpdu) == SHORT_ADDR_MODE) ? ADDR_MODE_SHORT_ADDRESS : ADDR_MODE_EXTENDED_ADDRESS),	 // DstAddrMode,
					        call MLME_GET.macPANId(),    // DstPANId,
					        &next_hop,         			 // DstAddr,
					        NULL                         // security
					 	  );

		if((status = call MCPS_DATA.request(
						        &dataFrame,         // frame,
						        payloadLength,		// payloadLength,
						        0,    // mhpduHandle,
						        macTxOptions	// TxOptions,
					     )) != IEEE154_SUCCESS)
		{
			if(!call MHME_GET.meshASESOn())
				call Pool.put(call Queue.dequeue());
			call Leds.led0Toggle();
		}
		else
			atomic
				transmittingData = TRUE;
	}

	void startAsynchronousEnergySaving(void)
	{
		double dataTimeEstimated, WNEstimated;

		call MHME_SET.meshASESOn(TRUE);

		WI = IEEE155_meshcBaseActiveDuration << call MHME_GET.meshWakeupOrder();
		AD = IEEE155_meshcBaseActiveDuration << call MHME_GET.meshActiveOrder();
		WI154Compliant = ((uint32_t)WI/1000) * 62500U;
		AD154Compliant = ((uint32_t)AD/1000) * 62500U;
		WISymbol154 = ((uint32_t)WI*1000) >> 4;
		ADSymbol154 = ((uint32_t)AD*1000) >> 4;

		ARC = 0;
		pending_tx = FALSE;
		WN_Recv = FALSE;

		minBE = call MLME_GET.macMinBE();
		macMaxCSMABackoffs = call MLME_GET.macMaxCSMABackoffs();

		/* WN message estimation tx time */
		WNEstimated =  (8 + 7 + 6) * 8 / 250000;
		WNEstimated += (2 - 1)*320e-6 + 320e-6;
		WNEstimated += (32 / 2.0) * 8 / 250000;	//radio turnaround
		WNEstimated += 100.0/200000000.0;	//max round trip delay
		WNTransactionTime = (uint32_t)(WNEstimated*1000000);	//usec
		/* Data message estimation tx time */
		dataTimeEstimated = 127 * 8 / 250000;	//tx time of one max PPDU
		dataTimeEstimated += (8 - 1)*320e-6 + 320e-6;
		dataTimeEstimated += (32 / 2.0) * 8 / 250000;	//radio turnaround and slot boundary ajustment
		dataTimeEstimated += 2 * 100.0/200000000.0;	//max round trip delay
		dataTimeEstimated += 11*8/250000;	// ACK transmission time
		dataTransactionTime = (uint32_t)(dataTimeEstimated*1000000);	//usec

		/* Start duty-cycling scheme*/
		if((call MHME_GET.meshActiveOrder() != call MHME_GET.meshWakeupOrder())
			&& (call MHME_GET.meshWakeupOrder() < 15))
		{
    		call MLME_SET.macRxOnWhenIdle(FALSE);
			call MLME_RX_ENABLE.request(FALSE, 0, ADSymbol154);
		}
		call WITimer.startPeriodic(WI154Compliant);
	}
	/* Enable/disable the radio*/
	event void WITimer.fired()
	{
		uint32_t RxOnDuration = ADSymbol154;
		uint8_t up_down_flag;
		ieee155_txframe_t *txFrame;

		if(call MHME_GET.meshWakeupOrder() < 15)
			post sendWakeupNotificationCmd();
		if(pending_tx)
		{
			if(!WN_Recv)
			{
				if(++ARC >= call MHME_GET.meshMaxNumASESRetries())
				{
					pending_tx = FALSE;
					pending_daddr = 0XFFFF;
					ARC = 0;

					txFrame = call Queue.head();
					if(call MeshFrame.getSrcShortAddress(txFrame->header) == call MHME_GET.meshNetworkAddress())	// I am the source
						signal MESH_DATA.confirm(txFrame->handle, IEEE154_TRANSACTION_EXPIRED, txFrame->payload + 2*sizeof(uint8_t));

					call Pool.put(call Queue.dequeue());

					if(call Queue.size() > 0)
					{
						txFrame = call Queue.head();
						pending_tx = TRUE;
						pending_daddr = call DataForwarding.nextHop(call MeshFrame.getDstShortAddress(txFrame->header), &up_down_flag, ROUTING_CRITERIA);
						memset(txFrame->payload + sizeof(uint8_t), (up_down_flag << 7), sizeof(uint8_t));
						RxOnDuration = WISymbol154;
					}
				}
				else
					RxOnDuration = WISymbol154;
			}
			else
				RxOnDuration = WISymbol154;
			WN_Recv = FALSE;
		}
		else
		{
			if(call Queue.size() > 0)
			{
				txFrame = call Queue.head();
				pending_tx = TRUE;
				WN_Recv = FALSE;
				pending_daddr = call DataForwarding.nextHop(call MeshFrame.getDstShortAddress(txFrame->header), &up_down_flag, ROUTING_CRITERIA);
				memset(txFrame->payload + sizeof(uint8_t), (up_down_flag << 7), sizeof(uint8_t));
				RxOnDuration = WISymbol154;
			}
		}

		if((call MHME_GET.meshActiveOrder() != call MHME_GET.meshWakeupOrder())
			&& (call MHME_GET.meshWakeupOrder() < 15))
			call MLME_RX_ENABLE.request(FALSE, 0, RxOnDuration);
	}
	event void MLME_RX_ENABLE.confirm (ieee154_status_t status)	{}

	/* Send a wakeup notification*/
	task void sendWakeupNotificationCmd()
	{
		uint8_t mhpduLen, mhpduHandle, macTxOptions, asesTimeInfo;
		uint8_t * mhpdu;
		ieee155_address_t sourceAddress, destAddress;
		ieee154_status_t status;

		mhpduLen = sizeof(uint16_t)	// Frame Control
					+ sizeof(uint16_t) // Destination Address
					+ sizeof(uint16_t) // Source Address
					+ sizeof(uint8_t)	// Command Frame Identifier
					+ sizeof(uint8_t);	// ASES Time Info

		if (mhpduLen <= call Packet.maxPayloadLength())
		{
			memset(&cmdFrame, 0, sizeof(message_t));
			mhpdu = call Frame.getPayload(&cmdFrame);

			destAddress.shortAddress = IEEE155_meshcBroadcastAddress;
			sourceAddress.shortAddress = call MHME_GET.meshNetworkAddress();

			asesTimeInfo = 0;
			asesTimeInfo = ((call MHME_GET.meshWakeupOrder() << 4) | call MHME_GET.meshActiveOrder());

			call MeshFrame.WakeupNotification(mhpdu,
										SHORT_ADDR_MODE,
										SHORT_ADDR_MODE,
										sourceAddress,
										asesTimeInfo);

			call MLME_SET.macMinBE(0x01);
			call MLME_SET.macMaxCSMABackoffs(0x00);

			mhpduHandle = WAKEUP_NOTIFICATION;
			macTxOptions = 0x00; // MESH_TX_OPTIONS_BROADCAST
			call Frame.setAddressingFields(
					   		&cmdFrame,
					        ADDR_MODE_SHORT_ADDRESS,	// SrcAddrMode,
					        ADDR_MODE_SHORT_ADDRESS,	 // DstAddrMode,
					        call MLME_GET.macPANId(),    // DstPANId,
					        &destAddress,         		 // DstAddr,
					        NULL                         // security
					 	  );

			if((status = call MCPS_DATA.request(
					        &cmdFrame,         // frame,
					        mhpduLen,		// payloadLength,
					        mhpduHandle,    // mhpduHandle,
					        macTxOptions	// TxOptions,
					     )) != IEEE154_SUCCESS)
			{
				call Leds.led0Toggle();
			}
			else transmittingCmd = TRUE;
		}
	}
	/* Extension Request */
	task void sendExtensionRequestCmd()
	{
		uint8_t mhpduLen, mhpduHandle, macTxOptions, extTime;
		uint8_t * mhpdu;
		ieee155_address_t sourceAddress, destAddress;
		ieee154_address_t destMACAddress;
		ieee154_status_t status;
		uint32_t erepTime;

		mhpduLen = sizeof(uint16_t)	// Frame Control
					+ sizeof(uint16_t) // Destination Address
					+ sizeof(uint16_t) // Source Address
					+ sizeof(uint8_t)	// Command Frame Identifier
					+ sizeof(uint8_t);	// Extension Time

		if (mhpduLen <= call Packet.maxPayloadLength())
		{
			memset(&cmdFrame, 0, sizeof(message_t));
			mhpdu = call Frame.getPayload(&cmdFrame);

			destMACAddress.shortAddress = IEEE155_meshcBroadcastAddress;
			destAddress.shortAddress = pending_daddr;
			sourceAddress.shortAddress = call MHME_GET.meshNetworkAddress();

			extTime = call MHME_GET.meshEREQTime();

			call MeshFrame.EREQ(mhpdu,
									SHORT_ADDR_MODE,
									SHORT_ADDR_MODE,
									destAddress,
									sourceAddress,
									extTime);

			call MLME_SET.macMaxCSMABackoffs(0x00);
			erepTime = (uint32_t)((call MHME_GET.meshEREPTime()/1000)*62500U);
			call EREPTimer.startOneShot(erepTime);

			mhpduHandle = EXTENSION_REQUEST;
			macTxOptions = 0x00; // MESH_TX_OPTIONS_BROADCAST
			call Frame.setAddressingFields(
					   		&cmdFrame,
					        ADDR_MODE_SHORT_ADDRESS,	// SrcAddrMode,
					        ADDR_MODE_SHORT_ADDRESS,	 // DstAddrMode,
					        call MLME_GET.macPANId(),    // DstPANId,
					        &destMACAddress,         		 // DstAddr,
					        NULL                         // security
					 	  );

			if((status = call MCPS_DATA.request(
					        &cmdFrame,         // frame,
					        mhpduLen,		// payloadLength,
					        mhpduHandle,    // mhpduHandle,
					        macTxOptions	// TxOptions,
					     )) != IEEE154_SUCCESS)
			{
				call Leds.led0Toggle();
			}
			else transmittingCmd = TRUE;
		}
	}

	event void EREPTimer.fired()
	{
		uint32_t RxOnDuration = 0;
		uint32_t elapsed_time = call WITimer.getNow() - call WITimer.gett0();
		if(elapsed_time < AD154Compliant)
		{
				RxOnDuration = ((AD154Compliant - elapsed_time)*1000)/62500U;	// TKN154 units --> milliseconds
				RxOnDuration = RxOnDuration*1000 >> 4; // milliseconds --> IEEE802154 symbols
		}
		if((call MHME_GET.meshActiveOrder() != call MHME_GET.meshWakeupOrder())
			&& (call MHME_GET.meshWakeupOrder() < 15))
			call MLME_RX_ENABLE.request(FALSE, 0, RxOnDuration);
	}
	/* Extension Reply */
	task void sendExtensionReplyCmd()
	{
		uint8_t mhpduLen, mhpduHandle, macTxOptions;
		uint8_t * mhpdu;
		ieee155_address_t sourceAddress, destAddress;
		ieee154_address_t destMACAddress;
		ieee154_status_t status;

		mhpduLen = sizeof(uint16_t)	// Frame Control
					+ sizeof(uint16_t) // Destination Address
					+ sizeof(uint16_t) // Source Address
					+ sizeof(uint8_t);	// Command Frame Identifier

		if (mhpduLen <= call Packet.maxPayloadLength())
		{
			memset(&cmdFrame, 0, sizeof(message_t));
			mhpdu = call Frame.getPayload(&cmdFrame);

			destMACAddress.shortAddress = IEEE155_meshcBroadcastAddress;
			destAddress.shortAddress = sourceEREP;
			sourceAddress.shortAddress = call MHME_GET.meshNetworkAddress();

			call MeshFrame.EREP(mhpdu,
									SHORT_ADDR_MODE,
									SHORT_ADDR_MODE,
									destAddress,
									sourceAddress);

			call MLME_SET.macMinBE(0x02);
			call MLME_SET.macMaxCSMABackoffs(0x00);

			mhpduHandle = EXTENSION_REPLY;
			macTxOptions = 0x00; // MESH_TX_OPTIONS_BROADCAST
			call Frame.setAddressingFields(
					   		&cmdFrame,
					        ADDR_MODE_SHORT_ADDRESS,	// SrcAddrMode,
					        ADDR_MODE_SHORT_ADDRESS,	 // DstAddrMode,
					        call MLME_GET.macPANId(),    // DstPANId,
					        &destMACAddress,       		 // DstAddr,
					        NULL                         // security
					 	  );

			if((status = call MCPS_DATA.request(
					        &cmdFrame,         // frame,
					        mhpduLen,		// payloadLength,
					        mhpduHandle,    // mhpduHandle,
					        macTxOptions	// TxOptions,
					     )) != IEEE154_SUCCESS)
			{
				call Leds.led0Toggle();
			}
			else transmittingCmd = TRUE;
		}
	}
}

