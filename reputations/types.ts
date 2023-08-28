export type Reputation = {
  verifyContract: string;
  chainId: number;
  dataGroupId: string;
  spec: string;
  description: string;
};

export type MultiReputation = {
  verifyContract: string;
  chainId: number;
  dataGroupId: string[];
};
