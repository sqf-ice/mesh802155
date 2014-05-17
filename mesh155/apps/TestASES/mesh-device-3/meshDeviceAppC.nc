/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

configuration meshDeviceAppC
{
} implementation {
  components meshDeviceC as App;
      
  components MainC;	
  App -> MainC.Boot;
  
  components Ieee802155C as MESH;
  App.MHME_DISCOVER -> MESH;
  App.MHME_JOIN -> MESH;  
  App.MHME_START_DEVICE -> MESH;
  App.MHME_SET -> MESH;
  App.MHME_GET -> MESH;
  App.MHME_RESET -> MESH;
  App.MESH_DATA -> MESH;

  components Ieee802154NonBeaconEnabledC as MAC;
  App.MLME_SET -> MAC;
  App.MLME_GET -> MAC;

  components new Timer62500C() as DiscoverNetworksTimer;
  App.DiscoverNetworksTimer -> DiscoverNetworksTimer;
	
  components LedsC;
  App.Leds -> LedsC;   
}

