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
    st_asgeojson(geo.geometry) as geometry
from vacancy_by_bbl
right join `empty-lots`.`nyc_pluto_historical.stg_lots_filtered` as filtered
    on bbl_key = cast(filtered.bbl as string)
join `empty-lots.nyc_pluto_historical.stg_geometry` as geo
    on filtered.bbl = geo.bbl
where filtered.version = {{ current_pluto_version() }}
    and landuse = '11'
