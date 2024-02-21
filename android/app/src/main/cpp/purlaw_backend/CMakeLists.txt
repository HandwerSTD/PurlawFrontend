cmake_minimum_required(VERSION 3.22.1)
project(purlaw_backend)

set(CMAKE_CXX_STANDARD 17)

include_directories(./sherpa_utils)

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
        clipper.cpp
        sherpa_utils/sherpa-ncnn/c-api/c-api.cc
        sherpa_utils/sherpa-ncnn/csrc/model.cc
        sherpa_utils/sherpa-ncnn/csrc/endpoint.cc
        sherpa_utils/sherpa-ncnn/csrc/features.cc
        sherpa_utils/sherpa-ncnn/csrc/hypothesis.cc
        sherpa_utils/sherpa-ncnn/csrc/stream.cc
        sherpa_utils/sherpa-ncnn/csrc/symbol-table.cc
        sherpa_utils/kaldi-native-fbank/csrc/online-feature.cc
        sherpa_utils/kaldi-native-fbank/csrc/feature-fbank.cc
        sherpa_utils/kaldi-native-fbank/csrc/whisper-feature.cc
        sherpa_utils/kaldi-native-fbank/csrc/rfft.cc
        sherpa_utils/kaldi-native-fbank/csrc/log.cc
        sherpa_utils/kaldi-native-fbank/csrc/feature-window.cc
        sherpa_utils/sherpa-ncnn/csrc/meta-data.cc
        sherpa_utils/kaldi-native-fbank/csrc/mel-computations.cc
        sherpa_utils/sherpa-ncnn/csrc/stack.cc
        sherpa_utils/sherpa-ncnn/csrc/simpleupsample.cc
        sherpa_utils/sherpa-ncnn/csrc/lstm-model.cc
        sherpa_utils/sherpa-ncnn/csrc/zipformer-model.cc
        sherpa_utils/kaldi-native-fbank/csrc/fftsg.cc
        sherpa_utils/kaldi-native-fbank/csrc/feature-functions.cc
        sherpa_utils/sherpa-ncnn/csrc/resample.cc
        sherpa_utils/sherpa-ncnn/csrc/conv-emformer-model.cc
        sherpa_utils/sherpa-ncnn/csrc/tensorasstrided.cc
        sherpa_utils/sherpa-ncnn/csrc/poolingmodulenoproj.cc
        sherpa_utils/sherpa-ncnn/csrc/recognizer.cc
        sherpa_utils/sherpa-ncnn/csrc/modified-beam-search-decoder.cc
        sherpa_utils/sherpa-ncnn/csrc/context-graph.cc
        sherpa_utils/sherpa-ncnn/csrc/greedy-search-decoder.cc
        sherpa_utils/sherpa-ncnn/csrc/decoder.cc
        sherpa_helper.cpp
        )
target_link_libraries(purlaw_backend ${OpenCV_LIBS})
target_link_libraries(purlaw_backend ncnn)