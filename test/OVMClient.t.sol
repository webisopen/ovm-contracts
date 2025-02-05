// solhint-disable no-console,comprehensive-interface,quotes
pragma solidity 0.8.24;

import {ExecMode, GPUModel, Requirement, Specification} from "../src/libraries/DataTypes.sol";
import {SpecificationUpdated} from "../src/libraries/Events.sol";
import {MockOVMGateway} from "./mocks/MockOVMGateway.sol";
import {OVMClientImpl} from "./mocks/OVMClientImpl.sol";

import {Test} from "forge-std/Test.sol";

contract OVMClientTest is Test {
    MockOVMGateway public mockTasks;
    OVMClientImpl public ovmClient;

    address public constant alice = address(0x1111);
    address public constant bob = address(0x2222);

    function setUp() public {
        mockTasks = new MockOVMGateway();
        ovmClient = new OVMClientImpl();

        uint256 openChainTestnetId = 57770793173;
        address expectedAddress = 0xbb2F7085Ad69653B8574121A549e247B24C64f25;

        vm.chainId(openChainTestnetId);
        assertEq(ovmClient.getOVMGatewayAddress(), expectedAddress);

        ovmClient.initialize(address(mockTasks));
    }

    function testRequest() public {
        bytes32 requestId = mockTasks.mockRequestId();
        uint256 payment = 1 ether / 10;

        vm.deal(alice, payment);

        uint256 royalty = (ovmClient.getSpecification().royalty * payment) / _denominator();

        // request
        vm.prank(alice);
        ovmClient.sendRequestCalculatePI{value: payment}(7);

        // check status
        vm.assertEq(ovmClient.isPendingRequest(requestId), true);

        // check balances
        vm.assertEq(address(mockTasks).balance, payment - royalty);
        vm.assertEq(address(ovmClient).balance, royalty);
    }

    function testCancelRequest() public {
        bytes32 requestId = mockTasks.mockRequestId();

        uint256 payment = 1 ether / 10;

        vm.deal(alice, payment);

        // request
        vm.prank(alice);
        ovmClient.sendRequestCalculatePI{value: payment}(7);

        skip(5 minutes);

        // cancel request
        vm.prank(alice, alice);
        ovmClient.cancelRequest(requestId);

        vm.assertEq(ovmClient.isPendingRequest(requestId), false);
    }

    function testTaxFeeAndWithdraw() public {
        uint256 newTaxBasisPoint = 100;
        address admin = alice;

        vm.prank(admin);

        Specification memory spec = ovmClient.getSpecification();
        spec.royalty = newTaxBasisPoint;

        vm.prank(admin);
        ovmClient.updateSpecification(spec);
        vm.assertEq(ovmClient.getSpecification().royalty, newTaxBasisPoint);

        vm.deal(bob, 100 ether);

        vm.prank(bob);
        ovmClient.sendRequestCalculatePI{value: 100 ether}(7);

        vm.assertEq(
            address(mockTasks).balance, 100 ether - (100 ether * newTaxBasisPoint) / _denominator()
        );
        vm.assertEq(address(ovmClient).balance, (100 ether * newTaxBasisPoint) / _denominator());

        vm.prank(admin);
    }

    function testSetResponse() public {
        bytes32 requestId = mockTasks.mockRequestId();
        bytes memory response = bytes("3.1415926");

        vm.prank(address(mockTasks));
        ovmClient.setResponse(requestId, response);

        bool pending = ovmClient.isPendingRequest(requestId);

        vm.assertEq(pending, false);
    }

    function testSetResponseFail() public {
        bytes32 requestId = mockTasks.mockRequestId();
        bytes memory response = bytes("3.1415926");

        vm.expectRevert("Caller is not the OVMGateway contract");

        ovmClient.setResponse(requestId, response);
    }

    function testUpdateSpecification() public {
        address admin = alice;

        Specification memory newSpec;
        newSpec.name = "ovmClient";
        newSpec.version = "1.0.1";
        newSpec.description = "Calculate ovmClient";
        newSpec.repository = "https://github.com/kallydev/kallyovmClient";
        newSpec.repoTag = "0xb6a6502fa480fd1fb5bf95c1fb1366bcbc335a08356c2a97daf6bc44e9cc0000";
        newSpec.license = "WTFPL";
        newSpec.requirement = Requirement({
            ram: "256mb",
            disk: "5mb",
            timeout: 600,
            gpu: 1,
            gpuModel: GPUModel.T4,
            cpu: 1
        });
        newSpec.royalty = 5;
        newSpec.execMode = ExecMode.JIT;

        vm.expectEmit(true, true, true, true);
        emit SpecificationUpdated(newSpec);
        vm.prank(admin);
        ovmClient.updateSpecification(newSpec);

        // check specification
        Specification memory spec = ovmClient.getSpecification();
        assertEq(spec.version, "1.0.1");
        assertEq(spec.description, "Calculate ovmClient");
        assertEq(spec.royalty, 5);
    }

    function _denominator() internal pure virtual returns (uint96) {
        return 10_000;
    }
}
