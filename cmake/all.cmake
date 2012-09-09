# XXXX prevent multiple inclusion
if(_CATKIN_ALL_INCLUDED_)
  message(FATAL_ERROR "catkin/cmake/all.cmake included multiple times")
endif()
set(_CATKIN_ALL_INCLUDED_ TRUE)

if(NOT DEFINED catkin_EXTRAS_DIR)
  message(FATAL_ERROR "catkin_EXTRAS_DIR is not set")
endif()

# use either CMAKE_PREFIX_PATH explicitly passed to CMake as a command line argument
# or CMAKE_PREFIX_PATH from the environment
if(NOT DEFINED CMAKE_PREFIX_PATH)
  set(CMAKE_PREFIX_PATH $ENV{CMAKE_PREFIX_PATH})
endif()

# list of unique workspaces based on CATKIN_WORKSPACES and CMAKE_PREFIX_PATH
set(CATKIN_WORKSPACES "")
foreach(workspace $ENV{CATKIN_WORKSPACES})
  list(FIND CATKIN_WORKSPACES ${workspace} _index)
  if(_index EQUAL -1)
    list(APPEND CATKIN_WORKSPACES ${workspace})
  endif()
endforeach()
# ...plus all CMAKE_PREFIX_PATH which are catkin workspaces
# extended with their sourcespace(s) from the CATKIN_WORKSPACE file if not empty
# for the case that setup.sh has not been sourced or CMAKE_PREFIX_PATH is overridden via command line arguments
foreach(path ${CMAKE_PREFIX_PATH})
  if(EXISTS "${path}/CATKIN_WORKSPACE")
    file(READ "${path}/CATKIN_WORKSPACE" sourcespaces)
    if("${sourcespaces}" STREQUAL "")
      list(FIND CATKIN_WORKSPACES ${path} _index)
      if(_index EQUAL -1)
        list(APPEND CATKIN_WORKSPACES ${path})
      endif()
    else()
      foreach(sourcespace ${sourcespaces})
        set(path "${path}:${sourcespace}")
        list(FIND CATKIN_WORKSPACES ${path} _index)
        if(_index EQUAL -1)
          list(APPEND CATKIN_WORKSPACES ${path})
        endif()
      endforeach()
    endif()
  endif()
endforeach()

# prepend all workspaces to the CMAKE_PREFIX_PATH
# for the case that setup.sh has not been sourced
set(workspaces "")
foreach(workspace $ENV{CATKIN_WORKSPACES})
  string(REGEX REPLACE ":.*" "" workspace ${workspace})
  list(INSERT workspaces 0 ${workspace})
endforeach() 
foreach(workspace ${workspaces})
  list(FIND CMAKE_PREFIX_PATH ${workspace} _index)
  if(_index EQUAL -1)
    list(INSERT CMAKE_PREFIX_PATH 0 ${workspace})
  endif()
endforeach()

# define buildspace
set(CATKIN_BUILD_PREFIX "${CMAKE_BINARY_DIR}/buildspace")
# prepend buildspace to CMAKE_PREFIX_PATH
list(INSERT CMAKE_PREFIX_PATH 0 ${CATKIN_BUILD_PREFIX})


# enable all new policies
cmake_policy(SET CMP0000 NEW)
cmake_policy(SET CMP0001 NEW)
cmake_policy(SET CMP0002 NEW)
cmake_policy(SET CMP0003 NEW)
cmake_policy(SET CMP0004 NEW)
cmake_policy(SET CMP0005 NEW)
cmake_policy(SET CMP0006 NEW)
cmake_policy(SET CMP0007 NEW)
cmake_policy(SET CMP0008 NEW)
cmake_policy(SET CMP0009 NEW)
cmake_policy(SET CMP0010 NEW)
cmake_policy(SET CMP0011 NEW)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0013 NEW)
cmake_policy(SET CMP0014 NEW)
cmake_policy(SET CMP0015 NEW)
cmake_policy(SET CMP0016 NEW)
cmake_policy(SET CMP0017 NEW)

# the following operations must be performed inside a project context
if(NOT PROJECT_NAME)
  project(catkin_internal)
endif()

# functions/macros: list_append_unique, safe_execute_process
# python-integration: catkin_python_setup.cmake, interrogate_setup_dot_py.py, templates/__init__.py.in, templates/script.py.in, templates/python_distutils_install.bat.in, templates/python_distutils_install.sh.in, templates/safe_execute_install.cmake.in
foreach(filename
    assert
    catkin_add_env_hooks
    catkin_generate_environment
    catkin_project
    catkin_stack
    catkin_workspace
    debug_message
    em_expand
    python # defines PYTHON_EXECUTABLE, required by empy
    empy
    find_program_required
    list_append_unique
    parse_arguments
    safe_execute_process
    stamp
    platform/lsb
    platform/ubuntu
    platform/windows
    test/download_test_data
    test/gtest
    test/nosetests
    test/tests
    tools/doxygen
    tools/libraries
    tools/rt

#    tools/threads
  )
  include(${catkin_EXTRAS_DIR}/${filename}.cmake)
endforeach()

# undefine CATKIN_ENV since it might be set in the cache from a previous build
set(CATKIN_ENV "" CACHE INTERNAL "catkin environment" FORCE)

# generate environment files like env.* and setup.*
# uses em_expand without CATKIN_ENV being set yet
catkin_generate_environment()

# file extension of env script
if(CMAKE_HOST_UNIX) # true for linux, apple, mingw-cross and cygwin
  set(script_ext sh)
else()
  set(script_ext bat)
endif()
# take snapshot of the modifications the env script causes
# to reproduce the same changes with a static script in a fraction of the time
safe_execute_process(COMMAND ${PYTHON_EXECUTABLE}
  ${catkin_EXTRAS_DIR}/env_caching.py
  ${CATKIN_BUILD_PREFIX}/env.${script_ext}
  --python ${PYTHON_EXECUTABLE}
  OUTPUT_VARIABLE SCRIPT)
configure_file(${catkin_EXTRAS_DIR}/templates/script.in
  ${CMAKE_CURRENT_BINARY_DIR}/catkin_generated/env_cached.${script_ext}
  @ONLY)
# environment to call external processes
set(CATKIN_ENV ${CMAKE_CURRENT_BINARY_DIR}/catkin_generated/env_cached.${script_ext} CACHE INTERNAL "catkin environment")

# add additional environment hooks
if(CATKIN_BUILD_BINARY_PACKAGE AND NOT "${PROJECT_NAME}" STREQUAL "catkin")
  set(catkin_skip_install_env_hooks "SKIP_INSTALL")
endif()
catkin_add_env_hooks(05.catkin-test-results SHELLS bat sh DIRECTORY ${catkin_EXTRAS_DIR}/env-hooks ${catkin_skip_install_env_hooks})

foreach(filename
    catkin_python_setup # requires stamp and environment files
  )
  include(${catkin_EXTRAS_DIR}/${filename}.cmake)
endforeach()
