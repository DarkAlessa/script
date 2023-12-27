#!/bin/bash

validation="[^A-Za-z0-9_-]"

read -p $'\e[38;2;168;212;255mThe project directory name:\e[0m ' ProjectName
while [[ "${ProjectName}" == '' || "${ProjectName}" =~ ${validation} ]]; do
    read -p $'\e[38;2;255;51;51mInvalid name (a-z, A-Z, 0-9, -, _)!:\e[0m ' ProjectName
done
mkdir -p ./${ProjectName}/src \
         ./${ProjectName}/include \
         ./${ProjectName}/build \
         ./${ProjectName}/lib \
         ./${ProjectName}/assets
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
cmake_minimum_required(VERSION 3.20 FATAL_ERROR)
project(${CMakeProjectName} VERSION 1.0.0 LANGUAGES C CXX)

# compiler flags/options INTERFACE
add_library(compiler_flags INTERFACE)
target_compile_features(compiler_flags INTERFACE \$<BUILD_LOCAL_INTERFACE:cxx_std_23>)
target_compile_options(compiler_flags BEFORE INTERFACE
    \$<BUILD_LOCAL_INTERFACE:-Wall;-Werror;-Wpedantic>
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/lib")

# include directory INTERFACE
add_library(include_interface INTERFACE)
target_include_directories(include_interface INTERFACE
    \$<BUILD_LOCAL_INTERFACE:\${CMAKE_SOURCE_DIR}/include>
    \$<BUILD_LOCAL_INTERFACE:\${SDL2_INCLUDE_DIRS}>
)

add_subdirectory(src)
EOF

cat << EOF > ./${ProjectName}/src/CMakeLists.txt
find_package(SDL2 REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(SDL2_ttf REQUIRED)
#find_package(SDL2_gfx REQUIRED)
#find_package(SDL2_mixer REQUIRED)
#find_package(SDL2_net REQUIRED)

#add_executable(${execute} WIN32)
add_executable(${execute})
target_sources(${execute} PRIVATE
    \${CMAKE_CURRENT_SOURCE_DIR}/${execute}.cpp
    \${CMAKE_CURRENT_SOURCE_DIR}/app.cpp
)

target_link_libraries(${execute} PRIVATE
    include_interface
    compiler_flags

    SDL2::SDL2main
    SDL2::SDL2
    SDL2_image::SDL2_image
    SDL2_ttf::SDL2_ttf
)

#message(STATUS "///////////////////////////////////")
#message(STATUS "\${SDL2_INCLUDE_DIRS}")
#message(STATUS "\${SDL2_LIBRARIES}")
#message(STATUS "///////////////////////////////////")
EOF

#--- Add code simple
cat << 'EOF' > ./${ProjectName}/src/${execute}.cpp
#include "app.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <iostream>

int main(int argc, char** argv) {
    init();
  
    bool quit = false;
    SDL_Event e;

    while(!quit) {
        while(SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_QUIT)
            quit = true;
        }

        present();
    }

    close();
    return 0;
}
EOF

cat << 'EOF' > ./${ProjectName}/include/app.h
#ifndef APP_H
#define APP_H

bool init();
void present();
void close();

#endif
EOF

cat << 'EOF' > ./${ProjectName}/src/app.cpp
#include "app.h"
#include <SDL2/SDL.h>
#include <iostream>

#define width 640
#define height 480

SDL_Window* window = nullptr;
SDL_Renderer* windowRenderer = nullptr;

bool init() {
  
    bool success = true;

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cout << "SDL failed to initialize! : " << SDL_GetError() << '\n';
        success = false;
    }
    else {
        window = SDL_CreateWindow("Demo", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_SHOWN);
        if (window == nullptr) {
            std::cout << "Create Window failed! : " << SDL_GetError() << '\n';
            success = false;
        }
        else {
            windowRenderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
            if (windowRenderer == nullptr) {
                std::cout <<"Create Renderer failed! : " << SDL_GetError() << '\n';
                success = false;
            }
            else {
                SDL_SetRenderDrawColor(windowRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
            }
        }
    }
  
    return success;
}

void present() {
    SDL_RenderPresent(windowRenderer);
}

void close() {
    SDL_DestroyRenderer(windowRenderer);
    SDL_DestroyWindow(window);
    windowRenderer = nullptr;
    window = nullptr;
    SDL_Quit();
}
EOF

#--- VSCode .vscode folders
#   c_cpp_properties.json
#   launch.json
#   tasks.json
#GCC_VERSION=$(g++ --version | head -n 1 | awk '{print $7}')

mkdir ./${ProjectName}/.vscode
cat << EOF > ./${ProjectName}/.vscode/c_cpp_properties.json
{
  "env": {
    "myDefaultIncludePath": [
      "\${workspaceFolder}",
      "\${workspaceFolder}/include"
    ],
    "myCompilerPath": "C:/msys64/ucrt64/bin/g++.exe"
  },
  "configurations": [
    {
      "name": "Win32",
      "includePath": [
        "\${workspaceFolder}/**",
        "\${myDefaultIncludePath}",
        "C:/msys64/ucrt64/include/**",
        "C:/msys64/ucrt64/lib/**"
      ],
      "defines": [
        "_DEBUG",
        "UNICODE",
        "_UNICODE"
      ],
      "compilerPath": "\${myCompilerPath}",
      "cStandard": "c17",
      "cppStandard": "c++${getCPPstd}",
      "intelliSenseMode": "gcc-x64",
      "browse": {
        "path": [
          "\${workspaceFolder}",
          "C:/msys64/ucrt64/lib",
          "C:/msys64/ucrt64/x86_64-w64-mingw32"      
        ],
        "limitSymbolsToIncludedHeaders": true,
        "databaseFilename": ""
      }
    }
  ],
  "version": 4
}
EOF

cat << EOF > ./${ProjectName}/.vscode/launch.json
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "(gdb) Launch",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${workspaceFolder}/${execute}.exe",
      "args": [],
      "stopAtEntry": false,
      "cwd": "\${workspaceFolder}/build",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "C:/msys64/ucrt64/bin/gdb.exe",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ]
      //"preLaunchTask": "Make"
    }
  ]
}
EOF

cat << 'EOF' > ./${ProjectName}/.vscode/tasks.json
{
  "version": "2.0.0",
  "options": {
    "cwd": "${workspaceFolder}"
  },
  "tasks": [
    {
      "label": "CMake --build",
      "type": "shell",
      "windows":{
        "command": "cmake --build ./build"
      },
      "linux":{
        "command": "cmake --build ./build"
      },
      "problemMatcher": [
        "$gcc"
      ]
    },
  ]
}
EOF

#--- Build CMake project
echo "-------------------------------"
cmake -S ./${ProjectName} -B ./${ProjectName}/build -G "MSYS Makefiles"

echo "-------------------------------"
tree ${ProjectName} -L 2
echo "-------------------------------"
