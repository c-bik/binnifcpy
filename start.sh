#!/bin/bash

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
     exename=erl
else
    exename='start //MAX werl.exe'
    #exename='erl.exe'
fi

# PATHS
paths="-pa"
paths=$paths" $PWD/ebin"

start_opts="$paths"

# DDERL start options
echo "------------------------------------------"
echo "Starting binnifcpy (Opts)"
echo "------------------------------------------"
echo "EBIN Path : $paths"
echo "------------------------------------------"

# Starting dderl
$exename $start_opts -s binnifcpy
