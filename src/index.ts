import { initStreetview, showStreetViewPanorama  } from "./streetview";
import { initMap, createInfoWindow } from "./map";
import type { Map, MapLayerMouseEvent} from "maplibre-gl";

function markerClickHandler(e: MapLayerMouseEvent) {
  if (!e.features || e.features.length == 0) return;
  e.features[0] && showStreetViewPanorama([e.features[0].properties.longitude, e.features[0].properties.latitude]);
}

async function init(): Promise<void> {
  const params = new URLSearchParams(window.location.search)
  const lat = Number(params.get("lat"))
  const lng = Number(params.get("lng"))

  const libremap = initMap(lat,lng)

  libremap.then((m: Map)=>{
    m.once('idle', () => {
      if (!lat || !lng) return
      showStreetViewPanorama([lng, lat])

      let point = m.project([lng, lat])
      let features = m.queryRenderedFeatures(point)

      if (!features || features.length === 0) return;
      const properties = features[0].properties;

      createInfoWindow(properties)
        .setLngLat([lng, lat])
        .addTo(m)
    })
    m.on('click', ['parkinglots', 'lotpolygons'], markerClickHandler);
  })
  await google.maps.importLibrary("streetView") as google.maps.MapsLibrary;
  initStreetview()
}

init();