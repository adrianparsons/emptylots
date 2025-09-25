// TODO: remove these vars from top-level scope.
let streetview: google.maps.StreetViewService;
let panorama: google.maps.StreetViewPanorama;

import { bearing } from "@turf/bearing";
import { point } from "@turf/helpers";
import { LngLat } from "maplibre-gl";

export async function initStreetview(): Promise<void> {
  panorama = new google.maps.StreetViewPanorama(
    document.getElementById("streetview") as HTMLElement);

  streetview = new google.maps.StreetViewService();
}

export function showStreetViewPanorama(position: LngLat)  {
  streetview.getPanorama({
    location: position,
    sources: [google.maps.StreetViewSource.OUTDOOR],
    radius: 50,
  }, (panoData: google.maps.StreetViewPanoramaData | null) => {

    const lat1 = panoData?.location?.latLng?.lat() || 0
    const lng1 = panoData?.location?.latLng?.lng() || 0
    const lat2 = position.lat
    const lng2 = position.lng

    const heading = bearing(point([lng1, lat1]), point([lng2, lat2]))
    console.log("heading: ", heading)

    panoData?.location?.pano && panorama.setPano(panoData.location.pano)
    panorama.setPov({heading, pitch: 0})
  })
}