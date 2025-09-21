import { initStreetview, showStreetViewPanorama  } from "./streetview.js";
import { initMap } from "./map.js";

function markerClickHandler(e) {
  //debugger;
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
  const pmap = initMap()
  pmap.then((m)=>{
    m.on('load', () => {
        m.on('click', 'lots', markerClickHandler);
    })
  })
  const { Map, InfoWindow } = await google.maps.importLibrary("maps") as google.maps.MapsLibrary;
  initStreetview()
}

init();