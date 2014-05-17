/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#include "Mesh155.h"

interface MHME_DISCOVER {

  /**
   * Allows the next higher layer to request the mesh sublayer to discover mesh networks currently operating within the neighborhood.
   *
   * @param ScanChannels 		The 27 bits (b0,..,b26) indicate which channels are to be scanned (1=scan,0=don't scan)
   *											for each of the 27 channels supported by the ChannelPage parameter as defined in IEE 802.15.4-2006
   *
   * @param ScanDuration		A value used to calculate the length of time to spend scanning each channel.
   *
   * @param ChannelPage 		The channel page on which to perform the scan.
   *
   * @param ReportCriteria 		The field indicates which criterion is used to select the best neighbor to be reported to the next higher layer.
   *
   *
   * @return       IEEE155_SUCCESS if the request succeeded and a confirm event will be signalled, an appropriate error code otherwise
   *               		(no confirm event will be signalled in this case).
   *
   * @see          confirm
  */

  command void request (uint32_t ScanChannels, uint8_t ScanDuration, uint8_t ChannelPage, ieee155_reportCriteria_t ReportCriteria);

  /**
   * Reports to its next higher layer the result of a network discovery operation.
   *
   * @param status		Any status value returned with the MLME_SCAN.confirm primitive.
   *
   * @param NetworkCount		Gives the number of networks discovered by the search.
   *
   * @param MeshDescriptorList		A list of descriptors, one for each of the mesh network discovered.
   */

  event void confirm (ieee154_status_t status, uint8_t NetworkCount, ieee155_MDT_t* MeshDescriptorList);

}
