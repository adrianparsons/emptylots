select
    *
from `empty-lots.nyc_pluto_historical.mart_parking_lots` as parking
where parking.geometry is not null
