// SPDX-License-Identifier: MIT
// solhint-disable var-name-mixedcase,quotes,comprehensive-interface
pragma solidity 0.8.24;

import {OVMClient} from "../../src/OVMClient.sol";

contract OVMClientImpl is OVMClient {
    bool public constant REQ_DETERMINISTIC = true;

    mapping(bytes32 requestId => bytes data) internal _responseData;

    /**
     * @dev Constructor function for the PI contract.
     * @param OVMGatewayAddress The address of the OVMGateway contract.
     * @param admin The address of the admin.
     */
    constructor(address OVMGatewayAddress, address admin) OVMClient(OVMGatewayAddress, admin) {}

    /**
     * @dev Sends a request to calculate the value of PI with a specified number of digits.
     * @param numDigits The number of digits to calculate for PI.
     * @return requestId The ID of the request returned by the OVMGateway contract.
     */
    function sendRequestCalculatePI(uint256 numDigits)
        external
        payable
        returns (bytes32 requestId)
    {
        // encode the data
        bytes memory data = abi.encode(numDigits);
        requestId = _sendRequest(msg.sender, msg.value, REQ_DETERMINISTIC, data);
    }

    /**
     * @dev Sets the response data for a specific request. This function is called by the OVMGateway
     * contract.
     * @param requestId The ID of the request.
     * @param data The response data to be set.
     */
    function setResponse(bytes32 requestId, bytes calldata data)
        external
        recordResponse(requestId)
        onlyOVMGateway
    {
        _responseData[requestId] = data;
    }
}
