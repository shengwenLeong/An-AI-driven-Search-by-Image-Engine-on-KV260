# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.17

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph

# Include any dependencies generated for this target.
include CMakeFiles/Knn_Imagenet.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/Knn_Imagenet.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/Knn_Imagenet.dir/flags.make

CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.o: CMakeFiles/Knn_Imagenet.dir/flags.make
CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.o: Knn_Imagenet.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.o"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.o -c /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph/Knn_Imagenet.cpp

CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph/Knn_Imagenet.cpp > CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.i

CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph/Knn_Imagenet.cpp -o CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.s

# Object files for target Knn_Imagenet
Knn_Imagenet_OBJECTS = \
"CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.o"

# External object files for target Knn_Imagenet
Knn_Imagenet_EXTERNAL_OBJECTS =

Knn_Imagenet: CMakeFiles/Knn_Imagenet.dir/Knn_Imagenet.cpp.o
Knn_Imagenet: CMakeFiles/Knn_Imagenet.dir/build.make
Knn_Imagenet: libkgraph.a
Knn_Imagenet: /usr/lib/x86_64-linux-gnu/libboost_timer.so
Knn_Imagenet: /usr/lib/x86_64-linux-gnu/libboost_chrono.so
Knn_Imagenet: /usr/lib/x86_64-linux-gnu/libboost_system.so
Knn_Imagenet: /usr/lib/x86_64-linux-gnu/libboost_program_options.so
Knn_Imagenet: CMakeFiles/Knn_Imagenet.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable Knn_Imagenet"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/Knn_Imagenet.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/Knn_Imagenet.dir/build: Knn_Imagenet

.PHONY : CMakeFiles/Knn_Imagenet.dir/build

CMakeFiles/Knn_Imagenet.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/Knn_Imagenet.dir/cmake_clean.cmake
.PHONY : CMakeFiles/Knn_Imagenet.dir/clean

CMakeFiles/Knn_Imagenet.dir/depend:
	cd /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph /home/liangshengwen/KV260/kgraph/kgraph/Army_Kgraph/CMakeFiles/Knn_Imagenet.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/Knn_Imagenet.dir/depend

