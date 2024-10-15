let map: google.maps.Map;
let infoWindow;
let panorama;
let streetview;

async function initMap(): Promise<void> {
  const { Map, InfoWindow } = await google.maps.importLibrary("maps") as google.maps.MapsLibrary;

  map = new Map(document.getElementById("map") as HTMLElement, {
    center: { lat: 40.7565749, lng: -73.9797362 },
    zoom: 13,
    mapId: "3be746a5b0357cb1"
  });

  infoWindow = new InfoWindow({pixelOffset: {height: -37}});

  panorama = new google.maps.StreetViewPanorama(
    document.getElementById("streetview") as HTMLElement);

  streetview = new google.maps.StreetViewService();

  //let layer = map.getDatasetFeatureLayer("aa920d72-66af-4c1b-975a-20c1d16df3de");
  //layer.style = { fillColor: "blue", pointRadius: 4 };

  await map.data.loadGeoJson("json/less_columns.json", {idPropertyName: "address"});

  map.data.addListener('click', (e) => {
    showInfo(e.latLng, e.feature);
    showStreetViewPanorama(e.latLng, e.feature);
  }
);

  // TODO REMOVE THIS
  globalThis.googlemap = map;
}

function showInfo(position, feature) {
  const lotArea = Number(feature.getProperty('lotarea')).toLocaleString();

  const content = `
    <div style="">
      <h3 style="margin-top: 0">${feature.getProperty('address')}</h3>
      <p>Owner: ${feature.getProperty('ownername')}</p>
      <p>${lotArea} square feet</p>
      <p>community board ${feature.getProperty('community board')}</p>
      <p>precinct ${feature.getProperty('policeprct')}</p>
      <p>council district ${feature.getProperty('council district')}</p>
      <p><a href="https://zola.planning.nyc.gov/l/lot/1/${feature.getProperty('Tax block')}/${feature.getProperty('Tax lot')}" target="_blank"}>ZoLa ⤴</a></p>
    </div>
  `;
  // feature.forEachProperty(console.log)

  infoWindow.setOptions({content, position});
  infoWindow.open({map, shouldFocus: false});
}

function showStreetViewPanorama(position)  {
  streetview.getPanorama({
    location: position,
    sources: [google.maps.StreetViewSource.OUTDOOR]
  }, (panoData){
    panorama.setPano(panoData.location.pano)
  })
}

initMap();