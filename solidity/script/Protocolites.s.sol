// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Protocolites} from "../src/Protocolites.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";

contract ProtocoliteScript is Script {
    Protocolites public protocolites;
    ProtocolitesRender public renderer;
    ProtocoliteFactory public factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy renderer
        renderer = new ProtocolitesRender();
        console.log("Renderer deployed at:", address(renderer));

        // Deploy factory
        factory = new ProtocoliteFactory();
        console.log("Factory deployed at:", address(factory));

        // Deploy first Protocolites contract
        protocolites = new Protocolites();
        console.log("Protocolites deployed at:", address(protocolites));

        // Set up connections
        protocolites.setRenderer(address(renderer));
        protocolites.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        factory.registerProtocolite(address(protocolites));

        vm.stopBroadcast();
    }
}
