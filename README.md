# install dependencies
forge install

# init local fork of mumbai
anvil --fork-url https://gateway.tenderly.co/public/polygon-mumbai --chain-id 5151111

# edit deploy script with customized dataGroups

# deploy contracts
```
forge script script/SismoCredentialFactory.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast -vvvv
forge script script/SismoCredential.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast -vvvv
```

# or deploy with owner's private key
forge script DeployReputations --rpc-url http://localhost:8545 -vv --private-key $PRIVATE_KEY --broadcast


# test
forge test --fork-url https://gateway.tenderly.co/public/polygon-mumbai

