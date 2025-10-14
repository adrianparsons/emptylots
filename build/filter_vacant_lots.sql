-- Used as an argument in an ogr2ogr command
-- Filters bad data and selects vacant properties
select * from MapPLUTO where LandUse = '11'
and Address is not null
and substr(Address, 1, 1) in ('0','1','2','3','4','5','6','7','8','9')