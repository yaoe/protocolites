// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRenderASCII} from "../src/ProtocolitesRenderASCII.sol";
import {ProtocoliteFactoryNew} from "../src/ProtocoliteFactoryNew.sol";

contract DeployFreshASCIIScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying fresh Protocolites system with ASCII renderer");
        console.log("Deployer address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy ASCII renderer
        ProtocolitesRenderASCII renderer = new ProtocolitesRenderASCII();
        console.log("ASCII Renderer deployed at:", address(renderer));

        // 2. Deploy factory
        ProtocoliteFactoryNew factory = new ProtocoliteFactoryNew();
        console.log("Factory deployed at:", address(factory));

        // 3. Deploy master contract
        ProtocolitesMaster master = new ProtocolitesMaster();
        console.log("Master deployed at:", address(master));

        // 4. Connect everything
        master.setRenderer(address(renderer));
        console.log("Master.setRenderer() called");

        master.setFactory(address(factory));
        console.log("Master.setFactory() called");

        factory.transferOwnership(address(master));
        console.log("Factory ownership transferred to Master");

        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("Master Contract:", address(master));
        console.log("Factory Contract:", address(factory));
        console.log("ASCII Renderer:", address(renderer));
        console.log("\nAll protocolites (parents & kids) will use ASCII renderer!");

        vm.stopBroadcast();
    }
}
