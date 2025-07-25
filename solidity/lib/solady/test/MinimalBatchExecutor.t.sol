// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import {
    MinimalBatchExecutor,
    MockMinimalBatchExecutor
} from "./utils/mocks/MockMinimalBatchExecutor.sol";
import {LibClone} from "../src/utils/LibClone.sol";

contract MinimalBatchExecutorTest is SoladyTest {
    error CustomError();

    MockMinimalBatchExecutor mbe;

    address target;

    function setUp() public {
        mbe = new MockMinimalBatchExecutor();
        target = LibClone.clone(address(this));
    }

    function revertsWithCustomError() external payable {
        revert CustomError();
    }

    function returnsBytes(bytes memory b) external payable returns (bytes memory) {
        return b;
    }

    function returnsHash(bytes memory b) external payable returns (bytes32) {
        return keccak256(b);
    }

    function testMinimalBatchExecutor() public {
        vm.deal(address(this), 1 ether);

        MinimalBatchExecutor.Call[] memory calls = new MinimalBatchExecutor.Call[](2);

        calls[0].target = target;
        calls[0].value = 123;
        calls[0].data = abi.encodeWithSignature("returnsBytes(bytes)", "hehe");

        calls[1].target = target;
        calls[1].value = 789;
        calls[1].data = abi.encodeWithSignature("returnsHash(bytes)", "lol");

        bytes[] memory results = mbe.execute{value: _totalValue(calls)}(calls, "");

        assertEq(results.length, 2);
        assertEq(abi.decode(results[0], (bytes)), "hehe");
        assertEq(abi.decode(results[1], (bytes32)), keccak256("lol"));
    }

    function testMinimalBatchExecutorForRevert() public {
        MinimalBatchExecutor.Call[] memory calls = new MinimalBatchExecutor.Call[](1);
        calls[0].target = target;
        calls[0].value = 0;
        calls[0].data = abi.encodeWithSignature("revertsWithCustomError()");

        vm.expectRevert(CustomError.selector);
        mbe.execute{value: _totalValue(calls)}(calls, "");
    }

    struct Payload {
        bytes data;
        uint256 mode;
    }

    function testMinimalBatchExecutor(bytes32) public {
        vm.deal(address(this), 1 ether);

        MinimalBatchExecutor.Call[] memory calls =
            new MinimalBatchExecutor.Call[](_randomUniform() & 3);
        Payload[] memory payloads = new Payload[](calls.length);

        for (uint256 i; i < calls.length; ++i) {
            calls[i].target = target;
            calls[i].value = _randomUniform() & 0xff;
            bytes memory data = _truncateBytes(_randomBytes(), 0x1ff);
            payloads[i].data = data;
            if (_randomChance(2)) {
                payloads[i].mode = 0;
                calls[i].data = abi.encodeWithSignature("returnsBytes(bytes)", data);
            } else {
                payloads[i].mode = 1;
                calls[i].data = abi.encodeWithSignature("returnsHash(bytes)", data);
            }
        }

        bytes[] memory results = mbe.executeDirect{value: _totalValue(calls)}(calls);
        for (uint256 i; i < calls.length; ++i) {
            if (payloads[i].mode == 0) {
                assertEq(abi.decode(results[i], (bytes)), payloads[i].data);
            } else {
                assertEq(abi.decode(results[i], (bytes32)), keccak256(payloads[i].data));
            }
        }

        if (calls.length != 0 && _randomChance(32)) {
            calls[_randomUniform() % calls.length].data =
                abi.encodeWithSignature("revertsWithCustomError()");
            vm.expectRevert(CustomError.selector);
            mbe.executeDirect{value: _totalValue(calls)}(calls);
        }
    }

    function _totalValue(MinimalBatchExecutor.Call[] memory calls)
        internal
        pure
        returns (uint256 result)
    {
        unchecked {
            for (uint256 i; i < calls.length; ++i) {
                result += calls[i].value;
            }
        }
    }
}
