catkin
======

Catkin is a collection of cmake macros and associated python code used
to build some parts of `ROS <http://www.ros.org>`_

Documentation
-------------

http://ros.org/doc/api/catkin/html/

To work with catch tests:

 1. `git clone https://github.com/harmishhk/Catch ~/.catch`
 2. `python ~/.catch/scripts/generateSingleHeader.py`
 3. `export CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH:~/.catch/single_include`
