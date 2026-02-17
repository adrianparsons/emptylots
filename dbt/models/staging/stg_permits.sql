/*
    Staging model for NYC DOB permit issuance data.
    Constructs a 10-digit BBL key for joining to PLUTO data.

    Incremental: on subsequent runs, only processes permits filed
    after the latest filing_date already in the table.
*/

{{ config(
    materialized='incremental',
    unique_key='permit_key'
) }}

select
    -- Unique key for deduplication
    concat(Job_No, '-', Job_doc_No) as permit_key,

    -- Construct BBL key: {borocode 1}{block 5}{lot 5}
    concat(
        case BOROUGH
            when 'MANHATTAN' then '1'
            when 'BRONX' then '2'
            when 'BROOKLYN' then '3'
            when 'QUEENS' then '4'
            when 'STATEN ISLAND' then '5'
        end,
        Block,
        Lot
    ) as bbl_key,

    -- Permit details
    Job_No,
    Job_Type,
    Work_Type,
    Permit_Type,
    Permit_Status,
    Permit_Subtype,

    -- Dates (mixed formats: MM/DD/YYYY and YYYY-MM-DD)
    coalesce(safe.parse_date('%m/%d/%Y', Filing_Date), safe.parse_date('%Y-%m-%d', Filing_Date)) as filing_date,
    coalesce(safe.parse_date('%m/%d/%Y', Issuance_Date), safe.parse_date('%Y-%m-%d', Issuance_Date)) as issuance_date,
    coalesce(safe.parse_date('%m/%d/%Y', Expiration_Date), safe.parse_date('%Y-%m-%d', Expiration_Date)) as expiration_date,
    coalesce(safe.parse_date('%m/%d/%Y', Job_Start_Date), safe.parse_date('%Y-%m-%d', Job_Start_Date)) as job_start_date

from {{ source('raw_dob', 'permit_issuance') }}
where BOROUGH is not null
  and Block is not null
  and Lot is not null

{% if is_incremental() %}
  -- Only process rows newer than what we already have
  and coalesce(
    safe.parse_date('%m/%d/%Y', Filing_Date),
    safe.parse_date('%Y-%m-%d', Filing_Date)
  ) > (select max(filing_date) from {{ this }})
{% endif %}
