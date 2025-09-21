let streetview: google.maps.StreetViewService;
let panorama: google.maps.StreetViewPanorama;

import * as turf from "@turf/turf";

export async function initStreetview(): Promise<void> {
  panorama = new google.maps.StreetViewPanorama(
    document.getElementById("streetview") as HTMLElement);

  streetview = new google.maps.StreetViewService();
}

export function showStreetViewPanorama(position: google.maps.LatLng)  {
  streetview.getPanorama({
    location: position,
    sources: [google.maps.StreetViewSource.OUTDOOR],
    radius: 50,
  }, (panoData: google.maps.StreetViewPanoramaData | null) => {

    const lat1 = panoData?.location?.latLng?.lat() || 0
    const lng1 = panoData?.location?.latLng?.lng() || 0
    const lat2 = position.lat
    const lng2 = position.lng

    const heading = turf.bearing(turf.point([lng1, lat1]), turf.point([lng2, lat2]))
    console.log("heading: ", heading)

    panoData?.location?.pano && panorama.setPano(panoData.location.pano)
    panorama.setPov({heading, pitch: 0})
  })
}