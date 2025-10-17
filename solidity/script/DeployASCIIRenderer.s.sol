// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesRenderASCII} from "../src/ProtocolitesRenderASCII.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";

contract DeployASCIIRendererScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Get existing master contract address from environment or hardcode
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying ASCII Renderer with address:", deployer);
        console.log("Existing ProtocolitesMaster:", masterAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new ASCII renderer
        ProtocolitesRenderASCII asciiRenderer = new ProtocolitesRenderASCII();
        console.log("ProtocolitesRenderASCII deployed at:", address(asciiRenderer));

        // Update master contract to use new renderer
        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));
        master.setRenderer(address(asciiRenderer));
        console.log("Master contract updated to use ASCII renderer!");

        vm.stopBroadcast();
    }
}
