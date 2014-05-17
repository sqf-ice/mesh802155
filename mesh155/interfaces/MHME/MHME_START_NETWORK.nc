/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

interface MHME_START_NETWORK {

  /**
   * Allows the next higher layer to request that the device start a new mesh network with itself as the MC.
   *
   * @param ScanChannels 		The 27 bits (b0,..,b26) indicate which channels are to be scanned (1=scan,0=don't scan)
   *							for each of the 27 channels supported by the ChannelPage parameter as defined in IEE 802.15.4-2006
   *
   * @param ScanDuration		A value used to calculate the length of time to spend scanning each channel.
   *
   * @param ChannelPage 		The channel page on which to perform the scan.
   *
   * @param BeaconOrder 		The beacon order of the network that the higher layers wish to form.
   * 							The value is always set to 0x0f indicating no periodic beacons are transmitted.
   *
   * @param SuperframeOrder 	The superframe order of the network that the higher layers wish to form.
   *							The value is always set to 0x0f indicating no periodic beacons are transmitted.
   *
   * @return       IEEE154_SUCCESS if the request succeeded and a confirm event
   *               will be signalled, an appropriate error code otherwise
   *               (no confirm event will be signalled in this case)
   * @see          confirm
  */

  command void request (uint32_t ScanChannels, uint8_t ScanDuration, uint8_t ChannelPage, uint8_t BeaconOrder, uint8_t SuperframeOrder);

  /**
   * Reports to the next higher layer the result of
   * the request to initialize a mesh coordinator in a network.
   *
   * @param status The status of the operation
   */

  event void confirm (ieee155_status_t status);

}
