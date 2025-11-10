
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='view') }}


select *
from {{ source('nyc-lots', 'pluto') }}
where address is not null
-- maybe this next line isn't that important, as long as bbl isn't replicated.
-- and regexp_contains(address, r'[0-9].*')