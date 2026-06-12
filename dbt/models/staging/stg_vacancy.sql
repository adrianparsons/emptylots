/*
    Time span when a property was vacant.
*/

select bbl,
{{ bbl_key_from_parts('borocode', 'block', 'lot') }} as bbl_key,

ownername,
range(
  date( concat('20', substring(version, 0, 2), '-1-1') ),
  date_add(date( concat('20', substring(version, 0, 2), '-1-1')), interval 1 year)
) as vacant_year
from {{ ref('stg_vacant') }}
