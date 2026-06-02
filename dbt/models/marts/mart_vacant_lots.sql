/*
    Vacant lots enriched with permit and stalled construction data.
    One row per vacant lot — tile-ready.
*/

{{ config(materialized='table') }}

with vacant_lots as (
    select
        *,
        {{ bbl_key_from_parts('borocode', 'block', 'lot') }} as bbl_key
    from {{ ref('stg_vacant') }}
    where version = {{ current_pluto_version() }}
),

geometry as (
    select bbl, geometry
    from {{ source('nyc_pluto_historical', 'stg_geometry') }}
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
),

stalled_summary as (
    select
        bbl_key,
        count(*) as num_stalled_complaints,
        min(complaint_received_at) as earliest_stalled_complaint,
        max(last_reported_at) as latest_stalled_report
    from {{ ref('int_stalled_construction') }}
    where bbl_key is not null
    group by bbl_key
)

select
    v.*,
    g.geometry,
    coalesce(p.num_permits, 0) as num_permits,
    p.latest_permit_date,
    p.latest_filing_date,
    p.years_since_last_permit,
    coalesce(s.num_stalled_complaints, 0) as num_stalled_complaints,
    s.earliest_stalled_complaint,
    s.latest_stalled_report
from vacant_lots v
left join geometry g
    on v.bbl = g.bbl
left join permit_summary p
    on v.bbl_key = p.bbl_key
left join stalled_summary s
    on v.bbl_key = s.bbl_key
