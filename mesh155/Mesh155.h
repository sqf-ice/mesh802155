/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#ifndef __MESH155_H
#define __MESH155_H

#include "TKN154.h"
#include "TKN154_MAC.h"

#define MAX_MDT_SIZE 6
#define	MAX_NUM_NEIGHBORS 10
#define	MAX_NUM_CHILDREN 5
#define ADDRESS_SPACE 4
#define _MESH_QUEUE_SIZE 10

/**************************************
 * IEEE 802.15.5 Mesh Status Values   *
 **************************************/
typedef enum	ieee155_status {

IEEE155_SUCCESS = SUCCESS,
IEEE155_FAIL = FAIL,
IEEE155_INVALID_REQUEST = 0xB1,
IEEE155_NOT_PERMITTED =  0xB2,
IEEE155_NO_NETWORKS = 0xB3,
IEEE155_READ_ONLY = 0xB4,
IEEE155_RECEIVE_SYNC_LOSS = 0xB5,
IEEE155_RECEIVE_SYNC_RESPONSE = 0xB6,
IEEE155_STARTUP_FAILURE = 0xB7,
IEEE155_SYNC_FAILURE = 0xB8,
IEEE155_SYNC_LOSS = 0xB9,
IEEE155_SYNC_SUCCESS = 0xBA,
IEEE155_TRACEROUTE_TIMEOUT = 0xBB,
IEEE155_TRACEROUTE_UNREACHABLE = 0xBC,
IEEE155_UNKNOWN_CHILD_DEVICE = 0xBD

}ieee155_status_t;

typedef enum ieee155_network_status {

NO_ASSOCIATED = 0x00,
ASSOCIATED = 0x01,
SENDING_CHILDREN_NR = 0x02,
SENDING_ADDRESS_ASS = 0x03,
SENDING_HELLO = 0x04,
NETWORK_FORMATION_COMPLETED = 0x05

}ieee155_network_status_t;

typedef enum ieee155_hello {

NUM_HELLO = 6,	// Num of hello messages that are sent during
				// the generation of mesh links
MAX_HELLO_INTERVAL = 71825U, //1.25*62500U
MIN_HELLO_INTERVAL = 46875U  //0.75*62500U

}ieee155_hello_t;

typedef enum ieee155_header_status {

IEEE155_HEADER_OK = 0,
IEEE155_INVALID_MESH_FRAME = -1,
IEEE155_INVALID_DEST_ADDR = -2,
IEEE155_INVALID_SOURCE_ADDR = -3,

}ieee155_header_status_t;

typedef enum ieee155_reportCriteria {

LINK_QUALITY = 0x00,
TREE_LEVEL = 0x01,
RSSI = 0x02,

}ieee155_reportCriteria_t;

/* Table 16 Capability Information bit-fields */

typedef nx_struct CapInfo {
	nx_bool DeviceType;
	nx_bool PowerSource;
	nx_bool ReceiverOnWhenIdle;
	nx_bool AllocateAddress;
}ieee155_meshCapabilityInformation_t;

/* Mesh Discovery Table (MDT) */

typedef struct ieee155_MDT {

	uint16_t 	PANId;
	uint16_t 	Address;
	uint8_t 	LogicalChannel;
	uint8_t 	ChannelPage;
	uint8_t 	MeshVersion;
	uint8_t 	BeaconOrder;
	uint8_t 	SuperframeOrder;
	uint8_t 	LinkQuality;
	int8_t 		RSSI;
	uint8_t 	TreeLevel;
	bool 		AcceptMeshDevice;
	bool 		AcceptEndDevice;
	bool 		SyncEnergySaving;
	bool 		AsyncEnergySaving;

}ieee155_MDT_t;

typedef ieee154_address_t ieee155_address_t;

typedef enum { //The relationship between this device and the neighbor.
	PARENT,
	CHILD,
	SIBLING_DEVICE,
	SYNC_PARENT,
	SYNC_CHILD,
	NO_RELATIONSHIP
} relationship_t;

typedef enum { //The status of this neighbor.
	KNOWN,
	UNKNOWN,
	DOWN,
	LEFT
} status_t;

typedef struct ieee155_meshNeighborList {
	ieee154_address_t macAddress;
	uint16_t begAddress;
	uint16_t endAddress;
	uint8_t treeLevel;
	uint8_t lqi;
	int8_t rssi;
	relationship_t relationship;
  	bool reliableBroadcast;
  	status_t status;
  	uint8_t numHops;
  	uint16_t *GroupMembership;
} ieee155_meshNeighborList_t;

enum frameControlField {

	PROTOCOL_VERSION = 0x01,

	DATA_FRAME = 0x00,
	COMMAND_FRAME = 0x01,

	EXTENDED_ADDR_MODE = 0x00,
	SHORT_ADDR_MODE = 0x01,

	MESH_TX_OPTIONS_ACK = 0x08,
	MESH_TX_OPTIONS_MULTICAST = 0x04,
	MESH_TX_OPTIONS_BROADCAST = 0x02,
	MESH_TX_OPTIONS_RELIABLE_BROADCAST = 0x01,
};

typedef enum meshDeviceType {
	MESH_DEVICE = 0x00,
	END_DEVICE = 0x01,
	MESH_COORD = 0x02
}ieee155_meshDeviceType_t;

/****************************************************
 * typedefs MIB value types
 */

 typedef uint8_t				ieee155_meshNbOfChildren_t;
 typedef uint8_t				ieee155_meshTTLOfHello_t;
 typedef uint16_t				ieee155_meshTreeLevel_t;
 typedef uint16_t				ieee155_meshPANId_t;
 typedef uint8_t				ieee155_meshSequenceNumber_t;
 typedef uint16_t				ieee155_meshNetworkAddress_t;
 typedef void 					ieee155_meshGroupCommTable_t;
 typedef void 					ieee155_meshAddressMapping_t;
 typedef bool					ieee155_meshAcceptMeshDevice_t;
 typedef bool					ieee155_meshAcceptEndDevice_t;
 typedef uint32_t				ieee155_meshChildNbReportTime_t;
 typedef uint16_t				ieee155_meshProbeInterval_t;
 typedef uint8_t				ieee155_meshMaxProbeNum_t;
 typedef uint16_t				ieee155_meshMaxProbeInterval_t;
 typedef uint8_t				ieee155_MaxMulticastJoinAttempts_t;
 typedef uint16_t				ieee155_meshRBCastTXTimer_t;
 typedef uint16_t				ieee155_meshRBCastRXTimer_t;
 typedef uint8_t				ieee155_meshMaxRBCastTrials_t;
 typedef bool					ieee155_meshASESOn_t;
 typedef bool					ieee155_meshASESExpected_t;
 typedef uint8_t				ieee155_meshWakeupOrder_t;
 typedef uint8_t				ieee155_meshActiveOrder_t;
 typedef uint8_t				ieee155_meshDestActiveOrder_t;
 typedef uint8_t				ieee155_meshEREQTime_t;
 typedef uint8_t				ieee155_meshEREPTime_t;
 typedef uint8_t				ieee155_meshDataTime_t;
 typedef uint8_t				ieee155_meshMaxNumASESRetries_t;
 typedef bool					ieee155_meshSESOn_t;
 typedef bool					ieee155_meshSESExpected_t;
 typedef uint8_t				ieee155_meshSyncInterval_t;
 typedef uint8_t				ieee155_meshMaxSyncRequestAttempts_t;
 typedef uint8_t				ieee155_meshSyncReplyWaitTime_t;
 typedef uint32_t				ieee155_meshFirstTxSyncTime_t;
 typedef uint32_t				ieee155_meshFirstRxSyncTime_t;
 typedef uint32_t				ieee155_meshSecondRxSyncTime_t;
 typedef bool					ieee155_meshRegionSynchronizerOn_t;
 typedef uint8_t				ieee155_meshExtendedNeighborHopDistance_t;
 typedef uint16_t				ieee155_meshRejoinTimer_t;

// Table 41
enum {
  // MESH sublayer constants
  IEEE155_meshcCoordinatorCapacity     = TRUE,
  IEEE155_meshcBroadcastAddress		   = 0xFFFF,
  IEEE155_meshcMaxMeshHeaderLength     = 0x12,
  IEEE155_meshcTimeUnit	               = 1,
  IEEE155_meshcBaseActiveDuration      = (IEEE155_meshcTimeUnit * 5),
  IEEE155_meshcMaxLostSynchronization  = 3,
  IEEE155_meshcReservationSlotDuration = 625
};

//Table 35 - Valid values of command frame identifiers field [Pag. 45 - IEE 802.15.5 - 2009]
typedef enum ieee155_commandFrameID
{
  CHILDREN_NUMBER_REPORT        = 0x01,
  ADDRESS_ASSIGNMENT			= 0x02,
  HELLO							= 0x03,
  NEIGHBOR_INFORMATION_REQUEST	= 0x04,
  NEIGHBOR_INFORMATION_REPLY	= 0x05,
  LINK_STATE					= 0x06,
  LINK_STATE_MISMATCH			= 0x07,
  PROBE							= 0x08,
  G_JREQ						= 0x09,
  G_JREP						= 0x0A,
  G_LREQ						= 0x0B,
  GROUP_LEAVE_REPLY				= 0x0C,
  WAKEUP_NOTIFICATION			= 0x0D,
  EXTENSION_REQUEST				= 0x0E,
  EXTENSION_REPLY				= 0x0F,
  SYNCHRONIZATION_REQUEST		= 0x10,
  SYNCHRONIZATION_REPLY			= 0x11,
  RESERVATION_REQUEST			= 0x12,
  RESERVATION_REPLY				= 0x13,
  REJOIN_NOTIFY					= 0x14,
  TRACEROUTE_REQUEST			= 0x15,
  TRACEROUTE_REPLY				= 0x16,
  LEAVE							= 0x17
//RESERVED						= 0x18 - 0xFF
} ieee155_commandFrameID_t;

#ifndef ROUTING_CRITERIA
#define ROUTING_CRITERIA TREE_LEVEL
#endif

typedef struct
{
  uint8_t header[IEEE155_meshcMaxMeshHeaderLength];
  uint8_t payload[IEEE154_aMaxMACPayloadSize - IEEE155_meshcMaxMeshHeaderLength];
  uint8_t headerLen;
  uint8_t payloadLen;
  uint8_t handle;
} ieee155_txframe_t;

#endif // __MESH155_H
