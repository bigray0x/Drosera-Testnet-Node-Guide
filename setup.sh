#!/bin/bash

# Detect OS for later use
OS=$(uname)

# Function to check if a command exists
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 is not installed. Installing..."
        install_dependency "$1"
    fi
}

# Function to install dependencies based on the OS
install_dependency() {
    if [ "$OS" == "Linux" ]; then
        sudo apt-get update
        sudo apt-get install -y "$1"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $1 on Linux."
            exit 1
        fi
    elif [ "$OS" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is required on macOS. Please install it from https://brew.sh."
            exit 1
        fi
        brew install "$1"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $1 on macOS."
            exit 1
        fi
    else
        echo "Unsupported OS: $OS."
        exit 1
    fi
}

# Check for necessary tools
check_dependency wget
check_dependency docker
check_dependency curl

# Function to deploy a Trap contract if needed (example using Foundry)
generate_trap_address() {
    echo "Deploying a new Trap contract using Foundry..."
    forge create TrapContract --rpc-url "$ETH_RPC_URL" --private-key "$PRIVATE_KEY"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to deploy the Trap contract."
        exit 1
    fi
    echo "Trap contract deployed successfully!"
}

# -- NETWORK SELECTION --
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

# -- RPC URL INPUT --
read -p "Enter your Ethereum RPC URL [$DEFAULT_RPC]: " ETH_RPC_URL
ETH_RPC_URL=${ETH_RPC_URL:-$DEFAULT_RPC}

# -- PRIVATE KEY INPUT --
read -p "Enter your Ethereum private key (0x...): " PRIVATE_KEY
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: Private key is required."
    exit 1
fi

# -- DROSERA CONTRACT ADDRESS INPUT --
read -p "Enter your Drosera contract address [$DEFAULT_DROSERA_ADDRESS]: " DROSERA_ADDRESS
DROSERA_ADDRESS=${DROSERA_ADDRESS:-$DEFAULT_DROSERA_ADDRESS}

# Confirm inputs
echo ""
echo "Configuration Summary:"
echo "Network:              $NETWORK"
echo "Ethereum RPC URL:     $ETH_RPC_URL"
echo "Private Key:          $PRIVATE_KEY"
echo "Drosera Contract Addr:$DROSERA_ADDRESS"
echo ""
read -p "Are these details correct? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Exiting. Please restart the script with correct inputs."
    exit 1
fi

# (Optional) If you want to auto-deploy a Trap contract when Drosera contract address is empty:
if [ -z "$DROSERA_ADDRESS" ]; then
    generate_trap_address
fi

# Download and extract Drosera Operator binary
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
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract Drosera Operator."
    exit 1
fi

sudo mv drosera-operator /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error: Failed to move Drosera Operator to /usr/local/bin."
    exit 1
fi

# Create drosera.toml configuration file with correct field names
echo "Creating configuration file 'drosera.toml'..."
cat <<EOL > drosera.toml
rpc_url = "$ETH_RPC_URL"
private_key = "$PRIVATE_KEY"
contract_address = "$DROSERA_ADDRESS"
EOL

if [ $? -ne 0 ]; then
    echo "Error: Failed to create configuration file."
    exit 1
fi

# Update shell environment for persistence
echo "Updating shell configuration..."
if [ "$OS" == "Linux" ]; then
    SHELL_RC=~/.bashrc
elif [ "$OS" == "Darwin" ]; then
    SHELL_RC=~/.zshrc
fi

echo "export ETH_RPC_URL=\"$ETH_RPC_URL\"" >> "$SHELL_RC"
echo "export PRIVATE_KEY=\"$PRIVATE_KEY\"" >> "$SHELL_RC"
echo "export DROSERA_ADDRESS=\"$DROSERA_ADDRESS\"" >> "$SHELL_RC"

# Source the configuration file to update the current session
source "$SHELL_RC"

# Start the Drosera Operator Node
echo "Starting Drosera Operator Node..."
drosera-operator node
if [ $? -ne 0 ]; then
    echo "Error: Failed to start Drosera Operator."
    exit 1
fi

echo "Drosera Operator setup complete! Your environment has been updated to include your variables."
