// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererUltra} from "../src/ProtocolitesRendererUltra.sol";

contract DeployUltraRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying ULTRA Renderer (<1M gas, authentic look)");
        console.log("Deployer:", deployer);
        console.log("Master:", masterAddress);

        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        require(master.owner() == deployer, "Not owner");

        vm.startBroadcast(deployerPrivateKey);

        ProtocolitesRendererUltra renderer = new ProtocolitesRendererUltra();
        console.log("[OK] Ultra Renderer:", address(renderer));

        master.setRenderer(address(renderer));
        console.log("[OK] Renderer updated!");
        console.log("\nFull ASCII + JetBrains Mono - 733K gas!");
        console.log("Features: 3 body types, eyes, arms, legs, antennas, mouth");

        vm.stopBroadcast();
    }
}
