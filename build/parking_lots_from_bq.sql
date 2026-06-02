select
    parking.*,
    st_asgeojson(geometry) as geometry
from `empty-lots.nyc_pluto_historical.mart_parking_lots` as parking
where geometry is not null

