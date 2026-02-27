# SPIRV-Cross (https://github.com/KhronosGroup/SPIRV-Cross)
# License: Apache-2.0
if(TARGET SPRIV-Cross::SPRIV-Cross)
    return()
endif()

message(STATUS "External: creating target 'SPRIV-Cross::SPRIV-Cross'")

# Read Git commit hash from ExternalRevisions file
file(READ "${MOLTEN_VK_EXTERNAL_REVISIONS_DIR}/SPIRV-Cross_repo_revision" SPIRV_CROSS_COMMIT_HASH)
string(STRIP "${SPIRV_CROSS_COMMIT_HASH}" SPIRV_CROSS_COMMIT_HASH)
set(SPIRV_CROSS_FALLBACK_GITHUB_REPOSITORY "KhronosGroup/SPIRV-Cross" CACHE STRING
	"GitHub repository used when vendored SPIRV-Cross is unavailable.")

include(CPM)
set(SPIRV_CROSS_LOCAL_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../External/SPIRV-Cross")
if(EXISTS "${SPIRV_CROSS_LOCAL_SOURCE_DIR}/CMakeLists.txt")
  message(STATUS "External: using vendored SPIRV-Cross source at '${SPIRV_CROSS_LOCAL_SOURCE_DIR}'")
  CPMAddPackage(
    NAME SPIRV-Cross
    SOURCE_DIR "${SPIRV_CROSS_LOCAL_SOURCE_DIR}"
    SYSTEM TRUE
    OPTIONS
      "SPIRV_CROSS_CLI OFF"
      "SPIRV_CROSS_ENABLE_TESTS OFF"
      "SPIRV_CROSS_ENABLE_GLSL ON"
      "SPIRV_CROSS_ENABLE_HLSL OFF"
      "SPIRV_CROSS_ENABLE_MSL ON"
      "SPIRV_CROSS_ENABLE_CPP OFF"
      "SPIRV_CROSS_ENABLE_REFLECT ON"
      "SPIRV_CROSS_ENABLE_C_API OFF"
      "SPIRV_CROSS_ENABLE_UTIL OFF"
      "SPIRV_CROSS_NAMESPACE_OVERRIDE MVK_spirv_cross"
      "SPIRV_CROSS_SKIP_INSTALL ON"
  )
else()
  message(STATUS "External: fetching SPIRV-Cross from '${SPIRV_CROSS_FALLBACK_GITHUB_REPOSITORY}' at '${SPIRV_CROSS_COMMIT_HASH}'")
  CPMAddPackage(
    NAME SPIRV-Cross
    GITHUB_REPOSITORY ${SPIRV_CROSS_FALLBACK_GITHUB_REPOSITORY}
    GIT_TAG ${SPIRV_CROSS_COMMIT_HASH}
    SYSTEM TRUE
    OPTIONS
      "SPIRV_CROSS_CLI OFF"
      "SPIRV_CROSS_ENABLE_TESTS OFF"
      "SPIRV_CROSS_ENABLE_GLSL ON"
      "SPIRV_CROSS_ENABLE_HLSL OFF"
      "SPIRV_CROSS_ENABLE_MSL ON"
      "SPIRV_CROSS_ENABLE_CPP OFF"
      "SPIRV_CROSS_ENABLE_REFLECT ON"
      "SPIRV_CROSS_ENABLE_C_API OFF"
      "SPIRV_CROSS_ENABLE_UTIL OFF"
      "SPIRV_CROSS_NAMESPACE_OVERRIDE MVK_spirv_cross"
      "SPIRV_CROSS_SKIP_INSTALL ON"
  )

  # Geometry emulation depends on mesh-pipeline MSL options.
  set(_spvc_msl_header "${SPIRV-Cross_SOURCE_DIR}/spirv_msl.hpp")
  if(NOT EXISTS "${_spvc_msl_header}")
    message(FATAL_ERROR "External: expected SPIRV-Cross header '${_spvc_msl_header}' was not found.")
  endif()

  file(READ "${_spvc_msl_header}" _spvc_msl_header_contents)
  if(NOT _spvc_msl_header_contents MATCHES "for_mesh_pipeline" OR
     NOT _spvc_msl_header_contents MATCHES "draw_info_index")
    message(FATAL_ERROR
      "External: fetched SPIRV-Cross revision '${SPIRV_CROSS_COMMIT_HASH}' from "
      "'${SPIRV_CROSS_FALLBACK_GITHUB_REPOSITORY}', but it is missing required mesh "
      "pipeline MSL options. Use a newer geometry-compatible revision or initialize the "
      "vendored External/SPIRV-Cross submodule.")
  endif()

  unset(_spvc_msl_header_contents)
  unset(_spvc_msl_header)
endif()

add_library(SPRIV-Cross::Core ALIAS spirv-cross-core)
add_library(SPRIV-Cross::Reflect ALIAS spirv-cross-reflect)
add_library(SPRIV-Cross::GLSL ALIAS spirv-cross-glsl)
add_library(SPRIV-Cross::MSL ALIAS spirv-cross-msl)

add_library(SPRIV-Cross INTERFACE)
add_library(SPRIV-Cross::SPRIV-Cross ALIAS SPRIV-Cross)
target_link_libraries(SPRIV-Cross INTERFACE
    spirv-cross-core
    spirv-cross-reflect
    spirv-cross-glsl
    spirv-cross-msl
)
