% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/render_snapshot_software.R
\name{render_snapshot_software}
\alias{render_snapshot_software}
\title{Render High Quality}
\usage{
render_snapshot_software(
  filename,
  cache_filename = NULL,
  camera_location = NULL,
  camera_lookat = c(0, 0, 0),
  background = NULL,
  return_all = FALSE,
  width = NULL,
  height = NULL,
  light_direction = NULL,
  fake_shadow = TRUE,
  text_angle = NULL,
  text_size = 1,
  text_offset = c(0, 0, 0),
  fov = NULL,
  print_scene_info = FALSE,
  point_radius = 1,
  line_offset = -1e-07,
  fsaa = 1,
  ...
)
}
\arguments{
\item{cache_filename}{Name of temporary filename to store OBJ file, if the user does not want to rewrite the file each time.}

\item{camera_location}{Default `NULL`. Custom position of the camera. The `FOV`, `width`, and `height` arguments will still
be derived from the rgl window.}

\item{...}{Additional parameters to pass to `rayvertex::rasterize_scene`()}

\item{ground_size}{Default `10000`. The width of the plane representing the ground.}
}
\description{
Render High Quality
}
\keyword{internal}
