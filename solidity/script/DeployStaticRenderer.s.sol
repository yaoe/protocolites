// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererStatic} from "../src/ProtocolitesRendererStatic.sol";

contract DeployStaticRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying Static ASCII Renderer (No Animations)");
        console.log("Deployer:", deployer);
        console.log("Master:", masterAddress);

        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        require(master.owner() == deployer, "Not owner");

        vm.startBroadcast(deployerPrivateKey);

        ProtocolitesRendererStatic renderer = new ProtocolitesRendererStatic();
        console.log("[OK] Static Renderer:", address(renderer));

        master.setRenderer(address(renderer));
        console.log("[OK] Renderer updated!");
        console.log("\nFull ASCII art with NO animations - should work everywhere!");

        vm.stopBroadcast();
    }
}
