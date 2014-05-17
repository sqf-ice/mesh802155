/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

configuration coordinatorAppC {
} 
implementation
{
	components coordinatorC as App;
	
	components MainC;
	App.Boot -> MainC;
	
	components Ieee802155C as MESH;
	App.MHME_JOIN -> MESH;
	App.MHME_START_NETWORK -> MESH;
	App.MHME_RESET -> MESH;	
	App.MHME_SET -> MESH;	
	App.MHME_GET -> MESH;	
	App.MESH_DATA -> MESH;
  	
	components Ieee802154NonBeaconEnabledC as MAC;
	App.MLME_SET -> MAC;
	App.MLME_GET -> MAC;
  	
	components LedsC;
	App.Leds -> LedsC;
}
