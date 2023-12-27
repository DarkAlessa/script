#!/bin/bash

validation="[^A-Za-z0-9_-]"

read -p $'\e[38;2;168;212;255mThe project directory name:\e[0m ' ProjectName
while [[ "${ProjectName}" == '' || "${ProjectName}" =~ ${validation} ]]; do
    read -p $'\e[38;2;255;51;51mInvalid name (a-z, A-Z, 0-9, -, _)!:\e[0m ' ProjectName
done
mkdir -p ./${ProjectName}/src \
         ./${ProjectName}/include \
         ./${ProjectName}/build \
         ./${ProjectName}/lib
echo -e "\e[38;2;181;255;168mThe project directory named \"${ProjectName}\" has been created. ✓\e[0m"

#--- CMake Project Name
read -p $'\e[38;2;168;212;255mCMake project name:\e[0m ' CMakeProjectName
while [[ "${CMakeProjectName}" == '' || "${CMakeProjectName}" =~ ${validation} ]]; do
    read -p $'\e[38;2;255;51;51mInvalid name (a-z, A-Z, 0-9, -, _)!:\e[0m ' CMakeProjectName
done

#--- Execute ouput file name
read -p $'\e[38;2;168;212;255mName the CMake executable file the same as the project name? (y/<new-name>):\e[0m ' execute
if [[ ${execute} == 'y' ]] || [[ ${execute} == 'Y' ]]; then
    execute=${CMakeProjectName}
else
    while [[ "${execute}" == '' || "${execute}" =~ ${validation} ]]; do
        read -p $'\e[38;2;255;51;51mInvalid name (a-z, A-Z, 0-9, -, _)! :\e[0m ' execute
    done
fi
echo -e "\e[38;2;181;255;168mCMake executable file name: \"${execute}\" ✓\e[0m"

#--- C++ Standard
read -p $'\e[38;2;168;212;255mC++ Standard (Ex. 11, 14, 17, 20, 23):\e[0m ' getCPPstd 
CPPstd=(11 14 17 20 23)
if ! [[ "${CPPstd[*]}" =~ "${getCPPstd}" ]] || [[ "${getCPPstd}" == '' ]]; then
    getCPPstd=11
    echo -e "\e[38;2;181;255;168mC++ Standard : -std=c++${getCPPstd} (default) ✓\e[0m"
else
    echo -e "\e[38;2;181;255;168mC++ Standard : -std=c++${getCPPstd} ✓\e[0m"
fi

#--- CMakeLists.txt
cat << EOF > ./${ProjectName}/CMakeLists.txt
cmake_minimum_required(VERSION 3.26 FATAL_ERROR)
project(${CMakeProjectName} VERSION 1.0.0 LANGUAGES C CXX)

# compiler flags/options INTERFACE
add_library(compiler_flags INTERFACE)
target_compile_features(compiler_flags INTERFACE \$<BUILD_LOCAL_INTERFACE:cxx_std_23>)
target_compile_options(compiler_flags BEFORE INTERFACE
	\$<BUILD_LOCAL_INTERFACE:-Wall;-Werror;-Wpedantic>
	\$<BUILD_LOCAL_INTERFACE:\${GTKMM_CFLAGS_OTHER}>
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/lib")

add_subdirectory(src)
EOF

cat << EOF > ./${ProjectName}/src/CMakeLists.txt
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTKMM REQUIRED gtkmm-4.0)

add_executable(${execute} WIN32)
target_sources(${execute} PRIVATE
	\${CMAKE_CURRENT_SOURCE_DIR}/${execute}.cpp
	\${CMAKE_CURRENT_SOURCE_DIR}/app.cpp
)

target_include_directories(${execute} PUBLIC
  	\${CMAKE_SOURCE_DIR}/include
	\${GTKMM_INCLUDE_DIRS}
)

target_link_directories(${execute} PUBLIC \${GTKMM_LIBRARY_DIRS})

target_link_libraries(${execute} PRIVATE \${GTKMM_LIBRARIES} compiler_flags)
EOF

#--- Add code simple
cat << 'EOF' > ./${ProjectName}/src/${execute}.cpp
#include "app.h"
#include <gtkmm/application.h>
#include <gtkmm/settings.h>
#include <iostream>

int main(int argc, char *argv[]) {
		auto app = Gtk::Application::create("demo");

		/* Dark theme
		auto settings = Gtk::Settings::get_default();
		settings->property_gtk_application_prefer_dark_theme() = true;
		*/

		return app->make_window_and_run<My_window>(argc, argv);
}
EOF

#--- app.h
cat << 'EOF' > ./${ProjectName}/include/app.h
#ifndef APP_H
#define APP_H

#include <gtkmm/window.h>

class My_window : public Gtk::Window {
public:
	My_window();
};

#endif // APP_H
EOF

#--- app.cpp
cat << 'EOF' > ./${ProjectName}/src/app.cpp
#include "app.h"

My_window::My_window() {
	set_title("Demo");
	set_default_size(640, 420);
}
EOF

#--- Build CMake project
echo "-------------------------------"
cmake -S ./${ProjectName} -B ./${ProjectName}/build -G "MSYS Makefiles"

echo "-------------------------------"
tree ${ProjectName} -L 2
echo "-------------------------------"
