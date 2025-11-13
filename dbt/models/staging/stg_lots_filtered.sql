select
    -- Identifiers
    borough,
    block,
    lot,
    bbl,
    borocode,

    -- Administrative districts
    cd,
    ct2010,
    cb2010,
    schooldist,
    council,
    zipcode,
    firecomp,
    policeprct,
    healtharea,
    sanitboro,
    sanitsub,
    sanitdistrict,
    healthcenterdistrict,

    -- Address and location
    address,
    latitude,
    longitude,
    xcoord,
    ycoord,

    -- Zoning
    zonedist1,
    zonedist2,
    zonedist3,
    zonedist4,
    overlay1,
    overlay2,
    ltdheight,
    splitzone,
    zonemap,
    zmcode,

    -- Building and land use
    bldgclass,
    landuse,
    ownertype,
    ownername,

    -- Areas and measurements
    lotarea,
    bldgarea,
    comarea,
    resarea,
    officearea,
    retailarea,
    garagearea,
    strgearea,
    factryarea,
    otherarea,
    areasource,

    -- Building details
    numbldgs,
    numfloors,
    unitsres,
    unitstotal,
    lotfront,
    lotdepth,
    bldgfront,
    bldgdepth,

    -- Assessment and valuation
    assessland,
    assesstot,
    exempttot,

    -- Dates and history
    yearbuilt,
    yearalter1,
    yearalter2,
    appdate,

    -- Historic and landmark
    histdist,
    landmark,

    -- FAR (Floor Area Ratio)
    builtfar,
    residfar,
    commfar,
    facilfar,

    -- Additional identifiers
    easements,

    -- Maps and references
    taxmap,
    edesignum,
    appbbl,
    plutomapid,

    -- Metadata
    version

from {{ ref('stg_lots') }}
