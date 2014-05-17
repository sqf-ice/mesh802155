/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

module NeighborListP{

	provides {
		interface NeighborList;
		interface DataForwarding;
	}
	uses {
		interface MHME_GET;
		interface MHME_SET;
	}
}
implementation {

	//Neighbor List variables
	ieee155_meshNeighborList_t * nbList;
	uint8_t nbList_size, numChildren;

	uint8_t numAddrAssign;
	uint16_t assigAddress;
	uint16_t endingAddress, nextAddrNoAssigned;
	uint8_t one_HopNb;
	uint16_t * connMtx;

	uint16_t getOneHopNeighbor(uint8_t anchor);
	uint16_t nextLinkQualityHop(uint16_t dst, uint8_t * up_down_flag, uint8_t criteria);
	uint16_t getLinkQualityOneHopNeighbor(uint8_t *anchor, uint8_t numNbFound, uint8_t minHop, uint8_t criteria);

	command void NeighborList.create(ieee155_meshDeviceType_t value)
	{
		uint8_t i;
		uint8_t size;
		
		nbList_size = 0;
		numChildren = 0;
		numAddrAssign = 0;
		assigAddress = 0;
		endingAddress = 0xFFFE;
		one_HopNb = 0;
		
		if(value == END_DEVICE)
			size = 1;
		else
			size = MAX_NUM_NEIGHBORS;

		nbList = (ieee155_meshNeighborList_t *)malloc(size*sizeof(ieee155_meshNeighborList_t));

		/*
		 *	|00000000|00000000|
		 *	1 bit (left): me (index = 0)
		 *	2 bit: my parent (index = 1)
		 *	3 bit: my child/neighbor	(index = 2)
		 *  n bit: my n-child/n-neighbor	(index = n), n < 16
		 *	The procedure to store a neighbor is:
		 *		P1: me --> connMtx[0] = 0x0001(0) << (15 - index_new-node);
		 *		P2: new node --> connMtx[index_new-node] = 0x0001(0) << (15);
		*/
		connMtx = (uint16_t *)malloc((size + 1)*sizeof(uint16_t));

		for(i = 0 ; i < size ; i++)
		{
			nbList[i].macAddress.extendedAddress = 0xFFFFFFFF;	// ieee154_address_t is an union. Uptading one
																// of the two variables comprising this union,
																// the other one also updates automatically.
			nbList[i].begAddress = 0xFFFE;
			nbList[i].endAddress = 0xFFFE;
			nbList[i].treeLevel = 0xFF;
			nbList[i].lqi = 0;
			nbList[i].rssi = -128;
			nbList[i].relationship = NO_RELATIONSHIP;
			nbList[i].reliableBroadcast = FALSE;
			nbList[i].status = UNKNOWN;
			nbList[i].numHops = 0xFF;
			// Multicast function has not been implemented in this version of the code
			connMtx[i] = 0x0000;
		}
		call MHME_SET.meshNeighborList(nbList);
	}

	command uint8_t NeighborList.size(void)
	{
		return nbList_size;
	}

	command uint8_t NeighborList.getNumChildren(void)
	{
		return numChildren;
	}

	command ieee155_status_t NeighborList.addParent(uint16_t shortddr)
	{
		uint8_t index = 0;

		nbList[index].macAddress.shortAddress = shortddr;
		nbList[index].begAddress = shortddr;
		nbList[index].treeLevel = call MHME_GET.meshTreeLevel() - 1;
		nbList[index].relationship = PARENT;
		nbList[index].status = KNOWN;
		nbList[index].numHops = 1;
		// Multicast function has not been implemented in this version of the code
		nbList_size ++;
		one_HopNb ++;

		connMtx[0] |= 0x0001 << (15 - 1);	// P1
		connMtx[1] |= 0x0001 << 15;			// P2
		return IEEE155_SUCCESS;
	}

	command ieee155_status_t NeighborList.addChildren(uint64_t extendedAddr, uint16_t logicalAddr, bool rejoin)
	{
		uint8_t index = 0;

		if(((call MHME_GET.meshDeviceType() == MESH_DEVICE) && !rejoin && (numChildren >= MAX_NUM_CHILDREN)) || (!rejoin && (nbList_size >= MAX_NUM_NEIGHBORS)))
			return IEEE155_FAIL;

		while((index < MAX_NUM_NEIGHBORS) && (nbList[index].macAddress.extendedAddress != extendedAddr))
			index++;

		if(index >= MAX_NUM_NEIGHBORS)
		{
			index = 0;
			while((index < MAX_NUM_NEIGHBORS) && (nbList[index].macAddress.extendedAddress != 0xFFFFFFFF))
				index++;

			if(index < MAX_NUM_NEIGHBORS)
			{
				nbList[index].macAddress.extendedAddress = extendedAddr;
				nbList[index].begAddress = logicalAddr;
				nbList[index].treeLevel = call MHME_GET.meshTreeLevel() + 1;
				nbList[index].relationship = CHILD;
				nbList[index].status = KNOWN;
				nbList[index].numHops = 1;
				// Multicast function has not been implemented in this version of the code
				numChildren ++;
				nbList_size ++;
				one_HopNb ++;
				// Update connectivity matrix
				connMtx[0] |= 0x0001 << (15 - (index + 1));	// P1
				connMtx[index + 1] |= 0x0001 << 15;	// P2

				call MHME_SET.meshNbOfChildren(numChildren);
				if((call MHME_GET.meshDeviceType() == MESH_DEVICE) && (numChildren == MAX_NUM_CHILDREN))
				{
					call MHME_SET.meshAcceptMeshDevice(FALSE);
					call MHME_SET.meshAcceptEndDevice(FALSE);
				}
			}
		}
		else
		{
			nbList[index].begAddress = logicalAddr;
		}

		return IEEE155_SUCCESS;
	}

	command ieee155_status_t NeighborList.setNbOfReqAddr(ieee154_address_t macAddr, uint16_t nbOfReqAddr)
	{
		// THIS METHOD SHOULD ONLY BE USED DURING THE ADDRESS ASSIGNMENT PHASE
		uint8_t index = 0;

		if(!nbList_size)	// no devices
			return IEEE155_FAIL;

		while((index < MAX_NUM_NEIGHBORS) && (nbList[index].macAddress.shortAddress != macAddr.shortAddress))
			index++;

		if(index >= MAX_NUM_NEIGHBORS)	// children not found
			return IEEE155_FAIL;

		nbList[index].begAddress = 0xFFFE;
		nbList[index].endAddress = nbOfReqAddr;

		return IEEE155_SUCCESS;
	}

	command ieee155_status_t NeighborList.updateNbInfo(uint16_t source,
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
	  					bool * updated)
	{
		// Leave function has not been implemented in this version of the code
		// Multicast function has not been implemented in this version of the code
		uint8_t index;
		uint8_t nb, offset, nbIndex;
		uint16_t nbBegAddr, nbEndAddr;
		relationship_t nbRelation;
		
		if(!nbList_size)	// no devices
			return IEEE155_FAIL;

		if((call MHME_GET.meshDeviceType() == END_DEVICE)
			&& (relation != PARENT))
			return IEEE155_FAIL;

		index = 0;
		if(call MHME_GET.meshDeviceType() != END_DEVICE)
		{
			while((index < MAX_NUM_NEIGHBORS) && (nbList[index].begAddress != source))
				index++;

			if(index >= MAX_NUM_NEIGHBORS)
			{
				// The device is new
				if(call MHME_GET.meshNetworkAddress() == 0xFFFF)
					return IEEE155_FAIL;	// source device not found and it has been allocated
											// no logical short address yet.

				if(nbList_size >= MAX_NUM_NEIGHBORS)
					return IEEE155_FAIL;

				index = nbList_size;
				nbList_size++;
				if(numHops == 1)
					one_HopNb++;
				*updated = TRUE;
			}
		}

		nbList[index].lqi = lqi;
		nbList[index].rssi = rssi;

		if((nbList[index].macAddress.shortAddress != begAddr)
				|| (nbList[index].begAddress != begAddr)
				|| (nbList[index].endAddress != endAddr)
				|| (nbList[index].treeLevel != treeLevel)
				|| (nbList[index].relationship != relation)
				|| (nbList[index].reliableBroadcast != rBcast)
				|| (nbList[index].status != status)
				|| (nbList[index].numHops > numHops)
			)
			*updated = TRUE;

		nbList[index].macAddress.shortAddress = begAddr;
		nbList[index].begAddress = begAddr;
		nbList[index].endAddress = endAddr;
		nbList[index].treeLevel = treeLevel;
		nbList[index].relationship = relation;
		nbList[index].reliableBroadcast = rBcast;
		nbList[index].status = status;
		nbList[index].numHops = numHops;

		// Update connectivity matrix
		connMtx[0] |= 0x0001 << (15 - (index + 1));	// P1
		connMtx[index + 1] |= 0x0001 << 15;	// P2

		if(call MHME_GET.meshDeviceType() != END_DEVICE)
		if(numOfOneHopNb > 0)
		{
			offset = 0;

			for (nb = 0 ; nb < numOfOneHopNb; nb++)
			{
				nbBegAddr = ((uint16_t)khopNeighbors[offset]) << 8 | khopNeighbors[offset + sizeof(uint8_t)];
				// If it is not me, my parent or any of my children, I continue checking the current neighbor
				if(nbBegAddr == call MHME_GET.meshNetworkAddress())
				{
					offset += 2*sizeof(uint16_t);
					continue;
				}
				offset += sizeof(uint16_t);
				nbEndAddr = ((uint16_t)khopNeighbors[offset]) << 8 | khopNeighbors[offset + sizeof(uint8_t)];
				offset += sizeof(uint16_t);

				nbIndex = 0;
				while((nbIndex < MAX_NUM_NEIGHBORS) && (nbList[nbIndex].begAddress != nbBegAddr))
					nbIndex++;

				if(nbIndex >= MAX_NUM_NEIGHBORS)
				{
					// The device is new
					if(nbList_size >= MAX_NUM_NEIGHBORS)
						continue;
					nbIndex = nbList_size;
					nbList_size++;
					*updated = TRUE;
				}
				connMtx[index + 1] |= 0x0001 << (15 - (nbIndex + 1));	// for index
				connMtx[nbIndex + 1] |= 0x0001 << (15 - (index + 1));	// for nbIndex
				nbRelation = call NeighborList.check_Relationship(nbBegAddr);

				if((nbList[nbIndex].begAddress != nbBegAddr)
					|| (nbList[nbIndex].endAddress != nbEndAddr))
				{
					*updated = TRUE;
					nbList[nbIndex].begAddress = nbBegAddr;
					if(nbEndAddr != 0xFFFF)
						nbList[nbIndex].endAddress = nbEndAddr;	// n-hop neighbor
					if(nbRelation == NO_RELATIONSHIP)
						nbList[nbIndex].relationship = SIBLING_DEVICE;
					if((nbList[nbIndex].numHops == 0xFF) || (nbList[nbIndex].numHops > nbList[index].numHops + 1))
						nbList[nbIndex].numHops = nbList[index].numHops + 1;
				}
			}
		}
		return IEEE155_SUCCESS;
	}


	command void NeighborList.setEndingAddress(uint16_t e)
	{
		endingAddress = e;
	}

	command ieee155_status_t NeighborList.nextNbToAssignAddress(ieee154_address_t * macAddr,
	  					uint16_t * begAddr,
	  					uint16_t * endAddr)
	{
		uint8_t index = 0;

		if(!numAddrAssign)
		{
			assigAddress = call MHME_GET.meshNetworkAddress()
							+ ((call MHME_GET.meshDeviceType() == MESH_COORD) ? 1 : (ADDRESS_SPACE + 1));

			if(!numChildren)
				nextAddrNoAssigned = ((call MHME_GET.meshDeviceType() == MESH_COORD) ? assigAddress : (call MHME_GET.meshNetworkAddress() + 1));
		}

		if(numAddrAssign == numChildren)
			return IEEE155_FAIL;

		while(index < MAX_NUM_NEIGHBORS)
		{
			if((nbList[index].relationship == CHILD) && nbList[index].begAddress == 0xFFFE)
			{
				nbList[index].begAddress = assigAddress;
				nbList[index].endAddress = assigAddress + nbList[index].endAddress - 1;
				assigAddress = nbList[index].endAddress + 1;
				nextAddrNoAssigned = assigAddress;
				numAddrAssign ++;

				*macAddr = nbList[index].macAddress;
				*begAddr = nbList[index].begAddress;
				*endAddr = nbList[index].endAddress;

				return IEEE155_SUCCESS;
			}

			index++;
		}
		return IEEE155_FAIL;
	}

	command relationship_t NeighborList.check_Relationship(uint16_t addr)
	{
		uint8_t index = 0;
		if(!nbList_size)	// no devices
			return NO_RELATIONSHIP;

		while((index < MAX_NUM_NEIGHBORS) && (nbList[index].begAddress != addr) && (nbList[index].macAddress.shortAddress != addr))
			index++;

		if(index >= MAX_NUM_NEIGHBORS)	// device not found
			return NO_RELATIONSHIP;

		return nbList[index].relationship;
	}

	command uint16_t NeighborList.getEndingAddress(void)
	{
		return endingAddress;
	}

	command uint8_t NeighborList.getNumOfOneHopNb(void)
	{
		return one_HopNb;
	}

	command void NeighborList.getNbInformation(uint8_t * mhpdu)
	{
		uint8_t index = 0;
		nx_uint16_t nx_bAddr, nx_eAddr;
		uint8_t offset = 3*sizeof(uint16_t)  // Mesh Sublayer Header
							+ 5*sizeof(uint8_t)	// Cmnd Frm Id + TTL + Hello Ctrl + NumOnehNb + NumMulG
							+ 3*sizeof(uint16_t); // Beg Addr + End Addr + Tree Lvl

		if(!nbList_size) //empty routing table
			return;

		for(index = 0; index < MAX_NUM_NEIGHBORS ; index++)
		{
			if(nbList[index].numHops == 1)
			{
				nx_bAddr = nbList[index].begAddress;
				nx_eAddr = nbList[index].endAddress;

				memcpy(mhpdu + offset, &nx_bAddr, sizeof(uint16_t));
				offset += sizeof(uint16_t);
				memcpy(mhpdu + offset, &nx_eAddr, sizeof(uint16_t));
				offset += sizeof(uint16_t);
			}
		}
	}

	command ieee155_status_t NeighborList.updateLinkQuality(uint16_t addr, uint8_t lqi, int8_t rssi)
	{
		uint8_t index = 0;

		if(!nbList_size) //empty routing table
			return IEEE155_FAIL;

		while((index < MAX_NUM_NEIGHBORS) && (nbList[index].begAddress != addr) && (nbList[index].macAddress.shortAddress != addr))
			index++;

		if(index >= MAX_NUM_NEIGHBORS)	// device not found
			return IEEE155_FAIL;

		nbList[index].lqi = lqi;
		nbList[index].rssi = rssi;

		return IEEE155_SUCCESS;
	}

	/***************************/
	/* DataForwarding Commands */
	/***************************/

	command uint16_t DataForwarding.nextHop(uint16_t dst, uint8_t * up_down_flag, uint8_t criteria)
	{
		/*
		 *	func nextHop(dst)
		 *		if(dst falls in address block of one of my neighbors or descendant)
		 *			anchor = node with smallest address block;
		 *		else
		 *			anchor = one of neighbors with smallest "tree level+hops";
		 *		end if
		 *		nexthop = getOneHopNeighbor(anchor);
		 *	end func
		 */

		uint8_t index;
		uint8_t treeLvlPlusHops;
		uint8_t anchor;	// index of the neighbor
		uint16_t minAddrBlock;

		uint8_t size_list = ((call MHME_GET.meshDeviceType() == END_DEVICE) ? 1 : MAX_NUM_NEIGHBORS);

		if(criteria != TREE_LEVEL)
			return nextLinkQualityHop(dst, up_down_flag, criteria);
		else
		{
			*up_down_flag = 1;
			anchor = 0xFF;
			minAddrBlock = 0xFFFF;

			if(!nbList_size)
				return 0xFFFF;

			for(index = 0 ; index < size_list ; index++)
			{
				if((nbList[index].numHops == 1)
					&& (nbList[index].begAddress <= dst)
					&& (nbList[index].endAddress >= dst))
				{
					if((nbList[index].endAddress - nbList[index].begAddress) < minAddrBlock)
					{
						*up_down_flag = 0;
						minAddrBlock = nbList[index].endAddress - nbList[index].begAddress;
						anchor = index;
					}
				}
			}
			if(!(*up_down_flag))
			{
				return getOneHopNeighbor(anchor);
			}
			else
			{
				treeLvlPlusHops = 0xFF;
				for(index = 0 ; index < size_list ; index++)
				{
					if(nbList[index].treeLevel == 0xFF || nbList[index].numHops == 0xFF)
						continue;
					if(nbList[index].treeLevel + nbList[index].numHops < treeLvlPlusHops)
					{
						treeLvlPlusHops = nbList[index].treeLevel + nbList[index].numHops;
						anchor = index;
					}
				}
				return getOneHopNeighbor(anchor);
			}
		}
	}

	uint16_t getOneHopNeighbor(uint8_t anchor)
	{
		/*
		 *	func getOneHopNeighbor(anchor)
		 *		current_hops = hop number of the anchor;
		 *		while current_hops > 1
		 *			for each neighbor nbi with a hop_number of current_hops
		 *				for each neighbor nbi directly connected to nbi
		 *					hop_number of nbi = current_hops - 1;
		 *				end for
		 *			end for
		 *			current_hops = current_hops - 1;
		 *		end while
		 *		return one of the neighbors with hop_number of 1;
		 *	end func
		 */

		uint8_t current_hops, dc;
		uint16_t nb_found;
		uint8_t j;
		uint8_t size_list = ((call MHME_GET.meshDeviceType() == END_DEVICE) ? 1 : MAX_NUM_NEIGHBORS);

		current_hops = nbList[anchor].numHops;
		nb_found = nbList[anchor].begAddress;

		while(current_hops > 1)
		{
			for(j = 1 ; j <= size_list ; j++)
			{
				dc = (connMtx[anchor + 1] & (0x0001 << (15 - j))) >> (15 - j);	// Connected directly with destination?
				if(!dc) continue;
				if(nbList[j - 1].numHops == current_hops - 1)
				{
					nb_found = nbList[j - 1].begAddress;
					current_hops--;
					break;
				}
			}
			if(j > size_list)	return 0xFFFF;
		}
		return nb_found;
	}


	uint16_t nextLinkQualityHop(uint16_t dst, uint8_t * up_down_flag, uint8_t criteria)
	{
		uint8_t index, j = 0, numNb_found = 0, min_hop = 0xFF;
		uint8_t treeLvlPlusHops;
		uint8_t anchor[nbList_size];	// index of the neighbor
		uint16_t minAddrBlock;
		uint8_t size_list = ((call MHME_GET.meshDeviceType() == END_DEVICE) ? 1 : MAX_NUM_NEIGHBORS);

		*up_down_flag = 1;
		minAddrBlock = 0xFFFF;

		if(!nbList_size)
			return 0xFFFF;

		for(index = 0 ; index <= size_list ; index++)
		{
			if((nbList[index].numHops == 1)
				&& (nbList[index].begAddress <= dst)
				&& (nbList[index].endAddress >= dst))
			{
				if((nbList[index].endAddress - nbList[index].begAddress) < minAddrBlock)
				{
					*up_down_flag = 0;
					minAddrBlock = nbList[index].endAddress - nbList[index].begAddress;
					numNb_found = 1;
					anchor[0] = index;
					min_hop	= nbList[index].numHops;
				}
			}
		}
		if(!(*up_down_flag))
		{
			return getLinkQualityOneHopNeighbor(anchor, numNb_found, min_hop, criteria);
		}
		else
		{
			treeLvlPlusHops = 0xFF;
			for(index = 0 ; index <= size_list ; index++)
			{
				if(nbList[index].treeLevel == 0xFF || nbList[index].numHops == 0xFF)
					continue;
					if(nbList[index].treeLevel + nbList[index].numHops < treeLvlPlusHops)
				{
					treeLvlPlusHops = nbList[index].treeLevel + nbList[index].numHops;
				}
			}

			for(index = 0 ; index <= size_list ; index++)
			{
				if(nbList[index].treeLevel + nbList[index].numHops == treeLvlPlusHops)
				{
					anchor[j++] = index;
					numNb_found++;
					if(min_hop > nbList[index].numHops)
						min_hop = nbList[index].numHops;
				}
			}
			return getLinkQualityOneHopNeighbor(anchor, numNb_found, min_hop, criteria);
		}
	}

	uint16_t getLinkQualityOneHopNeighbor(uint8_t *anchor, uint8_t numNbFound, uint8_t minHop, uint8_t criteria)
	{
		int8_t best_RSSI = -128;
		uint8_t best_LQI = 0;
		uint16_t index, nb_found = 0xFFFF;
		uint8_t current_hops, j, dc, i = 0;
		uint8_t size_list = ((call MHME_GET.meshDeviceType() == END_DEVICE) ? 1 : MAX_NUM_NEIGHBORS);

		if(minHop == 1)
		{
			for(i = 0 ; i < numNbFound; i++)
			{
				if(nbList[anchor[i]].numHops == 1)
				if(criteria == RSSI)
				{
					if(best_RSSI <= nbList[anchor[i]].rssi)
					{
						best_RSSI = nbList[anchor[i]].rssi;
						nb_found = nbList[anchor[i]].begAddress;
					}
				}
				else
				{
					if(best_LQI <= nbList[anchor[i]].lqi)
					{
						best_LQI = nbList[anchor[i]].lqi;
						nb_found = nbList[anchor[i]].begAddress;
					}
				}
			}
			return nb_found;
		}
		i = 0;
		while((nbList[anchor[i]].numHops != minHop) && (i < numNbFound))
			i++;

		index = anchor[i];
		nb_found = nbList[index].begAddress;
		current_hops = nbList[index].numHops;
		while(current_hops > 1)
		{
			for(j = 1 ; j <= size_list + 1 ; j++)
			{
				dc = (connMtx[index + 1] & (0x0001 << (15-j))) >> (15 - j);	// Connected directly with destination?
				if(!dc) continue;
				if(nbList[j - 1].numHops == current_hops - 1)
				{
					nb_found = nbList[j - 1].begAddress;
					current_hops--;
					break;
				}
			}
			if(j > size_list)	return 0xFFFF;
		}
		return nb_found;
	}
}

