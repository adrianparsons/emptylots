import { initStreetview, showStreetViewPanorama  } from "./streetview";
import { initMap } from "./map";
import type { Map, MapLayerMouseEvent} from "maplibre-gl";

function markerClickHandler(e: MapLayerMouseEvent) {
  if (!e.features || e.features.length == 0) return;
  e.features[0] && showStreetViewPanorama([e.features[0].properties.Longitude, e.features[0].properties.Latitude]);
}

async function init(): Promise<void> {
  const libremap = initMap()
  libremap.then((m: Map)=>{
    m.on('load', () => {
          const params = new URLSearchParams(window.location.search)
          if ( params.size >= 2) {
            //const param = new URLSearchParams(window.location.hash)
            showStreetViewPanorama([params.get("lng"), params.get("lat")])
          }
        m.on('click', ['parkinglots', 'lotpolygons'], markerClickHandler);
    })
  })
  // TODO: what exactly do we need to import from google's library to get streetview?
  await google.maps.importLibrary("maps") as google.maps.MapsLibrary;
  initStreetview()
}

init();