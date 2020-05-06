
<!-- README.md is generated from README.Rmd. Please edit that file -->

# aarapir

Access ArcGIS online API enpoints with R

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/aarapir)](https://cran.r-project.org/package=aarapir)
[![R build
status](https://github.com/mps9506/aarapir/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/aarapir/actions)
<!-- badges: end -->

aarapir provides an R interface for querying and downloading publically
accessible ArcGIS Online feature layers. The primary goal is to provide
R users with an easy way to download features from ArcMap Online. I
don’t not anticipate this to be a full-fledged API to ArcGIS Online
and Enterprise. See the [ArcGIS Python
API](https://github.com/Esri/arcgis-python-api) for a more robust access
to the ArcGIS API. This is super experimental and likely to change. This
project is not associated with or supported by ESRI.

## Features

  - [x] Return mapservice information

  - [x] Return feature layer information

  - [x] Return full feature layers (will loop requests if the maximum
    number of records is limited)

  - [x] Pass user query so only needed records are returned

  - [ ] Return image service information

  - [ ] Provide interface for image or tile data

## Example

Download a point feature layer:

``` r
library(aarapir)
## Start with a mapserver url, these typically end in "/MapServer"
## Some examples here: https://sampleserver6.arcgisonline.com/arcgis/rest/services

url <- "https://sampleserver6.arcgisonline.com/arcgis/rest/services/WindTurbines/MapServer"

## This returns a list with information from the Map Service
webserver <- service_info(url)

## We can see what feature layers are available to download
webserver$layers
#>   id               name parentLayerId defaultVisibility subLayerIds minScale
#> 1  0 TurbineInspections            -1              TRUE          NA        0
#>   maxScale          type      geometryType
#> 1        0 Feature Layer esriGeometryPoint

## This returns a list with information about the feature layer
## id 0
layerinfo <- layer_info(webserver, 0)

## This downloads the entire feature layer and reads it into a
## simple feature dataframe
dat <- layer_download(layerinfo)
#> Number of target records:  11
dat
#> Simple feature collection with 11 features and 6 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: -116.6811 ymin: 33.85035 xmax: -116.533 ymax: 33.91881
#> epsg (SRID):    4326
#> proj4string:    +proj=longlat +datum=WGS84 +no_defs
#> First 10 features:
#>    objectid status dateinspected notes photo
#> 1         2     NA  1.295451e+12  test  <NA>
#> 2         6      1 -2.209162e+12        <NA>
#> 3        12     NA            NA  <NA>  <NA>
#> 4        13     NA            NA  <NA>  <NA>
#> 5        14     NA            NA  <NA>  <NA>
#> 6        17     NA            NA        <NA>
#> 7        18     NA            NA        <NA>
#> 8        19     NA            NA        <NA>
#> 9        20     NA            NA        <NA>
#> 10       21     NA            NA        <NA>
#>                                  globalid                   geometry
#> 1  {E41FAF3C-BB03-445F-8E6A-12227C7EC007} POINT (-116.6155 33.86019)
#> 2  {DF9403DA-C08D-4C5C-A505-77A761F296D9}  POINT (-116.533 33.85035)
#> 3  {3EA788B3-32D8-4B1D-8CBC-D1E5757A50DC} POINT (-116.6173 33.91881)
#> 4  {FB929FD4-D75D-419D-B5B9-BDF371F0C34A} POINT (-116.6671 33.87114)
#> 5  {736F24BE-0A10-4779-BD66-71643191087B} POINT (-116.6811 33.91881)
#> 6  {9C4CE3DB-9B5F-4BE6-84E8-3949DF5DA6A4} POINT (-116.5993 33.91736)
#> 7  {CEE9E968-58A5-41D2-BF28-6B14E3997352} POINT (-116.5501 33.91302)
#> 8  {897F8DEF-8C3B-4CB2-88DE-8EA1EF9CD01D} POINT (-116.5407 33.88782)
#> 9  {D4F83D52-C26B-4BEF-A215-D4793B680476} POINT (-116.5773 33.85306)
#> 10 {4FAEBC0C-5060-49D5-B284-54B2F58C2A14} POINT (-116.5846 33.88956)


## If you want to return only objects from a query:
dat <- layer_download(layerinfo, query = "notes = 'test'")
#> Number of target records:  1
## note query support might vary by server, but generally standard query functions
## work. more info: https://gisweb.tceq.texas.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/
## enter the query in quoted plain text, the function will do the proper URI encoding
dat
#> Simple feature collection with 1 feature and 6 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: -116.6155 ymin: 33.86019 xmax: -116.6155 ymax: 33.86019
#> epsg (SRID):    4326
#> proj4string:    +proj=longlat +datum=WGS84 +no_defs
#>   objectid status dateinspected notes photo
#> 1        2   <NA>  1.295451e+12  test  <NA>
#>                                 globalid                   geometry
#> 1 {E41FAF3C-BB03-445F-8E6A-12227C7EC007} POINT (-116.6155 33.86019)
```

## experimental

Downloading mosaiced images works. I’m having difficulty finding maps
that allow downloading source rasters even though it is supported by the
API. This is definately going to change.

``` r
url <- "https://landsat2.arcgis.com/arcgis/rest/services/Landsat8_Views/ImageServer"
webserver <- service_info(url)
r1 <- image_download(webserver,
                     size = "800,500",)
r1
#> class      : RasterBrick 
#> dimensions : 500, 800, 4e+05, 11  (nrow, ncol, ncell, nlayers)
#> resolution : 50093.77, 50093.77  (x, y)
#> extent     : -20037507, 20037508, -12524893, 12521991  (xmin, xmax, ymin, ymax)
#> crs        : +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs 
#> source     : C:/Users/michael.schramm/AppData/Local/Temp/RtmpILzp8W/ras12c456bc427c.tiff 
#> names      : ras12c456bc427c.1, ras12c456bc427c.2, ras12c456bc427c.3, ras12c456bc427c.4, ras12c456bc427c.5, ras12c456bc427c.6, ras12c456bc427c.7, ras12c456bc427c.8, ras12c456bc427c.9, ras12c456bc427c.10, ras12c456bc427c.11 
#> min values :            -32768,            -32768,            -32768,            -32768,            -32768,            -32768,            -32768,            -32768,            -32768,             -32768,             -32768 
#> max values :             32767,             32767,             32767,             32767,             32767,             32767,             32767,             32767,             32767,              32767,              32767
raster::plotRGB(r1, r = 4, g = 3, b = 2, stretch = "lin",
                bgalpha = 0)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
