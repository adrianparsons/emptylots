/*
    Vacant lots enriched with building permit summary.
    One row per vacant lot — permits are aggregated before joining to prevent fan-out.
*/

{{ config(materialized='table') }}

with vacant_lots as (
    select
        *,
        concat(
            cast(borocode as string),
            lpad(cast(block as string), 5, '0'),
            lpad(cast(lot as string), 5, '0')
        ) as bbl_key
    from {{ ref('stg_vacant') }}
    where version = (select max(version) from {{ ref('stg_vacant') }})
),

permit_summary as (
    select
        bbl_key,
        count(*) as num_permits,
        max(issuance_date) as latest_permit_date,
        max(filing_date) as latest_filing_date,
        date_diff(current_date(), max(issuance_date), year) as years_since_last_permit
    from {{ ref('stg_permits') }}
    group by bbl_key
)

select
    v.*,
    coalesce(p.num_permits, 0) as num_permits,
    p.latest_permit_date,
    p.latest_filing_date,
    p.years_since_last_permit
from vacant_lots v
left join permit_summary p
    on v.bbl_key = p.bbl_key
