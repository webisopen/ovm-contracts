// solhint-disable no-console,comprehensive-interface,quotes
pragma solidity 0.8.24;

import {DeployConfig} from "../script/DeployConfig.s.sol";
import {OVMTasks} from "../src/OVMTasks.sol";
import {Commitment} from "../src/libraries/DataTypes.sol";
import {
    CallbackAddressIsNotContract,
    InvalidRequesterOrCallback,
    RequestNotExpired
} from "../src/libraries/Errors.sol";
import {TaskRequestCanceled, TaskRequestSent, TaskResponseSet} from "../src/libraries/Events.sol";

import {OVMClientImpl} from "./mocks/OVMClientImpl.sol";
import {TransparentUpgradeableProxy} from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Test} from "forge-std/Test.sol";

contract OVMTasksTest is Test {
    OVMClientImpl public ovmClient;
    OVMTasks public tasks;

    address public constant nodeOperator = address(0xaaaa);
    address public constant alice = address(0x1111);
    DeployConfig internal _cfg;

    function setUp() public {
        // read config from local.json
        string memory path = string.concat(vm.projectRoot(), "/deploy-config/", "local" ".json");
        _cfg = new DeployConfig(path);

        // deploy OVMTasks contract
        OVMTasks tasksImpl = new OVMTasks();
        TransparentUpgradeableProxy tasksProxy =
            new TransparentUpgradeableProxy(address(tasksImpl), _cfg.proxyAdminOwner(), "");
        tasks = OVMTasks(payable(tasksProxy));

        ovmClient = new OVMClientImpl(address(tasks), _cfg.templateAdmin());
    }

    function testRequest() public {
        bytes32 requestId = keccak256(abi.encodePacked(address(tasks), uint256(1)));
        uint256 payment = 1 ether / 10;
        bool deterministic = ovmClient.REQ_DETERMINISTIC();

        vm.deal(address(this), payment);

        // request
        vm.expectEmit(true, true, true, true);
        emit TaskRequestSent(
            alice,
            requestId,
            address(this),
            payment,
            block.timestamp + 5 minutes,
            deterministic,
            abi.encode(7)
        );
        tasks.sendRequest{value: payment}(alice, address(this), deterministic, abi.encode(7));

        // check status
        Commitment memory commitment = tasks.getCommitments(requestId);
        vm.assertEq(commitment.requester, alice);
        vm.assertEq(commitment.callbackAddress, address(this));
        vm.assertEq(commitment.payment, payment);
        vm.assertEq(commitment.cancelExpiration, block.timestamp + 5 minutes);

        // check balances
        vm.assertEq(address(tasks).balance, payment);

        // check request count
        vm.assertEq(tasks.getRequestsCount(), 1);
    }

    function testRequestFail() public {
        vm.deal(address(this), 1 ether);

        address callbackAddress = address(0x1234);

        // request
        vm.expectRevert(
            abi.encodeWithSelector(CallbackAddressIsNotContract.selector, callbackAddress)
        );
        tasks.sendRequest{value: 1 ether}(alice, callbackAddress, true, abi.encode(7));
    }

    function testCancelRequest() public {
        bytes32 requestId = keccak256(abi.encodePacked(address(tasks), uint256(1)));
        uint256 payment = 1 ether / 10;

        vm.deal(address(this), payment);

        // request
        tasks.sendRequest{value: payment}(
            alice, address(this), ovmClient.REQ_DETERMINISTIC(), abi.encode(7)
        );

        skip(5 minutes);

        // cancel request
        vm.expectEmit(true, true, true, true);
        emit TaskRequestCanceled(requestId);
        vm.prank(address(this), alice);
        tasks.cancelRequest(requestId);

        // check status
        _assertEmptyCommitment(requestId);
    }

    function testCancelRequestFail() public {
        bytes32 requestId = keccak256(abi.encodePacked(address(tasks), uint256(1)));
        uint256 payment = 1 ether / 10;

        vm.deal(address(this), payment);

        // request
        tasks.sendRequest{value: payment}(
            alice, address(this), ovmClient.REQ_DETERMINISTIC(), abi.encode(uint256(7))
        );

        skip(4 minutes);

        // cancel request
        // case 1: RequestNotExpired
        vm.expectRevert(abi.encodeWithSelector(RequestNotExpired.selector));
        vm.prank(address(this), alice);
        tasks.cancelRequest(requestId);

        // case 2: InvalidRequesterOrCallback
        address sender = address(0x123);
        skip(5 minutes);
        vm.expectRevert(
            abi.encodeWithSelector(InvalidRequesterOrCallback.selector, sender, address(this))
        );
        vm.prank(address(this), sender);
        tasks.cancelRequest(requestId);
    }

    function testSetResponse() public {
        uint256 payment = 1 ether / 10;

        vm.deal(alice, payment);

        // request
        vm.prank(alice);
        bytes32 requestId = ovmClient.sendRequestCalculatePI{value: payment}(7);

        bytes memory data = abi.encode(true, "3.1415");

        // set response
        vm.expectEmit(true, true, true, true);
        emit TaskResponseSet(requestId, data);
        vm.prank(nodeOperator);
        tasks.setResponse(requestId, data);

        // check status
        _assertEmptyCommitment(requestId);
        // check balances
        vm.assertEq(address(tasks).balance, 0);
        vm.assertEq(
            nodeOperator.balance, payment * (10000 - ovmClient.getSpecification().royalty) / 10000
        );
    }

    function testSetupState() public view {
        vm.assertEq(tasks.getRequestsCount(), 0);
    }

    function _assertEmptyCommitment(bytes32 requestId) internal view {
        Commitment memory commitment = tasks.getCommitments(requestId);
        vm.assertEq(commitment.requester, address(0));
        vm.assertEq(commitment.callbackAddress, address(0));
        vm.assertEq(commitment.payment, 0);
        vm.assertEq(commitment.cancelExpiration, 0);
    }
}
