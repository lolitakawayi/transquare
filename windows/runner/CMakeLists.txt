# Configuration for the "runner" target.
cmake_minimum_required(VERSION 3.14)

project(runner LANGUAGES CXX)

set(BINARY_NAME "transquare")

cmake_policy(VERSION 3.14...3.25)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/scripts")

add_executable(${BINARY_NAME} WIN32
  flutter_window.cpp
  flutter_window.h
  main.cpp
  platform_service.cpp
  platform_service.h
  resource.h
  runner.exe.manifest
  utils.cpp
  utils.h
  win32_window.cpp
  win32_window.h
  "${CMAKE_CURRENT_SOURCE_DIR}/Runner.rc"
  "${CMAKE_CURRENT_SOURCE_DIR}/../flutter/generated_plugin_registrant.cc"
)

apply_standard_settings(${BINARY_NAME})

# Force UTF-8 source encoding to prevent C4819 warnings with MSVC
target_compile_options(${BINARY_NAME} PRIVATE /utf-8)

set_target_properties(${BINARY_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner"
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../flutter/ephemeral")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../flutter/ephemeral/cpp_client_wrapper/include")

target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  flutter_wrapper_app
  dwmapi
  version
  wininet
  user32
  gdi32
  comctl32
  ole32
)

add_dependencies(${BINARY_NAME} flutter_assemble)

set_property(TARGET ${BINARY_NAME} PROPERTY
  MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

target_compile_options(${BINARY_NAME} PRIVATE /GR- /GS /guard:cf)

set_target_properties(${BINARY_NAME} PROPERTIES
  WIN32_EXECUTABLE TRUE
)