/*
    Parking lots from the latest PLUTO version joined with lot geometry.
    One row per parking lot — tile-ready.
*/

{{ config(materialized='table') }}

with parking as (
    select *
    from {{ ref('stg_parking') }}
    where version = {{ current_pluto_version() }}
),

geometry as (
    select bbl, geometry
    from {{ ref('stg_geometry') }}
)

select
    p.* except (spdist3, zonedist4),
    st_asgeojson(g.geometry) as geometry
from parking p
join geometry g
    on p.bbl = g.bbl
