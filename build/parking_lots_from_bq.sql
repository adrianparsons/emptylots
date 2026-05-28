with parking as (
    select *
    from `empty-lots`.`nyc_pluto_historical`.`stg_parking`
),


versions as (
    select distinct
        version
    from `nyc_pluto_historical.stg_lots_filtered`
)

select
    *,
    st_asgeojson(geo.geometry) as geometry
from parking
join `empty-lots.nyc_pluto_historical.stg_geometry` as geo
    on parking.bbl = geo.bbl
where filtered.version = (select max(version) from versions)
