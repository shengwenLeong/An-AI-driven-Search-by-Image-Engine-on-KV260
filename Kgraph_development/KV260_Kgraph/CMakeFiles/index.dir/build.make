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
CMAKE_SOURCE_DIR = /home/liangshengwen/KV260/kgraph/KV260_Kgraph

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/liangshengwen/KV260/kgraph/KV260_Kgraph

# Include any dependencies generated for this target.
include CMakeFiles/index.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/index.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/index.dir/flags.make

CMakeFiles/index.dir/index.cpp.o: CMakeFiles/index.dir/flags.make
CMakeFiles/index.dir/index.cpp.o: index.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/liangshengwen/KV260/kgraph/KV260_Kgraph/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/index.dir/index.cpp.o"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/index.dir/index.cpp.o -c /home/liangshengwen/KV260/kgraph/KV260_Kgraph/index.cpp

CMakeFiles/index.dir/index.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/index.dir/index.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/liangshengwen/KV260/kgraph/KV260_Kgraph/index.cpp > CMakeFiles/index.dir/index.cpp.i

CMakeFiles/index.dir/index.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/index.dir/index.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/liangshengwen/KV260/kgraph/KV260_Kgraph/index.cpp -o CMakeFiles/index.dir/index.cpp.s

# Object files for target index
index_OBJECTS = \
"CMakeFiles/index.dir/index.cpp.o"

# External object files for target index
index_EXTERNAL_OBJECTS =

index: CMakeFiles/index.dir/index.cpp.o
index: CMakeFiles/index.dir/build.make
index: libkgraph.a
index: /usr/lib/x86_64-linux-gnu/libboost_timer.so
index: /usr/lib/x86_64-linux-gnu/libboost_chrono.so
index: /usr/lib/x86_64-linux-gnu/libboost_system.so
index: /usr/lib/x86_64-linux-gnu/libboost_program_options.so
index: CMakeFiles/index.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/liangshengwen/KV260/kgraph/KV260_Kgraph/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable index"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/index.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/index.dir/build: index

.PHONY : CMakeFiles/index.dir/build

CMakeFiles/index.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/index.dir/cmake_clean.cmake
.PHONY : CMakeFiles/index.dir/clean

CMakeFiles/index.dir/depend:
	cd /home/liangshengwen/KV260/kgraph/KV260_Kgraph && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/liangshengwen/KV260/kgraph/KV260_Kgraph /home/liangshengwen/KV260/kgraph/KV260_Kgraph /home/liangshengwen/KV260/kgraph/KV260_Kgraph /home/liangshengwen/KV260/kgraph/KV260_Kgraph /home/liangshengwen/KV260/kgraph/KV260_Kgraph/CMakeFiles/index.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/index.dir/depend

