#!/bin/sh

# This script generates the ABI files for the contracts in the project.
# It is intended to be run from the project root directory
# the generated ABI will be used to call the contracts from the frontend



mkdir ./reputations/test-reputation
touch ./reputations/test-reputation/index.ts

# Specify the path to your JSON file
json_file="./broadcast/Reputation.s.sol/5151111/run-latest.json"
data_group_id_file="./data-group-id.txt"
# Read and parse the JSON file
json_data=$(cat "$json_file")

data_group_id_data=$(cat "$data_group_id_file")
echo "$data_group_id_data"

## Extract specific values from the JSON using jq
verifyContract=$(echo "$json_data" | jq -r '.transactions[0].contractAddress')
#value2=$(echo "$json_data" | jq -r '.transactions')
#
## Output the extracted values
echo "verifyContract: $verifyContract"
#echo "Value 2: $value2"

echo "import {Reputation} from \"../types\";

      const reputation: Reputation = {
        verifyContract: \"$verifyContract\",
        chainId: 5151111,
        dataGroupId: \"$data_group_id_data\",
        spec: \"This group consists of all the addresses holding more than 10 ethers on the Ethereum network.\",
        description: \"Addresses holding more than 10 ethers on the Ethereum network.\"
      }

      export default reputation" >| ./reputations/test-reputation/index.ts

echo  "import holdersHavingMoreThanTenEthers from \"./holders-having-more-than-ten-ethers\";
       import testReputation from \"./test-reputation\";
       export const Reputations = {
           holdersHavingMoreThanTenEthers: holdersHavingMoreThanTenEthers,
           testReputation: testReputation
       }"  >| ./reputations/reputations.ts



