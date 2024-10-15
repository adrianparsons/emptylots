"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
let map;
let infoWindow;
let panorama;
let streetview;
function initMap() {
    return __awaiter(this, void 0, void 0, function* () {
        const { Map, InfoWindow } = yield google.maps.importLibrary("maps");
        map = new Map(document.getElementById("map"), {
            center: { lat: 40.7565749, lng: -73.9797362 },
            zoom: 13,
            mapId: "3be746a5b0357cb1"
        });
        infoWindow = new InfoWindow({ pixelOffset: { height: -37 } });
        panorama = new google.maps.StreetViewPanorama(document.getElementById("streetview"));
        streetview = new google.maps.StreetViewService();
        //let layer = map.getDatasetFeatureLayer("aa920d72-66af-4c1b-975a-20c1d16df3de");
        //layer.style = { fillColor: "blue", pointRadius: 4 };
        yield map.data.loadGeoJson("json/less_columns.json", { idPropertyName: "address" });
        map.data.addListener('click', (e) => {
            showInfo(e.latLng, e.feature);
            showStreetViewPanorama(e.latLng, e.feature);
        });
        // TODO REMOVE THIS
        globalThis.googlemap = map;
    });
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
    infoWindow.setOptions({ content, position });
    infoWindow.open({ map, shouldFocus: false });
}
function showStreetViewPanorama(position) {
    streetview.getPanorama({
        location: position,
        sources: [google.maps.StreetViewSource.OUTDOOR]
    }, (panoData) => {
        panorama.setPano(panoData.location.pano);
    });
}
initMap();
