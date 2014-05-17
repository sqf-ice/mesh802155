/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

interface NeighborList {

	  command void create(ieee155_meshDeviceType_t value);

	  command uint8_t size(void);

	  command uint8_t getNumChildren(void);

	  command ieee155_status_t addParent(uint16_t shortddr);

	  command ieee155_status_t addChildren(uint64_t extendedAddr,
		  				uint16_t logicalAddr,
		  				bool rejoin);

	  command ieee155_status_t updateNbInfo(uint16_t source,
	  					bool leave,
	  					uint16_t begAddr,
	  					uint16_t endAddr,
	  					uint16_t treeLevel,
	  					relationship_t relation,
	  					bool rBcast,
	  					status_t status,
	  					uint8_t numHops,
	  					uint8_t numOfMGroups,
	  					uint8_t * groupMember,
	  					uint8_t numOfOneHopNb,
	  					uint8_t * khopNeighbors,
	  					uint8_t lqi,
	  					int8_t rssi,
	  					bool * updated);

	  command ieee155_status_t setNbOfReqAddr(ieee154_address_t macAddr,
	  					uint16_t nbOfReqAddr);

	  command ieee155_status_t nextNbToAssignAddress(ieee154_address_t * macAddr,
	  					uint16_t * begAddr,
	  					uint16_t * endAddr);

	  command void setEndingAddress(uint16_t e);

	  command relationship_t check_Relationship(uint16_t addr);

	  command uint8_t getNumOfOneHopNb(void);

	  command uint16_t getEndingAddress(void);

	  command void getNbInformation(uint8_t * mhpdu);

	  command ieee155_status_t updateLinkQuality(uint16_t addr,
	  					uint8_t lqi,
	  					int8_t rssi);
}
