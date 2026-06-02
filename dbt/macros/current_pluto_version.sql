-- Current PLUTO release version.
-- Resolved once per `dbt run` against stg_lots_filtered and baked into
-- compiled SQL as a literal. All PLUTO-derived staging tables share the
-- same version concept, so this is the single source of truth.

{% macro current_pluto_version() %}
  {%- set result = run_query("select max(version) as v from " ~ ref('stg_lots_filtered')) -%}
  {%- if execute -%}
    '{{ result.rows[0][0] }}'
  {%- else -%}
    ''
  {%- endif -%}
{% endmacro %}
