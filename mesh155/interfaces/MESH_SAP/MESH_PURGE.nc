/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

 #include "Mesh155.h"

interface MESH_PURGE {

  /**
   * Requests to purge an MHSDU from the transaction queue.
   *
   * @param mhsduHandle The handle of the MHSDU to be purged from the
   *                   	transaction queue
   *
   * @see          	request
   */
  command void request  (
                          uint8_t mhsduHandle
                        );

  /**
   * Notifies of the success of the request to purge an MHSDU from the
   * transaction queue.
   *
   * @param mhsduHandle The handle of the MHSDU requested to be purged from the
   *                   	transaction queue
   * @param status 		The status of the request to be purge an MHSDU from the
   *                   	transaction queue
   *
   * @return 		IEEE154_SUCCESS if the request succeeded;
   *				IEEE154_INVALID_HANDLE otherwise;
   *
   * @see          	confirm
   */
  event void confirm (uint8_t mhsduHandle,
              ieee154_status_t status);

}