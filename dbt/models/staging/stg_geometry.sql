select
    safe_cast(BBL as float64 ) as bbl,
    st_geogfromgeojson
    st_geo(geometry, make_valid => true) as geometry,
from {{ source('raw_pluto', 'mappluto_geometry') }}

