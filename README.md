# install dependencies
forge install

# init local fork of mumbai
anvil --fork-url https://gateway.tenderly.co/public/polygon-mumbai --chain-id 5151111

# edit deploy script with customized dataGroups

# deploy contracts
forge script DeployReputations --rpc-url http://localhost:8545 -vv --mnemonics 'test test test test test test test test test test test junk' --sender '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266' --broadcast

# test
forge test --fork-url https://gateway.tenderly.co/public/polygon-mumbai