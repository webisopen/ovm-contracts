// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Specification} from "./DataTypes.sol";

// events for the OVMGateway contract
/**
 * @dev Emitted on sendRequest()
 * @param requester The address of the requester.
 * @param requestId The unique identifier of the request.
 * @param callbackAddr The address of the callback contract.
 * @param payment The amount of tokens sent with the request.
 * @param cancelExpiration The timestamp when the request can be canceled.
 * @param deterministic Whether the request is deterministic.
 * @param data The data sent with the request.
 */
event TaskRequestSent(
    address indexed requester,
    bytes32 indexed requestId,
    address indexed callbackAddr,
    uint256 payment,
    uint256 cancelExpiration,
    bool deterministic,
    bytes data
);

/**
 * @dev Emitted on cancelRequest()
 * @param requestId The unique identifier of the request.
 */
event TaskRequestCanceled(bytes32 indexed requestId);

/**
 * @dev Emitted on setResponse()
 * @param requestId The unique identifier of the request.
 * @param data The response data.
 */
event TaskResponseSet(bytes32 indexed requestId, bytes data);

// events for the OVMClient contract
/**
 * @dev Emitted on _updateSpecification()
 * @param specification The new specification.
 */
event SpecificationUpdated(Specification specification);

/**
 * @dev Emitted on modifier recordResponse()
 * @param requestId The unique identifier of the request.
 */
event ResponseRecorded(bytes32 indexed requestId);
