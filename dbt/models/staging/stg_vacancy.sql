/*
    Time span when a property was vacant.
*/

select bbl,
cast(bbl as string) as bbl_key,
ownername,
range(
  date( concat('20', substring(version, 0, 2), '-1-1') ),
  date_add(date( concat('20', substring(version, 0, 2), '-1-1')), interval 1 year)
) as vacant_year
from {{ ref('stg_vacant') }}
