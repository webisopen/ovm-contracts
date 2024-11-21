// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Specification} from "../libraries/DataTypes.sol";

/**
 * @title IOVMClient
 * @notice The IOVMClient contract interface.
 */
interface IOVMClient {
    /**
     * @notice Cancels a request by its requestId.
     * Emits a {RequestCancelled} event.
     * @param requestId The ID of the request to be cancelled.
     */
    function cancelRequest(bytes32 requestId) external;

    /**
     * @dev Sets the response data for a specific request. This function is called by the OVMGateway
     * contract.
     * @param requestId The ID of the request.
     * @param data The response data to be set.
     */
    function setResponse(bytes32 requestId, bytes calldata data) external;

    /**
     * @dev Updates the specification of the OVM client.
     * @param newSpec The new specification to update.
     */
    function updateSpecification(Specification calldata newSpec) external;

    /**
     * @notice Withdraws the contract's balance to the contract owner.
     */
    function withdraw() external;

    /**
     * @notice Checks if a request is pending.
     * @param requestId The ID of the request.
     * @return isPending True if the request is pending, otherwise false.
     */
    function isPendingRequest(bytes32 requestId) external view returns (bool);

    /**
     * @notice Returns the specification of the contract.
     * @return specification The specification of the contract.
     */
    function getSpecification() external view returns (Specification memory);

    /**
     * @notice Get the address of the OVMGateway contract.
     * @return The address of the OVMGateway contract.
     */
    function getOVMGatewayAddress() external view returns (address);
}
