select count(bldgclass), bldgclass, numbldgs
from {{ ref('stg_vacant') }}
group by rollup(bldgclass, numbldgs) order by bldgclass
