// solhint-disable no-console,comprehensive-interface,quotes,no-unused-vars,no-empty-blocks
pragma solidity 0.8.24;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract MockOVMGateway {
    using Address for address;

    bytes32 public mockRequestId = keccak256(abi.encodePacked(address(this), uint256(1)));

    function sendRequest(
        address requester,
        address callbackAddress,
        bool deterministic,
        bytes calldata data
    ) external payable returns (bytes32 requestId) {
        return mockRequestId;
    }

    function cancelRequest(bytes32 requestId) external {}
}
