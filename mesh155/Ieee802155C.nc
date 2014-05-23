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
#include "Mesh155_MIB.h"

configuration Ieee802155C
{
  provides
  {
    interface MHME_RESET;
	interface MHME_GET;
	interface MHME_SET;
    interface MHME_START_NETWORK;
    interface MHME_START_DEVICE;
	interface MHME_DISCOVER;
	interface MHME_JOIN;
    interface IEEE155Frame;
    interface MESH_DATA;
    interface MESH_PURGE;
  }
}
implementation
{
  components MibP, Core155P;
  components Ieee802154NonBeaconEnabledC as MAC;
  components RandomLfsrC;
  components NeighborListP;
  components IEEE155FrameP;
  components new Timer62500C() as WaitingForAssociationsRequest;
  components new Timer62500C() as ChildrenReportTimer;
  components new Timer62500C() as HelloTimer;
  components LedsC;

  components new QueueC(ieee155_txframe_t*, _MESH_QUEUE_SIZE),
             new PoolC(ieee155_txframe_t, _MESH_QUEUE_SIZE);

  components new Timer62500C() as WITimer,
             new Timer62500C() as EREPTimer;

  /** PROVIDES **/

  MHME_RESET = MibP.MHME_RESET;
  MHME_GET = MibP.MHME_GET;
  MHME_SET = MibP.MHME_SET;
  MHME_START_NETWORK = Core155P.MHME_START_NETWORK;
  MHME_START_DEVICE = Core155P.MHME_START_DEVICE;
  MHME_DISCOVER = Core155P.MHME_DISCOVER;
  MHME_JOIN = Core155P.MHME_JOIN;
  IEEE155Frame = IEEE155FrameP;
  MESH_DATA = Core155P.MESH_DATA;
  MESH_PURGE = Core155P.MESH_PURGE;

  /** USES **/
  MibP.MLME_RESET -> MAC;
  MibP.MLME_SET -> MAC;
  MibP.NeighborList -> NeighborListP;

  NeighborListP.MHME_GET -> MibP;
  NeighborListP.MHME_SET -> MibP;

  Core155P.MHME_GET -> MibP;
  Core155P.MHME_SET -> MibP;
  Core155P.MLME_SET -> MAC;
  Core155P.MLME_GET -> MAC;
  Core155P.MLME_START -> MAC;
  Core155P.MLME_SCAN -> MAC;
  Core155P.IEEE154TxBeaconPayload -> MAC;
  Core155P.Random -> RandomLfsrC;
  Core155P.NeighborList -> NeighborListP;
  Core155P.MLME_BEACON_NOTIFY -> MAC;
  Core155P.MLME_ASSOCIATE -> MAC;
  Core155P.MLME_COMM_STATUS -> MAC;
  Core155P.Frame -> MAC;
  Core155P.Leds -> LedsC;
  Core155P.WaitingForAssociationsRequest -> WaitingForAssociationsRequest;
  Core155P.ChildrenReportTimer -> ChildrenReportTimer;
  Core155P.HelloTimer -> HelloTimer;
  Core155P.MeshFrame -> IEEE155FrameP;
  Core155P.MCPS_DATA -> MAC;
  Core155P.Packet -> MAC;
  Core155P.DataForwarding -> NeighborListP;
  Core155P.Queue -> QueueC;
  Core155P.Pool -> PoolC;
  Core155P.WITimer -> WITimer;
  Core155P.EREPTimer -> EREPTimer;
  Core155P.MCPS_PURGE -> MAC;
  Core155P.MLME_RX_ENABLE -> MAC;
}

