{{ config(materialized='view') }}

select *
from {{ source('nyc-lots', 'pluto') }}
where address is not null
