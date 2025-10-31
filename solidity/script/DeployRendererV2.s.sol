// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRendererV2} from "../src/ProtocolitesRendererV2.sol";

/**
 * @title DeployRendererV2
 * @author Protocolites Team
 * @notice Deployment script for upgrading to the V2 DOM-based renderer
 * @dev This script ONLY deploys the new V2 renderer and updates the existing Master contract
 *
 *      Deployment steps:
 *      1. Deploy ProtocolitesRendererV2 (DOM-based animations)
 *      2. Update existing ProtocolitesMaster to use the new renderer
 *
 *      Usage:
 *      export MASTER_ADDRESS=0x... (your existing Master contract address)
 *      forge script script/DeployRendererV2.s.sol:DeployRendererV2Script \
 *        --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
 *
 *      Features of V2 renderer:
 *      - DOM-based rendering with per-character positioning
 *      - Crisp text rendering (no canvas blur)
 *      - Temperament system (calm, balanced, energetic, chaotic, glitchy, unstable)
 *      - Per-character type tracking (body, eye, arm, leg, antenna, etc.)
 *      - Attribute-specific animations (breathing, blinking, waving, marching)
 *      - Row-based glitches and character corruption
 */
contract DeployRendererV2Script is Script {
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

        console.log("Deploying ProtocolitesRendererV2 (DOM-based)");
        console.log("Deployer address:", deployer);
        console.log("Target Master contract:", masterAddress);

        // Load the existing master contract
        ProtocolitesMaster master = ProtocolitesMaster(payable(masterAddress));

        // Verify deployer is owner of master contract
        require(master.owner() == deployer, "Deployer must be owner of Master contract");
        console.log("[OK] Ownership verified");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy new V2 renderer
        console.log("\nDeploying ProtocolitesRendererV2...");
        ProtocolitesRendererV2 newRenderer = new ProtocolitesRendererV2();
        console.log("[OK] RendererV2 deployed at:", address(newRenderer));

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
        console.log("   New V2 Renderer:", address(newRenderer));
        console.log("");
        console.log("New V2 Features:");
        console.log("   - DOM-based rendering (crisp text, no blur)");
        console.log("   - Per-character absolute positioning");
        console.log("   - Character type tracking system");
        console.log("   - Temperament-based animation intensity");
        console.log("   - Breathing, blinking, waving, marching animations");
        console.log("   - Row glitches and character corruption effects");
        console.log("");
        console.log("All existing and future NFTs will now use the V2 renderer!");

        vm.stopBroadcast();
    }
}
