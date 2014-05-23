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
