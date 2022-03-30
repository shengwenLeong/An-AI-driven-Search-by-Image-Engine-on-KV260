cmake_minimum_required (VERSION 2.6)
project (KGRAPH)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -msse2 -O3 -std=c++11 -fPIC -fext-numeric-literals")

find_package(OpenMP REQUIRED)
if (OPENMP_FOUND)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

find_package(Boost REQUIRED COMPONENTS timer chrono system program_options)

set(LIB_SRC kgraph.cpp metric.cpp)
include_directories(${KGRAPH_SOURCE_DIR})
add_library(kgraph SHARED ${LIB_SRC})
add_library(kgrapha STATIC ${LIB_SRC})
set_target_properties(kgrapha PROPERTIES OUTPUT_NAME kgraph)
add_executable(index index.cpp)
add_executable(search search.cpp)
add_executable(KV260_Knn_hamming KV260_Knn_hamming.cpp)
add_executable(KV260_dpu_tran_hash2bin KV260_dpu_tran_hash2bin.cpp)
set(TOOLS index search KV260_Knn_hamming KV260_dpu_tran_hash2bin)
foreach(TOOL ${TOOLS})
	target_link_libraries(${TOOL} kgrapha ${Boost_LIBRARIES} rt)
endforeach(TOOL)
install (FILES kgraph.h kgraph-data.h DESTINATION include) 
install (TARGETS kgraph kgrapha
	 LIBRARY DESTINATION lib
	 ARCHIVE DESTINATION lib)
