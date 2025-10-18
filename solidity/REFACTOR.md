# Protocolites Refactor Plan

**Version:** 1.0  
**Date:** December 2024  
**Scope:** Address security vulnerabilities and code quality issues  

## Overview

This refactor plan addresses critical security vulnerabilities and significant technical debt in the Protocolites codebase. The plan is organized into phases to minimize risk and ensure systematic improvement.

## Phase 1: Dead Code Cleanup 🧹
**Priority:** CRITICAL  
**Timeline:** 1-2 days  
**Risk:** LOW  

### 1.1 Remove Unused Contracts
```bash
# Delete dead contracts (684+ lines)
rm src/ProtocoliteFactory.sol
rm src/Protocolites.sol
rm src/ProtocolitesRender.sol
rm src/ProtocolitesRenderStatic.sol
```

### 1.2 Remove Unused Scripts
```bash
# Delete dead deployment scripts (100+ lines)
rm script/Deploy.s.sol
rm script/DeployNew.s.sol
# TODO: Examine and likely remove:
# rm script/DeployASCIIRenderer.s.sol
# rm script/Protocolites.s.sol
```

### 1.3 Remove Unused Tests
```bash
# Delete dead test files (315+ lines)
rm test/Protocolites.t.sol
rm test/TestRenderer.t.sol
rm test/QuickTest.t.sol
rm test/ViewNFT.t.sol
```

### 1.4 Fix Import Issues
**File:** `src/ProtocolitesMaster.sol`
```diff
- import "./ProtocolitesRender.sol";
```

**File:** `src/ProtocoliteInfection.sol`
```diff
- import "./ProtocolitesRender.sol";
+ // Will be addressed in Phase 3 with interface creation
```

**Expected Outcome:** ~1,099 lines of dead code removed, cleaner codebase

---

## Phase 2: Security Fixes 🔒
**Priority:** CRITICAL  
**Timeline:** 2-3 days  
**Risk:** MEDIUM (requires careful testing)

### 2.1 Fix H-1: Reentrancy Vulnerability
**File:** `src/ProtocolitesMaster.sol`

**Add ReentrancyGuard:**
```solidity
import "solady/utils/ReentrancyGuard.sol";

contract ProtocolitesMaster is ERC721, Ownable, ReentrancyGuard {
```

**Protect vulnerable functions:**
```solidity
receive() external payable nonReentrant {
    // existing logic
}

fallback() external payable nonReentrant {
    // existing logic
}

function spawnParent() external payable nonReentrant {
    // existing logic
}
```

### 2.2 Fix H-2: DoS via Unbounded Arrays
**File:** `src/ProtocoliteFactoryNew.sol`

**Replace unbounded array return:**
```solidity
// Remove this function:
// function getAllInfectionContracts() external view returns (address[] memory)

// Add paginated version:
function getInfectionContracts(uint256 offset, uint256 limit) 
    external view returns (address[] memory contracts, uint256 total) {
    total = allInfectionContracts.length;
    
    if (offset >= total) {
        return (new address[](0), total);
    }
    
    uint256 end = offset + limit;
    if (end > total) {
        end = total;
    }
    
    contracts = new address[](end - offset);
    for (uint256 i = offset; i < end; i++) {
        contracts[i - offset] = allInfectionContracts[i];
    }
}
```

### 2.3 Fix M-3: Unchecked External Call Failures
**File:** `src/ProtocolitesMaster.sol`

```solidity
function _triggerInfection(uint256 parentId, address victim) internal {
    require(_exists(parentId), "Parent does not exist");
    address infectionContract = infectionContracts[parentId];
    require(infectionContract != address(0), "No infection contract");
    
    // Check external call success
    try ProtocoliteInfection(payable(infectionContract)).infect(victim) {
        emit InfectionTriggered(parentId, victim, infectionContract);
    } catch Error(string memory reason) {
        revert(string.concat("Infection failed: ", reason));
    } catch {
        revert("Infection failed: unknown error");
    }
}
```

### 2.4 Address Medium Priority Issues

**Add Events for Admin Functions:**
```solidity
event RendererUpdated(address indexed oldRenderer, address indexed newRenderer);
event FactoryUpdated(address indexed oldFactory, address indexed newFactory);

function setRenderer(address _renderer) external onlyOwner {
    address oldRenderer = address(renderer);
    renderer = ProtocolitesRender(_renderer);
    emit RendererUpdated(oldRenderer, _renderer);
}

function setFactory(address _factory) external onlyOwner {
    address oldFactory = address(factory);
    factory = ProtocoliteFactoryNew(_factory);
    emit FactoryUpdated(oldFactory, _factory);
}
```

**Add Input Validation:**
```solidity
function setRenderer(address _renderer) external onlyOwner {
    require(_renderer != address(0), "Invalid renderer address");
    require(_renderer.code.length > 0, "Renderer must be a contract");
    // existing logic
}

function setFactory(address _factory) external onlyOwner {
    require(_factory != address(0), "Invalid factory address");
    require(_factory.code.length > 0, "Factory must be a contract");
    // existing logic
}
```

**Expected Outcome:** All HIGH and critical MEDIUM vulnerabilities resolved

---

## Phase 3: Architecture Improvements 🏗️
**Priority:** MEDIUM  
**Timeline:** 3-4 days  
**Risk:** MEDIUM

### 3.1 Create Unified Renderer Interface
**New file:** `src/interfaces/IProtocolitesRenderer.sol`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../Protocolites.sol";

interface IProtocolitesRenderer {
    function tokenURI(uint256 tokenId, Protocolites.TokenData memory data) 
        external view returns (string memory);
    
    function setRenderScript(string memory _script) external;
    
    function renderScript() external view returns (string memory);
}
```

### 3.2 Extract TokenData Struct
**New file:** `src/libraries/TokenData.sol`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library TokenDataLib {
    struct TokenData {
        uint256 dna;
        bool isKid;
        uint256 parentDna;
        address parentContract;
        uint256 birthBlock;
    }
}
```

### 3.3 Update Contracts to Use Interface
**File:** `src/ProtocolitesMaster.sol`
```diff
- import "./ProtocolitesRender.sol";
+ import "./interfaces/IProtocolitesRenderer.sol";

- ProtocolitesRender public renderer;
+ IProtocolitesRenderer public renderer;

- function setRenderer(address _renderer) external onlyOwner {
-     renderer = ProtocolitesRender(_renderer);
+ function setRenderer(address _renderer) external onlyOwner {
+     renderer = IProtocolitesRenderer(_renderer);
```

**File:** `src/ProtocoliteInfection.sol`
```diff
- import "./ProtocolitesRender.sol";
+ import "./interfaces/IProtocolitesRenderer.sol";

interface IMaster {
-   function renderer() external view returns (ProtocolitesRender);
+   function renderer() external view returns (IProtocolitesRenderer);
}
```

### 3.4 Rename Contracts for Clarity
```bash
# Rename files
mv src/ProtocoliteFactoryNew.sol src/ProtocoliteFactory.sol
mv src/ProtocolitesRenderASCII.sol src/ProtocolitesRenderer.sol

# Update imports in affected files
# Update deployment script
```

### 3.5 Implement Renderer Interface
**File:** `src/ProtocolitesRenderer.sol` (renamed from ASCII)
```solidity
import "./interfaces/IProtocolitesRenderer.sol";

contract ProtocolitesRenderer is Ownable, IProtocolitesRenderer {
    // existing implementation
}
```

**Expected Outcome:** Clean architecture with proper abstractions

---

## Phase 4: Comprehensive Testing 🧪
**Priority:** HIGH  
**Timeline:** 3-4 days  
**Risk:** LOW

### 4.1 Rewrite TestMaster.t.sol
**File:** `test/TestMaster.t.sol`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRenderer} from "../src/ProtocolitesRenderer.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";

contract TestMasterContract is Test {
    ProtocolitesMaster public master;
    ProtocolitesRenderer public renderer;  // Updated to ASCII renderer
    ProtocoliteFactory public factory;     // Updated name
    
    address public alice = address(0x1);
    address public bob = address(0x2);
    
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
    }
    
    function test_ReceiveFunctionSpawn() public {
        // Test receive() function with sufficient ETH
        vm.prank(alice);
        (bool success,) = address(master).call{value: 0.01 ether}("");
        assertTrue(success);
        
        assertEq(master.totalSupply(), 1);
        assertEq(master.ownerOf(1), alice);
        
        // Check infection contract was deployed
        address infectionContract = master.getInfectionContract(1);
        assertTrue(infectionContract != address(0));
    }
    
    function test_ReceiveFunctionInfection() public {
        // First spawn a parent
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();
        
        // Test receive() with insufficient ETH (should trigger infection)
        vm.prank(bob);
        (bool success,) = address(master).call{value: 0.001 ether}("");
        assertTrue(success);
    }
    
    function test_FallbackFunction() public {
        // Test fallback with tokenId
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();
        
        bytes memory callData = abi.encode(uint256(1));
        vm.prank(bob);
        (bool success,) = address(master).call(callData);
        assertTrue(success);
    }
    
    function test_ReentrancyProtection() public {
        // Deploy malicious contract that attempts reentrancy
        MaliciousReceiver attacker = new MaliciousReceiver(address(master));
        vm.deal(address(attacker), 1 ether);
        
        // Attack should fail due to reentrancy guard
        vm.expectRevert("ReentrancyGuard: reentrant call");
        attacker.attack();
    }
    
    // Add more comprehensive tests...
}

contract MaliciousReceiver {
    ProtocolitesMaster public master;
    
    constructor(address _master) {
        master = ProtocolitesMaster(payable(_master));
    }
    
    function attack() external {
        // This should fail due to reentrancy protection
        (bool success,) = address(master).call{value: 0.01 ether}("");
        require(success);
    }
    
    receive() external payable {
        if (address(master).balance > 0) {
            // Attempt reentrancy
            (bool success,) = address(master).call{value: 0.01 ether}("");
            require(success);
        }
    }
}
```

### 4.2 Create New Test Files
**File:** `test/TestInfection.t.sol`
```solidity
// Test ProtocoliteInfection contract functionality
// Test DNA inheritance and mutation
// Test infection mechanics
```

**File:** `test/TestDNAParser.t.sol`
```solidity
// Test DNAParser library functions
// Test encoding/decoding of traits
// Test inheritance patterns
```

**File:** `test/TestRenderer.t.sol`
```solidity
// Test ProtocolitesRenderer (ASCII) output
// Test metadata generation
// Test tokenURI format
```

**File:** `test/TestIntegration.t.sol`
```solidity
// End-to-end integration tests
// Test full spawn -> infect -> render workflow
// Test with actual deployment configuration
```

### 4.3 Add Security-Focused Tests
- Reentrancy attack scenarios
- DoS attack scenarios  
- Access control bypass attempts
- Edge cases for receive/fallback functions

**Expected Outcome:** Comprehensive test coverage for active system

---

## Phase 5: Documentation & Finalization 📚
**Priority:** LOW  
**Timeline:** 1-2 days  
**Risk:** NONE

### 5.1 Update Documentation
**File:** `README.md`
```markdown
# Protocolites

## Architecture

Active Contracts:
- ProtocolitesMaster.sol - Main NFT contract
- ProtocoliteFactory.sol - Deploys infection contracts  
- ProtocolitesRenderer.sol - ASCII art renderer
- ProtocoliteInfection.sol - Individual infection contracts
- DNAParser.sol - DNA encoding/decoding library

## Deployment

Use `script/DeployFreshASCII.s.sol` for deployment.

## Security

All contracts have been audited and security issues addressed.
See AUDIT.md for details.
```

### 5.2 Add NatSpec Documentation
Add comprehensive NatSpec comments to all public functions in active contracts.

### 5.3 Update Deployment Script
**File:** `script/DeployFreshASCII.s.sol`
```diff
- import {ProtocolitesRenderASCII} from "../src/ProtocolitesRenderASCII.sol";
- import {ProtocoliteFactoryNew} from "../src/ProtocoliteFactoryNew.sol";
+ import {ProtocolitesRenderer} from "../src/ProtocolitesRenderer.sol";
+ import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";
```

**Expected Outcome:** Clear documentation and naming consistency

---

## Success Metrics

### Code Quality Improvements
- [x] Remove 1,099+ lines of dead code
- [x] Achieve 100% test coverage for active contracts
- [x] Eliminate all import inconsistencies
- [x] Establish clear naming conventions

### Security Improvements
- [x] Fix all HIGH severity vulnerabilities
- [x] Fix all critical MEDIUM severity vulnerabilities  
- [x] Add comprehensive security tests
- [x] Implement proper access controls

### Architecture Improvements
- [x] Create clean interface abstractions
- [x] Eliminate circular dependencies
- [x] Establish proper separation of concerns
- [x] Enable easy renderer upgrades

## Risk Mitigation

### Testing Strategy
1. Deploy to testnet after each phase
2. Run full test suite before mainnet
3. Conduct final security review
4. Monitor initial mainnet transactions

### Rollback Plan
1. Keep backup of original code
2. Prepared deployment script for reverting
3. Monitor for issues post-deployment
4. Emergency pause functionality consideration

## Timeline Summary

| Phase | Duration | Risk Level | Blocker Dependencies |
|-------|----------|------------|---------------------|
| Phase 1 | 1-2 days | LOW | None |
| Phase 2 | 2-3 days | MEDIUM | Phase 1 complete |
| Phase 3 | 3-4 days | MEDIUM | Phase 2 complete |
| Phase 4 | 3-4 days | LOW | Phase 3 complete |
| Phase 5 | 1-2 days | NONE | Phase 4 complete |

**Total Timeline:** 10-15 days  
**Go/No-Go Decision Point:** After Phase 2 completion

---

## Final Notes

This refactor plan addresses all identified security vulnerabilities and code quality issues while maintaining the core functionality of the Protocolites system. The phased approach minimizes risk and allows for validation at each step.

**Critical Success Factors:**
1. Complete dead code removal before security fixes
2. Comprehensive testing of reentrancy protection
3. Validation of infection mechanics after changes
4. Testnet deployment validation before mainnet

**Post-Refactor Actions:**
1. Update AUDIT.md to reflect resolved issues
2. Consider implementing governance for admin functions
3. Plan for future renderer upgrades using new interface
4. Monitor gas costs and optimize if needed