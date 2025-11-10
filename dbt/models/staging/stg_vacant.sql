
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='view') }}

select *
from {{ ref('stg_lots') }}
where landuse = '11'

/*
with first_records as (
    select address, version
    from {{ ref('stg_lots') }}
    where landuse = '11'
    group by address, version
)
*/

/*
select address, version from first_records
group by version
*/

/*
select vacant.*
from {{ ref('stg_lots') }} vacant
inner join first_records f
    on 

*/

