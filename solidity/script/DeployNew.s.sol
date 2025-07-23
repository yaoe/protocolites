// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {ProtocoliteFactoryNew} from "../src/ProtocoliteFactoryNew.sol";

contract DeployNewScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying NEW Protocolite system with address:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy renderer first
        ProtocolitesRender renderer = new ProtocolitesRender();
        console.log("ProtocolitesRender deployed at:", address(renderer));
        
        // Deploy factory
        ProtocoliteFactoryNew factory = new ProtocoliteFactoryNew();
        console.log("ProtocoliteFactory deployed at:", address(factory));
        
        // Deploy master contract
        ProtocolitesMaster master = new ProtocolitesMaster();
        console.log("ProtocolitesMaster deployed at:", address(master));
        
        // Connect contracts
        master.setRenderer(address(renderer));
        master.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        
        // Transfer factory ownership to master so it can deploy infection contracts
        factory.transferOwnership(address(master));
        
        console.log("All contracts deployed and configured!");
        console.log("New Protocolite Infection System Ready!");
        console.log("");
        console.log("Usage:");
        console.log("- Send 0.01+ ETH to Master = Spawn parent + infection contract");
        console.log("- Send 0 ETH to Master = Random infection");
        console.log("- Send any ETH to Infection contract = Get infected (refunded)");
        
        vm.stopBroadcast();
    }
}