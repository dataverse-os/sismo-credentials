<br/>
<p align="center">
<a href=" " target="_blank">
<img src="https://bafybeifozdhcbbfydy2rs6vbkbbtj3wc4vjlz5zg2cnqhb2g4rm2o5ldna.ipfs.w3s.link/dataverse.svg" width="180" alt="Dataverse logo">
</a >
</p >
<br/>

# sismo-credentials

## Overview

Web3 social media apps require an identity verification feature to demonstrate ownership of specific badges or achievements. **Sismo** serves as the identity verification system in the web3 world.

- [What is Sismo](https://docs.sismo.io/sismo-docs/welcome-to-sismo/readme)

Users can [create data groups using Sismo](https://docs.sismo.io/sismo-docs/data-groups/tutorials/create-your-data-group), where each group maintains a list of web3 addresses or web2 social media accounts. These addresses or accounts represent the members of the group. The list can dynamically change, and the update frequency can be set during group creation. When the specified time is reached, the list is automatically updated.

Our contract inherits the functionality of verifying owner identity through ZK proof. Each data group in the `SismoCredential` contract is considered a credential. Users can verify themselves as members of a data group (thus owning the credential) through Sismo. The generated ZK proof bytes are then validated through our contract. Upon successful validation, the corresponding credential can be bound. This way, the user's credential information is securely stored on the blockchain, facilitating easy querying and displaying for web3 applications. The administrator of the `SismoCredential` contract (typically the project team of a social application) can manually add or remove data groups, allowing users to selectively verify and bind the credentials they wish to showcase.

Application developers can create their own dedicated `SismoCredential` contracts using the `SismoCredentialFactory`, with the caller being the default owner.

In addition, we have **SDK**( sismo-client in monorepo [dweb-toolkits](https://github.com/dataverse-os/dweb-toolkits/tree/main) ) and **backend** that are compatible with the contract. The SDK makes it easy for developers to retrieve contract information and perform contract operations on the frontend. The backend allows application developers to create and update the data groups list. When using Sismo's data groups, the API can be provided to Sismo. Sismo will periodically fetch the provided address/account list through the API and update accordingly.

## Setup

Install Foundry:

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Install dependencies:

```
forge install
```

# install dependencies

forge install

## Compile

```
forge build
```

## Test

```
source .env
forge test --fork-url $MUMBAI_RPC_URL
```

## Deploy

```
source .env
forge script script/SismoCredentialFactory.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast -vvvv --legacy
forge script script/SismoCredential.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast -vvvv --legacy
```

## Deployed Contract Address

```ts
const DeployedContracts = {
  SismoCredentialFactory: "0xC847b45FE9874f4A3Cb4aEeFE7B1270401913745",
};
```
