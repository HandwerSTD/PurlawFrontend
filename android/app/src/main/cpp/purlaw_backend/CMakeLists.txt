cmake_minimum_required(VERSION 3.22.1)
project(purlaw_backend)

set(CMAKE_CXX_STANDARD 17)

set(OpenCV_DIR ./3rdpart/ocvm/sdk/native/jni/)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

set(ncnn_DIR ./3rdpart/ncnn/lib/cmake/ncnn)
set(ncnn_INCLUDE_DIRS ./3rdpart/ncnn/include)
include_directories(${ncnn_INCLUDE_DIRS})
find_package(ncnn REQUIRED)

# Configure CCache if available
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif(CCACHE_FOUND)

add_library(purlaw_backend
        cvhelper.cpp
        clipper.cpp)
target_link_libraries(purlaw_backend ${OpenCV_LIBS})
target_link_libraries(purlaw_backend ncnn)