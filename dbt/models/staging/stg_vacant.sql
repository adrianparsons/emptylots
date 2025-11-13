{{ config(materialized='view') }}

select *
from {{ ref('stg_lots') }}
where landuse = '11'
