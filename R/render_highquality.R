#'@title Render High Quality
#'
#'@description Renders a raytraced version of the displayed rgl scene, using the `rayrender` package. 
#'User can specify the light direction, intensity, and color, as well as specify the material of the 
#'ground and add additional scene elements.
#'
#'Note: This version does not yet support meshes with missing entries (e.g. if any NA values are present,
#'output will be unpredictable).
#'
#'@param filename Filename of saved image. If missing, will display to current device.
#'@param light Default `TRUE`. Whether there should be a light in the scene. If not, the scene will be lit with a bluish sky.
#'@param lightdirection Default `315`. Position of the light angle around the scene. 
#'If this is a vector longer than one, multiple lights will be generated (using values from 
#'`lightangle`, `lightintensity`, and `lightcolor`)
#'@param lightangle Default `45`. Position above the horizon that the light is located. 
#'If this is a vector longer than one, multiple lights will be generated (using values from 
#'`lightdirection`, `lightintensity`, and `lightcolor`)
#'@param lightsize Default `NULL`. Radius of the light(s). Automatically chosen, but can be set here by the user.
#'@param lightintensity Default `500`. Intensity of the light.
#'@param lightcolor Default `white`. The color of the light.
#'@param cache_filename Name of temporary filename to store OBJ file, if the user does not want to rewrite the file each time.
#'@param width Defaults to the width of the rgl window. Width of the rendering. 
#'@param height Defaults to the height of the rgl window. Height of the rendering. 
#'@param ground_material Default `diffuse()`. Material defined by the rayrender material functions.
#'@param offset_camera Default `NULL`. Offset position of the camera.
#'@param offset_lookat Default `NULL`. Offset position at which the camera is directed.
#'@param scene_elements Default `NULL`. Extra scene elements to add to the scene, created with rayrender.
#'@param ... Additional parameters to pass to rayrender::render_scene()
#'@import rayrender
#'@export
#'@examples
#'\dontrun{
#'volcano %>%
#'  sphere_shade() %>%
#'  plot_3d(volcano,zscale = 2)
#'render_highquality()
#'}
render_highquality = function(filename = NULL, light = TRUE, lightdirection = 315, lightangle = 45, lightsize=NULL,
                              lightintensity = 500, lightcolor = "white", 
                              cache_filename=NULL, width = NULL, height = NULL, 
                              ground_material = diffuse(), scene_elements=NULL, 
                              offset_camera = c(0,0,0), offset_lookat = c(0,0,0), ...) {
  windowrect = rgl::par3d()$windowRect
  if(is.null(width)) {
    width = windowrect[3]-windowrect[1]
  }
  if(is.null(height)) {
    height = windowrect[4]-windowrect[2]
  }
  no_cache = FALSE
  if(is.null(cache_filename)) {
    no_cache = TRUE
    cache_filename = paste0(tempdir(), .Platform$file.sep, "temprayfile.obj")
  }
  shadowid = get_ids_with_labels(typeval = "shadow")
  if(nrow(shadowid) > 0) {
    shadowvertices = rgl.attrib(shadowid$id[1], "vertices")
    shadowdepth = shadowvertices[1,2]
    has_shadow = TRUE
  } else {
    has_shadow = FALSE
  }
  fov = rgl::par3d()$FOV
  rotmat = rot_to_euler(rgl::par3d()$userMatrix)
  projmat = rgl::par3d()$projMatrix
  zoom = rgl::par3d()$zoom
  phi = rotmat[1]
  if(0.001 > abs(abs(rotmat[3]) - 180)) {
    theta = -rotmat[2] + 180
    movevec = rgl::rotationMatrix(-rotmat[2]*pi/180, 0, 1, 0) %*%
      rgl::rotationMatrix(-rotmat[1]*pi/180, 1, 0, 0) %*% 
      rgl::par3d()$userMatrix[,4]
  } else {
    theta = rotmat[2]
    movevec = rgl::rotationMatrix(rotmat[3]*pi/180, 0, 0, 1) %*%
      rgl::rotationMatrix(-rotmat[2]*pi/180, 0, 1, 0) %*%
      rgl::rotationMatrix(-rotmat[1]*pi/180, 1, 0, 0) %*% 
      rgl::par3d()$userMatrix[,4]
  }
  movevec = movevec[1:3]
  observer_radius = rgl::par3d()$observer[3]
  lookvals = rgl::par3d()$bbox
  if(fov == 0) {
    ortho_dimensions = c(2/projmat[1,1],2/projmat[2,2])
  } else {
    fov = 2 * atan(1/projmat[2,2]) * 180/pi
    ortho_dimensions = c(1,1)
  }
  bbox_center = c(mean(lookvals[1:2]),mean(lookvals[3:4]),mean(lookvals[5:6])) - movevec
  observery = sinpi(phi/180) * observer_radius
  observerx = cospi(phi/180) * sinpi(theta/180) * observer_radius 
  observerz = cospi(phi/180) * cospi(theta/180) * observer_radius 
  lookfrom = c(observerx,observery,observerz) + offset_camera
  if(substring(cache_filename, nchar(cache_filename)-3,nchar(cache_filename)) != ".obj") {
    cache_filename = paste0(cache_filename,".obj")
  }
  if(no_cache || !file.exists(cache_filename)) {
    save_obj(cache_filename)
  }
  scene = obj_model(cache_filename, x=-bbox_center[1],y = -bbox_center[2],z=-bbox_center[3], texture=TRUE)
  if(has_shadow) {
    scene = add_object(scene, xz_rect(zwidth=100000,xwidth=100000,y=shadowdepth-bbox_center[2], material = ground_material))
  }
  if(light) {
    if(is.null(lightsize)) {
      lightsize = observer_radius/5
    }
    if(length(lightangle) >= 1 || length(lightdirection) >= 1) {
      if(length(lightangle) > 1 && length(lightdirection) > 1 && length(lightdirection) != length(lightangle)) {
        stop("lightangle vector ", lightangle, " and lightdirection vector ", lightdirection, "both greater than length 1 but not equal length" )
      }
      numberlights = ifelse(length(lightangle) > length(lightdirection), length(lightangle),length(lightdirection))
      lightangletemp = lightangle[1]
      lightdirectiontemp = lightdirection[1]
      lightintensitytemp = lightintensity[1]
      lightcolortemp = lightcolor[1]
      lightsizetemp = lightsize[1]
      for(i in seq_len(numberlights)) {
        if(!is.na(lightangle[i])) {
          lightangletemp = lightangle[i]
        }
        if(!is.na(lightdirection[i])) {
          lightdirectiontemp = lightdirection[i]
        }
        if(!is.na(lightintensity[i])) {
          lightintensitytemp = lightintensity[i]
        }
        if(!is.na(lightcolor[i])) {
          lightcolortemp = lightcolor[i]
        }
        if(!is.na(lightsize[i])) {
          lightsizetemp = lightsize[i]
        }
        scene = add_object(scene, sphere(x=observer_radius*5 * cospi(lightangletemp/180) * sinpi(lightdirectiontemp/180),
                                         y=observer_radius*5 * sinpi(lightangletemp/180),
                                         z=-observer_radius*5 * cospi(lightangletemp/180) * cospi(lightdirectiontemp/180), radius=lightsizetemp,
                                         material = diffuse(color = lightcolortemp, lightintensity = lightintensitytemp, implicit_sample=TRUE)))
      }
    }
  }
  if(!is.null(scene_elements)) {
    scene = add_object(scene,scene_elements)
  }
  render_scene(scene, lookfrom = lookfrom, lookat = offset_lookat, fov = fov, filename=filename,
              ortho_dimensions = ortho_dimensions, width = width, height = height, ...)
}