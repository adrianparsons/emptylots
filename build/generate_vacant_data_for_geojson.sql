with eight_years as (
    select * from `empty-lots`.`nyc_pluto_historical`.`stg_vacant_range`
    where range_end(session_range) = '2026-01-01'
    and range_contains(session_range, '2018-01-01')
),

eight_by_bbl as (
  select distinct(bbl_key), range_start(session_range) as range_start from eight_years
)

select vacant.bbl, range_start as vacant_since, * from eight_by_bbl
join `empty-lots`.`nyc_pluto_historical`.`stg_vacant` as vacant
on bbl_key = cast(vacant.bbl as string)
where version = "25v3"
and vacant.lotarea > 1500
and (ownertype is null) or (ownertype = 'P')
order by vacant.bbl asc