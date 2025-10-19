// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererAnimated} from "../src/ProtocolitesRendererAnimated.sol";

/**
 * @title DeployAnimatedRenderer
 * @author Protocolites Team
 * @notice Deployment script for upgrading to the advanced animated renderer
 * @dev This script ONLY deploys the new animated renderer and updates the existing Master contract
 *
 *      Deployment steps:
 *      1. Deploy ProtocolitesRendererAnimated (canvas-based animations)
 *      2. Update existing ProtocolitesMaster to use the new renderer
 *
 *      Usage:
 *      export MASTER_ADDRESS=0x... (your existing Master contract address)
 *      forge script script/DeployAnimatedRenderer.s.sol:DeployAnimatedRendererScript \
 *        --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
 *
 *      Features of new renderer:
 *      - Canvas-based animations instead of CSS
 *      - Temperament system (calm, balanced, energetic, chaotic, glitchy, unstable)
 *      - Per-attribute animations (breathing body, blinking eyes, waving arms, marching legs)
 *      - Character corruption and RGB color glitching based on temperament
 */
contract DeployAnimatedRendererScript is Script {
    /**
     * @notice Main deployment function
     * @dev Reads PRIVATE_KEY and MASTER_ADDRESS from environment
     *      Requires caller to be owner of the Master contract
     */
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // Get existing master contract address from environment
        address masterAddress = vm.envAddress("MASTER_ADDRESS");

        console.log("Deploying Advanced Animated Renderer");
        console.log("Deployer address:", deployer);
        console.log("Target Master contract:", masterAddress);

        // Load the existing master contract
        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));

        // Verify deployer is owner of master contract
        require(master.owner() == deployer, "Deployer must be owner of Master contract");
        console.log("[OK] Ownership verified");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy new animated renderer
        console.log("\nDeploying ProtocolitesRendererAnimated...");
        ProtocolitesRendererAnimated newRenderer = new ProtocolitesRendererAnimated();
        console.log("[OK] Animated Renderer deployed at:", address(newRenderer));

        // Step 2: Update master contract to use new renderer
        console.log("\nUpdating Master contract...");
        address oldRenderer = address(master.renderer());
        console.log("   Old renderer:", oldRenderer);

        master.setRenderer(address(newRenderer));
        console.log("[OK] Master.setRenderer() called");
        console.log("   New renderer:", address(master.renderer()));

        // Step 3: Deployment summary
        console.log("\n=== UPGRADE COMPLETE ===");
        console.log("Contract Addresses:");
        console.log("   Master Contract:", masterAddress);
        console.log("   Old Renderer:", oldRenderer);
        console.log("   New Animated Renderer:", address(newRenderer));
        console.log("");
        console.log("New Animation Features:");
        console.log("   - Canvas-based rendering with requestAnimationFrame");
        console.log("   - Temperament system affecting animation behavior");
        console.log("   - Per-attribute animations (breathing, blinking, waving, etc.)");
        console.log("   - Character corruption and color glitching");
        console.log("");
        console.log("All existing and future NFTs will now use the animated renderer!");

        vm.stopBroadcast();
    }
}
