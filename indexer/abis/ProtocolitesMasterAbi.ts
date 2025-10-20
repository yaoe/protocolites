export const ProtocolitesMasterAbi = [
  // Events
  {
    type: "event",
    name: "ParentSpawned",
    inputs: [
      { name: "tokenId", type: "uint256", indexed: true },
      { name: "owner", type: "address", indexed: true },
      { name: "infectionContract", type: "address", indexed: false },
    ],
  },
  {
    type: "event",
    name: "InfectionTriggered",
    inputs: [
      { name: "parentId", type: "uint256", indexed: true },
      { name: "victim", type: "address", indexed: true },
      { name: "infectionContract", type: "address", indexed: false },
    ],
  },
  {
    type: "event",
    name: "Transfer",
    inputs: [
      { name: "from", type: "address", indexed: true },
      { name: "to", type: "address", indexed: true },
      { name: "tokenId", type: "uint256", indexed: true },
    ],
  },
  // View functions
  {
    type: "function",
    name: "totalSupply",
    stateMutability: "view",
    inputs: [],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "tokenURI",
    stateMutability: "view",
    inputs: [{ name: "tokenId", type: "uint256" }],
    outputs: [{ type: "string" }],
  },
  {
    type: "function",
    name: "parentData",
    stateMutability: "view",
    inputs: [{ name: "tokenId", type: "uint256" }],
    outputs: [
      { name: "dna", type: "uint256" },
      { name: "birthBlock", type: "uint256" },
      { name: "infectionContract", type: "address" },
    ],
  },
  {
    type: "function",
    name: "ownerOf",
    stateMutability: "view",
    inputs: [{ name: "tokenId", type: "uint256" }],
    outputs: [{ type: "address" }],
  },
  {
    type: "function",
    name: "getInfectionContract",
    stateMutability: "view",
    inputs: [{ name: "parentId", type: "uint256" }],
    outputs: [{ type: "address" }],
  },
] as const;
