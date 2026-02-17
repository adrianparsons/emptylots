select
    bbl_key as BBL,
    address as Address,
    ownername as OwnerName,
    cast(borocode as string) as BoroCode,
    cast(block as string) as Block,
    cast(lot as string) as Lot,
    lotarea as LotArea,
    latitude as Latitude,
    longitude as Longitude,
    zonedist1 as ZoneDist1,
    num_permits,
    latest_permit_date,
    years_since_last_permit,
    num_stalled_complaints,
    st_asgeojson(geometry) as geometry
from `empty-lots.${BQ_DATASET}.mart_vacant_lots`
where geometry is not null
