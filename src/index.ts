let map: google.maps.Map;
let infoWindow: google.maps.InfoWindow;

import "./infoWindow.js"
import { initStreetview, showStreetViewPanorama  } from "./streetview.js";

function enableBorough(borough: string) {
  return (feature: google.maps.Data.Feature) => {
      if (feature.getProperty("borough") != borough) {
        return {
          visible: false
        }
      }
      return {}
  }
}

async function initMap(): Promise<void> {
  const { Map, InfoWindow } = await google.maps.importLibrary("maps") as google.maps.MapsLibrary;

  map = new Map(document.getElementById("map") as HTMLElement, {
    center: { lat: 40.7565749, lng: -73.9797362 },
    zoom: 13,
    mapId: "3be746a5b0357cb1"
  });


  infoWindow = new InfoWindow({pixelOffset: new google.maps.Size(0,-37)});

  await map.data.loadGeoJson("json/less_columns.json", {idPropertyName: "address"});

  // Default borough is Manhattan
  map.data.setStyle(enableBorough("MN"))

  const boroselect = document.getElementById("boro")

  initStreetview()

  boroselect && boroselect.addEventListener("click", (e) => {
    const selected = (e.target as HTMLElement)?.dataset?.borough || "MN";
    map.data.setStyle(enableBorough(selected))
    // TODO: change map center after enabling a new borough.
  })

  map.data.addListener('click', (e: google.maps.Data.MouseEvent) => {
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
  })
  // TODO REMOVE THIS
  //globalThis.googlemap = map;
}

function showInfo(position: google.maps.LatLng | undefined, feature: google.maps.Data.Feature) {

  const lotinfowindow = document.createElement("info-window") as any
  lotinfowindow.data = {
    address: feature.getProperty("address"),
    ownername: feature.getProperty("ownername"),
    lotArea: Number(feature.getProperty('lotarea')).toLocaleString(),
    zolaLink: `https://zola.planning.nyc.gov/l/lot/${feature.getProperty('borocode')}/${feature.getProperty('Tax block')}/${feature.getProperty('Tax lot')}`,
  }

  infoWindow.setOptions({content:lotinfowindow, position});
  infoWindow.open({map, shouldFocus: false});
}

initMap();