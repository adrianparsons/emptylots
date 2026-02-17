/*
    Deduplicated stalled construction sites.
    One row per complaint + BIN — the raw data has daily snapshots.
    A single complaint can span multiple BINs (buildings).
*/

select
    bin,
    borough,
    house_number,
    street_name,
    complaint_number,
    bbl_key,
    min(complaint_received_at) as complaint_received_at,
    max(dob_run_date) as last_reported_at
from {{ ref('stg_stalled_construction') }}
group by bin, borough, house_number, street_name, complaint_number, bbl_key
