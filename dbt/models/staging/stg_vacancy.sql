/*
    Time span when a property was vacant.
*/

select bbl,
cast(bbl as string) as bbl_key,
range(
  date( concat('20', substring(version, 0, 2), '-1-1') ),
  date( concat('20', substring(version, 0, 2), '-12-31') )
) as vacant_year
from {{ ref('stg_vacant') }}
