with combined as (
    {{ dbt_utils.union_relations(
        relations=[
            source('raw_pluto', 'pluto_18v2_1'),
            source('raw_pluto', 'pluto_19v2'),
            source('raw_pluto', 'pluto_20v8'),
            source('raw_pluto', 'pluto_21v3'),
            source('raw_pluto', 'pluto_22v3'),
            source('raw_pluto', 'pluto_23v3_1'),
            source('raw_pluto', 'pluto_24v4_1'),
            source('raw_pluto', 'pluto_25v4'),
            source('raw_pluto', 'pluto_26v1'),
        ],
        source_column_name=none
    ) }}
)

select
    -- Identifiers
    borough,
    safe_cast(block as int64)    as block,
    safe_cast(lot as int64)      as lot,
    safe_cast(bbl as float64)    as bbl,
    safe_cast(borocode as int64) as borocode,

    -- Administrative districts
    safe_cast(cd as int64)                   as cd,
    ct2010,
    cb2010,
    schooldist,
    safe_cast(council as int64)              as council,
    zipcode,
    firecomp,
    safe_cast(policeprct as int64)           as policeprct,
    safe_cast(healtharea as int64)           as healtharea,
    safe_cast(sanitboro as int64)            as sanitboro,
    sanitsub,
    safe_cast(sanitdistrict as int64)        as sanitdistrict,
    safe_cast(healthcenterdistrict as int64) as healthcenterdistrict,

    -- Address and location
    address,
    safe_cast(latitude as float64)  as latitude,
    safe_cast(longitude as float64) as longitude,
    safe_cast(xcoord as int64)      as xcoord,
    safe_cast(ycoord as int64)      as ycoord,

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
    spdist1,
    spdist2,
    spdist3,

    -- Building and land use
    bldgclass,
    landuse,
    ownertype,
    ownername,

    -- Areas and measurements
    safe_cast(lotarea as float64)   as lotarea,
    safe_cast(bldgarea as float64)  as bldgarea,
    safe_cast(comarea as int64)     as comarea,
    safe_cast(resarea as int64)     as resarea,
    safe_cast(officearea as int64)  as officearea,
    safe_cast(retailarea as int64)  as retailarea,
    safe_cast(garagearea as int64)  as garagearea,
    safe_cast(strgearea as int64)   as strgearea,
    safe_cast(factryarea as int64)  as factryarea,
    safe_cast(otherarea as int64)   as otherarea,
    areasource,

    -- Building details
    safe_cast(numbldgs as int64)    as numbldgs,
    safe_cast(numfloors as float64) as numfloors,
    safe_cast(unitsres as int64)    as unitsres,
    safe_cast(unitstotal as int64)  as unitstotal,
    safe_cast(lotfront as float64)  as lotfront,
    safe_cast(lotdepth as float64)  as lotdepth,
    safe_cast(bldgfront as float64) as bldgfront,
    safe_cast(bldgdepth as float64) as bldgdepth,
    ext,
    proxcode,
    irrlotcode,
    lottype,
    bsmtcode,
    tract2010,

    -- Assessment and valuation
    safe_cast(assessland as float64) as assessland,
    safe_cast(assesstot as float64)  as assesstot,
    safe_cast(exempttot as float64)  as exempttot,

    -- Dates and history
    safe_cast(yearbuilt as int64)  as yearbuilt,
    safe_cast(yearalter1 as int64) as yearalter1,
    safe_cast(yearalter2 as int64) as yearalter2,
    appdate,

    -- Historic and landmark
    histdist,
    landmark,

    -- FAR (Floor Area Ratio)
    safe_cast(builtfar as float64) as builtfar,
    safe_cast(residfar as float64) as residfar,
    safe_cast(commfar as float64)  as commfar,
    safe_cast(facilfar as float64) as facilfar,

    -- Additional identifiers
    safe_cast(easements as int64)  as easements,

    -- Maps and references
    taxmap,
    edesignum,
    safe_cast(appbbl as float64)   as appbbl,
    safe_cast(plutomapid as int64) as plutomapid,
    sanborn,

    -- Flags
    firm07_flag,
    pfirm15_flag,
    dcpedited,

    -- Metadata
    version

from combined
where address is not null
