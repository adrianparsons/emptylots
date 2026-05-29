select
    parking.*,
    st_asgeojson(geometry) as geometry
from `empty-lots.${BQ_DATASET}.mart_parking_lots` as parking
where geometry is not null
