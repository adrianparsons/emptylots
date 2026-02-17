-- BBL key: 11-digit string {borocode 1}{block 5}{lot 5}

{% macro bbl_key_from_parts(borocode, block, lot) %}
concat(
    cast({{ borocode }} as string),
    lpad(cast({{ block }} as string), 5, '0'),
    lpad(cast({{ lot }} as string), 5, '0')
)
{% endmacro %}

-- Map_Pluto_BBL is 10 digits: boro(1) + block(5) + lot(4)
-- Convert to 11 digits: boro(1) + block(5) + lot(5) to match PLUTO
{% macro bbl_key_from_pluto_bbl(pluto_bbl) %}
concat(
    substr({{ pluto_bbl }}, 1, 6),
    lpad(substr({{ pluto_bbl }}, 7), 5, '0')
)
{% endmacro %}
