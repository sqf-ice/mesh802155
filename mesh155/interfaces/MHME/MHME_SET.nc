/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

/**
 * This interface allows to set attribute values in the Mesh Information Base (MIB).
 * Instead of passing the MIB attribute identifier, there is a separate
 * command per attribute (and there are no confirm events).
 *
 */

#include "Mesh155.h"
#include "Mesh155_MIB.h"

interface MHME_SET {

  /** @param value new MIB attribute value for meshNbOfChildren (0xA1)
   *  @returns IEEE155_FAIL if MIB attribute was not updated */
  command ieee154_status_t meshNbOfChildren(ieee155_meshNbOfChildren_t value);

  /** @param value new MIB attribute value for meshCapabilityInformation (0xA2)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshCapabilityInformation(ieee155_meshCapabilityInformation_t value);

  /** @param value new MIB attribute value for meshTTLOfHello (0xA3)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshTTLOfHello(ieee155_meshTTLOfHello_t value);

  /** @param value new MIB attribute value for meshTreeLevel (0xA4)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshTreeLevel(ieee155_meshTreeLevel_t value);

  /** @param value new MIB attribute value for meshPANId (0xA5)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshPANId(ieee155_meshPANId_t value);

  /** @param value new MIB attribute value for meshNeighborList (0xA6)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshNeighborList(ieee155_meshNeighborList_t * value);

  /** @param value new MIB attribute value for meshDeviceType (0xA7)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshDeviceType(ieee155_meshDeviceType_t value);

  /** @param value new MIB attribute value for meshSequenceNumber (0xA8)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshSequenceNumber(ieee155_meshSequenceNumber_t value);

  /** @param value new MIB attribute value for meshNetworkAddress (0xA9)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshNetworkAddress(ieee155_meshNetworkAddress_t value);

  /** @param value new MIB attribute value for meshGroupCommTable (0xAA)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshGroupCommTable(ieee155_meshGroupCommTable_t * value);

  /** @param value new MIB attribute value for meshAddressMapping (0xAB)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshAddressMapping(ieee155_meshAddressMapping_t * value);

  /** @param value new MIB attribute value for meshAcceptMeshDevice (0xAC)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshAcceptMeshDevice(ieee155_meshAcceptMeshDevice_t value);

	/** @param value new MIB attribute value for meshAcceptEndDevice (0xAD)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshAcceptEndDevice(ieee155_meshAcceptEndDevice_t value);

  /** @param value new MIB attribute value for meshChildNbReportTime (0xAE)
   *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshChildNbReportTime(ieee155_meshChildNbReportTime_t value);

  /** @param value new MIB attribute value for meshProbeInterval (0xAF)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshProbeInterval(ieee155_meshProbeInterval_t value);

  /** @param value new MIB attribute value for meshMaxProbeNum (0xB0)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshMaxProbeNum(ieee155_meshMaxProbeNum_t value);

  /** @param value new MIB attribute value for meshMaxProbeInterval (0xB1)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshMaxProbeInterval(ieee155_meshMaxProbeInterval_t value);

  /** @param value new MIB attribute value for MaxMulticastJoinAttempts (0xB2)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t MaxMulticastJoinAttempts(ieee155_MaxMulticastJoinAttempts_t value);

  /** @param value new MIB attribute value for meshRBCastTXTimer (0xB3)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshRBCastTXTimer(ieee155_meshRBCastTXTimer_t value);

  /** @param value new MIB attribute value for meshRBCastRXTimer (0xB4)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshRBCastRXTimer(ieee155_meshRBCastRXTimer_t value);

  /** @param value new MIB attribute value for meshMaxRBCastTrials (0xB5)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshMaxRBCastTrials(ieee155_meshMaxRBCastTrials_t value);

  /** @param value new MIB attribute value for meshASESOn (0xB6)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshASESOn(ieee155_meshASESOn_t value);

  /** @param value new MIB attribute value for meshASESExpected (0xB7)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshASESExpected(ieee155_meshASESExpected_t value);

  /** @param value new MIB attribute value for meshWakeupOrder (0xB8)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshWakeupOrder(ieee155_meshWakeupOrder_t value);

  /** @param value new MIB attribute value for meshActiveOrder (0xB9)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshActiveOrder(ieee155_meshActiveOrder_t value);

  /** @param value new MIB attribute value for meshDestActiveOrder (0xBA)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshDestActiveOrder(ieee155_meshDestActiveOrder_t value);

  /** @param value new MIB attribute value for meshEREQTime (0xBB)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshEREQTime(ieee155_meshEREQTime_t value);

  /** @param value new MIB attribute value for meshEREPTime (0xBC)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshEREPTime(ieee155_meshEREPTime_t value);

  /** @param value new MIB attribute value for meshDataTime (0xBD)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshDataTime(ieee155_meshDataTime_t value);

  /** @param value new MIB attribute value for meshMaxNumASESRetries (0xBE)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshMaxNumASESRetries(ieee155_meshMaxNumASESRetries_t value);

  /** @param value new MIB attribute value for meshSESOn (0xBF)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshSESOn(ieee155_meshSESOn_t value);

  /** @param value new MIB attribute value for meshSESExpected (0xC0)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshSESExpected(ieee155_meshSESExpected_t value);

  /** @param value new MIB attribute value for meshSyncInterval (0xC1)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshSyncInterval(ieee155_meshSyncInterval_t value);

  /** @param value new MIB attribute value for meshMaxSyncRequestAttempts (0xC2)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshMaxSyncRequestAttempts(ieee155_meshMaxSyncRequestAttempts_t value);

  /** @param value new MIB attribute value for meshSyncReplyWaitTime (0xC3)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshSyncReplyWaitTime(ieee155_meshSyncReplyWaitTime_t value);

  /** @param value new MIB attribute value for meshFirstTxSyncTime (0xC4)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshFirstTxSyncTime(ieee155_meshFirstTxSyncTime_t value);

  /** @param value new MIB attribute value for meshFirstRxSyncTime (0xC5)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshFirstRxSyncTime(ieee155_meshFirstRxSyncTime_t value);

  /** @param value new MIB attribute value for meshSecondRxSyncTime (0xC6)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshSecondRxSyncTime(ieee155_meshSecondRxSyncTime_t value);

  /** @param value new MIB attribute value for meshRegionSynchronizerOn (-)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshRegionSynchronizerOn(ieee155_meshRegionSynchronizerOn_t value);

  /** @param value new MIB attribute value for meshExtendedNeighborHopDistance (0xC7)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshExtendedNeighborHopDistance(ieee155_meshExtendedNeighborHopDistance_t value);

  /** @param value new MIB attribute value for meshRejoinTimer (0xC8)
  *  @returns IEEE154_FAILURE if MIB attribute was not updated */
  command ieee154_status_t meshRejoinTimer(ieee155_meshRejoinTimer_t value);
}
