% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{monterey_roads_sf}
\alias{monterey_roads_sf}
\title{Road Data Around Monterey Bay}
\format{
An `sf` object with LINESTRING geometry.
}
\source{
https://www2.census.gov/geo/tiger/TIGER2015/PRISECROADS/tl_2015_06_prisecroads.zip
}
\usage{
monterey_roads_sf
}
\description{
This dataset is an `sf` object containing line data from the U.S. Department of Commerce
with selected roads, TIGER/Line Shapefile, 2015,  state, California, Primary and Secondary 
Roads State-based Shapefile. This data has been trimmed to only include 330 features in the extent of
the `montereybay` dataset.
}
\examples{
# This is the full code (commented out) used to generate this dataset from the original data:
#counties = sf::st_read("tl_2015_06_prisecroads.shp")
#monterey_roads_sf = sf::st_crop(counties, attr(montereybay,"extent"))
}
\keyword{datasets}
