/*
    Time span when a property was vacant.
    Converting BBL to string for more reliable partitioning.
*/

select
  bbl_key,
  ownername,
  vacant_year,
  session_range
from range_sessionize(
  table {{ ref('stg_vacancy') }},
  'vacant_year',
  ['bbl_key']
)
