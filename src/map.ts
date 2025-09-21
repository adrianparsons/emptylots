import maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';

import "./infoWindow"

export async function initMap(){
  const map = new maplibregl.Map({
      container: 'map', // container id
      style: 'https://tiles.openfreemap.org/styles/liberty',
      center: [-73.979736, 40.7565749], // starting position [lng, lat]
      zoom: 13 // starting zoom
  })

  map.on('load',async () => {

    map.addSource('emptylots', {
      type: 'geojson',
      data: './static/emptylots.json',
      promoteId: 'address'
    });

    map.addLayer({
      'id': 'lots',
      'type': 'circle',
      'source': 'emptylots',
      'layout': {},
      'paint': {
        'circle-color': ['case', ['boolean', ['feature-state', 'hover'], false],
          '#2727F5',
          '#F52795'
        ]
      }
    });

    var hovered: string[] = []

    map.on('mousemove', 'lots', (e) => {
      map.getCanvas().style.cursor = "pointer";
      if (e.features.length > 0) {
        map.setFeatureState({
          source: 'emptylots',
          id: e.features[0].id,
        }, {
          hover: true
        });
      }
      hovered.push(e.features[0].id)
    });

    map.on('mouseleave', 'lots', (e) => {
      map.getCanvas().style.cursor = "default";
      while (hovered.length > 0) {
          map.setFeatureState({
          source: 'emptylots',
          id: hovered.pop(),
        }, {
          hover: false
        });
      }
    });

    map.on('click', 'lots', (e) => {
      const {lng, lat} = e.lngLat
      const props = e.features[0].properties

      const lotinfowindow = document.createElement("info-window") as any
        lotinfowindow.data = {
          address: props.address,
          ownername: props.ownername,
          lotArea: Number(props.lotarea).toLocaleString(),
          zolaLink: `https://zola.planning.nyc.gov/l/lot/${props.borocode}/${props['Tax block']}/${props['Tax lot']}`,
        }

      new maplibregl.Popup()
          .setLngLat([lng, lat])
          .setDOMContent(lotinfowindow)
          .addTo(map);
    })

    /*
    const lots = await map.getSource('emptylots').getData()

    lots.features.forEach((f)=> {
      const [lng, lat]  = f.geometry.coordinates

      new maplibregl.Marker()
        .setLngLat([lng, lat])
        .addTo(map);

    })
    */

  })
  return map
}
