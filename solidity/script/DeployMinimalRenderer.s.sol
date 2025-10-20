// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererMinimal} from "../src/ProtocolitesRendererMinimal.sol";

/**
 * @title DeployMinimalRenderer
 * @notice Ultra-lightweight SVG renderer for OpenSea compatibility
 */
contract DeployMinimalRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying Ultra-Minimal SVG Renderer");
        console.log("Deployer:", deployer);
        console.log("Master:", masterAddress);

        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        require(master.owner() == deployer, "Not owner");

        vm.startBroadcast(deployerPrivateKey);

        ProtocolitesRendererMinimal renderer = new ProtocolitesRendererMinimal();
        console.log("[OK] Minimal Renderer:", address(renderer));

        master.setRenderer(address(renderer));
        console.log("[OK] Renderer updated!");
        console.log("\nThis SVG renderer will work on OpenSea!");

        vm.stopBroadcast();
    }
}
