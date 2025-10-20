import { createConfig, factory } from "ponder";
import { parseAbiItem } from "viem";

import { ProtocolitesMasterAbi } from "./abis/ProtocolitesMasterAbi";
import { ProtocoliteFactoryAbi } from "./abis/ProtocoliteFactoryAbi";
import { ProtocoliteInfectionAbi } from "./abis/ProtocoliteInfectionAbi";
import { mainnet } from "viem/chains";

export default createConfig({
  chains: {
    mainnet: {
      id: 1,
      rpc: process.env.PONDER_RPC_URL_1!,
    },
  },
  contracts: {
    ProtocolitesMaster: {
      chain: "mainnet",
      abi: ProtocolitesMasterAbi,
      address: "0xB990DDE14b6510E8EA615Ffb66C55aeBF7cd9192",
      startBlock: 23617975,
    },
    ProtocoliteFactory: {
      chain: "mainnet",
      abi: ProtocoliteFactoryAbi,
      address: "0xE1ce2E011239AEb8095659Cb81020Ac16C2fc483",
      startBlock: 23617975,
    },
    ProtocoliteInfection: {
      chain: "mainnet",
      abi: ProtocoliteInfectionAbi,
      // Dynamic factory pattern - infections are created by Factory contract
      address: factory({
        address: "0xE1ce2E011239AEb8095659Cb81020Ac16C2fc483",
        event: parseAbiItem(
          "event InfectionContractDeployed(uint256 indexed parentTokenId, address indexed infectionContract, uint256 parentDna)",
        ),
        parameter: "infectionContract",
      }),
      startBlock: 23617975,
    },
  },
});
