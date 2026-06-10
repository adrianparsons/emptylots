/*
    For every vacant lot calculate how long it has been vacant
*/

with has_vacancy as (
    select *
    from from {{ ref('stg_vacant_range') }}
    -- We want to get ranges from places that are *currently* vacant
    where range_end(session_range) = max(range_end(session_range))
),

vacancy_by_bbl as (
    select distinct
        bbl_key,
        range_start(session_range) as range_start
    from has_vacancy
),

select
    filtered.*,
    range_start as vacant_since,
from vacancy_by_bbl
right join {{ ref('stg_vacant') }} as filtered
    on bbl_key = cast(filtered.bbl as string)
where filtered.version = {{ current_pluto_version() }}