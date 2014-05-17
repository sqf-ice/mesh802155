/*
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

