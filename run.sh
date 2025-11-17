#!/bin/bash

# Script to compile and run the minimania-ext-client application

set -e  # Stop on first error

# Change to script directory
cd "$(dirname "$0")"

# Compile the application
echo "Compiling application..."
./build.sh

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Error: Compilation failed!"
    exit 1
fi

# Run the application
echo "Running application..."
open build/MiniMania.app

echo "Application started!"





