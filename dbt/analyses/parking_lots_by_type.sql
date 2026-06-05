
select count(bldgclass), bldgclass
from {{ ref('stg_lots') }}
where landuse = '10'
group by bldgclass
