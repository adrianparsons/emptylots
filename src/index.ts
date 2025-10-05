import { initStreetview, showStreetViewPanorama  } from "./streetview";
import { initMap } from "./map";
import type { Map, MapLayerMouseEvent} from "maplibre-gl";

function markerClickHandler(e: MapLayerMouseEvent) {
  if (!e.features || e.features.length == 0) return;
  e.features[0] && showStreetViewPanorama([e.features[0].properties.Longitude, e.features[0].properties.Latitude]);

  // Hide the "about" panel after user clicks on the map.
  const aboutEl = document.getElementById("about")
  if (aboutEl){
    aboutEl.style.display = "none"
  }
  const streetviewEl = document.getElementById("streetview");
  if (streetviewEl) {
      streetviewEl.style.display = "block";
  }
}

async function init(): Promise<void> {
  const libremap = initMap()
  libremap.then((m: Map)=>{
    m.on('load', () => {
        m.on('click', 'lotpolygons', markerClickHandler);
    })
  })
  // TODO: what exactly do we need to import from google's library to get streetview?
  await google.maps.importLibrary("maps") as google.maps.MapsLibrary;
  initStreetview()
}

init();