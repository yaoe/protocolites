// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererOptimized} from "../src/ProtocolitesRendererOptimized.sol";

contract DeployOptimizedRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying OPTIMIZED Renderer (Same look, minimal gas)");
        console.log("Deployer:", deployer);
        console.log("Master:", masterAddress);

        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        require(master.owner() == deployer, "Not owner");

        vm.startBroadcast(deployerPrivateKey);

        ProtocolitesRendererOptimized renderer = new ProtocolitesRendererOptimized();
        console.log("[OK] Optimized Renderer:", address(renderer));

        master.setRenderer(address(renderer));
        console.log("[OK] Renderer updated!");
        console.log("\nFull ASCII generation + JetBrains Mono - aggressively optimized!");

        vm.stopBroadcast();
    }
}
