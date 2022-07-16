#!/bin/bash

PROJECT_NAME="${0##*/}"
PROJECT_NAME="${PROJECT_NAME%.*}"

help() {
   # Display Help
   echo "Run script for your projects"
   echo "To change project output file name just change the name of this file"
   echo
   echo "Syntax: run.sh [-h|c|t|td]"
   echo "Options:"
   echo "h     Print this help"
   echo "c     Clean project before build"
   echo "t     Run tests for the project"
   echo "d     Run tests with GDB"
   echo "i     Install prerequisites (GTest, GMock)"
   echo
}

install_prerequisites() {
    sudo apt-get install libgtest-dev libgmock-dev
}

clean() {
    echo "[ BUILD ] Remove cached files"
    rm -rf build
}

build() {
    echo "[ BUILD ] Build project"
    if [[ ! -d "./build" ]]; then
        mkdir build
    fi
    cd build
    cmake -DDEFINED_PROJECT_NAME="${PROJECT_NAME}" -DTEST_ONLY=OFF -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ ..
    make
    ./${PROJECT_NAME}
}

testrun() {
    echo "[ BUILD ] Build project for tests"
    if [[ ! -d "./build" ]]; then
        mkdir build
    fi
    cd build
    cmake -DDEFINED_PROJECT_NAME="${PROJECT_NAME}-test" -DTEST_ONLY=ON -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ ..
    make

    if [[ $1 = true ]]; then
        gdb ./${PROJECT_NAME}-test
    else
        ./${PROJECT_NAME}-test
    fi
}

CURRENT_DIRECTORY=$(pwd)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CLEAN_UP=false
TEST_RUN=false
TEST_GDB=false
INSTALLP=false

echo "[ BUILD ] Run script found at '$SCRIPT_DIR'"

while getopts ":hctdi" option; do
   case $option in
      h) help
         exit;;
      c) echo "[ BUILD ] Set clean-up ON"
         CLEAN_UP=true;;
      t) echo "[ BUILD ] Set test ON" 
         TEST_RUN=true;;
      d) echo "[ BUILD ] Set test under GDB ON"
         TEST_GDB=true;;
      i) echo "[ INSTALL ] Prerequisites"
         INSTALLP=true;;
     \?) echo "[ BUILD ] ERROR: Invalid option"
         exit;;
   esac
done

if [ $INSTALLP = true ]; then
    install_prerequisites
    exit 0
fi

cd "$SCRIPT_DIR"

if [ $CLEAN_UP = true ]; then
    clean
fi

if [ $TEST_RUN = true ]; then
    testrun $TEST_GDB
else
    build
fi

cd "$CURRENT_DIRECTORY"
