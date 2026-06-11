/*
    For every vacant lot calculate how long it has been vacant
*/

with has_vacancy as (
    select
        bbl_key,
        vacant_year,
        session_range
    from {{ ref('stg_vacant_range') }}
    -- We want to get ranges from places that are *currently* vacant
    where range_end(session_range) = (
        select max(range_end(vacant_year)) from {{ ref('stg_vacancy') }}
    )
)

select distinct
    bbl_key,
    range_start(session_range) as vacant_since
from has_vacancy