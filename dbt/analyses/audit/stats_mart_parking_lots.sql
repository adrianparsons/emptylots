/*
    Basic stats for mart_parking_lots. Run once per environment and compare the
    two printouts by eye — ref() resolves to amp_dev or nyc_pluto_historical
    depending on --target:

      dbt show -s stats_mart_parking_lots --target dev
      dbt show -s stats_mart_parking_lots --target prod
*/

select
  count(*)                  as n_rows,
  count(distinct bbl)       as distinct_bbl,
  round(sum(lotarea))       as total_lotarea,
  round(avg(lotarea), 1)    as avg_lotarea,
  round(avg(assesstot))     as avg_assesstot,
  countif(geometry is null) as null_geometry
from {{ ref('mart_parking_lots') }}
