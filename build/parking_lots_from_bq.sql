with versions as (
    select distinct
        version
    from `nyc_pluto_historical.stg_lots_filtered`
)

select
    parking.*,
    st_asgeojson(geo.geometry) as geometry
from `empty-lots`.`nyc_pluto_historical`.`stg_parking` as parking
join `empty-lots.nyc_pluto_historical.stg_geometry` as geo
    on parking.bbl = geo.bbl
where parking.version = (select max(version) from versions)
