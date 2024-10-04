let map: google.maps.Map;
async function initMap(): Promise<void> {
  const { Map } = await google.maps.importLibrary("maps") as google.maps.MapsLibrary;
  const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");

  map = new Map(document.getElementById("map") as HTMLElement, {
    center: { lat: 40.7565749, lng: -73.9797362 },
    zoom: 13,
    mapId: "3be746a5b0357cb1"
  });

  //let layer = map.getDatasetFeatureLayer("aa920d72-66af-4c1b-975a-20c1d16df3de");
  //layer.style = { fillColor: "blue", pointRadius: 4 };

  await map.data.loadGeoJson("json/less_columns.json", {idPropertyName: "address"}, (feature) => {
    for (let ft in feature) {
      console.log("feature!", ft)
    }
    console.log("fuuutuuuures featuressssss!", feature)
  });
  //await map.data.addGeoJson(geojson);

  globalThis.googlemap = map;
}

initMap();