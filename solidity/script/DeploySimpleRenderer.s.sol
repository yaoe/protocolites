// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererSimple} from "../src/ProtocolitesRendererSimple.sol";

contract DeploySimpleRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying ULTRA SIMPLE Renderer (Pre-defined ASCII)");
        console.log("Deployer:", deployer);
        console.log("Master:", masterAddress);

        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        require(master.owner() == deployer, "Not owner");

        vm.startBroadcast(deployerPrivateKey);

        ProtocolitesRendererSimple renderer = new ProtocolitesRendererSimple();
        console.log("[OK] Simple Renderer:", address(renderer));

        master.setRenderer(address(renderer));
        console.log("[OK] Renderer updated!");
        console.log("\n16 pre-defined ASCII variants - VERY low gas!");

        vm.stopBroadcast();
    }
}
