/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

#ifndef __APP_PROFILE_H
#define __APP_PROFILE_H

enum {
  WAKEUP_ORDER = 9,
  ACTIVE_ORDER = 7,
  TX_POWER = -20, // in dBm
  RADIO_CHANNEL = 26,
  PAN_ID = 0x4927,
  DATA_TRANSFER_PERIOD = 312500U,
  SINK_ADDRESS = 0x0000,	// Mesh Coordinator
  NREADINGS = 10
};

#endif
