// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @dev Transfer failed.
error TransferFailed();

/// @dev Request not expired.
error RequestNotExpired();

/// @dev Requester or callback is invalid.
error InvalidRequesterOrCallback(address sender, address callbackAddress);

/// @dev Callback address is not a contract.
error CallbackAddressIsNotContract(address callbackAddress);
