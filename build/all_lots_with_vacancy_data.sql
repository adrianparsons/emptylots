with has_vacancy as (
    select *
    from `empty-lots`.`nyc_pluto_historical`.`stg_vacant_range`
    where range_end(session_range) = '2026-01-01'
),

vacancy_by_bbl as (
    select distinct
        bbl_key,
        range_start(session_range) as range_start
    from has_vacancy
),

versions as (
    select distinct
        version
    from `nyc_pluto_historical.stg_lots_filtered`
)

select
    filtered.*,
    range_start as vacant_since,
    st_asgeojson(geo.geometry) as geometry
from vacancy_by_bbl
right join `empty-lots`.`nyc_pluto_historical.stg_lots_filtered` as filtered
    on bbl_key = cast(filtered.bbl as string)
join `empty-lots.nyc_pluto_historical.stg_geometry` as geo
    on filtered.bbl = geo.bbl
where filtered.version = (select max(version) from versions)
    and landuse = '11'