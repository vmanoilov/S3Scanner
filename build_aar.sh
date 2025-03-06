#!/bin/bash

# Set up environment variables if not already set
if [ -z "$GOPATH" ]; then
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
fi

if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME=$HOME/android-sdk
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
    export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# Set NDK path
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653
export PATH=$PATH:$ANDROID_NDK_HOME

# Verify gomobile installation
if ! command -v gomobile &> /dev/null; then
    echo "Installing gomobile..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    gomobile init
fi

# Build the AAR
echo "Building AAR..."
echo "Using NDK path: $ANDROID_NDK_HOME"
cd scanner
gomobile bind -target=android -androidapi 21 -o ../s3scanner.aar .

if [ $? -eq 0 ]; then
    echo "Successfully generated s3scanner.aar"
    echo "AAR file location: $(pwd)/../s3scanner.aar"
else
    echo "Error generating AAR file"
    exit 1
fi