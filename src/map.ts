import maplibregl, { Map, MapLayerMouseEvent } from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import { Protocol } from "pmtiles";

import "./infoWindow"

export async function initMap(): Promise<Map>{
  let protocol = new Protocol();
  maplibregl.addProtocol("pmtiles",protocol.tile);

  var center = [-73.979736, 40.7565749]
  var zoom = 13

  const params = new URLSearchParams(window.location.search)
  if ( params.size >= 2) {
    center = [params.get("lng"), params.get("lat")]
    console.log(`setting center to ${center}`)
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
      url: `pmtiles://${tileBaseUrl}/vacant.pmtiles`,
      promoteId: 'BBL'
    });

    map.addSource('parking', {
      type: 'vector',
      url: `pmtiles://${tileBaseUrl}/parking.pmtiles`,
      promoteId: 'BBL'
    });

    map.addSource('alllots', {
      type: 'vector',
      url: `pmtiles://${tileBaseUrl}/alllotsnyc.pmtiles`,
    });

    map.addLayer({
      'id': 'parkinglots',
      'source-layer': 'parking',
      'type': 'fill',
      'source': 'parking',
      'paint': {
        'fill-color': '#777777'
      }
    });

    map.addLayer({
      'id': 'alllots',
      'source-layer': 'MapPLUTO',
      'type': 'line',
      'minzoom': 16,
      'source': 'alllots',
      'paint': {
        'line-color': '#111111'
      }
    });


    map.addLayer({
      'id': 'lotpolygons',
      'type': 'fill',
      'source': 'vacant',
      'source-layer': 'vacant',
      'layout': {},
      'paint': {
        'fill-color': ['case', ['boolean', ['feature-state', 'selected'], false],
          '#ffff00',
          '#00ff00'
        ]
      }
    });


    var hovered: [] = []

    map.on('mousemove', ['parkinglots', 'lotpolygons'], (e: MapLayerMouseEvent) => {
      map.getCanvas().style.cursor = "pointer";
      if (e.features && e.features.length > 0) {
        map.setFeatureState({
          source: 'vacant',
          sourceLayer: 'vacant',
          id: e.features[0].properties.BBL,
        }, {
          hover: true
        });
        e.features[0].id && hovered.push(e.features[0].properties.BBL)
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

    map.on('click', ['parkinglots', 'lotpolygons'], (e: MapSourceMapEvent) => {
      const { lng, lat } = e.lngLat
      if (!e.features || e.features.length === 0) return;
      const props = e.features[0].properties;


      map.removeFeatureState({ source: 'vacant', sourceLayer:'vacant' });
      map.setFeatureState(
        {
          source: 'vacant',
          sourceLayer: 'vacant',
          id: props.BBL,
        },
        {
          selected: true,
        }
      );

      const lotinfowindow = document.createElement("info-window") as any
      lotinfowindow.data = {
        bbl: props.BBL,
        address: props.Address,
        ownername: props.OwnerName,
        lotArea: Number(props.LotArea).toLocaleString(),
        zolaLink: `https://zola.planning.nyc.gov/l/lot/${props.BoroCode}/${props.Block}/${props.Lot}`,
      }

      map.easeTo({center: [lng, lat]})

      const url = new URL(window.location);
      url.searchParams.set("lat", lat);
      url.searchParams.set("lng", lng);
      history.pushState({}, "", url)

      new maplibregl.Popup({ offset: { 'bottom': [0, -5] } })
        .setLngLat([lng, lat])
        .setDOMContent(lotinfowindow)
        .addTo(map);
    })
  })
  return map
}
