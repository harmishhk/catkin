_generate_function_if_testing_is_disabled("catkin_add_catchtest")

#
# Add a catch based test target.
#
# An executable target is created with the source files, it is compiled with
# catch header and added to the set of unit tests.
#
# .. note:: The test can be executed by calling the binary directly
#   or using: ``make run_tests_${PROJECT_NAME}_cppunit_${target}``
#
# :param target: the target name
# :type target: string
# :param source_files: a list of source files used to build the test
#   executable
# :type source_files: list of strings
# :param WORKING_DIRECTORY: the working directory when executing the
#   executable
# :type WORKING_DIRECTORY: string
#
# @public
#
function(catkin_add_catchtest target)
  _warn_if_skip_testing("catkin_add_catchtest")

  if(NOT CATCH_FOUND)
    message(WARNING "skipping catch test '${target}' in project '${PROJECT_NAME}'")
    return()
  endif()

  if(NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    message(FATAL_ERROR "catkin_add_catchtest() must be called after catkin_package() so that default output directories for the test binaries are defined")
  endif()

  # parse for optional arguments
  cmake_parse_arguments(_catchtest "" "WORKING_DIRECTORY" "" ${ARGN})
  
  # create the executable, with catch test build flags
  include_directories(${CATCH_INCLUDE_DIRS})
  add_executable(${target} ${_catchtest_UNPARSED_ARGUMENTS})

  # make sure the target is built before running tests
  add_dependencies(tests ${target})

  # we DONT use rosunit to call the executable to get process control
  get_target_property(_target_path ${target} RUNTIME_OUTPUT_DIRECTORY)
  #set(cmd "${_target_path}/${target}")
  set(cmd "${_target_path}/${target} -r=junit -o=${CATKIN_TEST_RESULTS_DIR}/${PROJECT_NAME}/catchtest-${target}.xml")
  catkin_run_tests_target("catchtest" ${target} "catchtest-${target}.xml" COMMAND ${cmd} DEPENDENCIES ${target} WORKING_DIRECTORY ${_catchtest_WORKING_DIRECTORY})
endfunction()

# if catch header is not in standard paths, set CMAKE_INCLUDE_PATH's in environment
# export CMAKE_INCLUDE_PATH=/opt/local/catch/include
find_file(CATCH_HEADER "catch.hpp")
find_path(CATCH_HEADER_PATH "catch.hpp")
if(CATCH_HEADER)
  message(STATUS "found catch header: catch tests will be built")
  set(CATCH_FOUND TRUE CACHE INTERNAL "")
  set(CATCH_INCLUDE_DIRS ${CATCH_HEADER_PATH} CACHE INTERNAL "")
else(CATCH_HEADER)
  message(STATUS "catch header not found, C++ tests can not be built")
endif(CATCH_HEADER)
