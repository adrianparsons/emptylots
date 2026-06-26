/*
    Staging model for NYC planimetric parking lots (OTI basemap).

    The raw table loads all-STRING; the numeric columns carry comma
    thousands-separators (e.g. "5,000", "4,566.43"), so strip commas before
    casting. the_geom is WKT in WGS-84 — 13 of 20,429 rows are
    invalid-but-parseable and are repaired by make_valid.

    Note: shape_length / shape_area come from the source projection
    (NAD83 / NY Long Island ftUS), so they are in feet and square feet — not
    the meters that ST_* geography functions return.

    Distinct from stg_parking, which is PLUTO landuse-derived (not basemap).
*/

select
    safe_cast(replace(SOURCE_ID, ',', '') as int64) as source_id,
    safe_cast(replace(FEAT_CODE, ',', '') as int64) as feat_code,
    safe_cast(replace(SUB_CODE, ',', '') as int64) as sub_code,
    STATUS as status,
    safe_cast(replace(SHAPE_Leng, ',', '') as float64) as shape_length,
    safe_cast(replace(SHAPE_Area, ',', '') as float64) as shape_area,
    st_geogfromtext(the_geom, make_valid => true) as geometry,
from {{ source('raw_planimetric', 'planimetric_parking') }}
