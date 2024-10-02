let map: google.maps.Map;
async function initMap(): Promise<void> {
  const { Map } = await google.maps.importLibrary("maps") as google.maps.MapsLibrary;
  map = new Map(document.getElementById("map") as HTMLElement, {
    center: { lat: 40.7565749, lng: -73.9797362 },
    zoom: 13,
    mapId: "3be746a5b0357cb1"
  });
  let layer = map.getDatasetFeatureLayer("aa920d72-66af-4c1b-975a-20c1d16df3de");
  layer.style = { fillColor: "blue", pointRadius: 4 };

  globalThis.googlemap = map;
}

initMap();