export const ProtocoliteFactoryAbi = [
  // Events
  {
    type: "event",
    name: "InfectionContractDeployed",
    inputs: [
      { name: "parentTokenId", type: "uint256", indexed: true },
      { name: "infectionContract", type: "address", indexed: true },
      { name: "parentDna", type: "uint256", indexed: false },
    ],
  },
] as const;
