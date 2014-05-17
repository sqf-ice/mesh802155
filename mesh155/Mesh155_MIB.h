/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#ifndef __MESH155_MIB_H
#define __MESH155_MIB_H

#include "Mesh155.h"

/****************************************************
 * IEEE 802.15.5 Mesh information base IDENTIFIERS
 **/

enum {

  IEEE155_meshNbOfChildren								= 0xA1,
  IEEE155_meshCapabilityInformation				= 0xA2,
  IEEE155_meshTTLOfHello									= 0xA3,
  IEEE155_meshTreeLevel										= 0xA4,
  IEEE155_meshPANId 											= 0xA5,
  IEEE155_meshNeighborList								= 0xA6,
  IEEE155_meshDeviceType 									= 0xA7,
  IEEE155_meshSequenceNumber							= 0xA8,
  IEEE155_meshNetworkAddress 							= 0xA9,
  IEEE155_meshGroupCommTable 							= 0xAA,
  IEEE155_meshAddressMapping 							= 0xAB,
  IEEE155_meshAcceptMeshDevice 						= 0xAC,
  IEEE155_meshAcceptEndDevice 						= 0xAD,
  IEEE155_meshChildNbReportTime						= 0xAE,
  IEEE155_meshProbeInterval 							= 0xAF,
  IEEE155_meshMaxProbeNum									= 0xB0,
  IEEE155_meshMaxProbeInterval 						= 0xB1,
  IEEE155_MaxMulticastJoinAttempts				= 0xB2,
  IEEE155_meshRBCastTXTimer 							= 0xB3,
  IEEE155_meshRBCastRXTimer 							= 0xB4,
  IEEE155_meshMaxRBCastTrials							= 0xB5,
  IEEE155_meshASESOn 											= 0xB6,
  IEEE155_meshASESExpected								= 0xB7,
  IEEE155_meshWakeupOrder									= 0xB8,
  IEEE155_meshActiveOrder									= 0xB9,
  IEEE155_meshDestActiveOrder							= 0xBA,
  IEEE155_meshEREQTime										= 0xBB,
  IEEE155_meshEREPTime										= 0xBC,
  IEEE155_meshDataTime										= 0xBD,
  IEEE155_meshMaxNumASESRetries						= 0xBE,
  IEEE155_meshSESOn												= 0xBF,
  IEEE155_meshSESExpected									= 0xC0,
  IEEE155_meshSyncInterval								= 0xC1,
  IEEE155_meshMaxSyncRequestAttempts			= 0xC2,
  IEEE155_meshSyncReplyWaitTime						= 0xC3,
  IEEE155_meshFirstTxSyncTime							= 0xC4,
  IEEE155_meshFirstRxSyncTime 						= 0xC5,
  IEEE155_meshSecondRxSyncTime 						= 0xC6,
  IEEE155_meshRegionSynchronizerOn				= 0xC9, //No ID defined, we set C9,
  IEEE155_meshExtendedNeighborHopDistance	= 0xC7,
  IEEE155_meshRejoinTimer 								= 0xC8
};


/****************************************************
 * IEEE 802.15.5 MESH information base (MIB)
 */

typedef struct ieee155_MIB {

  ieee155_meshNbOfChildren_t								meshNbOfChildren;
  ieee155_meshCapabilityInformation_t				meshCapabilityInformation;
  ieee155_meshTTLOfHello_t									meshTTLOfHello;
  ieee155_meshTreeLevel_t										meshTreeLevel;
  ieee155_meshPANId_t												meshPANId;
  ieee155_meshNeighborList_t 							* meshNeighborList;
  ieee155_meshDeviceType_t 									meshDeviceType;
  ieee155_meshSequenceNumber_t							meshSequenceNumber;
  ieee155_meshNetworkAddress_t							meshNetworkAddress;
  ieee155_meshGroupCommTable_t						*	meshGroupCommTable;
  ieee155_meshAddressMapping_t						*	meshAddressMapping;
  ieee155_meshAcceptMeshDevice_t 						meshAcceptMeshDevice;
  ieee155_meshAcceptEndDevice_t							meshAcceptEndDevice;
  ieee155_meshChildNbReportTime_t						meshChildNbReportTime;
  ieee155_meshProbeInterval_t								meshProbeInterval;
  ieee155_meshMaxProbeNum_t									meshMaxProbeNum;
  ieee155_meshMaxProbeInterval_t						meshMaxProbeInterval;
  ieee155_MaxMulticastJoinAttempts_t				MaxMulticastJoinAttempts;
  ieee155_meshRBCastTXTimer_t								meshRBCastTXTimer;
  ieee155_meshRBCastRXTimer_t								meshRBCastRXTimer;
  ieee155_meshMaxRBCastTrials_t							meshMaxRBCastTrials;
  ieee155_meshASESOn_t											meshASESOn;
  ieee155_meshASESExpected_t 								meshASESExpected;
  ieee155_meshWakeupOrder_t									meshWakeupOrder;
  ieee155_meshActiveOrder_t									meshActiveOrder;
  ieee155_meshDestActiveOrder_t							meshDestActiveOrder;
  ieee155_meshEREQTime_t										meshEREQTime;
  ieee155_meshEREPTime_t										meshEREPTime;
  ieee155_meshDataTime_t										meshDataTime;
  ieee155_meshMaxNumASESRetries_t						meshMaxNumASESRetries;
  ieee155_meshSESOn_t												meshSESOn;
  ieee155_meshSESExpected_t 								meshSESExpected;
  ieee155_meshSyncInterval_t								meshSyncInterval;
  ieee155_meshMaxSyncRequestAttempts_t			meshMaxSyncRequestAttempts;
  ieee155_meshSyncReplyWaitTime_t						meshSyncReplyWaitTime;
  ieee155_meshFirstTxSyncTime_t							meshFirstTxSyncTime;
  ieee155_meshFirstRxSyncTime_t							meshFirstRxSyncTime;
  ieee155_meshSecondRxSyncTime_t						meshSecondRxSyncTime;
  ieee155_meshRegionSynchronizerOn_t 				meshRegionSynchronizerOn;
  ieee155_meshExtendedNeighborHopDistance_t	meshExtendedNeighborHopDistance;
 	ieee155_meshRejoinTimer_t									meshRejoinTimer;

} ieee155_MIB_t;

// MESH Information Base (MIB) default attributes

#ifndef IEEE155_DEFAULT_NBOFCHILDREN
  #define IEEE155_DEFAULT_NBOFCHILDREN      0x00
#endif
#ifndef IEEE155_DEFAULT_TTLOFHELLO
  #define IEEE155_DEFAULT_TTLOFHELLO		0x01
#endif
#ifndef IEEE155_DEFAULT_TREELEVEL
  #define IEEE155_DEFAULT_TREELEVEL	0x00
#endif
#ifndef IEEE155_DEFAULT_PANID
  #define IEEE155_DEFAULT_PANID		0xFFFF
#endif
#ifndef IEEE155_DEFAULT_NEIGHBORLIST
  #define IEEE155_DEFAULT_NEIGHBORLIST	NULL
#endif
#ifndef IEEE155_DEFAULT_DEVICETYPE
  #define IEEE155_DEFAULT_DEVICETYPE	END_DEVICE
#endif
#ifndef IEEE155_DEFAULT_SEQUENCENUMBER
  #define IEEE155_DEFAULT_SEQUENCENUMBER	0x00 //Random value.
#endif
#ifndef IEEE155_DEFAULT_NETWORKADDRESS
  #define IEEE155_DEFAULT_NETWORKADDRESS	0xFFFF
#endif
#ifndef IEEE155_DEFAULT_GROUPCOMMTABLE
  #define IEEE155_DEFAULT_GROUPCOMMTABLE	NULL
#endif
#ifndef IEEE155_DEFAULT_ADDRESSMAPPING
  #define IEEE155_DEFAULT_ADDRESSMAPPING	NULL
#endif
#ifndef IEEE155_DEFAULT_ACCEPTMESHDEVICE
  #define IEEE155_DEFAULT_ACCEPTMESHDEVICE	FALSE
#endif
#ifndef IEEE155_DEFAULT_ACCEPTENDDEVICE
  #define IEEE155_DEFAULT_ACCEPTENDDEVICE	FALSE
#endif
#ifndef IEEE155_DEFAULT_CHILDNBREPORTTIME
  #define IEEE155_DEFAULT_CHILDNBREPORTTIME	10 //seconds. (SET AT BUILD TIME)
#endif
#ifndef IEEE155_DEFAULT_PROBEINTERVAL
  #define IEEE155_DEFAULT_PROBEINTERVAL	0x10
#endif
#ifndef IEEE155_DEFAULT_MAXPROBENUM
  #define IEEE155_DEFAULT_MAXPROBENUM		0xFF
#endif
#ifndef IEEE155_DEFAULT_MAXPROBEINTERVAL
  #define IEEE155_DEFAULT_MAXPROBEINTERVAL 0xFFFF
#endif
#ifndef IEEE155_DEFAULT_MAXMULTICASTJOINATTEMPTS
  #define IEEE155_DEFAULT_MAXMULTICASTJOINATTEMPTS	0x07
#endif
#ifndef IEEE155_DEFAULT_RBCASTTXTIMER
  #define IEEE155_DEFAULT_RBCASTTXTIMER 0x00//(SET AT BUILD TIME)
#endif
#ifndef IEEE155_DEFAULT_RBCASTRXTIMER
  #define IEEE155_DEFAULT_RBCASTRXTIMER 0x00//(SET AT BUILD TIME)
#endif
#ifndef IEEE155_DEFAULT_MAXRBCASTTRIALS
  #define IEEE155_DEFAULT_MAXRBCASTTRIALS 0x00//(SET AT BUILD TIME)
#endif
#ifndef IEEE155_DEFAULT_ASESON
  #define IEEE155_DEFAULT_ASESON		FALSE
#endif
#ifndef IEEE155_DEFAULT_ASESEXPECTED
  #define IEEE155_DEFAULT_ASESEXPECTED		FALSE
#endif
#ifndef IEEE155_DEFAULT_WAKEUPORDER
  #define IEEE155_DEFAULT_WAKEUPORDER		15
#endif
#ifndef IEEE155_DEFAULT_ACTIVEORDER
  #define IEEE155_DEFAULT_ACTIVEORDER		15
#endif
#ifndef IEEE155_DEFAULT_DESTACTIVEORDER
  #define IEEE155_DEFAULT_DESTACTIVEORDER	0
#endif
#ifndef IEEE155_DEFAULT_EREQTIME
  #define IEEE155_DEFAULT_EREQTIME		30
#endif
#ifndef IEEE155_DEFAULT_EREPTIME
  #define IEEE155_DEFAULT_EREPTIME		15
#endif
#ifndef IEEE155_DEFAULT_DATATIME
  #define IEEE155_DEFAULT_DATATIME		15
#endif
#ifndef IEEE155_DEFAULT_MAXNUMASESRETRIES
  #define IEEE155_DEFAULT_MAXNUMASESRETRIES		2
#endif
#ifndef IEEE155_DEFAULT_SESON
  #define IEEE155_DEFAULT_SESON		FALSE
#endif
#ifndef IEEE155_DEFAULT_SESEXPECTED
  #define IEEE155_DEFAULT_SESEXPECTED		FALSE
#endif
#ifndef IEEE155_DEFAULT_SYNCINTERVAL
  #define IEEE155_DEFAULT_SYNCINTERVAL		0x0A
#endif
#ifndef IEEE155_DEFAULT_MAXSYNCREQUESTATTEMPTS
  #define IEEE155_DEFAULT_MAXSYNCREQUESTATTEMPTS		0x03
#endif
#ifndef IEEE155_DEFAULT_SYNCREPLYWAITTIME
  #define IEEE155_DEFAULT_SYNCREPLYWAITTIME		50
#endif
#ifndef IEEE155_DEFAULT_FIRSTTXSYNCTIME
  #define IEEE155_DEFAULT_FIRSTTXSYNCTIME		0x00000000
#endif
#ifndef IEEE155_DEFAULT_FIRSTRXSYNCTIME
  #define IEEE155_DEFAULT_FIRSTRXSYNCTIME		0x00000000
#endif
#ifndef IEEE155_DEFAULT_SECONDRXSYNCTIME
  #define IEEE155_DEFAULT_SECONDRXSYNCTIME		0x00000000
#endif
#ifndef IEEE155_DEFAULT_REGIONSYNCHRONIZERON
  #define IEEE155_DEFAULT_REGIONSYNCHRONIZERON		FALSE
#endif
#ifndef IEEE155_DEFAULT_EXTNEIGBRHOPDIST
  #define IEEE155_DEFAULT_EXTNEIGBRHOPDIST		0x03
#endif
#ifndef IEEE155_DEFAULT_REJOINTIME
  #define IEEE155_DEFAULT_REJOINTIME		0xFFFF
#endif

#endif	// __MESH155_MIB_H


