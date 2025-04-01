#!/bin/bash

# Function to check if a command exists
check_dependency() {
    if ! command -v "$1" &> /dev/null
    then
        echo "$1 could not be found, installing..."
        sudo apt-get install -y "$1"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $1."
            exit 1
        fi
    fi
}

# Check for necessary tools
check_dependency wget
check_dependency docker
check_dependency curl

# Function to generate a new Trap contract address
generate_trap_address() {
    echo "Generating a new Trap contract address..."
    # Assuming you have an Ethereum deployment tool like Foundry or Hardhat
    # Deploying a Trap contract on Sepolia using Foundry as an example:
    forge create TrapContract --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY
    if [ $? -ne 0 ]; then
        echo "Error: Failed to deploy the Trap contract."
        exit 1
    fi
    echo "Trap contract deployed successfully!"
}

# Ask for parameters if not provided
if [ -z "$1" ]; then
    read -p "Enter your Ethereum RPC URL: " ETH_RPC_URL
else
    ETH_RPC_URL=$1
fi

if [ -z "$2" ]; then
    read -p "Enter your private key: " PRIVATE_KEY
else
    PRIVATE_KEY=$2
fi

if [ -z "$3" ]; then
    read -p "Enter your Drosera contract address: " DROSERA_ADDRESS
else
    DROSERA_ADDRESS=$3
fi

# Validate the inputs
if [ -z "$ETH_RPC_URL" ] || [ -z "$PRIVATE_KEY" ] || [ -z "$DROSERA_ADDRESS" ]; then
    echo "Error: Missing one or more required parameters."
    exit 1
fi

# Confirm inputs
echo "You entered the following information:"
echo "Ethereum RPC URL: $ETH_RPC_URL"
echo "Private Key: $PRIVATE_KEY"
echo "Drosera Contract Address: $DROSERA_ADDRESS"

# Prompt user for confirmation
read -p "Is this correct? (y/n): " confirmation
if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Please restart the script and provide correct inputs."
    exit 1
fi

# Check if the Trap address is provided
if [ -z "$DROSERA_ADDRESS" ]; then
    generate_trap_address
fi

# Download and extract Drosera Operator
echo "Downloading Drosera Operator..."
wget https://github.com/drosera-network/releases/latest/download/drosera-operator-linux-x86_64.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Drosera Operator."
    exit 1
fi

tar -xvf drosera-operator-linux-x86_64.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract Drosera Operator."
    exit 1
fi

sudo mv drosera-operator /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error: Failed to move Drosera Operator to /usr/local/bin."
    exit 1
fi

# Create configuration file
echo "Creating configuration file..."
cat <<EOL > drosera.toml
eth_rpc_url = "$ETH_RPC_URL"
eth_private_key = "$PRIVATE_KEY"
drosera_address = "$DROSERA_ADDRESS"
EOL

# Verify configuration file was created
if [ $? -ne 0 ]; then
    echo "Error: Failed to create configuration file."
    exit 1
fi

# Add variables to environment to reload shell automatically
echo "Setting up environment variables for auto-reload..."
echo "export ETH_RPC_URL=\"$ETH_RPC_URL\"" >> ~/.bashrc
echo "export PRIVATE_KEY=\"$PRIVATE_KEY\"" >> ~/.bashrc
echo "export DROSERA_ADDRESS=\"$DROSERA_ADDRESS\"" >> ~/.bashrc

# Source the updated bashrc to apply changes
source ~/.bashrc

# Start Drosera Operator
echo "Starting Drosera Operator Node..."
drosera-operator node
if [ $? -ne 0 ]; then
    echo "Error: Failed to start Drosera Operator."
    exit 1
fi

# Done
echo "Drosera Operator setup complete! If you made any changes to the script or variables, the shell has been reloaded automatically."

