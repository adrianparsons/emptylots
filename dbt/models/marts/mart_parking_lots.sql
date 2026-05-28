/*
    Parking lots from the latest PLUTO version joined with lot geometry.
    One row per parking lot — tile-ready.
*/

{{ config(materialized='table') }}

with parking as (
    select *
    from {{ ref('stg_parking') }}
    where version = (select max(version) from {{ ref('stg_parking') }})
),

geometry as (
    select bbl, geometry
    from {{ source('nyc_pluto_historical', 'stg_geometry') }}
)

select
    p.*,
    g.geometry
from parking p
join geometry g on p.bbl = g.bbl
