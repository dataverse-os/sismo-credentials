# install dependencies
forge install

# init local fork of mumbai
anvil --fork-url https://gateway.tenderly.co/public/polygon-mumbai --chain-id 5151111

# edit deploy script with customized dataGroups

# deploy contracts
forge script DeployReputations --rpc-url http://localhost:8545 -vv --mnemonics 'test test test test test test test test test test test junk' --sender '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266' --broadcast

# or deploy with owner's private key
forge script DeployReputations --rpc-url http://localhost:8545 -vv --private-key $PRIVATE_KEY --broadcast


# test
forge test --fork-url https://gateway.tenderly.co/public/polygon-mumbai

# test single method
forge test --match-contract ReputationsTest --match-test test_addReputations --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract ReputationsTest --match-test test_deleteReputations --fork-url https://gateway.tenderly.co/public/polygon-mumbai

forge test --match-contract ReputationsTest --match-test test_reputationDetail_should_not_return_deleted_reputation --fork-url https://gateway.tenderly.co/public/polygon-mumbai