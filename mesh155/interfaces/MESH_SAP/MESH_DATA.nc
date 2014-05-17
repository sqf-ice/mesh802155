/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

interface MESH_DATA {

  /**
   * "Requests to transfer a data SPDU (i.e., MSDU) from a local SSCS
   * entity to a single peer SSCS entity." (IEEE 802.15.4-2006, Sec.
   * 7.1.1.1)
   *
   * The function of the mesh sublayer data service is to support the transport
   * of application protocol data units (APDUs) between peer application entities
   * residing at different devices that can be multiple hops away from each other.
   *
   * If this command returns IEEE155_SUCCESS, then the confirm event
   * will be signalled in the future; otherwise, the confirm event
   * will not be signalled.
   *
   * @param SrcAddrMode       The source addressing mode for this primitive and subsequent MHPDU.
   * @param DstAddrMode			  The destination addressing mode for this primitive and subsequent MHPDU.
   * @param DstAddr 				  The device address of the entity, or entities in the case of multicast and broadcast, to which the MHSDU is being transferred.
   * @param mhsduLenght       The number of octects contained in the MHSDU to be transmitted by the mesh sublayer entity.
   * @param mhsdu             The set of octets forming the MHSDU to be transmitted by the mesh sublater entity.
   * @param msduHandle        The handle associated with the MHSDU to be transmitted by the mesh sublayer entity.
   * @param AckTransmission   This field is set to TRUE if an acknowledgement is required from the receiver; otherwise, it is set to FALSE.
   * @param McstTransmission  This field is set to TRUE if the data is to be multicast; otherwise, it is set to FALSE.
   * @param BcstTransmission  This field is set to TRUE if the data is to be broadcast; otherwise, it is set to FALSE.
   * @param ReliableBcst      This field is set to TRUE if reliable broadcast is required; otherwise, it is set to FALSE.
   *
   * @return       IEEE155_SUCCESS if the request succeeded and only
   *               then the confirm() event will be signalled;
   *               an appropriate error code otherwise
   * @see          confirm
   */


  command ieee155_status_t request (uint8_t SrcAddrMode,
              uint8_t DstAddrMode,
              ieee155_address_t DstAddr,
              uint8_t mhsduLenght,
              uint8_t* mhsdu,
              uint8_t mhsduHandle,
              bool AckTransmission,
              bool McstTransmission,
              bool BcstTransmission,
              bool ReliableBcst);
  /**
   * Reports the results of a request to transfer a data SPDU (MHSDU)
   * from a local SSCS entity to one or more peer SSCS entities.
   *
   * @param mhsduHandle The handle associated with the MHSDU being confirmed.
   * @param status      The status of the last MHSDU transmission.
   * @param mhsdu       The set of octects forming the MHSDU being indicated by the MESH sublayer entity
   *
   */
  event void confirm (uint8_t mhpduHandle,
              ieee154_status_t status,
              uint8_t *mhsdu);

  /**
   * Indicates the arrival of a MESH frame.
   * Use the IEEE155MeshFrame interface to get the payload,
   * source/destination addresses, and other information
   * associated with this frame.
   *
   * @param SrcAddrMode   The source addressing mode for this primitive corresponding to the received MHPDU.
   * @param SrcPANId      The 16-bit PAN identifier of the entity from which the MHSDU was received
   * @param SrcAddr       The individual device address of the entity from which the MHSDU was received
   * @param mhsduLenght   The number of octects forming the MHSDU being indicated by the MESH sublater entity
   * @param mhsdu         The set of octects forming the MHSDU being indicated by the MESH sublayer entity
   */
  event uint8_t* indication (
									uint8_t SrcAddrMode,
									uint16_t SrcPANId,
									ieee154_address_t SourceAddress,
									uint8_t mhsduLen,
									uint8_t *mhsdu
								);

}
