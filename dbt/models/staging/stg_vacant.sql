select *
from {{ ref('stg_lots_filtered') }}
where landuse = '11'
