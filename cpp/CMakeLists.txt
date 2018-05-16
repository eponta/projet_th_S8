cmake_minimum_required(VERSION 3.5)
project(gr_toyexample)
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/Modules)
set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
        main.cpp)

add_executable(gr_toyexample ${SOURCE_FILES})

find_package (uhd)
if    (UHD_FOUND)
    include_directories(${UHD_INCLUDE_DIRS})
    target_link_libraries (gr_toyexample ${UHD_LIBRARIES})
endif (UHD_FOUND)

find_package(Boost COMPONENTS system filesystem REQUIRED)

target_link_libraries(gr_toyexample
        ${Boost_FILESYSTEM_LIBRARY}
        ${Boost_SYSTEM_LIBRARY}
        )

