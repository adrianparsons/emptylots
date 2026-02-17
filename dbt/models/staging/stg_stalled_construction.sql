/*
    Staging model for NYC DOB Stalled Construction Sites.
    Uses BUILDING dataset for BIN → BBL mapping.
*/

with bin_to_bbl as (
    select distinct
        BIN as bin,
        {{ bbl_key_from_pluto_bbl('Map_Pluto_BBL') }} as bbl_key
    from {{ source('raw_dob', 'building') }}
    where BIN is not null
      and Map_Pluto_BBL is not null
),

stalled as (
    select
        BIN as bin,
        Borough_Name as borough,
        House_Number as house_number,
        Street_Name as street_name,
        Complaint_Number as complaint_number,
        safe.parse_timestamp('%Y %b %d %I:%M:%S %p', Date_Complaint_Received) as complaint_received_at,
        safe.parse_timestamp('%Y %b %d %I:%M:%S %p', DOBRunDate) as dob_run_date
    from {{ source('raw_dob', 'stalled_construction') }}
    where BIN is not null
)

select
    s.*,
    b.bbl_key
from stalled s
left join bin_to_bbl b
    on s.bin = b.bin
