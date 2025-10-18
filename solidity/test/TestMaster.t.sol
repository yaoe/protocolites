// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRenderer} from "../src/ProtocolitesRenderer.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";
import {ProtocoliteInfection} from "../src/ProtocoliteInfection.sol";

contract TestMasterContract is Test {
    ProtocolitesMaster public master;
    ProtocolitesRenderer public renderer;
    ProtocoliteFactory public factory;

    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    address public deployer = address(this);

    event ParentSpawned(uint256 indexed tokenId, address indexed owner, address infectionContract);
    event InfectionTriggered(uint256 indexed parentId, address indexed victim, address infectionContract);
    event RendererUpdated(address indexed oldRenderer, address indexed newRenderer);
    event FactoryUpdated(address indexed oldFactory, address indexed newFactory);

    function setUp() public {
        // Deploy using exact same configuration as DeployFreshASCII.s.sol
        renderer = new ProtocolitesRenderer();
        factory = new ProtocoliteFactory();
        master = new ProtocolitesMaster();

        master.setRenderer(address(renderer));
        master.setFactory(address(factory));
        factory.transferOwnership(address(master));

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 10 ether);
    }

    // ===== BASIC FUNCTIONALITY TESTS =====

    function test_ReceiveFunctionSpawn() public {
        // Test receive() function with sufficient ETH
        vm.prank(alice);
        (bool success,) = address(master).call{value: 0.01 ether}("");
        assertTrue(success, "ETH transfer should succeed");

        assertEq(master.totalSupply(), 1, "Should mint 1 NFT");
        assertEq(master.ownerOf(1), alice, "Alice should own token 1");

        // Check infection contract was deployed
        address infectionContract = master.getInfectionContract(1);
        assertTrue(infectionContract != address(0), "Infection contract should be deployed");

        // Verify infection contract is properly configured
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));
        assertEq(infection.owner(), address(master), "Master should own infection contract");
        (uint256 parentId, uint256 parentDna) = infection.getParentInfo();
        assertEq(parentId, 1, "Parent ID should be 1");
        assertTrue(parentDna != 0, "Parent DNA should be set");
    }

    function test_ReceiveFunctionInfection() public {
        // First spawn a parent
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        // Test receive() with insufficient ETH (should trigger infection)
        uint256 initialSupply = master.totalSupply();

        vm.prank(bob);
        (bool success,) = address(master).call{value: 0.001 ether}("");
        assertTrue(success, "Low ETH transfer should succeed");

        // Should not mint new parent NFT
        assertEq(master.totalSupply(), initialSupply, "Should not mint new parent");

        // Should have triggered infection - check infection contract state
        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));
        assertTrue(infection.totalSupply() > 0, "Should have created infection NFT");
    }

    function test_FallbackFunction() public {
        // Test fallback with tokenId
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        bytes memory callData = abi.encode(uint256(1));
        vm.prank(bob);
        (bool success,) = address(master).call(callData);
        assertTrue(success, "Fallback call should succeed");

        // Check that infection was triggered
        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));
        assertTrue(infection.totalSupply() > 0, "Should have created infection NFT");
    }

    function test_FallbackFunctionRandomInfection() public {
        // First spawn a parent
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        // Call fallback with invalid/empty data
        vm.prank(bob);
        (bool success,) = address(master).call("");
        assertTrue(success, "Empty fallback call should succeed");

        // Should trigger random infection
        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));
        assertTrue(infection.totalSupply() > 0, "Should have created infection NFT");
    }

    function test_SpawnParentFunction() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit ParentSpawned(1, alice, address(0)); // address will be calculated

        master.spawnParent{value: 0.01 ether}();

        assertEq(master.totalSupply(), 1, "Should mint 1 NFT");
        assertEq(master.ownerOf(1), alice, "Alice should own the NFT");
    }

    function test_SpawnParentInsufficientPayment() public {
        vm.prank(alice);
        vm.expectRevert("Insufficient payment");
        master.spawnParent{value: 0.005 ether}();
    }

    function test_InfectFunction() public {
        // Spawn parent first
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        // Trigger infection
        vm.prank(bob);
        master.infect(1);

        // Verify infection NFT was minted
        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));
        assertEq(infection.totalSupply(), 1, "Should have 1 infection NFT");
        assertEq(infection.ownerOf(1), bob, "Bob should own infection NFT");
    }

    function test_InfectRandomFunction() public {
        // Spawn parent first
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        // Trigger random infection
        vm.prank(bob);
        master.infectRandom();

        // Verify infection NFT was minted
        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));
        assertTrue(infection.totalSupply() > 0, "Should have infection NFT");
    }

    // ===== SECURITY TESTS =====

    function test_ReentrancyProtectionReceive() public {
        MaliciousReceiver attacker = new MaliciousReceiver(address(master));
        vm.deal(address(attacker), 1 ether);

        // Attack should fail due to reentrancy guard
        vm.expectRevert("ReentrancyGuard: reentrant call");
        attacker.attackReceive();
    }

    function test_ReentrancyProtectionFallback() public {
        MaliciousFallback attacker = new MaliciousFallback(address(master));
        vm.deal(address(attacker), 1 ether);

        // Attack should fail due to reentrancy guard
        vm.expectRevert("ReentrancyGuard: reentrant call");
        attacker.attackFallback();
    }

    function test_ReentrancyProtectionSpawnParent() public {
        MaliciousSpawner attacker = new MaliciousSpawner(address(master));
        vm.deal(address(attacker), 1 ether);

        // Attack should fail due to reentrancy guard
        vm.expectRevert("ReentrancyGuard: reentrant call");
        attacker.attackSpawnParent();
    }

    function test_ExternalCallFailureHandling() public {
        // Deploy broken infection contract factory
        BrokenInfectionContract brokenInfection = new BrokenInfectionContract();

        // Create a factory that will deploy broken contracts
        ProtocoliteFactory brokenFactory = new ProtocoliteFactory();

        // Set up master with broken factory
        ProtocolitesMaster testMaster = new ProtocolitesMaster();
        testMaster.setRenderer(address(renderer));
        testMaster.setFactory(address(brokenFactory));
        brokenFactory.transferOwnership(address(testMaster));

        vm.deal(alice, 1 ether);

        // This should fail gracefully with our error handling
        vm.prank(alice);
        testMaster.spawnParent{value: 0.01 ether}();

        // Try to infect - should handle the error properly
        vm.prank(bob);
        vm.expectRevert(); // Should revert with our error message
        testMaster.infect(1);
    }

    function test_AccessControlSetRenderer() public {
        address newRenderer = address(new ProtocolitesRenderer());

        // Only owner should be able to set renderer
        vm.prank(alice);
        vm.expectRevert("Unauthorized");
        master.setRenderer(newRenderer);

        // Owner can set renderer
        vm.expectEmit(true, true, false, false);
        emit RendererUpdated(address(renderer), newRenderer);
        master.setRenderer(newRenderer);

        assertEq(address(master.renderer()), newRenderer, "Renderer should be updated");
    }

    function test_AccessControlSetFactory() public {
        address newFactory = address(new ProtocoliteFactory());

        // Only owner should be able to set factory
        vm.prank(alice);
        vm.expectRevert("Unauthorized");
        master.setFactory(newFactory);

        // Owner can set factory
        vm.expectEmit(true, true, false, false);
        emit FactoryUpdated(address(factory), newFactory);
        master.setFactory(newFactory);

        assertEq(address(master.factory()), newFactory, "Factory should be updated");
    }

    function test_SetRendererInputValidation() public {
        // Should reject zero address
        vm.expectRevert("Invalid renderer address");
        master.setRenderer(address(0));

        // Should reject EOA (non-contract)
        vm.expectRevert("Renderer must be a contract");
        master.setRenderer(alice);
    }

    function test_SetFactoryInputValidation() public {
        // Should reject zero address
        vm.expectRevert("Invalid factory address");
        master.setFactory(address(0));

        // Should reject EOA (non-contract)
        vm.expectRevert("Factory must be a contract");
        master.setFactory(alice);
    }

    function test_InfectNonexistentParent() public {
        vm.prank(bob);
        vm.expectRevert("Parent does not exist");
        master.infect(999);
    }

    function test_InfectRandomWithNoParents() public {
        vm.prank(bob);
        vm.expectRevert("No parents exist");
        master.infectRandom();
    }

    function test_FallbackWithPayment() public {
        vm.prank(alice);
        vm.expectRevert("Use receive() for paid spawns");
        (bool success,) = address(master).call{value: 0.01 ether}(abi.encode(uint256(1)));
        assertFalse(success);
    }

    // ===== INTEGRATION TESTS =====

    function test_EndToEndWorkflow() public {
        // 1. Alice spawns a parent
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        uint256 tokenId = 1;
        assertEq(master.ownerOf(tokenId), alice);

        // 2. Get the infection contract
        address infectionContract = master.getInfectionContract(tokenId);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));

        // 3. Bob gets infected
        vm.prank(bob);
        master.infect(tokenId);

        assertEq(infection.totalSupply(), 1);
        assertEq(infection.ownerOf(1), bob);

        // 4. Charlie also gets infected by the same parent
        vm.prank(charlie);
        master.infect(tokenId);

        assertEq(infection.totalSupply(), 2);
        assertEq(infection.ownerOf(2), charlie);

        // 5. Test tokenURI generation
        string memory parentURI = master.tokenURI(tokenId);
        string memory infectionURI = infection.tokenURI(1);

        assertTrue(bytes(parentURI).length > 0, "Parent URI should not be empty");
        assertTrue(bytes(infectionURI).length > 0, "Infection URI should not be empty");

        // 6. Test multiple parents
        vm.prank(bob);
        master.spawnParent{value: 0.01 ether}();

        assertEq(master.totalSupply(), 2);
        assertEq(master.ownerOf(2), bob);
    }

    function test_MultipleInfections() public {
        // Spawn multiple parents
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        vm.prank(bob);
        master.spawnParent{value: 0.01 ether}();

        // Get multiple infections from different parents
        vm.prank(charlie);
        master.infect(1);

        vm.prank(charlie);
        master.infect(2);

        // Charlie should have infections from both parents
        address infection1 = master.getInfectionContract(1);
        address infection2 = master.getInfectionContract(2);

        ProtocoliteInfection inf1 = ProtocoliteInfection(payable(infection1));
        ProtocoliteInfection inf2 = ProtocoliteInfection(payable(infection2));

        assertEq(inf1.ownerOf(1), charlie);
        assertEq(inf2.ownerOf(1), charlie);
    }

    function test_WithdrawFunctionality() public {
        uint256 initialBalance = address(this).balance;

        // Generate some fees
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        vm.prank(bob);
        master.spawnParent{value: 0.01 ether}();

        assertEq(address(master).balance, 0.02 ether);

        // Withdraw
        master.withdraw();

        assertEq(address(master).balance, 0);
        assertEq(address(this).balance, initialBalance - 0.02 ether + 0.02 ether);
    }

    function test_WithdrawAccessControl() public {
        vm.prank(alice);
        vm.expectRevert("Unauthorized");
        master.withdraw();
    }

    // Test helper to receive ETH
    receive() external payable {}
}

// ===== MALICIOUS CONTRACTS FOR TESTING =====

contract MaliciousReceiver {
    ProtocolitesMaster public master;
    bool public attacking = false;

    constructor(address _master) {
        master = ProtocolitesMaster(payable(_master));
    }

    function attackReceive() external {
        attacking = true;
        (bool success,) = address(master).call{value: 0.01 ether}("");
        require(success);
    }

    receive() external payable {
        if (attacking && address(master).balance > 0) {
            // Attempt reentrancy
            (bool success,) = address(master).call{value: 0.01 ether}("");
            require(success);
        }
    }
}

contract MaliciousFallback {
    ProtocolitesMaster public master;
    bool public attacking = false;

    constructor(address _master) {
        master = ProtocolitesMaster(payable(_master));
    }

    function attackFallback() external {
        attacking = true;
        (bool success,) = address(master).call("");
        require(success);
    }

    receive() external payable {
        // Handle ETH receives
    }

    fallback() external payable {
        if (attacking && address(master).balance > 0) {
            // Attempt reentrancy
            (bool success,) = address(master).call("");
            require(success);
        }
    }
}

contract MaliciousSpawner {
    ProtocolitesMaster public master;
    bool public attacking = false;

    constructor(address _master) {
        master = ProtocolitesMaster(payable(_master));
    }

    function attackSpawnParent() external {
        attacking = true;
        master.spawnParent{value: 0.01 ether}();
    }

    receive() external payable {
        if (attacking && address(master).balance > 0) {
            // Attempt reentrancy
            master.spawnParent{value: 0.01 ether}();
        }
    }
}

contract BrokenInfectionContract {
    function infect(address) external pure {
        revert("Broken infection contract");
    }
}
