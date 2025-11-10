select count(version), version
from {{ ref('stg_lots') }}
where landuse = '11' group by version
