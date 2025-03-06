#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="gomobile_setup_log.txt"
touch $LOG_FILE

log_message() {
    echo -e "${2}${1}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Ensure GOPATH is set
if [ -z "$GOPATH" ]; then
    export GOPATH=$HOME/go
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Clean existing gomobile installation
log_message "Cleaning existing gomobile installation..." "${YELLOW}"
rm -rf $GOPATH/pkg/mod/golang.org/x/mobile*
rm -rf $GOPATH/bin/gomobile

# Get the latest mobile package
log_message "Getting latest mobile package..." "${YELLOW}"
go get -d golang.org/x/mobile/cmd/gomobile

# Install gomobile
log_message "Installing gomobile..." "${YELLOW}"
go install golang.org/x/mobile/cmd/gomobile@latest

# Install gobind
log_message "Installing gobind..." "${YELLOW}"
go install golang.org/x/mobile/cmd/gobind@latest

# Initialize gomobile
log_message "Initializing gomobile..." "${YELLOW}"
gomobile init

# Verify installation
if command -v gomobile &> /dev/null; then
    log_message "✅ Gomobile installed successfully" "${GREEN}"
    gomobile version
else
    log_message "❌ Gomobile installation failed" "${RED}"
    exit 1
fi

log_message "\nSetup completed! Current versions:" "${GREEN}"
go version
gomobile version