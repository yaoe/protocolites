// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererAnimated} from "../src/ProtocolitesRendererAnimated.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";

/**
 * @title DeployFreshAnimated
 * @author Protocolites Team
 * @notice Deployment script for a complete fresh Protocolites system with Animated renderer
 * @dev This script deploys all contracts and properly connects them with correct ownership
 *
 *      Deployment order:
 *      1. ProtocolitesRendererAnimated (Animated canvas-based renderer)
 *      2. ProtocoliteFactory (infection contract deployer)
 *      3. ProtocolitesMaster (main NFT contract)
 *      4. Connect all contracts with proper ownership
 *
 *      Usage:
 *      forge script script/Deploy.s.sol:DeployFreshAnimatedScript \
 *        --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
 */
contract DeployFreshAnimatedScript is Script {
    /**
     * @notice Main deployment function
     * @dev Reads PRIVATE_KEY from environment and deploys complete system
     */
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying fresh Protocolites system with Animated renderer");
        console.log("Deployer address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy Animated renderer
        // This contract generates on-chain ASCII art with advanced canvas animations and temperament system
        ProtocolitesRendererAnimated renderer = new ProtocolitesRendererAnimated();
        console.log("[OK] Animated Renderer deployed at:", address(renderer));

        // Step 2: Deploy factory
        // This contract deploys individual infection contracts for each parent NFT
        ProtocoliteFactory factory = new ProtocoliteFactory();
        console.log("[OK] Factory deployed at:", address(factory));

        // Step 3: Deploy master contract
        // This is the main NFT contract that handles spawning and infections
        ProtocolitesMaster master = new ProtocolitesMaster();
        console.log("[OK] Master deployed at:", address(master));

        // Step 4: Connect all contracts with proper configuration

        // Set renderer in master (with input validation and events)
        master.setRenderer(address(renderer));
        console.log("[LINK] Master.setRenderer() called - all NFTs will use Animated renderer");

        // Set factory in master (with input validation and events)
        master.setFactory(address(factory));
        console.log("[LINK] Master.setFactory() called - master can deploy infection contracts");

        // Transfer factory ownership to master for security
        // Only master should be able to deploy infection contracts
        factory.transferOwnership(address(master));
        console.log("[SECURE] Factory ownership transferred to Master");

        // Step 5: Deployment summary
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("Contract Addresses:");
        console.log("   Master Contract:", address(master));
        console.log("   Factory Contract:", address(factory));
        console.log("   Animated Renderer:", address(renderer));
        console.log("");
        console.log("Renderer Features:");
        console.log("   - Canvas-based animations with temperament system");
        console.log("   - Per-attribute animations (breathing, blinking, waving, etc.)");
        console.log("   - Character corruption and color glitching");
        console.log("");
        console.log("Spawn Costs:");
        console.log("   Mainnet: 0.01 ETH");
        console.log("   Sepolia: 0.001 ETH");
        console.log("");
        console.log("Ready for viral infections!");
        console.log("   Send ETH to spawn spreaders");
        console.log("   Send small amounts to get infected");

        vm.stopBroadcast();
    }
}
