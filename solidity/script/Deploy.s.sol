// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Protocolites} from "../src/Protocolites.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying contracts with address:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy renderer first
        ProtocolitesRender renderer = new ProtocolitesRender();
        console.log("ProtocolitesRender deployed at:", address(renderer));
        
        // Deploy factory
        ProtocoliteFactory factory = new ProtocoliteFactory();
        console.log("ProtocoliteFactory deployed at:", address(factory));
        
        // Deploy main Protocolite contract
        Protocolites protocolites = new Protocolites();
        console.log("Protocolites deployed at:", address(protocolites));
        
        // Connect contracts
        protocolites.setRenderer(address(renderer));
        protocolites.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        factory.registerProtocolite(address(protocolites));
        
        console.log("All contracts deployed and configured!");
        console.log("Protocolite NFT System Ready!");
        
        vm.stopBroadcast();
    }
}