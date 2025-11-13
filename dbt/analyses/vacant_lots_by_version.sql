select count(version), version
from {{ ref('stg_vacant') }}
where landuse = '11' group by version
