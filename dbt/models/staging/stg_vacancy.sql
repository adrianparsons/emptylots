/*
    Time span when a property was vacant.
*/

select bbl,
range(
  date( concat('20', substring(version, 0, 2), '-1-1') ),
  date( concat('20', substring(version, 0, 2), '-12-31') )
) as year
from {{ ref('stg_vacant') }}
