import { initStreetview, showStreetViewPanorama  } from "./streetview";
import { initMap } from "./map";
import { MapLayerMouseEvent} from "maplibre-gl";

function markerClickHandler(e: MapLayerMouseEvent) {
  e.lngLat && showStreetViewPanorama(e.lngLat);
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
  libremap.then((m)=>{
    m.on('load', () => {
        m.on('click', 'lots', markerClickHandler);
    })
  })
  // TODO: what exactly do we need to import from google's library to get streetview?
  await google.maps.importLibrary("maps") as google.maps.MapsLibrary;
  initStreetview()
}

init();