/*
    Basic stats for mart_vacant_lots. Run once per environment and compare the
    two printouts by eye — ref() resolves to amp_dev or nyc_pluto_historical
    depending on --target:

      dbt show -s stats_mart_vacant_lots --target dev
      dbt show -s stats_mart_vacant_lots --target prod
*/

select
  count(*)                    as n_rows,
  count(distinct bbl)         as distinct_bbl,
  round(sum(lotarea))         as total_lotarea,
  sum(num_permits)            as total_permits,
  countif(num_permits > 0)    as lots_w_permits,
  sum(num_stalled_complaints) as total_stalled,
  min(vacant_since)           as earliest_vacant_since,
  max(vacant_since)           as latest_vacant_since,
  round(avg(assesstot))       as avg_assesstot
from {{ ref('mart_vacant_lots') }}
