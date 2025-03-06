# Paths cleanup
unset GOROOT
unset GOPATH
PATH="/usr/local/bin:/usr/bin:/bin"

# Remove old Go folders
sudo rm -rf /usr/local/go
rm -rf $HOME/go
rm -rf /go/pkg/mod/golang.org/toolchain*

# Install Go 1.20.14
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz -P /tmp/
sudo tar -C /usr/local -xzf /tmp/go1.20.14.linux-amd64.tar.gz
rm /tmp/go1.20.14.linux-amd64.tar.gz

# Setup environment variables
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

# Reload environment variables
source ~/.bashrc

# Verify installation
go version