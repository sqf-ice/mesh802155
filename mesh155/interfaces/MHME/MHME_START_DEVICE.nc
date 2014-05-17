/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

interface MHME_START_DEVICE {

  /**
   * This primitive allows the next higher layer of a mesh device to initiate the activities expected of a mesh device,
   * including the routing of data frames and the accepting of requests to join the network from other devices.
   *
   * @param BeaconOrder 		The value is always set to 0x0f indicating no periodic beacons are transmitted.
   *
   * @param SuperframeOrder		The value is always set to 0x0f indicating no periodic beacons are transmitted.
   *
   * @see          confirm
  */

  command void request (uint8_t BeaconOrder, uint8_t SuperframeOrder);

  /**
   * Reports to its next higher layer the result of a network discovery operation.
   *
   * @param status		INVALID_REQUEST or any status value returned from the MLME- START.confirm primitive.
   *
   */

  event void confirm (ieee154_status_t status);

}
