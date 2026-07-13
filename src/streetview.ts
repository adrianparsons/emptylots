// TODO: remove these vars from top-level scope.
let streetview: google.maps.StreetViewService;
let panorama: google.maps.StreetViewPanorama;

import { bearing } from "@turf/bearing";
import { point } from "@turf/helpers";

export async function initStreetview(): Promise<void> {
  panorama = new google.maps.StreetViewPanorama(
    document.getElementById("streetview") as HTMLElement);

  streetview = new google.maps.StreetViewService();
}

export function showStreetViewPanorama([lng, lat]: [number, number])  {

  // Hide the "about" panel after user clicks on the map.
  const aboutEl = document.getElementById("about")
  if (aboutEl){
    aboutEl.style.display = "none"
  }
  const streetviewEl = document.getElementById("streetview");
  if (streetviewEl) {
      streetviewEl.style.display = "block";
  }

  streetview.getPanorama({
    location: {lng: parseFloat(lng), lat: parseFloat(lat)},
    sources: [google.maps.StreetViewSource.OUTDOOR],
    radius: 50,
  })
  .then(
    ({data: panoData}: google.maps.StreetViewResponse) => {

    const lat1 = panoData?.location?.latLng?.lat() || 0
    const lng1 = panoData?.location?.latLng?.lng() || 0
    const lat2 = lat
    const lng2 = lng

    const heading = bearing(point([lng1, lat1]), point([lng2, lat2]))
    console.log("heading: ", heading)

    panoData?.location?.pano && panorama.setPano(panoData.location.pano)
    panorama.setPov({heading, pitch: 0})
    panorama.setOptions({imageDateControl: true})
    panorama.setVisible(true)
  })
  .catch(
    (err: unknown) => {
      // If we don't have a streetview image, hide the streetview element (and previous results)
      panorama.setVisible(false)
      console.error("streetview error", err)
    }
  )
}