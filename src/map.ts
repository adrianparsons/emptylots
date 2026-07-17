import maplibregl, { Map, MapLayerMouseEvent, Popup } from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import { Protocol } from "pmtiles";

import "./infoWindow"

const center_default = [-73.979736, 40.7565749]
const zoom_default = 13

export function createInfoWindow(props): Popup {
  const lotinfowindow = document.createElement("info-window") as any

  lotinfowindow.data = {
    bbl: props.bbl,
    address: props.address,
    ownername: props.ownername,
    lotArea: Number(props.lotarea).toLocaleString(),
    zolaLink: `https://zola.planning.nyc.gov/l/lot/${props.borocode}/${props.block}/${props.lot}`,
    numPermits: Number(props.num_permits) || 0,
    latestPermitDate: props.latest_permit_date,
    numStalledComplaints: Number(props.num_stalled_complaints) || 0,
    vacantSince: props.vacant_since ? new Date(`${props.vacant_since}T00:00:00`) : null
  }

  return new maplibregl.Popup({ offset: { bottom: [0, -5] } })
    .setDOMContent(lotinfowindow)
}


export async function initMap(loadlat=null,loadlng=null): Promise<Map>{
  let protocol = new Protocol();
  maplibregl.addProtocol("pmtiles",protocol.tile);

  var center = center_default
  var zoom = zoom_default

  if (loadlat && loadlng) {
    center = [loadlng,loadlat]
    console.debug(`setting center to ${center}`)
    zoom = 16
  }

  const map = new maplibregl.Map({
    container: 'map', // container id
    style: 'https://tiles.openfreemap.org/styles/positron',
    center,
    zoom
  })

  map.on('load', async () => {
    // Add geolocate control to the map.
    map.addControl(
      new maplibregl.GeolocateControl({
        positionOptions: {
          enableHighAccuracy: true
        },
        trackUserLocation: true
      })
    );

    const tileBaseUrl = process.env.TILE_CDN_URL || 'https://cdn.empty.nyc';

    map.addSource('vacant', {
      type: 'vector',
      url: `pmtiles://${tileBaseUrl}/lots.pmtiles`,
      promoteId: 'bbl'
    });

    map.addLayer({
      'id': 'parkinglots',
      'source-layer': 'parking',
      'type': 'fill',
      'source': 'vacant',
      'paint': {
        'fill-color': '#777777'
      }
    });

    map.addLayer({
      'id': 'lotpolygons',
      'type': 'fill',
      'source': 'vacant',
      'source-layer': 'lots',
      'layout': {},
      'paint': {
        'fill-color': ['case', ['boolean', ['feature-state', 'selected'], false],
          '#ffff00',
          '#00ff00'
        ]
      }
    });


    var hovered: [] = []

    map.on('mousemove', ['lotpolygons', 'parkinglots'], (e: MapLayerMouseEvent) => {
      map.getCanvas().style.cursor = "pointer";
      if (e.features && e.features.length > 0) {
        map.setFeatureState({
          source: 'vacant',
          sourceLayer: 'lots',
          id: e.features[0].properties.bbl,
        }, {
          hover: true
        });
        e.features[0].id && hovered.push(e.features[0].properties.bbl)
      }
    });

    map.on('mouseleave',['parkinglots', 'lotpolygons'], (e: MapLayerMouseEvent) => {
      map.getCanvas().style.cursor = "default";
      while (hovered.length > 0) {
        map.setFeatureState({
          source: 'vacant',
          sourceLayer: 'vacant',
          id: hovered.pop(),
        }, {
          hover: false
        });
      }
    });

    map.on('click', ['lotpolygons', 'parkinglots'], (e: MapSourceMapEvent) => {
      const { lng, lat } = e.lngLat
      if (!e.features || e.features.length === 0) return;
      const properties = e.features[0].properties;

      map.removeFeatureState({ source: 'vacant', sourceLayer:'lots' });
      map.setFeatureState(
        {
          source: 'vacant',
          sourceLayer: 'lots',
          id: properties.bbl,
        },
        {
          selected: true,
        }
      );

      createInfoWindow(properties)
        .setLngLat([lng, lat])
        .addTo(map);

      map.easeTo({center: [lng, lat]})

      const url = new URL(window.location);
      url.searchParams.set("lat", lat);
      url.searchParams.set("lng", lng);
      history.pushState({}, "", url)
    })
  })
  return map
}
