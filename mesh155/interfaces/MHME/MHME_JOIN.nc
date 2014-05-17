/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

interface MHME_JOIN {

  /**
   * This primitive allows the next higher layer of a device to request to join or rejoin a network.
   *
   * @param DirectJoin 		The value is set to TRUE if direct joining is chosen; otherwise, its value is FALSE.
   *
   * @param ParentDevAddr		The 16-bit short address of the parent device to join. This field will be read only when the DirectJoin parameter has a value equal to TRUE.
   *
   * @param PANId 		The 16-bit PAN identifier of the network to join. This field will be read only when the DirectJoin parameter has a value equal to TRUE.
   *
   * @param RejoinNetwork 		This parameter controls the method of joining the network.
   *											The parameter is 0x00 if the device is requesting to join a network through association.
   *											The parameter is 0x01 if the device is joining the network using the mesh sublayer rejoining procedure.
   *											This field will be read only when the DirectJoin parameter has a value equal to TRUE.
   *
   *
   * @param JoinAsMeshDevice		The parameter is set to TRUE if the device is going to function as a mesh device;
   *												it is set to FALSE if the device is going to function as an end device.
   *
   * @param ScanChannels 		The 27 bits (b0,..,b26) indicate which channels are to be scanned (1=scan,0=don't scan)
   *											for each of the 27 channels supported by the ChannelPage parameter as defined in IEE 802.15.4-2006
   *											This field will be read only when the DirectJoin parameter has a value equal to FALSE.
   *
   * @param ScanDuration		A value used to calculate the length of time to spend scanning each channel.
   *										This field will be read only when the DirectJoin parameter has a value equal to FALSE.
   *
   * @param ChannelPage 		The channel page on which to perform the scan. This field will be read only when the DirectJoin parameter has a value equal to FALSE.
   *
   * @param CapabilityInformation		The operating capabilities of the device being directly joined.
   *
   *
   * @return       IEEE155_SUCCESS if the request succeeded and a confirm event will be signalled, an appropriate error code otherwise
   *               		(no confirm event will be signalled in this case).
   *
   * @see          confirm
  */

  command void request (
														bool DirectJoin,
														uint16_t ParentDevAddr,
														uint16_t PANId ,
														uint8_t RejoinNetwork,
														bool JoinAsMeshDevice,
														uint32_t ScanChannels,
														uint8_t ScanDuration,
														uint8_t ChannelPage ,
														ieee155_meshCapabilityInformation_t CapabilityInformation);



  /**
   * This primitive allows the next higher layer of a mesh coordinator or a mesh device to be notified when
   * a new device has successfully joined its network by association or rejoined using mesh sublayer rejoin procedure.
   *
   * @param NetworkAddress		When a short network address of an entity has been assigned, this will be the short address that has been added to the network.
   *											Otherwise, the value of this parameter will equal to 0xfffe indicating the short address has not been assigned and
   *											the device can only be reached by its 64-bit extended address.
   *
   * @param ExtendedAddress		The 64-bit IEEE address of an entity that has been added to the network.
   *
   * @param CapabilityInformation		Specifies the operational capabilities of the joining device.
   *
   * @param RejoinNetwork		The RejoinNetwork parameter indicating the method used to join the network.
   *											The parameter is 0x00 of the device joined through association.
   *											The parameter is 0x01 if the device joined through mesh sublayer rejoin precedure.
   *
   */

  event void indication (
								uint16_t NetworkAddress,
								uint64_t ExtendedAddress,
								ieee154_CapabilityInformation_t CapabilityInformation,
								uint8_t RejoinNetwork);



  /**
   * This primitive allows the next higher layer to be notified of the result of its request to join a network.
   *
   * @param status		Any status value returned from the MLME- ASSOCIATE.confirm primitive or the MLME- SCAN.confirm primitive.
   *
   * @param NetworkAddress		The 16-bit network address that was allocated to this device. This parameter will be equal to 0xffff if the join attempt was unsuccessful.
   *
   * @param PANId 		The 16-bit PAN identifier of the network of which the device is now a member.

   * @param ChannelPage		The channel page on which the ActiveChannel was found.
   *
   * @param ActiveChannel 		The value of phyCurrentChannel parameter which is equal to the current channel of the network that has been joined
   *
   */

  event void confirm (uint8_t status, uint16_t NetworkAddress, uint16_t PANId, uint8_t ChannelPage, uint8_t ActiveChannel);

}

