import { createConfig, factory } from "ponder";
import { parseAbiItem } from "viem";

import { ProtocolitesMasterAbi } from "./abis/ProtocolitesMasterAbi";
import { ProtocoliteFactoryAbi } from "./abis/ProtocoliteFactoryAbi";
import { ProtocoliteInfectionAbi } from "./abis/ProtocoliteInfectionAbi";

export default createConfig({
  chains: {
    sepolia: {
      id: 11155111,
      rpc: process.env.PONDER_RPC_URL_11155111!,
    },
  },
  contracts: {
    ProtocolitesMaster: {
      chain: "sepolia",
      abi: ProtocolitesMasterAbi,
      address: "0x35bea8249cde6c0e3ce9a3f3d0a526b1845b957d",
      startBlock: 9440296,
    },
    ProtocoliteFactory: {
      chain: "sepolia",
      abi: ProtocoliteFactoryAbi,
      address: "0x4b7201b36a699de652249064ff3094c16eda161b",
      startBlock: 9440296,
    },
    ProtocoliteInfection: {
      chain: "sepolia",
      abi: ProtocoliteInfectionAbi,
      // Dynamic factory pattern - infections are created by Factory contract
      address: factory({
        address: "0x4b7201b36a699de652249064ff3094c16eda161b",
        event: parseAbiItem("event InfectionContractDeployed(uint256 indexed parentTokenId, address indexed infectionContract, uint256 parentDna)"),
        parameter: "infectionContract",
      }),
      startBlock: 9440296,
    },
  },
});
