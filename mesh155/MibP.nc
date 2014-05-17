/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"
#include "Mesh155_MIB.h"

module MibP {
	provides {
    interface MHME_RESET;
		interface MHME_SET;
		interface MHME_GET;
		interface Notify<const void*> as MIBUpdate[uint8_t MIBAttributeID];
	}
	uses {
     interface MLME_RESET;
		 interface MLME_SET;
		 interface NeighborList;
	}

}

implementation
{

ieee155_MIB_t mesh_mib;

void resetMeshAttributesToDefault();


  command ieee155_status_t MHME_RESET.request()
  {
  	// It should check if it is connected to any other network.
  	// No implementation provided.
		call MLME_RESET.request(TRUE);
		return IEEE155_SUCCESS;
  }

  event void MLME_RESET.confirm(ieee154_status_t status){
			resetMeshAttributesToDefault();
			signal MHME_RESET.confirm(status);
  }


  void resetMeshAttributesToDefault()
  {
		mesh_mib.meshNbOfChildren 								= IEEE155_DEFAULT_NBOFCHILDREN;
		mesh_mib.meshCapabilityInformation.DeviceType 				= FALSE;
		mesh_mib.meshCapabilityInformation.PowerSource 				= FALSE;
		mesh_mib.meshCapabilityInformation.ReceiverOnWhenIdle = FALSE;
		mesh_mib.meshCapabilityInformation.AllocateAddress 		= TRUE;
		mesh_mib.meshTTLOfHello 									= IEEE155_DEFAULT_TTLOFHELLO;
		mesh_mib.meshTreeLevel 										= IEEE155_DEFAULT_TREELEVEL;
		mesh_mib.meshPANId 												= IEEE155_DEFAULT_PANID;
		mesh_mib.meshNeighborList 								= IEEE155_DEFAULT_NEIGHBORLIST;
		mesh_mib.meshDeviceType										= IEEE155_DEFAULT_DEVICETYPE;
		mesh_mib.meshSequenceNumber 							= IEEE155_DEFAULT_SEQUENCENUMBER;
		mesh_mib.meshNetworkAddress   						= IEEE155_DEFAULT_NETWORKADDRESS;
		mesh_mib.meshGroupCommTable 							= IEEE155_DEFAULT_GROUPCOMMTABLE;
		mesh_mib.meshAddressMapping 							= IEEE155_DEFAULT_ADDRESSMAPPING;
		mesh_mib.meshAcceptMeshDevice 						= IEEE155_DEFAULT_ACCEPTMESHDEVICE;
		mesh_mib.meshAcceptEndDevice 							= IEEE155_DEFAULT_ACCEPTENDDEVICE;
		mesh_mib.meshChildNbReportTime   					= IEEE155_DEFAULT_CHILDNBREPORTTIME;
		mesh_mib.meshProbeInterval   							= IEEE155_DEFAULT_PROBEINTERVAL;
		mesh_mib.meshMaxProbeNum 									= IEEE155_DEFAULT_MAXPROBENUM;
		mesh_mib.meshMaxProbeInterval   					= IEEE155_DEFAULT_MAXPROBEINTERVAL;
		mesh_mib.MaxMulticastJoinAttempts 				= IEEE155_DEFAULT_MAXMULTICASTJOINATTEMPTS;
		mesh_mib.meshRBCastTXTimer 								= IEEE155_DEFAULT_RBCASTTXTIMER;
		mesh_mib.meshRBCastRXTimer  							= IEEE155_DEFAULT_RBCASTRXTIMER;
		mesh_mib.meshMaxRBCastTrials							= IEEE155_DEFAULT_MAXRBCASTTRIALS;
		mesh_mib.meshASESOn 											= IEEE155_DEFAULT_ASESON;
		mesh_mib.meshASESExpected 								= IEEE155_DEFAULT_ASESEXPECTED;
		mesh_mib.meshWakeupOrder 									= IEEE155_DEFAULT_WAKEUPORDER;
		mesh_mib.meshActiveOrder 									= IEEE155_DEFAULT_ACTIVEORDER;
		mesh_mib.meshDestActiveOrder 							= IEEE155_DEFAULT_DESTACTIVEORDER;
		mesh_mib.meshEREQTime 										= IEEE155_DEFAULT_EREQTIME;
		mesh_mib.meshEREPTime 										= IEEE155_DEFAULT_EREPTIME;
		mesh_mib.meshDataTime											= IEEE155_DEFAULT_DATATIME;
		mesh_mib.meshMaxNumASESRetries 						= IEEE155_DEFAULT_MAXNUMASESRETRIES;
		mesh_mib.meshSESOn 												= IEEE155_DEFAULT_SESON;
		mesh_mib.meshSESExpected 									= IEEE155_DEFAULT_SESEXPECTED;
		mesh_mib.meshSyncInterval 								= IEEE155_DEFAULT_SYNCINTERVAL;
		mesh_mib.meshMaxSyncRequestAttempts 			= IEEE155_DEFAULT_MAXSYNCREQUESTATTEMPTS;
		mesh_mib.meshSyncReplyWaitTime 						= IEEE155_DEFAULT_SYNCREPLYWAITTIME;
		mesh_mib.meshFirstTxSyncTime   						= IEEE155_DEFAULT_FIRSTTXSYNCTIME;
		mesh_mib.meshFirstRxSyncTime   						= IEEE155_DEFAULT_FIRSTRXSYNCTIME;
		mesh_mib.meshSecondRxSyncTime   					= IEEE155_DEFAULT_SECONDRXSYNCTIME;
		mesh_mib.meshRegionSynchronizerOn 				= IEEE155_DEFAULT_REGIONSYNCHRONIZERON;
  	mesh_mib.meshExtendedNeighborHopDistance	= IEEE155_DEFAULT_EXTNEIGBRHOPDIST;
  	mesh_mib.meshRejoinTimer 									= IEEE155_DEFAULT_REJOINTIME;
  }



	/* ----------------------- MHME-SET ----------------------- */

  command ieee154_status_t MHME_SET.meshNbOfChildren(ieee155_meshNbOfChildren_t value)
  {
  	mesh_mib.meshNbOfChildren = value;
		signal MIBUpdate.notify[IEEE155_meshNbOfChildren](&mesh_mib.meshNbOfChildren);
		return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshCapabilityInformation(ieee155_meshCapabilityInformation_t value)
  {
  	mesh_mib.meshCapabilityInformation = value;

  	call MLME_SET.macAutoRequest(TRUE);
    call MLME_SET.macRxOnWhenIdle((value.ReceiverOnWhenIdle == TRUE)?1:0);

    if(value.DeviceType == TRUE)
    	call MHME_SET.meshDeviceType(MESH_DEVICE);
    else
    	call MHME_SET.meshDeviceType(END_DEVICE);

		signal MIBUpdate.notify[IEEE155_meshCapabilityInformation](&mesh_mib.meshCapabilityInformation);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshTTLOfHello(ieee155_meshTTLOfHello_t value)
  {
  	mesh_mib.meshTTLOfHello = value;
		signal MIBUpdate.notify[IEEE155_meshTTLOfHello](&mesh_mib.meshTTLOfHello);
		return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshTreeLevel(ieee155_meshTreeLevel_t value)
  {
  	mesh_mib.meshTreeLevel = value;
		signal MIBUpdate.notify[IEEE155_meshTreeLevel](&mesh_mib.meshTreeLevel);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshPANId(ieee155_meshPANId_t value)
  {
  	mesh_mib.meshPANId = value;
	signal MIBUpdate.notify[IEEE155_meshPANId](&mesh_mib.meshPANId);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshNeighborList(ieee155_meshNeighborList_t * value)
  {
  	mesh_mib.meshNeighborList = value;
  	signal MIBUpdate.notify[IEEE155_meshNeighborList](&mesh_mib.meshNeighborList);
  	return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshDeviceType(ieee155_meshDeviceType_t value)
  {
  	if((value != MESH_COORD) && (value != MESH_DEVICE) && (value != END_DEVICE))
      return IEEE154_INVALID_PARAMETER;
    mesh_mib.meshDeviceType = value;
    call NeighborList.create(value);
	signal MIBUpdate.notify[IEEE155_meshDeviceType](&mesh_mib.meshDeviceType);
	return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshSequenceNumber(ieee155_meshSequenceNumber_t value)
  {
  	mesh_mib.meshSequenceNumber = value;
	signal MIBUpdate.notify[IEEE155_meshSequenceNumber](&mesh_mib.meshSequenceNumber);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshNetworkAddress(ieee155_meshNetworkAddress_t value)
  {
    if(value == 0xFFFF)
      return IEEE154_INVALID_PARAMETER;
  	mesh_mib.meshNetworkAddress = value;
	signal MIBUpdate.notify[IEEE155_meshNetworkAddress](&mesh_mib.meshNetworkAddress);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshGroupCommTable(ieee155_meshGroupCommTable_t * value)
  {
  	mesh_mib.meshGroupCommTable = value;
		signal MIBUpdate.notify[IEEE155_meshGroupCommTable](&mesh_mib.meshGroupCommTable);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshAddressMapping(ieee155_meshAddressMapping_t * value)
  {
  	mesh_mib.meshAddressMapping = value;
		signal MIBUpdate.notify[IEEE155_meshAddressMapping](&mesh_mib.meshAddressMapping);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshAcceptMeshDevice(ieee155_meshAcceptMeshDevice_t value)
  {
  	mesh_mib.meshAcceptMeshDevice = value;
		signal MIBUpdate.notify[IEEE155_meshAcceptMeshDevice](&mesh_mib.meshAcceptMeshDevice);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshAcceptEndDevice(ieee155_meshAcceptEndDevice_t value)
  {
  	mesh_mib.meshAcceptEndDevice = value;
		signal MIBUpdate.notify[IEEE155_meshAcceptEndDevice](&mesh_mib.meshAcceptEndDevice);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshChildNbReportTime(ieee155_meshChildNbReportTime_t value)
  {
  	mesh_mib.meshChildNbReportTime = value;
		signal MIBUpdate.notify[IEEE155_meshChildNbReportTime](&mesh_mib.meshChildNbReportTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshProbeInterval(ieee155_meshProbeInterval_t value)
  {
  	mesh_mib.meshProbeInterval = value;
		signal MIBUpdate.notify[IEEE155_meshProbeInterval](&mesh_mib.meshProbeInterval);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshMaxProbeNum(ieee155_meshMaxProbeNum_t value)
  {
  	mesh_mib.meshMaxProbeNum = value;
		signal MIBUpdate.notify[IEEE155_meshMaxProbeNum](&mesh_mib.meshMaxProbeNum);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshMaxProbeInterval(ieee155_meshMaxProbeInterval_t value)
  {
  	mesh_mib.meshMaxProbeInterval = value;
		signal MIBUpdate.notify[IEEE155_meshMaxProbeInterval](&mesh_mib.meshMaxProbeInterval);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.MaxMulticastJoinAttempts(ieee155_MaxMulticastJoinAttempts_t value)
  {
  	mesh_mib.MaxMulticastJoinAttempts = value;
		signal MIBUpdate.notify[IEEE155_MaxMulticastJoinAttempts](&mesh_mib.MaxMulticastJoinAttempts);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshRBCastTXTimer(ieee155_meshRBCastTXTimer_t value)
  {
  	mesh_mib.meshRBCastTXTimer = value;
		signal MIBUpdate.notify[IEEE155_meshRBCastTXTimer](&mesh_mib.meshRBCastTXTimer);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshRBCastRXTimer(ieee155_meshRBCastRXTimer_t value)
  {
  	mesh_mib.meshRBCastRXTimer = value;
		signal MIBUpdate.notify[IEEE155_meshRBCastRXTimer](&mesh_mib.meshRBCastRXTimer);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshMaxRBCastTrials(ieee155_meshMaxRBCastTrials_t value)
  {
  	mesh_mib.meshMaxRBCastTrials = value;
		signal MIBUpdate.notify[IEEE155_meshMaxRBCastTrials](&mesh_mib.meshMaxRBCastTrials);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshASESOn(ieee155_meshASESOn_t value)
  {
  	mesh_mib.meshASESOn = value;
		signal MIBUpdate.notify[IEEE155_meshASESOn](&mesh_mib.meshASESOn);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshASESExpected(ieee155_meshASESExpected_t value)
  {
  	mesh_mib.meshASESExpected = value;
		signal MIBUpdate.notify[IEEE155_meshASESExpected](&mesh_mib.meshASESExpected);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshWakeupOrder(ieee155_meshWakeupOrder_t value)
  {
    if(value > 15)
      return IEEE154_INVALID_PARAMETER;
  	mesh_mib.meshWakeupOrder = value;
		signal MIBUpdate.notify[IEEE155_meshWakeupOrder](&mesh_mib.meshWakeupOrder);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshActiveOrder(ieee155_meshActiveOrder_t value)
  {
    if(value > 15)
      return IEEE154_INVALID_PARAMETER;
  	mesh_mib.meshActiveOrder = value;
		signal MIBUpdate.notify[IEEE155_meshActiveOrder](&mesh_mib.meshActiveOrder);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshDestActiveOrder(ieee155_meshDestActiveOrder_t value)
  {
    if(value > 15)
      return IEEE154_INVALID_PARAMETER;
  	mesh_mib.meshDestActiveOrder = value;
		signal MIBUpdate.notify[IEEE155_meshDestActiveOrder](&mesh_mib.meshDestActiveOrder);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshEREQTime(ieee155_meshEREQTime_t value)
  {
  	mesh_mib.meshEREQTime = value;
		signal MIBUpdate.notify[IEEE155_meshEREQTime](&mesh_mib.meshEREQTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshEREPTime(ieee155_meshEREPTime_t value)
  {
  	mesh_mib.meshEREPTime = value;
		signal MIBUpdate.notify[IEEE155_meshEREPTime](&mesh_mib.meshEREPTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshDataTime(ieee155_meshDataTime_t value)
  {
  	mesh_mib.meshDataTime = value;
		signal MIBUpdate.notify[IEEE155_meshDataTime](&mesh_mib.meshDataTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshMaxNumASESRetries(ieee155_meshMaxNumASESRetries_t value)
  {
    if(value > 15)
      return IEEE154_INVALID_PARAMETER;
  	mesh_mib.meshMaxNumASESRetries = value;
		signal MIBUpdate.notify[IEEE155_meshMaxNumASESRetries](&mesh_mib.meshMaxNumASESRetries);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshSESOn(ieee155_meshSESOn_t value)
  {
  	mesh_mib.meshSESOn = value;
		signal MIBUpdate.notify[IEEE155_meshSESOn](&mesh_mib.meshSESOn);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshSESExpected(ieee155_meshSESExpected_t value)
  {
  	mesh_mib.meshSESExpected = value;
		signal MIBUpdate.notify[IEEE155_meshSESExpected](&mesh_mib.meshSESExpected);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshSyncInterval(ieee155_meshSyncInterval_t value)
  {
  	mesh_mib.meshSyncInterval = value;
		signal MIBUpdate.notify[IEEE155_meshSyncInterval](&mesh_mib.meshSyncInterval);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshMaxSyncRequestAttempts(ieee155_meshMaxSyncRequestAttempts_t value)
  {
  	mesh_mib.meshMaxSyncRequestAttempts = value;
		signal MIBUpdate.notify[IEEE155_meshMaxSyncRequestAttempts](&mesh_mib.meshMaxSyncRequestAttempts);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshSyncReplyWaitTime(ieee155_meshSyncReplyWaitTime_t value)
  {
  	mesh_mib.meshSyncReplyWaitTime = value;
		signal MIBUpdate.notify[IEEE155_meshSyncReplyWaitTime](&mesh_mib.meshSyncReplyWaitTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshFirstTxSyncTime(ieee155_meshFirstTxSyncTime_t value)
  {
  	mesh_mib.meshFirstTxSyncTime = value;
		signal MIBUpdate.notify[IEEE155_meshFirstTxSyncTime](&mesh_mib.meshFirstTxSyncTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshFirstRxSyncTime(ieee155_meshFirstRxSyncTime_t value)
  {
  	mesh_mib.meshFirstRxSyncTime = value;
		signal MIBUpdate.notify[IEEE155_meshFirstRxSyncTime](&mesh_mib.meshFirstRxSyncTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshSecondRxSyncTime(ieee155_meshSecondRxSyncTime_t value)
  {
  	mesh_mib.meshSecondRxSyncTime = value;
		signal MIBUpdate.notify[IEEE155_meshSecondRxSyncTime](&mesh_mib.meshSecondRxSyncTime);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshRegionSynchronizerOn(ieee155_meshRegionSynchronizerOn_t value)
  {
  	mesh_mib.meshRegionSynchronizerOn = value;
		signal MIBUpdate.notify[IEEE155_meshRegionSynchronizerOn](&mesh_mib.meshRegionSynchronizerOn);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshExtendedNeighborHopDistance(ieee155_meshExtendedNeighborHopDistance_t value)
  {
  	mesh_mib.meshExtendedNeighborHopDistance = value;
		signal MIBUpdate.notify[IEEE155_meshExtendedNeighborHopDistance](&mesh_mib.meshExtendedNeighborHopDistance);
    return IEEE154_SUCCESS;
  }

  command ieee154_status_t MHME_SET.meshRejoinTimer(ieee155_meshRejoinTimer_t value)
  {
  	mesh_mib.meshRejoinTimer = value;
		signal MIBUpdate.notify[IEEE155_meshRejoinTimer](&mesh_mib.meshRejoinTimer);
    return IEEE154_SUCCESS;
  }


	  /* ----------------------- MHME-GET ----------------------- */


	default event void MIBUpdate.notify[uint8_t MIBAttributeID](const void* MIBAttributeValue) {}
	command error_t MIBUpdate.enable[uint8_t MIBAttributeID]() {return FAIL;}
	command error_t MIBUpdate.disable[uint8_t MIBAttributeID]() {return FAIL;}

	command ieee155_meshNbOfChildren_t MHME_GET.meshNbOfChildren(){ return mesh_mib.meshNbOfChildren; }

	command ieee155_meshCapabilityInformation_t MHME_GET.meshCapabilityInformation(){ return mesh_mib.meshCapabilityInformation; }

	command ieee155_meshTTLOfHello_t MHME_GET.meshTTLOfHello(){ return mesh_mib.meshTTLOfHello; }

	command ieee155_meshTreeLevel_t MHME_GET.meshTreeLevel(){ return mesh_mib.meshTreeLevel; }

	command ieee155_meshPANId_t MHME_GET.meshPANId(){ return mesh_mib.meshPANId; }

	command ieee155_meshNeighborList_t * MHME_GET.meshNeighborList(){ return mesh_mib.meshNeighborList; }

	command ieee155_meshDeviceType_t MHME_GET.meshDeviceType(){ return mesh_mib.meshDeviceType; }

	command ieee155_meshSequenceNumber_t MHME_GET.meshSequenceNumber(){ return mesh_mib.meshSequenceNumber; }

	command ieee155_meshNetworkAddress_t MHME_GET.meshNetworkAddress(){ return mesh_mib.meshNetworkAddress; }

	command ieee155_meshGroupCommTable_t * MHME_GET.meshGroupCommTable(){ return mesh_mib.meshGroupCommTable; }

	command ieee155_meshAddressMapping_t * MHME_GET.meshAddressMapping(){ return mesh_mib.meshAddressMapping; }

	command ieee155_meshAcceptMeshDevice_t MHME_GET.meshAcceptMeshDevice(){ return mesh_mib.meshAcceptMeshDevice; }

	command ieee155_meshAcceptEndDevice_t MHME_GET.meshAcceptEndDevice(){ return mesh_mib.meshAcceptEndDevice; }

	command ieee155_meshChildNbReportTime_t MHME_GET.meshChildNbReportTime(){ return mesh_mib.meshChildNbReportTime; }

 	command ieee155_meshProbeInterval_t MHME_GET.meshProbeInterval(){ return mesh_mib.meshProbeInterval; }

 	command ieee155_meshMaxProbeNum_t MHME_GET.meshMaxProbeNum(){ return mesh_mib.meshMaxProbeNum; }

 	command ieee155_meshMaxProbeInterval_t MHME_GET.meshMaxProbeInterval(){ return mesh_mib.meshMaxProbeInterval; }

 	command ieee155_MaxMulticastJoinAttempts_t MHME_GET.MaxMulticastJoinAttempts(){ return mesh_mib.MaxMulticastJoinAttempts; }

 	command ieee155_meshRBCastTXTimer_t MHME_GET.meshRBCastTXTimer(){ return mesh_mib.meshRBCastTXTimer; }

 	command ieee155_meshRBCastRXTimer_t MHME_GET.meshRBCastRXTimer(){ return mesh_mib.meshRBCastRXTimer; }

 	command ieee155_meshMaxRBCastTrials_t MHME_GET.meshMaxRBCastTrials(){ return mesh_mib.meshMaxRBCastTrials; }

 	command ieee155_meshASESOn_t MHME_GET.meshASESOn(){ return mesh_mib.meshASESOn; }

 	command ieee155_meshASESExpected_t MHME_GET.meshASESExpected(){ return mesh_mib.meshASESExpected; }

 	command ieee155_meshWakeupOrder_t MHME_GET.meshWakeupOrder(){ return mesh_mib.meshWakeupOrder; }

 	command ieee155_meshActiveOrder_t MHME_GET.meshActiveOrder(){ return mesh_mib.meshActiveOrder; }

 	command ieee155_meshDestActiveOrder_t MHME_GET.meshDestActiveOrder(){ return mesh_mib.meshDestActiveOrder; }

 	command ieee155_meshEREQTime_t MHME_GET.meshEREQTime(){ return mesh_mib.meshEREQTime; }

 	command ieee155_meshEREPTime_t MHME_GET.meshEREPTime(){ return mesh_mib.meshEREPTime; }

 	command ieee155_meshDataTime_t MHME_GET.meshDataTime(){ return mesh_mib.meshDataTime; }

 	command ieee155_meshMaxNumASESRetries_t MHME_GET.meshMaxNumASESRetries(){ return mesh_mib.meshMaxNumASESRetries; }

 	command ieee155_meshSESOn_t MHME_GET.meshSESOn(){ return mesh_mib.meshSESOn; }

 	command ieee155_meshSESExpected_t MHME_GET.meshSESExpected(){ return mesh_mib.meshSESExpected; }

 	command ieee155_meshSyncInterval_t MHME_GET.meshSyncInterval(){ return mesh_mib.meshSyncInterval; }

 	command ieee155_meshMaxSyncRequestAttempts_t MHME_GET.meshMaxSyncRequestAttempts(){ return mesh_mib.meshMaxSyncRequestAttempts; }

 	command ieee155_meshSyncReplyWaitTime_t MHME_GET.meshSyncReplyWaitTime(){ return mesh_mib.meshSyncReplyWaitTime; }

 	command ieee155_meshFirstTxSyncTime_t MHME_GET.meshFirstTxSyncTime(){ return mesh_mib.meshFirstTxSyncTime; }

 	command ieee155_meshFirstRxSyncTime_t MHME_GET.meshFirstRxSyncTime(){ return mesh_mib.meshFirstRxSyncTime; }

 	command ieee155_meshSecondRxSyncTime_t MHME_GET.meshSecondRxSyncTime(){ return mesh_mib.meshSecondRxSyncTime; }

 	command ieee155_meshRegionSynchronizerOn_t MHME_GET.meshRegionSynchronizerOn(){ return mesh_mib.meshRegionSynchronizerOn; }

 	command ieee155_meshExtendedNeighborHopDistance_t MHME_GET.meshExtendedNeighborHopDistance(){ return mesh_mib.meshExtendedNeighborHopDistance; }

 	command ieee155_meshRejoinTimer_t MHME_GET.meshRejoinTimer(){ return mesh_mib.meshRejoinTimer; }

}
