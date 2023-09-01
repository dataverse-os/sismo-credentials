# install dependencies
forge install

# init local fork of mumbai
anvil --fork-url https://gateway.tenderly.co/public/polygon-mumbai --chain-id 5151111

# edit deploy script with customized dataGroups

# deploy contracts
```
forge script script/DataPool.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast -vvvv
```

# test
forge test --fork-url https://gateway.tenderly.co/public/polygon-mumbai

# test single method
forge test --match-contract ReputationsTest --match-test test_addReputations --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract ReputationsTest --match-test test_deleteReputations --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract ReputationsTest --match-test test_reputationDetail_should_not_return_deleted_reputation --fork-url https://gateway.tenderly.co/public/polygon-mumbai