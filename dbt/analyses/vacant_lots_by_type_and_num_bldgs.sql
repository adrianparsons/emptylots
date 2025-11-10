select count(bldgclass), bldgclass, numbldgs
from {{ ref('stg_lots') }}
where landuse = '11' group by rollup(bldgclass, numbldgs) order by bldgclass
