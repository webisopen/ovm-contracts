// SPDX-License-Identifier: MIT
// solhint-disable avoid-tx-origin
pragma solidity 0.8.24;

import {IOVMClient} from "./interfaces/IOVMClient.sol";
import {IOVMGateway} from "./interfaces/IOVMGateway.sol";
import {Commitment, Specification} from "./libraries/DataTypes.sol";
import {
    CallbackAddressIsNotContract,
    InvalidRequesterOrCallback,
    RequestNotExpired
} from "./libraries/Errors.sol";
import {TaskRequestCanceled, TaskRequestSent, TaskResponseSet} from "./libraries/Events.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * THIS EXAMPLE USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract OVMGateway is IOVMGateway {
    using Address for address;

    /// @dev The time after which a request can be canceled
    uint256 public constant EXPIRYTIME = 5 minutes;

    uint256 internal _requestCount;
    /// @dev  a commitment is a request that has not been fulfilled yet
    mapping(bytes32 requestId => Commitment commitment) internal _commitments;

    /// @dev Tokens sent for requests that have not been fulfilled yet
    uint256 internal _tokensInEscrow;

    /// @inheritdoc IOVMGateway
    function sendRequest(
        address requester,
        address callbackAddress,
        bool deterministic,
        bytes calldata data
    ) external payable override returns (bytes32 requestId) {
        uint256 payment = msg.value;
        requestId = keccak256(abi.encodePacked(this, ++_requestCount));
        uint256 cancelExpiration = block.timestamp + EXPIRYTIME;

        // check if the callbackAddress is a contract
        if (callbackAddress.code.length == 0) {
            revert CallbackAddressIsNotContract(callbackAddress);
        }

        // save the commitment
        _commitments[requestId] = Commitment({
            requester: requester,
            callbackAddress: callbackAddress,
            payment: payment,
            cancelExpiration: cancelExpiration
        });
        // escrow the payment
        _tokensInEscrow += payment;

        emit TaskRequestSent(
            requester, requestId, callbackAddress, payment, cancelExpiration, deterministic, data
        );
    }

    /// @inheritdoc IOVMGateway
    function cancelRequest(bytes32 requestId) external override {
        Commitment memory commitment = _commitments[requestId];

        // only the requester or the callback contract can cancel the request
        if (tx.origin != commitment.requester || msg.sender != commitment.callbackAddress) {
            revert InvalidRequesterOrCallback(tx.origin, msg.sender);
        }
        //  the request can only be canceled after the expiration time
        if (block.timestamp < commitment.cancelExpiration) {
            revert RequestNotExpired();
        }

        // delete the commitment
        delete _commitments[requestId];

        emit TaskRequestCanceled(requestId);

        // free up the escrowed funds, as we're sending them back to the requester
        _tokensInEscrow -= commitment.payment;
        _transfer(commitment.requester, commitment.payment);
    }

    /// @inheritdoc IOVMGateway
    function setResponse(bytes32 requestId, bytes calldata data) external override {
        Commitment memory commitment = _commitments[requestId];

        // free up the escrowed funds
        _tokensInEscrow -= commitment.payment;
        // delete the commitment
        delete _commitments[requestId];

        emit TaskResponseSet(requestId, data);

        // transfer the payment to caller
        _transfer(msg.sender, commitment.payment);

        // call the callback function `setResponse` to set the response
        commitment.callbackAddress.functionCall(
            abi.encodeCall(IOVMClient.setResponse, (requestId, data))
        );
    }

    /// @inheritdoc IOVMGateway
    function getSpecification(address callbackAddress)
        external
        view
        override
        returns (Specification memory)
    {
        return IOVMClient(callbackAddress).getSpecification();
    }

    /// @inheritdoc IOVMGateway
    function getCommitments(bytes32 requestId) external view override returns (Commitment memory) {
        return _commitments[requestId];
    }

    /// @inheritdoc IOVMGateway
    function getRequestsCount() external view override returns (uint256) {
        return _requestCount;
    }

    /// @dev transfer native tokens by a low-level call.
    /// _transfer should always be at the end of the function,
    /// to apply the checks-effects-interactions pattern
    function _transfer(address to, uint256 amount) internal {
        Address.sendValue(payable(to), amount);
    }
}
