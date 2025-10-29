-- Used as an argument in an ogr2ogr command
-- Filters some parking lots with no buildings on them
select * from MapPLUTO where LandUse = '10'
and BldgClass in ('G0', 'G1', 'G6', 'G7')
and NumBldgs = 0