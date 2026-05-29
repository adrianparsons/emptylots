select *
from {{ source('nyc_pluto_historical', 'pluto') }}
where address is not null
