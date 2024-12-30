// SPDX-License-Identifier: MIT
// solhint-disable var-name-mixedcase,immutable-vars-naming
pragma solidity 0.8.24;

import {IOVMClient} from "./interfaces/IOVMClient.sol";
import {IOVMGateway} from "./interfaces/IOVMGateway.sol";
import {Specification} from "./libraries/DataTypes.sol";
import {ResponseRecorded, SpecificationUpdated} from "./libraries/Events.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * THIS EXAMPLE USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
abstract contract OVMClient is IOVMClient {
    uint96 public constant DENOMINATOR = 10000;

    /// @dev address of the OVMGateway contract
    address private _OVMGateway;
    /// @dev pending requests are requests that are not yet responded by the OVM task contract
    mapping(bytes32 requestId => bool isPending) private _pendingRequests;

    /// @dev specification is the metadata of the OVM client
    Specification private _specification;

    /**
     * @dev Modifier to record the response of a request.
     * It removes the pending request, emits a `ResponseRecorded` event, and then executes the
     * function.
     * @param requestId The ID of the request to record the response for.
     */
    modifier recordResponse(bytes32 requestId) {
        _removePendingRequest(requestId);
        emit ResponseRecorded(requestId);
        _;
    }

    /* @notice It is supposed to be used along with setResponse */
    modifier onlyOVMGateway() {
        address ovmGateway = _getOVMGatewayAddress();
        require(ovmGateway != address(0), "OVMGateway is not set");
        require(msg.sender == ovmGateway, "Caller is not the OVMGateway contract");
        _;
    }

    /// @inheritdoc IOVMClient
    function cancelRequest(bytes32 requestId) public virtual override {
        address ovmGateway = _getOVMGatewayAddress();
        IOVMGateway(ovmGateway).cancelRequest(requestId);
        _removePendingRequest(requestId);
    }

    /// @inheritdoc IOVMClient
    function isPendingRequest(bytes32 requestId) public view virtual override returns (bool) {
        return _pendingRequests[requestId];
    }

    /// @inheritdoc IOVMClient
    function getSpecification() public view virtual override returns (Specification memory) {
        return _specification;
    }

    /// @inheritdoc IOVMClient
    function getOVMGatewayAddress() public view virtual override returns (address) {
        return _getOVMGatewayAddress();
    }

    /**
     * @dev Updates the specification of the OVM client.
     * @param spec The new specification to update.
     */
    function _updateSpecification(Specification memory spec) internal {
        _specification.name = spec.name;
        _specification.version = spec.version;
        _specification.description = spec.description;
        _specification.repository = spec.repository;
        _specification.repoTag = spec.repoTag;
        _specification.license = spec.license;
        _specification.requirement = spec.requirement;
        _specification.apiABIs = spec.apiABIs;
        _specification.royalty = spec.royalty;
        _specification.execMode = spec.execMode;

        emit SpecificationUpdated(spec);
    }

    /**
     * @dev Creates a request that can hold additional parameters.
     * @param requester The address to send the requester.
     * @param payment The amount of payment to send with the request.
     * @param deterministic Whether the request is deterministic.
     * @param data The data encoded with computing params to send in the request.
     * @return requestId The new ID of the request.
     */
    function _sendRequest(address requester, uint256 payment, bool deterministic, bytes memory data)
        internal
        virtual
        returns (bytes32 requestId)
    {
        // calculate royalty, 1 basis point is 0.01%
        // the royalty will be deducted from the payment
        uint256 royalty = (payment * _specification.royalty) / DENOMINATOR;
        address ovmGateway = _getOVMGatewayAddress();
        requestId = IOVMGateway(ovmGateway).sendRequest{value: payment - royalty}(
            requester, address(this), deterministic, data
        );
        // mark the request as pending
        _pendingRequests[requestId] = true;
    }

    /**
     * @dev Removes a pending request.
     * @param requestId The ID of the pending request to be removed.
     */
    function _removePendingRequest(bytes32 requestId) internal virtual {
        delete _pendingRequests[requestId];
    }

    /**
     * @dev Update the address of the OVMGateway contract
     * @param OVMGateway The address of the OVMGateway contract
     */
    function _updateOVMGatewayAddress(address OVMGateway) internal {
        _OVMGateway = OVMGateway;
    }

    /**
     * @dev Get the address of the OVMGateway contract
     * @return The address of the OVMGateway contract
     */
    function _getOVMGatewayAddress() internal view returns (address) {
        if (_OVMGateway != address(0)) {
            return _OVMGateway;
        }

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        // OpenChain Testnet
        if (chainId == 57770793173) {
            return 0xbb2F7085Ad69653B8574121A549e247B24C64f25; // 替换为特定链上的固定地址
        } else {
            return address(0);
        }
    }
}
