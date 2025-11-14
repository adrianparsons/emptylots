with eight_years as (
    select * from {{ ref('stg_vacant_range') }}
    where range_end(session_range) = '2026-01-01'
    and range_contains(session_range, '2018-01-01')
),

eight_by_bbl as (
  select distinct(bbl_key) from eight_years
)

select vacant.lotarea, * from eight_by_bbl
join {{ ref('stg_vacant') }} as vacant
on bbl_key = cast(vacant.bbl as string)
where version = "25v3"
and vacant.lotarea > 1500
and (ownertype is null) or (ownertype = 'P')