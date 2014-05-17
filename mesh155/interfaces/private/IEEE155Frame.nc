/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

interface IEEE155Frame
{

	/* This interface provides all the methods needed to insert and get the Frame Control information,
   	 * source/destination addresses and the payload of a mesh frame.*/


 // General mesh service frame format (MSPDU)
/*
+----- 16 bits ----+------ 64/16 bits ------+------ 64/16 bits ----+--------- Variable -----------------+
|   Frame Control  |   Destination Address  |   Source Address     |      Mesh Sublayer payload 	 	|
|------------------+------------------------+----------------------|------------------------------------|
|		  				MESH SUBLAYER HEADER					   |	 	MESH  PAYLOAD (MHSDU)    	|
+------------------------------------------------------------------|------------------------------------+
*/

	command void 				setAddressingFields(uint8_t* meshFrame,
										uint8_t *offset,
										uint8_t frameType,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint8_t txOptions);

	command	uint8_t 			getHeaderLength(uint8_t* mhpdu);
	command uint8_t 			getProtocolVersion(uint8_t* mhpdu);
	command uint8_t 			getFrameType(uint8_t* mhpdu);
	command	uint8_t 			getDstAddrMode(uint8_t* mhpdu);
	command	uint8_t 			getSrcAddrMode(uint8_t* mhpdu);
	command	uint8_t 			getTxOptions(uint8_t* mhpdu);

	command void			 	getDstAddress(uint8_t* mhpdu, ieee155_address_t * dstAddr);
	command void			 	getSrcAddress(uint8_t* mhpdu, ieee155_address_t * srcAddr);

	command uint16_t 			getDstShortAddress(uint8_t* mhpdu);
	command uint16_t 			getSrcShortAddress(uint8_t* mhpdu);

	//--------------------------------- Payload methods ---------------------------------//

	command uint8_t 			getCommandType(uint8_t* mhpdu);
	command uint8_t 			getSequenceNumber(uint8_t* mhpdu);
	command uint8_t 			getRoutingControl(uint8_t* mhpdu);
	command uint8_t* 			getPayload(uint8_t* mhpdu);

	/*
	 * Command: Children Number Report (See 5.3.2.2.1)
	 * Command frame identifier: 0x01
	 * Mandatory
	*/
	command void 				ChildrenNbReport( uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint16_t numOfDesc,
										uint16_t numOfReqAddr);

	/*
	 * Command: Address assignment (See 5.3.2.2.2)
	 * Command frame identifier: 0x02
	 * Mandatory
	*/
	command void 				AddressAssignment(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint16_t begAddr,
										uint16_t endAddr,
										uint16_t parentTreeLvl);

	/*
	 * Command: Hello (See 5.3.2.2.3)
	 * Command frame identifier: 0x03
	 * Mandatory
	*/
	command void 				Hello(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t sourceAddress,
										uint8_t ttl,
										uint16_t begAddr,
										uint16_t endAddr,
										uint16_t treeLvl,
										uint8_t helloCtrl,
										uint8_t	numOfOneHopNb,
										uint8_t numOfMultiCastG);
	/*
	 * Command: Wakeup notification (See 5.3.2.2.13)
	 * Command frame identifier: 0x0d
	 * Optional
	*/
	command void 				WakeupNotification(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t sourceAddress,
										uint8_t asesTimeInfo);

	/*
	 * Command: Extension request (See 5.3.2.2.14)
	 * Command frame identifier: 0x0e
	 * Optional
	*/
	command void 				EREQ(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress,
										uint8_t extTime);

	/*
	 * Command: Extension reply (See 5.3.2.2.15)
	 * Command frame identifier: 0x0f
	 * Optional
	*/
	command void 				EREP(uint8_t* mhpdu,
										uint8_t dest_AddrMode,
										uint8_t src_AddrMode,
										ieee155_address_t destAddress,
										ieee155_address_t sourceAddress);
}

