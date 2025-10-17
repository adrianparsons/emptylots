import maplibregl, { Map, MapLayerMouseEvent } from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import { Protocol } from "pmtiles";

import "./infoWindow"

export async function initMap(): Promise<Map>{
  let protocol = new Protocol();
  maplibregl.addProtocol("pmtiles",protocol.tile);

  const map = new maplibregl.Map({
    container: 'map', // container id
    style: 'https://tiles.openfreemap.org/styles/positron',
    center: [-73.979736, 40.7565749], // starting position [lng, lat]
    zoom: 13 // starting zoom
  })

  map.on('load', async () => {

    /*
    map.addSource('lotpoints', {
      type: 'geojson',
      data: './static/emptylots.json',
      promoteId: 'address'
    });
    */

    // Add geolocate control to the map.
    map.addControl(
      new maplibregl.GeolocateControl({
        positionOptions: {
          enableHighAccuracy: true
        },
        trackUserLocation: true
      })
    );

    map.addSource('vacant', {
      type: 'vector',
      url: 'pmtiles://https://cdn.empty.nyc/vacant.pmtiles',
      promoteId: 'BBL'
    });

/*
    map.addLayer({
      'id': 'lots',
      'type': 'circle',
      'source': 'lotpoints',
      'layout': {},
    })
*/
    map.addSource('alllots', {
      type: 'vector',
      url: 'pmtiles://https://cdn.empty.nyc/alllotsnyc.pmtiles'
    });

    map.addLayer({
      'id': 'alllots',
      'source-layer': 'MapPLUTO',
      'type': 'line',
      'minzoom': 15,
      'source': 'alllots',
      'paint': {
        'line-color': '#F52795'
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

    map.on('mousemove', 'lotpolygons', (e: MapLayerMouseEvent) => {
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

    map.on('mouseleave', 'lotpolygons', (e: MapLayerMouseEvent) => {
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

    map.on('click', 'lotpolygons', (e: MapSourceMapEvent) => {
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

      new maplibregl.Popup({ offset: { 'bottom': [0, -5] } })
        .setLngLat([lng, lat])
        .setDOMContent(lotinfowindow)
        .addTo(map);
    })
  })
  return map
}
