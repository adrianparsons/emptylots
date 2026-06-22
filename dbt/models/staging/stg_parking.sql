select *
from {{ ref('stg_lots') }}
where landuse = '10'
and bldgarea = 0