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
          showStreetViewPanorama([params.get("lng"), params.get("lat")])
        }
    })
    m.on('click', ['parkinglots', 'lotpolygons'], markerClickHandler);
  })
  await google.maps.importLibrary("streetView") as google.maps.MapsLibrary;
  initStreetview()
}

init();