let map: google.maps.Map;
let infoWindow: google.maps.InfoWindow;

import "./infoWindow.js"

const boroughCenter: Record<string, [number, number]> = {
  "BK": [40.6690628,-73.9653658],
  "MN": [40.7565749,-73.979736],
  "SI": [40.5983874,-74.1580968],
  "QN": [40.7329813,-73.8879294],
  "BX": [40.8341748,-73.9018563],
}

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

export async function initGoogleMap(): Promise<google.maps.Map> {
  const { Map, InfoWindow } = await google.maps.importLibrary("maps") as google.maps.MapsLibrary;

  map = new Map(document.getElementById("map") as HTMLElement, {
    center: { lat: boroughCenter["MN"][0], lng: boroughCenter["MN"][1] },
    zoom: 13,
    mapId: "3be746a5b0357cb1"
  });

  infoWindow = new InfoWindow({pixelOffset: new google.maps.Size(0,-37)});

  map.data.loadGeoJson("json/emptylots.json", {idPropertyName: "address"});

  // Default borough is Manhattan
  map.data.setStyle(enableBorough("MN"))

  const boroselect = document.getElementById("boro")

  boroselect && boroselect.addEventListener("click", (e) => {
    const selected = (e.target as HTMLElement)?.dataset?.borough || "MN";
    map.data.setStyle(enableBorough(selected))
    map.setCenter({lat: boroughCenter[selected][0], lng: boroughCenter[selected][1]})

  })

  return map;
}

export function showInfo(position: google.maps.LatLng | undefined, feature: google.maps.Data.Feature) {

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