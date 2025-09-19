let streetview: google.maps.StreetViewService;
let panorama: google.maps.StreetViewPanorama;

export async function initStreetview(): Promise<void> {
  panorama = new google.maps.StreetViewPanorama(
    document.getElementById("streetview") as HTMLElement);

  streetview = new google.maps.StreetViewService();
}

export function showStreetViewPanorama(position: google.maps.LatLng)  {
  streetview.getPanorama({
    location: position,
    sources: [google.maps.StreetViewSource.OUTDOOR]
  }, (panoData: google.maps.StreetViewPanoramaData | null) => {

    const lat1 = panoData?.location?.latLng?.lat()
    const lng1 = panoData?.location?.latLng?.lng()
    const lat2 = position.lat()
    const lng2 = position.lng()

    const heading = turf.bearing([lat1, lng1],[lat2,lng2])
    console.log("heading: ", heading)

    panoData?.location?.pano && panorama.setPano(panoData.location.pano)
    panorama.setPov({heading, pitch: 0})
  })
}