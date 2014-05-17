/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */


/**
 * MHME-SAP reset primitives specify how to reset the MESH sublayer to
 * its default values. (IEEE 802.15.5-2009, Sect. 5.2.2.13)
 */

#include "Mesh155.h"

interface MHME_RESET {

  /**
   * Allows the next higher layer to request that the MESH Sublayer
   * performs a reset operation.
   */

  command ieee155_status_t request();

  /**
   * Reports the results of the reset operation
   *
   * @param status The status of the reset operation
   */

  event void confirm(ieee155_status_t status);

}
