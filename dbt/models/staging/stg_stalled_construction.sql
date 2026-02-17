/*
    Staging model for NYC DOB Stalled Construction Sites.
    Uses BUILDING dataset for BIN → BBL mapping.
*/

with bin_to_bbl as (
    select distinct
        BIN as bin,
        -- Map_Pluto_BBL is 10 digits: boro(1) + block(5) + lot(4)
        -- Convert to 11 digits: boro(1) + block(5) + lot(5) to match PLUTO
        concat(
            substr(Map_Pluto_BBL, 1, 6),
            lpad(substr(Map_Pluto_BBL, 7), 5, '0')
        ) as bbl_key
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
