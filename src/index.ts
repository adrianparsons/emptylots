import { initStreetview, showStreetViewPanorama  } from "./streetview.js";
import { initGoogleMap, showInfo } from "./googleMaps.js";

function markerClickHandler(e: google.maps.Data.MouseEvent) {
  e.latLng && showInfo(e.latLng, e.feature );
  e.latLng && showStreetViewPanorama(e.latLng);
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
  const gmap = await initGoogleMap()

  initStreetview()

  gmap.data.addListener('click', markerClickHandler)
}

init();