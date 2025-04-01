#!/bin/bash

# Detect OS
OS=$(uname)

# Function to check if a command exists
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 is not installed. Installing..."
        install_dependency "$1"
    fi
}

# Function to install dependencies based on OS
install_dependency() {
    if [ "$OS" == "Linux" ]; then
        sudo apt-get update
        sudo apt-get install -y "$1"
    elif [ "$OS" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is required on macOS. Please install it from https://brew.sh."
            exit 1
        fi
        brew install "$1"
    else
        echo "Unsupported OS: $OS."
        exit 1
    fi
}

# Check dependencies
check_dependency wget
check_dependency curl

# Network Selection
echo "Select the network to deploy on:"
echo "1) Holesky Testnet (default for Drosera Testnet)"
echo "2) Ethereum Mainnet"
echo "3) Sepolia Testnet"
read -p "Enter your choice (1/2/3): " NETWORK_CHOICE

case "$NETWORK_CHOICE" in
    1)
        NETWORK="Holesky"
        DEFAULT_RPC="https://ethereum-holesky-rpc.publicnode.com"
        DEFAULT_DROSERA_ADDRESS="0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"
        ;;
    2)
        NETWORK="Mainnet"
        DEFAULT_RPC="https://mainnet.infura.io/v3/YOUR_API_KEY"
        DEFAULT_DROSERA_ADDRESS="0xYOUR_MAINNET_CONTRACT_ADDRESS"
        ;;
    3)
        NETWORK="Sepolia"
        DEFAULT_RPC="https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
        DEFAULT_DROSERA_ADDRESS="0xYOUR_SEPOLIA_CONTRACT_ADDRESS"
        ;;
    *)
        echo "Invalid selection. Exiting..."
        exit 1
        ;;
esac

echo "You selected: $NETWORK"

# Get Ethereum RPC URL
read -p "Enter your Ethereum RPC URL [$DEFAULT_RPC]: " ETH_RPC_URL
ETH_RPC_URL=${ETH_RPC_URL:-$DEFAULT_RPC}

# Get Private Key (but do NOT store it in the config file)
read -s -p "Enter your Ethereum private key (0x...): " PRIVATE_KEY
echo ""

if [[ ! $PRIVATE_KEY =~ ^0x[0-9a-fA-F]{64}$ ]]; then
    echo "Error: Invalid private key format."
    exit 1
fi

# Get Drosera Contract Address
read -p "Enter your Drosera contract address [$DEFAULT_DROSERA_ADDRESS]: " DROSERA_ADDRESS
DROSERA_ADDRESS=${DROSERA_ADDRESS:-$DEFAULT_DROSERA_ADDRESS}

# Confirm details
echo ""
echo "Configuration Summary:"
echo "Network:              $NETWORK"
echo "Ethereum RPC URL:     $ETH_RPC_URL"
echo "Drosera Contract Addr:$DROSERA_ADDRESS"
echo ""
read -p "Are these details correct? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Exiting. Please restart the script with correct inputs."
    exit 1
fi

# Download and extract Drosera Operator
echo "Downloading Drosera Operator..."
DROSERA_VERSION="v1.16.2"
DROSERA_BINARY="drosera-operator-${DROSERA_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
DROSERA_URL="https://github.com/drosera-network/releases/releases/download/${DROSERA_VERSION}/${DROSERA_BINARY}"

wget -O drosera-operator.tar.gz "$DROSERA_URL"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Drosera Operator."
    exit 1
fi

tar -xvf drosera-operator.tar.gz
sudo mv drosera-operator /usr/local/bin/

# Create drosera.toml configuration file WITHOUT `private_key`
echo "Creating configuration file 'drosera.toml'..."
cat <<EOL > drosera.toml
rpc_url = "$ETH_RPC_URL"
contract_address = "$DROSERA_ADDRESS"
EOL

# Set private key as an environment variable
export PRIVATE_KEY="$PRIVATE_KEY"
echo "export PRIVATE_KEY=\"$PRIVATE_KEY\"" >> ~/.bashrc

# Start Drosera Operator Node with the private key as a CLI argument
echo "Starting Drosera Operator Node..."
drosera-operator node --private-key "$PRIVATE_KEY"
if [ $? -ne 0 ]; then
    echo "Error: Failed to start Drosera Operator."
    exit 1
fi

echo "Drosera Operator setup complete!"
