# Drosera-Testnet-Guide

----

This Guide Covers The Following Topics :

* How to set up your trap.
* How to opt into the operator.
* How to deploy an operator or multiple.
* How to debug errors.

| Recommendations | Details                                                    |
|----------------------------|------------------------------------------------------------|
| CPU                        | 2 CPU Cores                                                |
| Architecture               | arm64 or amd64                                             |
| RAM                        | 4 GB RAM                                                   |
| PC / VPS                   | A VPS from [contabo.com](https://contabo.com) (recommended)|
| Private RPC                | A Private RPC from [alchemy.com](https://alchemy.com) or [quicknode.com](https://quicknode.com) |

# 1. How to Setup a Trap :

1. Install sudo and other pre-requisites :
   
```bash
apt update && apt install -y sudo && sudo apt-get update && sudo apt-get upgrade -y && sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
```

2. Install docker :

```bash
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker
sudo docker run hello-world
```

3. Install environment requirements 

Drosera Cli

```bash
curl -L https://app.drosera.io/install | bash
```

```bash
source /root/.bashrc
```

```bash
droseraup
```

Foundry cli 

```bash
curl -L https://foundry.paradigm.xyz | bash
```

```bash
source /root/.bashrc
```

```bash
foundryup
```

Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

```bash
source /root/.bashrc
```
## Deploy The Trap Contract

```bash
mkdir my-drosera-trap && cd my-drosera-trap
```

Replace Github_Email & Github_Username

```bash
git config --global user.email "Github_Email"
git config --global user.name "Github_Username"
```

Initialize the Trap Contract :

```bash
forge init -t drosera-network/trap-foundry-template
```
```bash

curl -fsSL https://bun.sh/install | bash

source /root/.bashrc

bun install
```
```bash
forge build
```
Skip warnings

Deploy the Trap :
```bash
DROSERA_PRIVATE_KEY=xxx drosera apply
```
* Replace xxx with your EVM wallet privatekey (Ensure it's funded with Holesky ETH, you can claim 1E from holeskyfaucet.io)
* If you encounter rpc issues use this format instead “DROSERA_PRIVATE_KEY=xxx drosera apply --eth-rpc-url your_rpc_here”
* Use the private RPCs you got incase of errors.
* Enter the command, when prompted, write ofc and press Enter.

# 2. How to setup and opt-in to an Operator:

- Whitelist Your Operator 

Edit Trap configuration:

```bash 
cd my-drosera-trap
nano drosera.toml
```

Add the following codes at the bottom of drosera.toml:

```bash
private_trap = true
whitelist = ["Operator_Address_1","Operator_address_2"]
```
* Replace Operator_Address with your EVM wallet Public Address between " " symbols.
* Your EVM Address is your Operator address.
* You can whitelist maximum of two operators.
Update Trap Configuration:

```bash
DROSERA_PRIVATE_KEY=xxx drosera apply 
```
* Replace xxx with your EVM wallet privatekey
* If RPC issue, use DROSERA_PRIVATE_KEY=xxx drosera apply --eth-rpc-url RPC and replace RPC with your own.
* If you get “drosera command not found error” reinstall the foundry cli again from ealier and it’ll work.
  
Your Trap should be private now with your operator address whitelisted internally.
<img width="1057" alt="Screenshot 2025-04-29 at 9 58 14 AM" src="https://github.com/user-attachments/assets/8aa3bfc9-df06-4aa8-ab0a-33f81e652e71" />

## Register Both operators

```bash 
cd ~
```

 ## Download The Operator Executable file.

```bash
curl -LO https://github.com/drosera-network/releases/releases/download/v1.17.1/drosera-operator-v1.17.1-x86_64-unknown-linux-gnu.tar.gz
```

 ## Install the executable file 

```bash
tar -xvf drosera-operator-v1.17.1-x86_64-unknown-linux-gnu.tar.gz
```

Test the CLI with ./drosera-operator --version to verify it's working.

## Check version

```bash
./drosera-operator --version
```

```bash
# Move path to run it globally
sudo cp drosera-operator /usr/bin
```

```bash
# Check if it is working
drosera-operator
```

## Install Docker image

```bash
docker pull ghcr.io/drosera-network/drosera-operator:latest
```


## Register Operators

```bash
drosera-operator register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key PV_KEY1
```

```bash 
drosera-operator register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key PV_KEY2
```

* Replace PV_KEY1 and PV_KEY2 with your Operator EVM privatekeys.

## Enable firewall
 ```bash
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw enable
```

## Allow Drosera ports

```bash
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
```

## Edit And Run Operators On Docker

Check if docker is running properly 

```bash
sudo docker run hello-world
```

```bash
# create a folder for the operator node
mkdir drosera-operator1 && cd drosera-operator1 
```

```bash
# edit the docker compose file and replace input your private rpc 
nano docker-compose.yaml
```

## Paste the following file inside and replace RPC_URL_1 and RPC_URL_2 with your own RPCs.
```bash

services:
  drosera1:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-node1
    network_mode: host
    volumes:
      - drosera_data1:/data
    command: node --db-file-path /data/drosera.db --network-p2p-port 31313 --server-port 31314 --eth-rpc-url RPC_URL_1 --eth-backup-rpc-url https://holesky.drpc.org --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 --eth-private-key ${ETH_PRIVATE_KEY} --listen-address 0.0.0.0 --network-external-p2p-address ${VPS_IP} --disable-dnr-confirmation true
    restart: always

  drosera2:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-node2
    network_mode: host
    volumes:
      - drosera_data2:/data
    command: node --db-file-path /data/drosera.db --network-p2p-port 31315 --server-port 31316 --eth-rpc-url RPC_URL_2 --eth-backup-rpc-url https://holesky.drpc.org --drosera-address 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8 --eth-private-key ${ETH_PRIVATE_KEY2} --listen-address 0.0.0.0 --network-external-p2p-address ${VPS_IP} --disable-dnr-confirmation true
    restart: always

volumes:
  drosera_data1:
  drosera_data2:
```

Save the file by doing Ctrl + X + Y + Enter.

## Stop and remove old Drosera System Nodes

 ```bash
sudo systemctl stop drosera
sudo systemctl disable drosera
```

## Edit the .ENV file.

```bash
nano .env
```

## Paste the following details inside and add your private keys and IP address.

```bash
ETH_PRIVATE_KEY=
ETH_PRIVATE_KEY2=
VPS_IP=
P2P_PORT1=31313
SERVER_PORT1=31314
P2P_PORT2=31315
SERVER_PORT2=31316
```
Save with Ctrl + X + Y + enter.

## Stop and remove old drosera nodes 

```bash
docker compose down -v
docker stop drosera-node
docker rm drosera-node
```

## Run the both operator nodes

```bash
docker-compose up -d
```

### Opt-in Operators

Method 1: Login with your 2nd Operator wallet in [Dashboard](https://app.drosera.io), and Opt-in to your Trap

Method 2: via CLI

operator 1 

```bash
drosera-operator optin --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key 1st_Operator_Privatekey --trap-config-address Trap_Address
```
operator 2 

```bash
drosera-operator optin --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key 2nd_Operator_Privatekey --trap-config-address Trap_Address
```

Replace 1st and 2nd_Operator_Privatekey & Trap_Address.


## Traps and Operator Update

### Trap Update

update trap configuration

```bash
cd $home && cd my-drosera-trap && nano drosera.toml
```
Change previous seed-node rpc to new one

From 

```bash
"https://seed-node.testnet.drosera.io"
```
To 

```bash
"https://relay.testnet.drosera.io"
```
Control + X + Y + Enter to save.

### Reapply to update configurations

```bash
DROSERA_PRIVATE_KEY=xxx drosera apply 
```
### Operator Update

Kill nodes running in docker

```bash
cd Drosera-Network && docker-compose down
```

Update drosera operator cli

```bash
curl -L https://foundry.paradigm.xyz | bash
```

```bash
source /root/.bashrc
```

```bash
foundryup
```
Pull latest docker image

```bash
docker pull ghcr.io/drosera-network/drosera-operator:latest
```
Restart your node to reflect latest chnages

```bash
docker-compose up -d
```
both operators and traps are now succesfully uodated.

<img width="1440" alt="Screenshot 2025-05-08 at 6 06 20 PM" src="https://github.com/user-attachments/assets/2a1c31fd-babd-4f50-8996-184f22a835ff" />

# How to get CADET role on discord :

you have to Immortalize Discord username on-chain and Earn Cadet role!.

- you have to first deploy a trap and run operator to do this part.

### step 1 : create a new trap in your trap directory
Move to your trap directory:

```
cd my-drosera-trap
```
Create a new Trap.sol file:

```
nano src/Trap.sol
```
Paste the following contract code in it:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x4608Afa7f277C8E0BE232232265850d1cDeB600E;
    string constant discordName = "DISCORD_USERNAME"; // add your discord name here

    function collect() external view returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active, discordName);
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // take the latest block data from collect
        (bool active, string memory name) = abi.decode(data[0], (bool, string));
        // will not run if the contract is not active or the discord name is not set
        if (!active || bytes(name).length == 0) {
            return (false, bytes(""));
        }

        return (true, abi.encode(name));
    }
}
```
- Replace DISCORD_USERNAME with your discord username.
- To save: Ctrl+X, Y & Enter

### step 2 : Edit drosera.toml config
```
nano drosera.toml
```
- Modify the values of the specified variables as follows:
- path = "out/Trap.sol/Trap.json"
- response_contract = "0x4608Afa7f277C8E0BE232232265850d1cDeB600E"
- response_function = "respondWithDiscordName(string)"
  
![Image 5-31-25 at 10 01 AM](https://github.com/user-attachments/assets/5fb1624d-a2ec-4fe0-b69f-7e5b35847109)

- the right format should look like this when done.
- To save: Ctrl+X, Y & Enter.

### step 3 : Deploy Trap

- Compile your Trap's Contract:

```
forge build
```

- Test the trap before deploying:

```
drosera dryrun
```
- Apply and Deploy the Trap:

```
DROSERA_PRIVATE_KEY=xxx drosera apply
```
Replace xxx with your EVM wallet privatekey (Ensure it's funded with Holesky ETH)
Enter the command, when prompted, write ofc and press Enter.

- if you get this error below :

```
root@vmi2289783:~/my-drosera-trap# forge build

FORGE - training program for SNAP (version 2006-07-28)

usage: forge [options] <ann> <dna> [options]
options:
  -help
  -verbose
  -pseudocount <float>  [1]   (absolute number for all models)
  -pseudoCoding <float> [0.0] (eg. 0.05)
  -pseudoIntron <float> [0.0]
  -pseudoInter <float>  [0.0]
  -min-counts           [0]
  -lcmask [-fragmentN]
  -utr5-length <int>    [50]
  -utr5-offset <int>    [10]
  -utr3-length <int>    [50]
  -utr3-offset <int>    [10]
  -explicit <int>       [250]
  -min-intron <int>     [30]
  -boost <file>  (file of ID <int>)
```

- use this to build instead :

```
~/.foundry/bin/forge build
```

### step 4 : Verify Trap can respond :

After the trap is deployed, we can check if the user has responded by calling the isResponder function on the response contract.

```
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "isResponder(address)(bool)" OWNER_ADDRESS --rpc-url https://ethereum-holesky-rpc.publicnode.com
```
Replace OWNER_ADDRESS with your Trap's owner address. (Your main address that has deployed the Trap's contract)
If you receive true as a response, it means you have successfully completed all the steps.
image

- you may get false if you check immediately after deployment.
- It may take a 2-5 minutes to successfully receive "true" as a response.

### step 5 : Verify Name Onchain :

```
source /root/.bashrc
cast call 0x4608Afa7f277C8E0BE232232265850d1cDeB600E "getDiscordNamesBatch(uint256,uint256)(string[])" 0 2000 --rpc-url https://ethereum-holesky-rpc.publicnode.com/
```

now wait for the role to be automatically assigned.
## Debugging common Errors

1. operator config timeout not elapsed when trying to apply : simply wait and try after 15mins.

2. Getting red blocks only? Ensure your ports are open by running the allow drosera ports commands again.

3. Second operator not showing to opt in on the trap site? Opt in with cli method :
```bash
drosera-operator optin --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key 2nd_Operator_Privatekey --trap-config-address Trap_Address
```
4. Onlyowner error when trying to apply? : make sure you’re using same private key you used to deploy trap to apply again.

5. Restart operators? :

```bash
docker compose up -d
# OR
docker compose restart
```
6. Getting red blocks after green for sometime? : just let it run, could be seed node issue from backend.
