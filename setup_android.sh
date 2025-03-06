#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="android_setup_log.txt"
touch $LOG_FILE

log_message() {
    echo -e "${2}${1}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Set up Android SDK directory
export ANDROID_HOME=$HOME/android-sdk
mkdir -p $ANDROID_HOME/cmdline-tools

# Download and install Command-line Tools
log_message "Downloading Android Command-line Tools..." "${YELLOW}"
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -P /tmp/ >> $LOG_FILE 2>&1

if [ $? -ne 0 ]; then
    log_message "Failed to download Command-line Tools" "${RED}"
    exit 1
fi

# Unzip and organize Command-line Tools
log_message "Installing Command-line Tools..." "${YELLOW}"
unzip -q /tmp/commandlinetools-linux-9477386_latest.zip -d /tmp/cmdline-tools
mkdir -p $ANDROID_HOME/cmdline-tools/latest
mv /tmp/cmdline-tools/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/
rm -rf /tmp/cmdline-tools
rm /tmp/commandlinetools-linux-9477386_latest.zip

# Set up environment variables
echo "export ANDROID_HOME=$ANDROID_HOME" >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc

# Load new environment variables
source ~/.bashrc

# Verify sdkmanager installation
if command -v sdkmanager &> /dev/null; then
    log_message "✅ sdkmanager installed successfully" "${GREEN}"
else
    log_message "❌ sdkmanager installation failed" "${RED}"
    exit 1
fi

# Accept licenses and install required components
log_message "Accepting licenses and installing components..." "${YELLOW}"
yes | sdkmanager --licenses >> $LOG_FILE 2>&1
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" "ndk;25.2.9519653" >> $LOG_FILE 2>&1

# Set NDK path
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653
echo "export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653" >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_NDK_HOME' >> ~/.bashrc

# Verify installation
log_message "\nVerifying installations:" "${YELLOW}"
log_message "ANDROID_HOME: $ANDROID_HOME" "${GREEN}"
log_message "ANDROID_NDK_HOME: $ANDROID_NDK_HOME" "${GREEN}"

# Initialize gomobile with NDK
log_message "Reinitializing gomobile with NDK..." "${YELLOW}"
gomobile init >> $LOG_FILE 2>&1

source ~/.bashrc

log_message "\nSetup completed! Run these commands to verify:" "${GREEN}"
echo -e "${YELLOW}sdkmanager --list"
echo -e "ls -la \$ANDROID_HOME/cmdline-tools/latest/bin"
echo -e "ls -la \$ANDROID_NDK_HOME${NC}"
