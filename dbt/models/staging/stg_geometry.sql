select *
from {{ source('raw_pluto', 'mappluto_geometry') }}