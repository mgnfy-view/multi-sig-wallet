// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {MultiSigWallet} from "./MultiSigWallet.sol";

contract Factory {
    mapping(address => address) private ownersAndWallets;

    function deployWallet(
        address[] memory _owners,
        uint256 _requiredApprovals
    ) public {
        MultiSigWallet multiSigWalletwallet = new MultiSigWallet(
            _owners,
            _requiredApprovals
        );
        for (uint256 count = 0; count < _owners.length; count++) {
            ownersAndWallets[_owners[count]] = address(multiSigWalletwallet);
        }
    }

    function getOwnersWalletAddress(
        address _owner
    ) public view returns (address) {
        return ownersAndWallets[_owner];
    }
}
