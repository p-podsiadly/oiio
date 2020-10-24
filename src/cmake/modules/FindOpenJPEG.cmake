# Module to find OpenJPEG.
#
# This module will first look into the directories defined by the variables:
#   - OpenJPEG_ROOT
#
# This module defines the following variables:
#
# OpenJPEG_INCLUDES    - where to find openjpeg.h
# OpenJPEG_LIBRARIES   - list of libraries to link against when using OpenJPEG.
# OpenJPEG_FOUND       - True if OpenJPEG was found.
# OpenJPEG_VERSION     - Set to the OpenJPEG version found
include (FindPackageHandleStandardArgs)
include (FindPackageMessage)
include (SelectLibraryConfigurations)

macro (PREFIX_FIND_INCLUDE_DIR prefix includefile libpath_var)
  string (TOUPPER ${prefix}_INCLUDE_DIR tmp_varname)
  find_path(${tmp_varname} ${includefile}
    PATHS ${${libpath_var}}
    NO_DEFAULT_PATH
  )
  if (${tmp_varname})
    mark_as_advanced (${tmp_varname})
  endif ()
  unset (tmp_varname)
endmacro ()


macro (PREFIX_FIND_LIB prefix libname libpath_var liblist_var cachelist_var)
  string (TOUPPER ${prefix}_${libname} tmp_prefix)
  find_library(${tmp_prefix}_LIBRARY_RELEASE
    NAMES ${libname}
    PATHS ${${libpath_var}}
    NO_DEFAULT_PATH
  )
  find_library(${tmp_prefix}_LIBRARY_DEBUG
    NAMES ${libname}d ${libname}_d ${libname}debug ${libname}_debug
    PATHS ${${libpath_var}}
    NO_DEFAULT_PATH
  )
  # Properly define ${tmp_prefix}_LIBRARY (cached) and ${tmp_prefix}_LIBRARIES
  select_library_configurations (${tmp_prefix})
  list (APPEND ${liblist_var} ${tmp_prefix}_LIBRARIES)

  # Add to the list of variables which should be reset
  list (APPEND ${cachelist_var}
    ${tmp_prefix}_LIBRARY
    ${tmp_prefix}_LIBRARY_RELEASE
    ${tmp_prefix}_LIBRARY_DEBUG)
  mark_as_advanced (
    ${tmp_prefix}_LIBRARY
    ${tmp_prefix}_LIBRARY_RELEASE
    ${tmp_prefix}_LIBRARY_DEBUG)
  unset (tmp_prefix)
endmacro ()

# Generic search paths
set (OpenJPEG_include_paths
     /usr/local/include/openjpeg-2.3
     /usr/local/include/openjpeg-2.2
     /usr/local/include/openjpeg-2.1
     /usr/local/include/openjpeg-2.0
     /usr/local/include/openjpeg
     /usr/local/include
     /usr/include/openjpeg-2.3
     /usr/include/openjpeg-2.2
     /usr/include/openjpeg-2.1
     /usr/include/openjpeg
     /usr/include
     /opt/local/include
     /opt/local/include/openjpeg-2.3
     /opt/local/include/openjpeg-2.2
     /opt/local/include/openjpeg-2.1
     /opt/local/include/openjpeg-2.0)

set (OpenJPEG_library_paths
  /usr/lib
  /usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}
  /usr/local/lib
  /sw/lib
  /opt/local/lib)

if (OpenJPEG_ROOT)
  set (OpenJPEG_library_paths
       ${OpenJPEG_ROOT}/lib
       ${OpenJPEG_ROOT}/lib64
       ${OpenJPEG_ROOT}/bin
       ${OpenJPEG_library_paths}
      )
  set (OpenJPEG_include_paths
       ${OpenJPEG_ROOT}/include/openjpeg-2.3
       ${OpenJPEG_ROOT}/include/openjpeg-2.2
       ${OpenJPEG_ROOT}/include/openjpeg-2.1
       ${OpenJPEG_ROOT}/include/openjpeg-2.0
       ${OpenJPEG_ROOT}/include/openjpeg
       ${OpenJPEG_ROOT}/include
       ${OpenJPEG_include_paths}
      )
endif()


# Locate the header files
PREFIX_FIND_INCLUDE_DIR (OpenJPEG openjpeg.h OpenJPEG_include_paths)

# If the headers were found, add its parent to the list of lib directories
if (OpenJPEG_INCLUDE_DIR)
  get_filename_component (tmp_extra_dir "${OpenJPEG_INCLUDE_DIR}/../" ABSOLUTE)
  list (APPEND OpenJPEG_library_paths ${tmp_extra_dir})
  unset (tmp_extra_dir)
endif ()

# Search for opj_config.h -- it is only part of OpenJPEG >= 2.0, and will
# contain symbols OPJ_VERSION_MAJOR and OPJ_VERSION_MINOR. If the file
# doesn't exist, we're dealing with OpenJPEG 1.x.
# Note that for OpenJPEG 2.x, the library is named libopenjp2, not
# libopenjpeg (which is for 1.x)
set (OpenJPEG_CONFIG_FILE "${OpenJPEG_INCLUDE_DIR}/opj_config.h")
if (EXISTS "${OpenJPEG_CONFIG_FILE}")
    file(STRINGS "${OpenJPEG_CONFIG_FILE}" TMP REGEX "^#define OPJ_PACKAGE_VERSION .*$")
    if (TMP)
        # 2.0 is the only one with this construct
        set (OPJ_VERSION_MAJOR 2)
        set (OPJ_VERSION_MINOR 0)
    else ()
        # 2.1 and beyond
        file(STRINGS "${OpenJPEG_CONFIG_FILE}" TMP REGEX "^#define OPJ_VERSION_MAJOR .*$")
        string (REGEX MATCHALL "[0-9]+" OPJ_VERSION_MAJOR ${TMP})
        file(STRINGS "${OpenJPEG_CONFIG_FILE}" TMP REGEX "^#define OPJ_VERSION_MINOR .*$")
        string (REGEX MATCHALL "[0-9]+" OPJ_VERSION_MINOR ${TMP})
    endif ()
else ()
    # Guess OpenJPEG 1.5 -- older versions didn't have the version readily
    # apparent in the headers.
    set (OPJ_VERSION_MAJOR 1)
    set (OPJ_VERSION_MINOR 5)
endif ()
set (OpenJPEG_VERSION "${OPJ_VERSION_MAJOR}.${OPJ_VERSION_MINOR}")


# Locate the OpenJPEG library
set (OpenJPEG_libvars "")
set (OpenJPEG_cachevars "")
if ("${OpenJPEG_VERSION}" VERSION_LESS 2.0)
    PREFIX_FIND_LIB (OpenJPEG openjpeg
      OpenJPEG_library_paths OpenJPEG_libvars OpenJPEG_cachevars)
else ()
    PREFIX_FIND_LIB (OpenJPEG openjp2
      OpenJPEG_library_paths OpenJPEG_libvars OpenJPEG_cachevars)
endif ()

# Use the standard function to handle OpenJPEG_FOUND
FIND_PACKAGE_HANDLE_STANDARD_ARGS (OpenJPEG
  VERSION_VAR OpenJPEG_VERSION
  REQUIRED_VARS OpenJPEG_INCLUDE_DIR ${OpenJPEG_libvars})

if (OpenJPEG_FOUND)
  set (OpenJPEG_INCLUDES ${OpenJPEG_INCLUDE_DIR})
  set (OpenJPEG_LIBRARIES "")
  foreach (tmplib ${OpenJPEG_libvars})
    list (APPEND OpenJPEG_LIBRARIES ${${tmplib}})
  endforeach ()
  if (NOT OpenJPEG_FIND_QUIETLY)
    FIND_PACKAGE_MESSAGE (OPENJPEG
      "Found OpenJPEG: v${OpenJPEG_VERSION} ${OpenJPEG_LIBRARIES}"
      "[${OpenJPEG_INCLUDE_DIR}][${OpenJPEG_LIBRARIES}]"
      )
  endif ()

  #############################
  # OpenJPEG::OpenJPEG target #
  #############################

  if (NOT TARGET OpenJPEG::OpenJPEG)
    add_library (OpenJPEG::OpenJPEG INTERFACE IMPORTED GLOBAL)
    set_target_properties (
      OpenJPEG::OpenJPEG
      INTERFACE_INCLUDE_DIRECTORIES "${OpenJPEG_INCLUDE_DIR}"
      INTERFACE_LINK_LIBRARIES "${OpenJPEG_LIBRARIES}"
    )
  endif ()

endif ()

unset (OpenJPEG_include_paths)
unset (OpenJPEG_library_paths)
unset (OpenJPEG_libvars)
unset (OpenJPEG_cachevars)
