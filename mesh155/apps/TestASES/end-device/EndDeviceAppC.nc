/*
 * $Revision: 1.0 $
 * $Date: 2013-03-21 11:21:26 $
 * @author: David Rodenas-Herraiz <rodenasherraiz.david@gmail.com>
 * ========================================================================
 */

configuration EndDeviceAppC
{
} implementation {

  components EndDeviceC as App;

  components MainC;
  App.Boot -> MainC;

  components Ieee802155C as MESH;
  App.MHME_RESET -> MESH;
  App.MHME_GET -> MESH;
  App.MHME_SET -> MESH;
  App.MHME_DISCOVER -> MESH;
  App.MHME_JOIN -> MESH;
  App.MESH_DATA -> MESH;

  components Ieee802154NonBeaconEnabledC as MAC;
  App.MLME_SET -> MAC;
  App.MLME_GET -> MAC;

  components new Timer62500C() as DiscoverNetworksTimer;
  App.DiscoverNetworksTimer -> DiscoverNetworksTimer;

  components LedsC;
  App.Leds -> LedsC;

  components new Timer62500C() as DataTimer;
  App.DataTimer -> DataTimer;

  components new SensorMts300C();
  App.Temp -> SensorMts300C.Temp;
}

