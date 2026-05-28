select *
from {{ ref('stg_lots_filtered') }}
where landuse = '10'
and bldgclass in ('G0', 'G1', 'G6', 'G7')
and numbldgs = 0