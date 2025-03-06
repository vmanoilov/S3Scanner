#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="ndk_setup_log.txt"
touch $LOG_FILE

log_message() {
    echo -e "${2}${1}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Ensure ANDROID_HOME is set
if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME=$HOME/android-sdk
    echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
fi

# Install NDK using sdkmanager
log_message "Installing Android NDK..." "${YELLOW}"
yes | sdkmanager --install "ndk;25.2.9519653" >> $LOG_FILE 2>&1

# Set NDK path
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653
echo "export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653" >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_NDK_HOME' >> ~/.bashrc

# Verify NDK installation
if [ -d "$ANDROID_NDK_HOME" ]; then
    log_message "✅ NDK installed successfully at: $ANDROID_NDK_HOME" "${GREEN}"
else
    log_message "❌ NDK installation failed. Check $LOG_FILE for details." "${RED}"
    exit 1
fi

# Initialize gomobile with NDK
log_message "Reinitializing gomobile with NDK..." "${YELLOW}"
gomobile init >> $LOG_FILE 2>&1

source ~/.bashrc

log_message "Setup completed! NDK is installed and configured." "${GREEN}"
log_message "ANDROID_NDK_HOME: $ANDROID_NDK_HOME" "${GREEN}"
