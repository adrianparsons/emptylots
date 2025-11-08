
select count(bldgclass)
from {{ source('nyc-lots', 'pluto') }}
where landuse = '10'
group by bldgclass
