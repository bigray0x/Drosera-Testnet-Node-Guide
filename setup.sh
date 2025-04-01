#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Function to install required dependencies
install_dependencies() {
  if ! command_exists curl; then
    echo "Installing curl..."
    sudo apt-get update && sudo apt-get install -y curl
  fi

  if ! command_exists tar; then
    echo "Installing tar..."
    sudo apt-get install -y tar
  fi

  if ! command_exists jq; then
    echo "Installing jq..."
    sudo apt-get install -y jq
  fi
}

# Function to get public IP address
get_public_ip() {
  echo "Detecting public IP address..."
  IP_ADDRESS=$(curl -s ifconfig.me)
  echo "Public IP detected: $IP_ADDRESS"
}

# Function to configure Drosera settings
configure_drosera() {
  echo "Enter the Ethereum RPC URL [default: https://ethereum-holesky-rpc.publicnode.com]:"
  read ETH_RPC_URL
  ETH_RPC_URL=${ETH_RPC_URL:-"https://ethereum-holesky-rpc.publicnode.com"}

  echo "Enter your Ethereum private key (0x...):"
  read -s ETH_PRIVATE_KEY
  echo "Enter your Drosera contract address [default: 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8]:"
  read DRO_CONTRACT_ADDR
  DRO_CONTRACT_ADDR=${DRO_CONTRACT_ADDR:-"0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"}

  echo "Configuration Summary:"
  echo "Network:              Holesky"
  echo "Ethereum RPC URL:     $ETH_RPC_URL"
  echo "Private Key:          (hidden for security)"
  echo "Drosera Contract Addr:$DRO_CONTRACT_ADDR"

  echo "Are these details correct? (y/n):"
  read CONFIRM
  if [[ $CONFIRM != "y" ]]; then
    echo "Please re-enter the details."
    configure_drosera
  fi
}

# Function to download and extract Drosera Operator
download_drosera_operator() {
  echo "Downloading Drosera Operator..."
  wget https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz -O drosera-operator.tar.gz
  tar -xzf drosera-operator.tar.gz
  rm drosera-operator.tar.gz
}

# Function to create 'drosera.toml' configuration file
create_drosera_toml() {
  echo "Creating configuration file 'drosera.toml'..."

  cat <<EOF > drosera.toml
# Ethereum Network Configuration
ethereum_rpc_url = "$ETH_RPC_URL"
private_key = "$ETH_PRIVATE_KEY"
drosera_contract_address = "$DRO_CONTRACT_ADDR"
external_p2p_address = "$IP_ADDRESS"
EOF
}

# Function to update shell configuration
update_shell_configuration() {
  echo "Updating shell configuration..."

  echo 'export ETH_RPC_URL="$ETH_RPC_URL"' >> ~/.bashrc
  echo 'export DRO_CONTRACT_ADDR="$DRO_CONTRACT_ADDR"' >> ~/.bashrc
  echo 'export IP_ADDRESS="$IP_ADDRESS"' >> ~/.bashrc
  source ~/.bashrc
}

# Function to start Drosera Operator node
start_drosera_operator() {
  echo "Starting Drosera Operator Node..."
  ./drosera-operator node --eth-private-key "$ETH_PRIVATE_KEY" --ethereum-rpc-url "$ETH_RPC_URL" --p2p-address "$IP_ADDRESS"
}

# Main function to execute the setup process
main() {
  install_dependencies
  get_public_ip
  configure_drosera
  download_drosera_operator
  create_drosera_toml
  update_shell_configuration
  start_drosera_operator
}

main
