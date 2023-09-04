# install dependencies
forge install

# init local fork of mumbai
anvil --fork-url https://gateway.tenderly.co/public/polygon-mumbai --chain-id 5151111

# edit deploy script with customized dataGroups

# deploy contracts
```
forge script script/SismoCredential.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast -vvvv
```

# or deploy with owner's private key
forge script DeployReputations --rpc-url http://localhost:8545 -vv --private-key $PRIVATE_KEY --broadcast


# test
forge test --fork-url https://gateway.tenderly.co/public/polygon-mumbai

# test single method
forge test --match-contract SismoCredentialsTest --match-test test_bindCredential --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract SismoCredentialsTest --match-test test_addReputations --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract SismoCredentialsTest --match-test test_deleteReputations --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract SismoCredentialsTest --match-test test_getCredential --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract SismoCredentialsTest --match-test test_getCredentialInfoList_should_not_return_deleted_credential --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract SismoCredentialsTest --match-test test_should_bind_new_account_after_refresh_duration --fork-url https://gateway.tenderly.co/public/polygon-mumbai