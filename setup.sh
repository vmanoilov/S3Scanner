#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file setup
LOG_FILE="setup_log.txt"
touch $LOG_FILE

log_message() {
    echo -e "${2}${1}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        log_message "❌ $1 is not installed." "${RED}"
        return 1
    else
        log_message "✅ $1 is installed: $(command -v $1)" "${GREEN}"
        return 0
    fi
}

# Update package lists
log_message "Updating package lists..." "${YELLOW}"
sudo apt-get update >> $LOG_FILE 2>&1

# Install basic requirements
log_message "Installing basic requirements..." "${YELLOW}"
sudo apt-get install -y \
    build-essential \
    wget \
    unzip \
    openjdk-11-jdk \
    >> $LOG_FILE 2>&1

# Install Go if not present
if ! check_command go; then
    log_message "Installing Go..." "${YELLOW}"
    wget https://golang.org/dl/go1.21.0.linux-amd64.tar.gz >> $LOG_FILE 2>&1
    sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz >> $LOG_FILE 2>&1
    rm go1.21.0.linux-amd64.tar.gz
    
    # Set up Go environment
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Install Android SDK
if [ ! -d "$HOME/android-sdk" ]; then
    log_message "Installing Android SDK..." "${YELLOW}"
    mkdir -p $HOME/android-sdk
    wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip >> $LOG_FILE 2>&1
    unzip commandlinetools-linux-8512546_latest.zip -d $HOME/android-sdk >> $LOG_FILE 2>&1
    rm commandlinetools-linux-8512546_latest.zip

    # Set up Android SDK environment variables
    echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
    source ~/.bashrc
fi

# Install Go Mobile
log_message "Installing Go Mobile..." "${YELLOW}"
go install golang.org/x/mobile/cmd/gomobile@latest >> $LOG_FILE 2>&1
gomobile init >> $LOG_FILE 2>&1

# Verify installations
log_message "\nVerifying installations:" "${YELLOW}"
check_command go
check_command java
check_command gomobile

# Install Android SDK components
if command -v sdkmanager &> /dev/null; then
    log_message "Installing Android SDK components..." "${YELLOW}"
    yes | sdkmanager --licenses >> $LOG_FILE 2>&1
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" >> $LOG_FILE 2>&1
fi

# Final verification
log_message "\nEnvironment setup complete. Verifying versions:" "${GREEN}"
go version
java -version
gomobile version

log_message "\nSetup completed! Check $LOG_FILE for detailed logs." "${GREEN}"