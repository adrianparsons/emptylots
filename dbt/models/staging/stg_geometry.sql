select
    safe_cast(BBL as float64 ) as bbl,
    st_geogfromgeojson(geometry, make_valid => true) as geometry,
from {{ source('raw_pluto', 'mappluto_geometry') }}

