// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {MultiSigWallet} from "./MultiSigWallet.sol";

/**
 * @title Factory
 * @author Sahil Gujrati
 * @notice This contract helps to deploy and track multi-sig wallets.
 */
contract Factory {
    uint256 private s_numberOfWallets;
    mapping(address => address) private s_ownersAndWallets;

    /**
     * @notice Emitted when a wallet is deployed.
     * @param walletAddress The deployed wallet's address.
     */
    event WalletDeployed(address walletAddress);

    /**
     * @notice Initialises the number of wallets to 0.
     */
    constructor() {
        s_numberOfWallets = 0;
    }

    /**
     * @notice Allows anyone to deploy a multi-sig wallet by passing in a list of account owners, and a valid requiredApprovals value.
     * @param owners The owners of the wallet.
     * @param requiredApprovals The minimum number of approvals required for the wallet's transactions to be authorized.
     * @return The deployed wallet's address.
     */
    function deployWallet(
        address[] memory owners,
        uint256 requiredApprovals
    ) external returns (address) {
        ++s_numberOfWallets;
        MultiSigWallet multiSigWallet = new MultiSigWallet(
            owners,
            requiredApprovals
        );

        emit WalletDeployed(address(multiSigWallet));

        uint256 numberOfOwners = owners.length;
        for (uint256 count = 0; count < numberOfOwners; ++count) {
            s_ownersAndWallets[owners[count]] = address(multiSigWallet);
        }

        return address(multiSigWallet);
    }

    /**
     * @notice Returns the total number of wallets deployed using the factory.
     */
    function getTotalNumberOfWalletsDeployed() external view returns (uint256) {
        return s_numberOfWallets;
    }

    /**
     * @notice Gets the address of the wallet held by the owner, or an address 0 if the owner holds no wallet.
     * @param owner The owner of a wallet.
     */
    function getWalletAddress(address owner) external view returns (address) {
        return s_ownersAndWallets[owner];
    }
}
