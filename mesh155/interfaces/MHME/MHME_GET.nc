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

/**
 * This interface allows to get attribute values in the Mesh Information Base (MIB).
 */

#include "Mesh155_MIB.h"

interface MHME_GET {

	/** @return MIB attribute meshNbOfChildren */
	command ieee155_meshNbOfChildren_t meshNbOfChildren();

	/** @return MIB attribute meshCapabilityInformation */
	command ieee155_meshCapabilityInformation_t meshCapabilityInformation();

	/** @return MIB attribute meshTTLOfHello */
	command ieee155_meshTTLOfHello_t meshTTLOfHello();

	/** @return MIB attribute meshTreeLevel */
	command ieee155_meshTreeLevel_t meshTreeLevel();

	/** @return MIB attribute meshPANId */
	command ieee155_meshPANId_t meshPANId();

 	/** @return MIB attribute meshNeighborList */
	command ieee155_meshNeighborList_t * meshNeighborList();

	/** @return MIB attribute meshDeviceType */
	command ieee155_meshDeviceType_t meshDeviceType();

	/** @return MIB attribute meshSequenceNumber */
	command ieee155_meshSequenceNumber_t meshSequenceNumber();

	/** @return MIB attribute meshNetworkAddress */
	command ieee155_meshNetworkAddress_t meshNetworkAddress();

	/** @return MIB attribute meshGroupCommTable */
	command ieee155_meshGroupCommTable_t * meshGroupCommTable();

	/** @return MIB attribute meshAddressMapping */
	command ieee155_meshAddressMapping_t * meshAddressMapping();

	/** @return MIB attribute meshAcceptMeshDevice */
	command ieee155_meshAcceptMeshDevice_t meshAcceptMeshDevice();

	/** @return MIB attribute meshAcceptEndDevice */
	command ieee155_meshAcceptEndDevice_t meshAcceptEndDevice();

	/** @return MIB attribute meshChildNbReportTime */
 	 command ieee155_meshChildNbReportTime_t meshChildNbReportTime();

 	/** @return MIB attribute meshProbeInterval */
 	command ieee155_meshProbeInterval_t meshProbeInterval();

	/** @return MIB attribute meshMaxProbeNum */
 	command ieee155_meshMaxProbeNum_t meshMaxProbeNum();

 	/** @return MIB attribute meshMaxProbeInterval */
 	command ieee155_meshMaxProbeInterval_t meshMaxProbeInterval();

 	/** @return MIB attribute MaxMulticastJoinAttempts */
 	command ieee155_MaxMulticastJoinAttempts_t MaxMulticastJoinAttempts();

	/** @return MIB attribute meshRBCastTXTimer */
 	command ieee155_meshRBCastTXTimer_t meshRBCastTXTimer();

 	/** @return MIB attribute meshRBCastRXTimer */
 	command ieee155_meshRBCastRXTimer_t meshRBCastRXTimer();

 	/** @return MIB attribute meshMaxRBCastTrials */
 	command ieee155_meshMaxRBCastTrials_t meshMaxRBCastTrials();

 	/** @return MIB attribute meshASESOn */
 	command ieee155_meshASESOn_t meshASESOn();

 	/** @return MIB attribute meshASESExpected */
 	command ieee155_meshASESExpected_t meshASESExpected();

	/** @return MIB attribute meshWakeupOrder */
 	command ieee155_meshWakeupOrder_t meshWakeupOrder();

 	/** @return MIB attribute meshActiveOrder */
 	command ieee155_meshActiveOrder_t meshActiveOrder();

 	/** @return MIB attribute meshDestActiveOrder */
 	command ieee155_meshDestActiveOrder_t meshDestActiveOrder();

 	/** @return MIB attribute meshEREQTime */
 	command ieee155_meshEREQTime_t meshEREQTime();

 	/** @return MIB attribute meshEREPTime */
 	command ieee155_meshEREPTime_t meshEREPTime();

 	/** @return MIB attribute meshDataTime */
 	command ieee155_meshDataTime_t meshDataTime();

 	/** @return MIB attribute meshMaxNumASESRetries */
 	command ieee155_meshMaxNumASESRetries_t meshMaxNumASESRetries();

 	/** @return MIB attribute meshSESOn */
 	command ieee155_meshSESOn_t meshSESOn();

 	/** @return MIB attribute meshSESExpected */
 	command ieee155_meshSESExpected_t meshSESExpected();

 	/** @return MIB attribute meshSyncInterval */
 	command ieee155_meshSyncInterval_t meshSyncInterval();

 	/** @return MIB attribute meshMaxSyncRequestAttempts */
 	command ieee155_meshMaxSyncRequestAttempts_t meshMaxSyncRequestAttempts();

 	/** @return MIB attribute meshSyncReplyWaitTime */
 	command ieee155_meshSyncReplyWaitTime_t meshSyncReplyWaitTime();

 	/** @return MIB attribute meshFirstTxSyncTime */
 	command ieee155_meshFirstTxSyncTime_t meshFirstTxSyncTime();

 	/** @return MIB attribute meshFirstRxSyncTime */
 	command ieee155_meshFirstRxSyncTime_t meshFirstRxSyncTime();

 	/** @return MIB attribute meshSecondRxSyncTime */
 	command ieee155_meshSecondRxSyncTime_t meshSecondRxSyncTime();

 	/** @return MIB attribute meshRegionSynchronizerOn */
 	command ieee155_meshRegionSynchronizerOn_t meshRegionSynchronizerOn();

 	/** @return MIB attribute meshExtendedNeighborHopDistance */
 	command ieee155_meshExtendedNeighborHopDistance_t meshExtendedNeighborHopDistance();

 	/** @return MIB attribute meshRejoinTimer */
 	command ieee155_meshRejoinTimer_t meshRejoinTimer();

}
