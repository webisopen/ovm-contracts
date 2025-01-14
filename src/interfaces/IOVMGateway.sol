// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Commitment, Specification} from "../libraries/DataTypes.sol";

/**
 * @title OVMGateway
 * @notice The OVMGateway contract interface.
 */
interface IOVMGateway {
    /**
     * @dev Sends a request to execute a task.
     * @param requester The address of the requester.
     * @param callbackAddress The address of the contract to receive the callback.
     * @param deterministic Whether the request is deterministic.
     * @param data The data to be passed to the callback function.
     *  msg.value is the payment for the task.
     * @return requestId The unique identifier for the request.
     */
    function sendRequest(
        address requester,
        address callbackAddress,
        bool deterministic,
        bytes calldata data
    ) external payable returns (bytes32 requestId);

    /**
     * @notice Cancels a request.
     * @param requestId The request ID to cancel.
     */
    function cancelRequest(bytes32 requestId) external;

    /**
     * @dev Sets the response for a given requestId.
     * @param requestId The unique identifier for the request.
     * @param data The response data to be set.
     * @param envProof The environment proof to be set.
     * @param inputProof The input proof to be set.
     * @param outputProof The output proof to be set.
     * @param rootProof The root proof to be set.
     */
    function setResponse(
        bytes32 requestId,
        bytes calldata data,
        string calldata envProof,
        string calldata inputProof,
        string calldata outputProof,
        string calldata rootProof
    ) external;

    /**
     * @notice Gets the specification of the callback contract.
     * @param callbackAddress The address of the callback contract.
     * @return specification The specification of the callback contract.
     */
    function getSpecification(address callbackAddress)
        external
        view
        returns (Specification memory);

    /**
     * @notice Gets the commitments of a request.
     * @param requestId The request ID to get the commitments for.
     * @return commitments The commitments of the request.
     */
    function getCommitments(bytes32 requestId) external view returns (Commitment memory);

    /**
     * @notice Gets the number of requests.
     * @return count The number of requests.
     */
    function getRequestsCount() external view returns (uint256);
}
