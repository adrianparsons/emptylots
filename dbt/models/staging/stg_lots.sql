{{ config(materialized='view') }}

select *
from `empty-lots`.`nyc_pluto_historical`.`pluto`
where address is not null
