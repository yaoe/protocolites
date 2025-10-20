// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererCompact} from "../src/ProtocolitesRendererCompact.sol";

contract DeployCompactRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying Compact ASCII Renderer");
        console.log("Deployer:", deployer);
        console.log("Master:", masterAddress);

        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        require(master.owner() == deployer, "Not owner");

        vm.startBroadcast(deployerPrivateKey);

        ProtocolitesRendererCompact renderer = new ProtocolitesRendererCompact();
        console.log("[OK] Compact Renderer:", address(renderer));

        master.setRenderer(address(renderer));
        console.log("[OK] Renderer updated!");
        console.log("\nCompact ASCII renderer active - should work on OpenSea!");

        vm.stopBroadcast();
    }
}
